#!/bin/bash
# Download latest models
# Usage:
#    $ bash download_weights.sh

#下载yolov4.cfg
#wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4.cfg
#回显确认
#ls -la

#下载yolov4.weights
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights
#回显确认
ls -la