import sys
import os
import time
import math
import torch
import numpy as np
import cv2
import struct  # get_image_size
import imghdr  # get_image_size

from tool.utils import post_processing
from tool.yolo_layer import yolo_forward
import torch_mlu.core.mlu_model as ct

def bbox_ious(boxes1, boxes2, x1y1x2y2=True):
    if x1y1x2y2:
        mx = torch.min(boxes1[0], boxes2[0])
        Mx = torch.max(boxes1[2], boxes2[2])
        my = torch.min(boxes1[1], boxes2[1])
        My = torch.max(boxes1[3], boxes2[3])
        w1 = boxes1[2] - boxes1[0]
        h1 = boxes1[3] - boxes1[1]
        w2 = boxes2[2] - boxes2[0]
        h2 = boxes2[3] - boxes2[1]
    else:
        mx = torch.min(boxes1[0] - boxes1[2] / 2.0, boxes2[0] - boxes2[2] / 2.0)
        Mx = torch.max(boxes1[0] + boxes1[2] / 2.0, boxes2[0] + boxes2[2] / 2.0)
        my = torch.min(boxes1[1] - boxes1[3] / 2.0, boxes2[1] - boxes2[3] / 2.0)
        My = torch.max(boxes1[1] + boxes1[3] / 2.0, boxes2[1] + boxes2[3] / 2.0)
        w1 = boxes1[2]
        h1 = boxes1[3]
        w2 = boxes2[2]
        h2 = boxes2[3]
    uw = Mx - mx
    uh = My - my
    cw = w1 + w2 - uw
    ch = h1 + h2 - uh
    mask = ((cw <= 0) + (ch <= 0) > 0)
    area1 = w1 * h1
    area2 = w2 * h2
    carea = cw * ch
    carea[mask] = 0
    uarea = area1 + area2 - carea
    return carea / uarea


def get_region_boxes(boxes_and_confs):

    # print('Getting boxes from boxes and confs ...')

    boxes_list = []
    confs_list = []

    for item in boxes_and_confs:
        boxes_list.append(item[0])
        confs_list.append(item[1])

    # boxes: [batch, num1 + num2 + num3, 4]
    # confs: [batch, num1 + num2 + num3, num_classes]
    boxes = torch.cat(boxes_list, dim=1)
    confs = torch.cat(confs_list, dim=1)

    output = torch.cat((boxes, confs), dim=2)
    return output


def convert2cpu(gpu_matrix):
    return torch.FloatTensor(gpu_matrix.size()).copy_(gpu_matrix)


def convert2cpu_long(gpu_matrix):
    return torch.LongTensor(gpu_matrix.size()).copy_(gpu_matrix)

def yolo_layer(inputs):
    anchor_masks = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
    thresh = 0.6
    num_class = 80
    anchor_step = 2
    anchors = [12.0, 16.0, 19.0, 36.0, 40.0, 28.0, 36.0, 75.0, 76.0, 55.0, 72.0, 146.0, 142.0, 110.0, 192.0, 243.0, 459.0, 401.0]
    outputs = []
    for idx, input in enumerate(inputs):
        stride = 512 / input.shape[2]
        masked_anchors = []
        for m in anchor_masks[idx]:
            masked_anchors += anchors[m * anchor_step:(m + 1) * anchor_step]
            print('mask_anchor:{}, stride:{}, masked anchors:{}'.format(anchor_step, stride, masked_anchors))
        masked_anchors = [anchor / stride for anchor in masked_anchors]
        out = yolo_forward(input.cpu().float(), thresh, num_class, masked_anchors, 3)
        outputs.append(out)
    return get_region_boxes(outputs)


def get_boxes(prediction, batch_size, imgs, class_name, image_id, json_list, savename=None):
    """
    Returns detections with shape:
        (x1, y1, x2, y2, object_conf, class_score, class_pred)
    """
    # img_size = img.shape
    max_limit = 1
    min_limit = 0
    for batch_idx in range(batch_size):
        img = imgs[batch_idx]
        img_size = img.shape
        # achieve an out
        out = prediction[batch_idx].unsqueeze(0)
        # reshape output data
        reshape_value = torch.reshape(out, (-1, 1))
        num_boxes_final = int(reshape_value[0].item())
        # box_num = int((out.shape[1] - 64) / 7)
        # index = (64 + box_num * 7) #* batch_idx
        # for i in range(int(reshape_value[index].item())):
        for i in range(num_boxes_final):
            if batch_idx >= 0 and batch_idx < batch_size:
                clas = int(reshape_value[64 + i * 7 + 1].item())
                conf = reshape_value[64 + i * 7 + 2].item()
                bl = int(max(min_limit, min(max_limit, reshape_value[64 + i * 7 + 3].item()) * img_size[1]))
                bt = int(max(min_limit, min(max_limit, reshape_value[64 + i * 7 + 4].item()) * img_size[0]))
                br = int(max(min_limit, min(max_limit, reshape_value[64 + i * 7 + 5].item()) * img_size[1]))
                bb = int(max(min_limit, min(max_limit, reshape_value[64 + i * 7 + 6].item()) * img_size[0]))
                box_info = {'image_id':image_id[batch_idx],
                            'category_id':int(clas),
                            'bbox':[round(bl, 1), 
                                    round(bt, 1), 
                                    round((br - bl), 1), 
                                    round((bb - bt), 1)],
                            'score':round(float(conf), 6)}
                print(box_info)
                json_list.append(box_info)
            img = cv2.putText(img, class_name[clas], (bl, bt), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 0), 1)
            cv2.rectangle(img, (bl, bt), (br, bb), (0, 255, 0), 2)
        if savename:
            cv2.imwrite(savename, img)

def do_detect(model, img, conf_thresh, nms_thresh, device, half_input=0):
    t1 = time.time()
    outputs = model(img)
    t2 = time.time()
    print('-----------------------------------')
    print('      Model Inference : %f' % (t2 - t1))
    print('-----------------------------------')

    if device == "mlu":
        print(outputs.shape)
        outputs = outputs.cpu().float()
        return outputs, t2-t1
    else:
        return post_processing(img, conf_thresh, nms_thresh, outputs), t2-t1

