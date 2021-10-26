#coding: utf-8
from tool.utils import *
from tool.change_cat_id import change_id_func
from tool.COCO_eval import calculateAp
from tool.torch_utils import *
from tool.darknet2pytorch import Darknet, yolov4
import argparse
import torch
import cv2
import os
import torch_mlu
import torch_mlu.core.mlu_model as ct
import torch_mlu.core.mlu_quantize as mlu_quantize
from pycocotools.coco import COCO

sys.path.append("../")
from common_utils import Timer # pylint: disable=C0411,C0413
from common_utils import DumpData # pylint: disable=C0411,C0413

use_cuda = False

def saveResult(imageNum,batch_size,top1,top5,meanAp,hardwaretime,endToEndTime,threads=1):
    if not os.getenv('OUTPUT_JSON_FILE'):
        return
    TIME=-1
    hardwareFps=-1
    endToEndFps=-1
    latencytime=-1
    if hardwaretime!=TIME:
        hardwareFps=imageNum/hardwaretime
        latencytime = hardwaretime / (imageNum / batch_size) * 1000
    if endToEndTime!=TIME:
        endToEndFps=imageNum/endToEndTime
    if top1!=TIME:
        top1=top1/imageNum*100
    if top5!=TIME:
        top5=top5/imageNum*100
    result={
            "Output":{
                "Accuracy":{
                    "top1":'%.2f'%top1,
                    "top5":'%.2f'%top5,
                    "meanAp":str(meanAp)
                    },
                "HostLatency(ms)":{
                    "average":'%.2f'%latencytime,
                    "throughput(fps)":"%.2f"%endToEndFps,
                    }
                }
            }
    with open(os.getenv("OUTPUT_JSON_FILE"),"w") as outputfile:
        json.dump(result,outputfile,indent=4,sort_keys=True)
        outputfile.write('\n')

def generate_pth(cfgfile, weightfile, imgfile):
    m = Darknet(cfgfile)

    m.print_network()
    m.load_weights(weightfile)
    m.eval()
    print('Loading weights from %s... Done!' % (weightfile))

    if use_cuda:
        m.cuda()

    num_classes = m.num_classes
    if num_classes == 20:
        namesfile = 'data/voc.names'
    elif num_classes == 80:
        namesfile = 'data/coco.names'
    else:
        namesfile = 'data/x.names'
    class_names = load_class_names(namesfile)

    img = cv2.imread(imgfile)
    sized = cv2.resize(img, (m.width, m.height))
    sized = cv2.cvtColor(sized, cv2.COLOR_BGR2RGB)
    input_data = torch.from_numpy(sized.transpose(2, 0, 1)).float().div(255.0).unsqueeze(0)

    with torch.no_grad():
        start = time.time()
        boxes, _= do_detect(m, input_data, 0.4, 0.6, use_cuda)
        finish = time.time()
        print('%s: Predicted in %f seconds.' % (imgfile, (finish - start)))
        pth_name = cfgfile.split('/')[-1].split('.')[0]+ '.pth'
        torch.save(m.state_dict(), pth_name)
        print('Save {pth} Done!!!'.format(pth = pth_name))

    plot_boxes_cv2(img, boxes[0], savename='predictions.jpg', class_names=class_names, file_name=list())

def quantification(per_channel=False, quanti_type ='int8', yolov4_version='yolov4'):
    with torch.no_grad():
        mean = [0.0, 0.0, 0.0]
        std =  [1.0, 1.0, 1.0]
        model = yolov4(pretrained=True, quantize=False, yolov4_version=yolov4_version)
        model = model.to(torch.device('cpu'))
        '''
          In order to improve accuracy, INT8+INT16 mixed quantization is used here. 
          After testing and analysis, using the following layers of INT16 quantization,
          and this image('COCO/test2017/000000000161.jpg')  can meet the requirements of
          precision and performance.    
          
          You can also try other images and INT16 layers.
        '''
        mixed_layers = {"models.1.conv2, models.158.conv108, models.159.conv109, models.160.conv110": "int16"}
        model = mlu_quantize.quantize_dynamic_mlu(model,
                                                  {'mean': mean,
                                                   'std': std,
                                                   'data_scale':1.0,
                                                   'per_channel':per_channel,
                                                   'use_avg':False,
                                                   'firstconv': True},
                                                  mixed_layer=mixed_layers,
                                                  dtype=quanti_type,
                                                  gen_quant=True)

        # meat.jpg is COCO/test2017/000000000161.jpg.
        img = cv2.imread('./data/meat.jpg')
        print(img.shape)
        sized = cv2.resize(img, (model.width, model.height))
        sized = cv2.cvtColor(sized, cv2.COLOR_BGR2RGB)
        input_img = torch.from_numpy(sized.transpose(2, 0, 1)).float().div(255.0).unsqueeze(0)
        outs = model(input_img)

        save_name = yolov4_version + '.pth'
        torch.save(model.state_dict(), save_name)
        print('save quantized {} success!!!'.format(save_name))

def calc_coco(args):
    # set MLU configure
    ct.set_core_version("MLU270")
    ct.set_core_number(args.core_number)

    # locate COCO2017
    DATASET = os.getenv('COCO_PATH_PYTORCH')
    if DATASET==None:
        print("Warning: please set environment variable COCO_PATH_PYTORCH, which includes COCO2017")
        exit(1)

    dataType = 'val2017'
    dataSetDir = '{}/{}'.format(args.datadir, dataType)
    annFile = '{}/annotations/instances_{}.json'.format(args.datadir, dataType)

    coco = COCO(annFile)
    catIds = coco.getCatIds()
    cats = coco.loadCats(catIds)
    imgIds = coco.getImgIds()
    imgs = coco.loadImgs(imgIds)
    image_path = [os.path.join(dataSetDir, img['file_name']) for img in imgs]
    image_path = image_path[:args.img_num]
    image_ids = [img['id'] for img in imgs]
    print(len(image_path))

    num_batch = len(image_path) // args.batch_size
    class_names = load_class_names('data/coco.names')
    device = "mlu" if args.use_mlu else "cpu"

    dtype = "int16" if args.quantized_mode == 2 or args.quantized_mode == 4 else "int8"

    # "output.json" is result of detection.
    coco_result_file = '%s.json'%(args.json_name)
    if os.path.exists(coco_result_file):
        os.remove(coco_result_file)

    json_list = list()
    total_hardware = 0
    total_e2e = 0
    with torch.no_grad():
        model = yolov4(pretrained=True, quantize=bool(args.quantized_mode), yolov4_version=args.yolov4_version)
        model.to(device)

        # preprocess
        input_h = model.height
        input_w = model.width
        print('H:{}, W:{}'.format(model.height, model.width))
        trace_input = torch.randn((args.batch_size, 3, model.height, model.width), dtype=torch.float)
        # fusion mode
        if args.jit:
            if args.half_input:
                trace_input = trace_input.type(torch.HalfTensor)
                print('half input')
            if args.offline == True:
                ct.save_as_cambricon(args.mname)
                print("save offline cambricon")
            model = torch.jit.trace(model, trace_input.to(device), check_trace=False)
            out = model(trace_input.to(device))
            print('fusion success')

        total_e2e = 0.0
        total_hw = 0.0
        timer_e2e = Timer()
        for num in range(num_batch):
            img_datas = image_path[args.batch_size * num : args.batch_size * (num + 1)]
            input_img = torch.tensor([])
            img_tuple = list()
            imgId_tuple = list()
            for idx, p in enumerate(img_datas):
                print('evaluating {} image'.format(num * args.batch_size + idx), end='\r')
                img = cv2.imread(img_datas[idx])
                img_tuple.append(img)
                imgId_tuple.append(image_ids[num * args.batch_size + idx])
                sized = cv2.resize(img, (input_w, input_h))
                sized = cv2.cvtColor(sized, cv2.COLOR_BGR2RGB)

                if type(sized) == np.ndarray and len(sized.shape) == 3:  # cv2 image
                    if device == 'mlu':
                        input_data = torch.from_numpy(sized.transpose(2, 0, 1)).float().unsqueeze(0)
                    else:
                        input_data = torch.from_numpy(sized.transpose(2, 0, 1)).float().div(255.0).unsqueeze(0)
                elif type(sized) == np.ndarray and len(sized.shape) == 4:
                    input_data = torch.from_numpy(sized.transpose(0, 3, 1, 2)).float().div(255.0)
                else:
                    print("unknow image type")
                    exit(-1)
                # concat to a tensor
                input_img = torch.cat((input_img, input_data), 0)
            # concert type
            if args.half_input:
                input_img = input_img.type(torch.HalfTensor)
            # concert device
            input_img = input_img.to(device)
            # do compute
            time_start = time.time()
            boxes, hardware_time = do_detect(model, input_img, 0.1, 0.6, device, args.half_input)
            e2e_time = time.time() - time_start

            total_hardware += hardware_time
            total_e2e += e2e_time

            if args.use_mlu:
                save_name='output/mlu_res/{}.jpg'.format(num * args.batch_size + idx)
                get_boxes(boxes, args.batch_size, img_tuple, class_names, imgId_tuple, json_list, savename=save_name)
            else:
                for idx in range(args.batch_size):
                    res_idx = num * args.batch_size + idx
                    save_name = 'output/cpu_res/{}.jpg'.format(res_idx)
                    plot_boxes_cv2(img_tuple[idx], boxes[idx], savename=save_name, class_names=class_names, image_id=imgId_tuple[idx], file_name=json_list)

        # change id
        new_list = change_id_func(json_list)
        with open(coco_result_file, "w") as file_json:
            json.dump(new_list, file_json)

        # calculate meanAP
        mAP = calculateAp(coco_result_file, annFile)
        saveResult(args.img_num, args.batch_size, -1, -1, mAP, total_hardware, total_e2e)


def str2bool(v):
    return v.lower() in ("yes", "true", "1")

def get_args():
    parser = argparse.ArgumentParser('Test your image or video by trained model.')
    parser.add_argument('-yolov4_version', type=str,
                        default='yolov4',
                        help='choose yolov4 or yolov4-tiny', dest='yolov4_version')
    parser.add_argument('-cfgfile', type=str,
                        default='./model/yolov4.cfg',
                        help='path of yolov4 config', dest='cfgfile')
    parser.add_argument('-weightfile', type=str,
                        help='path of trained model. format is darknet', dest='weightfile')
    parser.add_argument('-imgfile', type=str,
                        default='./data/dog.jpg',
                        help='path of your image file.', dest='imgfile')
    parser.add_argument('-batch_size', type=int, default=1, help="size of each image batch")
    parser.add_argument('-use_mlu', type=str2bool, default=True, help="use mlu to compute")
    parser.add_argument('-jit', type=str2bool, default=True, help="use jit to compute")
    parser.add_argument('-offline', type=str2bool, default=False, help="generate offline cambricon")
    parser.add_argument('-mname', type=str, default="yolov4", help="cambricon name")
    parser.add_argument('-img_num', type=int, default=5000, help="number of image")
    parser.add_argument('-quantized_mode', type=int, default=1, help="1-int8, 2-int16, 3-c_int8, 4-c_int16")
    parser.add_argument('-half_input', type=int, default=1, help="data type for input tensor")
    parser.add_argument('-core_number', type=int, default=16, help="Core Number for MLU")
    parser.add_argument('-quantization', type=str2bool, default=False, help="do quantization")
    parser.add_argument('-darknet2pth', type=str2bool, default=False, help="convert darknet to pth")
    parser.add_argument('-datadir', type=str, default='', help="coco dataset dir")
    parser.add_argument("-json_name", dest = "json_name", help ="name of the output file(.json)",
                    default = 'results',type = str)

    args = parser.parse_args()

    return args

if __name__ == '__main__':
    # parse args
    args = get_args()

    if args.darknet2pth:
        generate_pth(args.cfgfile, args.weightfile, args.imgfile)
        exit(0)

    # set pretrained model path
    TORCH_HOME = os.getenv('TORCH_HOME')
    if TORCH_HOME==None:
        print('Warning: please set environment variable TORCH_HOME such as $PWD/models/pytorch')
        exit(1)
    if args.quantization or args.quantized_mode == 0:
        TORCH_HOME = os.path.join(TORCH_HOME, 'origin')
        print("will run yolov4 origin model ...")
    elif args.quantized_mode == 1:
        TORCH_HOME = os.path.join(TORCH_HOME, 'int8')
        print("will run yolov4 int8 model ...")
    elif args.quantized_mode == 2:
        TORCH_HOME = os.path.join(TORCH_HOME, 'int16')
        print("will run yolov4 int16 model ...")
    elif args.quantized_mode == 3:
        TORCH_HOME = os.path.join(TORCH_HOME, 'c_int8')
        print("will run yolov4 c_int8 model ...")
    elif args.quantized_mode == 4:
        TORCH_HOME = os.path.join(TORCH_HOME, 'c_int16')
        print("will run yolov4 c_int16 model ...")
    else:
        print("[WARNING] " + str(args.quantized_mode) + " is NOT supported, please check it!!!")
        exit(1)

    os.environ['TORCH_HOME'] = TORCH_HOME
    DATASET = os.getenv('COCO_PATH_PYTORCH')
    if DATASET==None:
        print("Warning: please set environment variable COCO_PATH_PYTORCH, which includes COCO2017")
        exit(1)

    # quantization is True:
    #   do quantization in cpu
    # quantization is False:
    #   do inference in mlu or cpu
    if args.quantization:
        per_channel = False if args.quantized_mode == 1 or args.quantized_mode == 2 else True
        dtype = "int16" if args.quantized_mode == 2 or args.quantized_mode == 4 else "int8"
        quantification(per_channel, dtype, args.yolov4_version)
    else:
        calc_coco(args)
