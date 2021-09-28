#import argparse
#import pdb
import cv2
from utils.datasets import *
from utils.general import ( non_max_suppression, scale_coords, xyxy2xywh, strip_optimizer)
from utils.torch_utils import select_device, load_classifier
from models.yolo import Model
import torch_mlu
import torch_mlu.core.mlu_model as ct
import torch_mlu.core.mlu_quantize as mlu_quantize
import numpy as np


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


class DetectMark():
    def __init__(self, ModelPath = None):
        # initialize models
        if ModelPath is not None:
                self.model_path = ModelPath
        else:
            self.model_path = './weights/nozip.pt'
        self.model = Model('./models/yolov5x.yaml')
        state_dict = torch.load(self.model_path, map_location=torch.device('cpu'))
        #self.model = torch.nn.DataParallel(self.model)
        self.model.load_state_dict(state_dict, strict=False)
        #self.model.to('cuda').eval()
        self.model.eval()
        self.names = ['person']#self.model.names if hasattr(self.model, 'names') else self.model.modules.names

    def detect_img(self, im0, img_size = 640, conf_thres = 0.25, iou_thres = 0.45):
        with torch.no_grad():
            # Padded resize
            img = letterbox(im0, new_shape = img_size)[0]
            # Convert
            img = img[:, :, ::-1].transpose(2, 0, 1)  # BGR to RGB, to 3x320x320
            img = np.ascontiguousarray(img)
            #img = torch.from_numpy(img).to('cuda').float()
            img = torch.from_numpy(img).float()
            img /= 255.0  # 0 - 255 to 0.0 - 1.0
            if img.ndimension() == 3:
                img = img.unsqueeze(0)

            qconfig={'iteration': 1, 'use_avg':False, 'data_scale':1.0, 'firstconv':False, 'per_channel': False}
            quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(self.model.eval().float(),qconfig_spec=qconfig, dtype='int8', gen_quant=True)
            quantized_net = quantized_net.eval().float()

            pred = self.model(img, augment=False)[0]
            # print(pred[0].shape)
            #import pdb; pdb.set_trace()
            # pred = quantized_net(img, augment=False)[0]
            #np.savetxt("out_mlu_cpu_.txt", pred.flatten(), fmt="%f")
            torch.save(quantized_net.state_dict(), 'weights/yolov5_quant.pth')
            # print("save end")
            # Apply NMS
            #pred = non_max_suppression(pred, conf_thres, iou_thres, fast=True, classes=None, agnostic=False)
            # pred = non_max_suppression(pred, opt.conf_thres, opt.iou_thres, classes=opt.classes, agnostic=opt.agnostic_nms)
            pred = non_max_suppression(pred, conf_thres, iou_thres)
            # print(pred.shape())

            # Process detections
            detect_result = []
            for i, det in enumerate(pred):  # detections per image
                if det is not None and len(det):
                    det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()

                    for *xyxy, conf, cls in reversed(det):
                        label = self.names[int(cls)]
                        plot_one_box(xyxy, im0, label=label, color=[255,0,0], line_thickness=3)                        
            if len(detect_result) == 0:
                detect_result.append('None')
            cv2.imwrite('./res.jpg', im0)
            return detect_result

if __name__ == '__main__':

    DM = DetectMark()
    img = cv2.imread('./20210325105908190_0.jpg')
    det_result = DM.detect_img(img)
    #print(det_result)

    # start = time.time()
    # for i in range(1):
    #     det_result = DM.detect_img(img)
    # end = time.time()
    # time_mean = (end - start)/1
    # print('mean_time:%s'%time_mean)
