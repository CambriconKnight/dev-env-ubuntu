#!/bin/bash
# Download latest models
# Usage:
#    $ bash download_weights.sh

#下载yolov4-tiny.cfg
wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg
#回显确认
ls -la

#下载yolov4-tiny.weights
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights
#回显确认
ls -la
