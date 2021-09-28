import argparse
import pdb
import cv2
from utils.datasets import *
from utils.general import ( non_max_suppression, scale_coords, xyxy2xywh, strip_optimizer)
from utils.torch_utils import select_device, load_classifier
from models.yolo import Model
import torch_mlu
import torch_mlu.core.mlu_model as ct
import torch_mlu.core.mlu_quantize as mlu_quantize
import numpy as np

device=ct.mlu_device()
torch.set_grad_enabled(False)

def get_boxes(prediction, batch_size=1, img_size=640):
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

def yolo_corner_to_coords(corner):
    left, top, right, bottom = corner
 #   centerx = (left + right)/2
 #   centery = (top + bottom)/2
    centerx = left
      #centerx = (left + right)/2
      #centery = (top + bottom)/2
    centery = top
    w = right - left
    h = bottom - top
    result = [centerx, centery, w, h]
    return result

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
            self.model_path = 'weights/yolov5_quant.pth'
        self.model = Model('./models/yolov5x.yaml')
        self.quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(self.model.eval().float())
        state_dict = torch.load(self.model_path)
        self.quantized_net.load_state_dict(state_dict, strict=False)
        self.quantized_net_mlu = self.quantized_net.to(device)
        #self.model.to('cuda').eval()
        self.model.eval()
        self.names = ['mark', 'top_window', 'tissue_box', 'roof_rack', 'pendant', 'spaer_wheel_rack']#self.model.names if hasattr(self.model, 'names') else self.model.modules.names

    def detect_img(self, im0, img_size = 640, conf_thres = 0.35, iou_thres = 0.5):
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

            #pred = self.model(img, augment=False)[0]
            pred = self.quantized_net_mlu(img.to(device), augment=False)[0].cpu()
#            import pdb; pdb.set_trace()

            box_result = get_boxes(pred)

            box_result=torch.Tensor(box_result)

            detect_result = []
            for i, det in enumerate(box_result): 
                if det is not None and len(det):
                    # Rescale boxes from img_size to im0 size
                    det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()
                    for *xyxy, conf, cls in det.cpu().detach().tolist():
                        #print(*xyxy, conf, cls)
                        xywh = yolo_corner_to_coords(xyxy)
                        label = self.names[int(cls)]
                        plot_one_box(xyxy, im0, label=label, color=[255,0,0], line_thickness=3)  
                        #detect_result.append(res)
                    #print(detect_result)
            cv2.imwrite('./res_mlu.jpg', im0)
            return detect_result


            # print(pred[0].numpy().flatten())
            # np.savetxt("mlu_out.txt", pred[0].numpy().flatten(), fmt='%.5f') 
            # pred2 = self.model(img, augment=False)[1]
            # print(pred2[0].numpy().flatten())
            # print(pred)

                
            # dump_utils.register_dump_hook(self.quantized_net_mlu)
            # dump_utils.save_data("output/", "mlu")
            # #Apply NMS
            # pred = non_max_suppression(pred, conf_thres, iou_thres, fast=True, classes=None, agnostic=False)
            # # Process detections
            # detect_result = []
            # for i, det in enumerate(pred):  # detections per image
            #     if det is not None and len(det):
            #         for c in det[:, -1].unique():
            #             detect_result.append(self.names[int(c)])
            # if len(detect_result) == 0:
            #     detect_result.append('None')

            # #            dump_utils.diff_data("output/dump_cpu_data.pth", "output/dump_mlu_data.pth")
            # return detect_result


            # import pdb; pdb.set_trace()
            # #np.savetxt("out_mlu.txt", pred.flatten(), fmt="%f")
            # det_list = []  
            # for i, det in enumerate(pred):  # detections per image
            #     if det is not None and len(det):
            #         # det[:, :4] = scale_coords(img.shape[2:], det[:, :4], im0.shape).round()
            #         # Write results
            #         for *xyxy, conf, cls in det:
            #             temp = []
            #             label = '%s' % (names[int(cls)])
            #             temp.append(label)
            #             conf = '%.2f' %(conf)
            #             temp.append(float(conf))
            #             x1 = xyxy[0].tolist()
            #             y1 = xyxy[1].tolist()
            #             x2 = xyxy[2].tolist()
            #             y2 = xyxy[3].tolist()
            #             temp.append([x1, y1, x2, y2])
            #             # plot_one_box([x1, y1, x2, y2], frame, color=None, label=label, line_thickness=3)
            #             # cv2.imwrite('/home/wangyr/car_count/21.jpg',frame)
            #             # print(temp)
            #             det_list.append(temp)
        
            # return det_list

            #return pred
            # print(pred)
            # Apply NMS
            # pred = non_max_suppression(pred, conf_thres, iou_thres, classes=1, agnostic=False)
            # # Process detections
            # detect_result = []
            # for i, det in enumerate(pred):  # detections per image
            #     if det is not None and len(det):
            #         for c in det[:, -1].unique():
            #             detect_result.append(self.names[int(c)])
            # if len(detect_result) == 0:
            #     detect_result.append('None')
            # return detect_result

if __name__ == '__main__':

    DM = DetectMark()
    img = cv2.imread('./20210325105908190_0.jpg')
    det_result = DM.detect_img(img)
    print(det_result)

    # start = time.time()
    # for i in range(1):
    #     det_result = DM.detect_img(img)
    # end = time.time()
    # time_mean = (end - start)/1
    #print('mean_time:%s'%time_mean)
