#!/bin/bash
set -e

VERSION_YOLOV5="5.0"
PATH_WORK_TMP="yolov5"
NAME_YOLOV5_ALIGN="$PATH_WORK_TMP-$VERSION_YOLOV5"
FILENAME_YOLOV5_ALIGN="${NAME_YOLOV5_ALIGN}.tar.gz"
#################### main ####################
cp -rvf ./dependent_files/$FILENAME_YOLOV5_ALIGN ./
cp -rvf ./dependent_files/yolov5s.pt ./weights
