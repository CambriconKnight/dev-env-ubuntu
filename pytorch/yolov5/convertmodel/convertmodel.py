import argparse
import pdb
import cv2
from utils.datasets import *
#from utils.utils import *
from utils.general import ( non_max_suppression, scale_coords, xyxy2xywh, strip_optimizer)


from models.yolo import Model

import torch_mlu
import torch_mlu.core.mlu_model as ct
import torch_mlu.core.mlu_quantize as mlu_quantize

import numpy as np
#device = 'cpu'
#device = ct.mlu_device()
#torch.set_grad_enabled(False)

def plot_one_box(x, img, color=None, label=None, line_thickness=None):
    # Plots one bounding box on image img
    tl = line_thickness or round(0.002 * (img.shape[0] + img.shape[1]) / 2) + 1  # line/font thickness
    color = color or [random.randint(0, 255) for _ in range(3)]
    c1, c2 = (int(x[0]), int(x[1])), (int(x[2]), int(x[3]))
    cv2.rectangle(img, c1, c2, color, thickness=tl, lineType=cv2.LINE_AA)
    if label:
        tf = max(tl - 1, 1)  # font thickness
        t_size = cv2.getTextSize(label, 0, fontScale=tl / 3, thickness=tf)[0]
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] - 3
        cv2.rectangle(img, c1, c2, color, -1, cv2.LINE_AA)  # filled
        cv2.putText(img, label, (c1[0], c1[1] - 2), 0, tl / 3, [225, 255, 255], thickness=tf, lineType=cv2.LINE_AA)




def get_boxes(prediction, batch_size=1, img_size=608):
    """
    Returns detections with shape:
        (x1, y1, x2, y2, object_conf, class_score, class_pred)
    """
    reshape_value = torch.reshape(prediction, (-1, 1))

    num_boxes_final = reshape_value[0].item()
    print('num_boxes_final: ',num_boxes_final)
    all_list = [[] for _ in range(batch_size)]
    for i in range(int(num_boxes_final)):
        batch_idx = int(reshape_value[64 + i * 7 + 0].item())
        if batch_idx >= 0 and batch_idx < batch_size:
            bl = reshape_value[64 + i * 7 + 3].item()
            br = reshape_value[64 + i * 7 + 4].item()
            bt = reshape_value[64 + i * 7 + 5].item()
            bb = reshape_value[64 + i * 7 + 6].item()

            if bt - bl > 0 and bb -br > 0:
                all_list[batch_idx].append(bl)
                all_list[batch_idx].append(br)
                all_list[batch_idx].append(bt)
                all_list[batch_idx].append(bb)
                all_list[batch_idx].append(reshape_value[64 + i * 7 + 2].item())
                # all_list[batch_idx].append(reshape_value[64 + i * 7 + 2].item())
                all_list[batch_idx].append(reshape_value[64 + i * 7 + 1].item())

    output = [np.array(all_list[i]).reshape(-1, 6) for i in range(batch_size)]
    # outputs = [torch.FloatTensor(all_list[i]).reshape(-1, 6) for i in range(batch_size)]
    return output



class DetectMark():
    def __init__(self, opt):
        # initialize models
        ModelPath = None
        self.running_mode = opt.arg
        self.gen_off = opt.genoff
        if ModelPath is not None:
                self.model_path = ModelPath
        else:
            if self.running_mode == 'cpu' or self.running_mode == 'quant':
                #self.model_path = './weights/nozip.pt'
                self.model_path = './yolov5s.pth'
            else:
                self.model_path = './yolov5_quant.pth'
        self.model = Model('./models/yolov5s.yaml')
        if self.running_mode == 'cpu' or self.running_mode == 'quant':
            state_dict = torch.load(self.model_path, map_location=torch.device('cpu'))
            self.model.load_state_dict(state_dict, strict=True)
            self.model.eval()
        else:
            self.device = ct.mlu_device()
            self.quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(self.model.eval().float())
            state_dict = torch.load(self.model_path)
            self.quantized_net.load_state_dict(state_dict, strict=False)
            self.quantized_net_mlu = self.quantized_net.to(self.device)
                     
        #self.names = ['mark', 'top_window', 'tissue_box', 'roof_rack', 'pendant', 'spaer_wheel_rack']#self.model.names if hasattr(self.model, 'names') else self.model.modules.names
        self.names=['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', \
                'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', \
                'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', \
                'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', \
                'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove', \
                'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', \
                'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot', \
                'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed', 'dining table', \
                'toilet', 'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', \
                'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush']

    def detect_img(self, im0, img_size = 608, conf_thres = 0.25, iou_thres = 0.45):
        colors = [[random.randint(0, 255) for _ in range(3)] for _ in range(len(self.names))]
        save_img = True
        with torch.no_grad():
            # Padded resize
            batch_size = 1
            #img = letterbox(im0, new_shape = img_size)[0]
            img = letterbox(im0, new_shape = img_size,auto=False)[0]
            # Convert
            img = img[:, :, ::-1].transpose(2, 0, 1)  # BGR to RGB, to 3x320x320
            img = np.repeat(img, batch_size, axis=0)
            img = np.ascontiguousarray(img)
            #img = torch.from_numpy(img).to('cuda').float()
            img = torch.from_numpy(img).float()
            img /= 255.0  # 0 - 255 to 0.0 - 1.0
            if img.ndimension() == 3: 
                img = img.unsqueeze(0)
            
            if self.running_mode == 'cpu' or self.running_mode == 'quant':
                if self.running_mode == 'quant':
                    qconfig={'iteration': 1, 'use_avg':False, 'data_scale':1.0, 'firstconv':False, 'per_channel': False}
                    quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(self.model.eval().float(),qconfig_spec=qconfig, dtype='int8', gen_quant=True)
                    quantized_net = quantized_net.eval().float()
                    pred = quantized_net(img, augment=False)[0]
                    torch.save(quantized_net.state_dict(), 'yolov5_quant.pth')
                else:    
                    pred = self.model(img, augment=False)[0]
                # Apply NMS
                pred = non_max_suppression(pred, conf_thres, iou_thres)
                print(pred)
                for i, det in enumerate(pred):
                    if det is not None and len(det):
                        det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()
                        for c in det[:, -1].unique():
                            n = (det[:, -1] == c).sum()
                        for *xyxy, conf, cls in det:
                            if save_img:
                                label = '%s %.2f' % (self.names[int(cls)], conf)
                                plot_one_box(xyxy, im0, label=label, color=colors[int(cls)], line_thickness=1)
                    if save_img:
                        cv2.imwrite('./cpu_result.jpg', im0)
            elif self.running_mode == 'mlu':
                device = self.device
                pred = self.quantized_net_mlu(img.to(device))
                
                pred = pred.to(torch.device('cpu'))
                pred = get_boxes(pred)
                print(pred)
                for i, det in enumerate(pred):
                    if det is not None and len(det):
                        det[:, :4] = scale_coords(img.shape[2:], torch.Tensor(det[:, :4]), im0.shape).round()
                        for c in torch.Tensor(det[:, -1]).unique():
                            n = (torch.Tensor(det[:, -1]) == c).sum()
                        for *xyxy, conf, cls in det:
                            if save_img:
                                label = '%s %.2f' % (self.names[int(cls)], conf)
                                plot_one_box(xyxy, im0, label=label, color=colors[int(cls)], line_thickness=3)
                    if save_img:
                        cv2.imwrite('./mlu_result.jpg', im0)

            elif self.running_mode == 'mfus':
                device = self.device
                if self.gen_off:
                    print('generate offline model')
                    ct.save_as_cambricon('yolov5s_int8_4b_4c')
                torch.set_grad_enabled(False) 
                batch_size = 4
                ct.set_core_number(4)
                ct.set_core_version('MLU270')
                example_mlu = torch.randn(batch_size, 3,608,608, dtype=torch.float)
                trace_input = torch.randn(1, 3, 608, 608,dtype=torch.float)

                trace_input=trace_input.half()
                example_mlu = example_mlu.half()

                trace_input=trace_input.to(ct.mlu_device())

                trace_model = torch.jit.trace(self.quantized_net, trace_input, check_trace = False)

                if self.gen_off:
                    trace_model(example_mlu.to(device))
                    ct.save_as_cambricon('')
                    exit(0)
                else:
                    img = img.half()
                    pred = trace_model(img.to(device))
                pred = pred.to(torch.device('cpu'))
                pred = get_boxes(pred)
                print(pred)
                for i, det in enumerate(pred):
                   if det is not None and len(det):
                       det[:, :4] = scale_coords(img.shape[2:], torch.Tensor(det[:, :4]), im0.shape).round()
                       for c in torch.Tensor(det[:, -1]).unique():
                           n = (torch.Tensor(det[:, -1]) == c).sum()
                       for *xyxy, conf, cls in det:
                           if save_img:
                               label = '%s %.2f' % (self.names[int(cls)], conf)
                               plot_one_box(xyxy, im0, label=label, color=colors[int(cls)], line_thickness=3)
                   if save_img:
                       cv2.imwrite('./mfus_result.jpg', im0)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--arg', type=str, default='cpu', help=' cpu? mlu? mfus? quant? ')
    parser.add_argument('--genoff', type=str, default=False, help='true or false')
#    parser.add_argument('--model-path', type=str, default=None)
    opt = parser.parse_args()
    DM = DetectMark(opt)
    img = cv2.imread('./bus.jpg')
    det_result = DM.detect_img(img)
#    print(det_result)

#    start = time.time()
#    for i in range(1):
#        det_result = DM.detect_img(img)
#    end = time.time()
#    time_mean = (end - start)/1
#    print('mean_time:%s'%time_mean)
