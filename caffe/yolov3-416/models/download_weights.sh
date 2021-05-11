#!/bin/bash
# Download latest models from https://pjreddie.com/media/files/yolov3.weights
# Usage:
#    $ bash download_weights.sh

#下载yolov3.weights
wget https://pjreddie.com/media/files/yolov3.weights
#回显确认
ls -la