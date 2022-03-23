import argparse
import torch
import pandas as pd
import requests
import cv2
import yaml

from models.yolo import Model
from models.experimental import attempt_load



def pytorch_model_file_align(weights , output):
    model=attempt_load(weights)
    #print(model)
    torch.save(model.state_dict(), output,_use_new_zipfile_serialization=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--weights', type=str, default='./weights/yolov5s.pt', help='src model ')
    parser.add_argument('--output', type=str, default='./output/yolov5s.pth', help='dst model ')

    opt = parser.parse_args()
    print(opt)
    weights = opt.weights
    output = opt.output
    pytorch_model_file_align(weights, output)

