#!/bin/bash

set -e

# 0.Check param
if [ ! -f "$COCO_PATH_PYTORCH/COCO" ] ; then
	echo "Directory ($COCO_PATH_PYTORCH/COCO) not exist, pleas download COCO datasets !"
fi

python eval.py -half_input 1 -quantized_mode 1 -datadir $COCO_PATH_PYTORCH/COCO -yolov4_version yolov4-tiny

