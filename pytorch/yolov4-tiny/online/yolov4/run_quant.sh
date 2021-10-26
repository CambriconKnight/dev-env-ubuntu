#!/bin/bash

set -e

# 0.Check param
if [ ! -d "$TORCH_HOME/origin/checkpoints/" ] ; then
        mkdir -p $TORCH_HOME/origin/checkpoints/
        echo "Create $TORCH_HOME/origin/checkpoints/ ok !"
else
        echo "Directory ($TORCH_HOME/origin/checkpoints/): Exist!"
fi

if [ ! -d "$TORCH_HOME/int8/checkpoints/" ] ; then
        mkdir -p $TORCH_HOME/int8/checkpoints/
        echo "Create $TORCH_HOME/int8/checkpoints/ ok !"
else
        echo "Directory ($TORCH_HOME/int8/checkpoints/): Exist!"
fi

python eval.py -cfgfile model/yolov4-tiny.cfg -weightfile model/yolov4-tiny.weights -darknet2pth true

mv yolov4-tiny.pth $TORCH_HOME/origin/checkpoints/yolov4-tiny.pth

python eval.py -quantized_mode 1 -quantization True -yolov4_version yolov4-tiny

mv yolov4-tiny.pth $TORCH_HOME/int8/checkpoints/
