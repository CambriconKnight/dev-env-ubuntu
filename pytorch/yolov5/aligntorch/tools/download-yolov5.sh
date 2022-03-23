#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-ffmpeg-mlu.sh
# UpdateDate:   2022/02/08
# Description:  Build ffmpeg-mlu.
# Example:      ./build-ffmpeg-mlu.sh
# Depends:
#               YOLOv5(git clone https://github.com/ultralytics/yolov5 -b v5.0)
#               https://github.com/ultralytics/yolov5/archive/refs/tags/v5.0.tar.gz
# Notes:
# -------------------------------------------------------------------------------
#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
#ENV
WORK_DIR="/home/share"
VERSION_YOLOV5="5.0"
PATH_WORK_TMP="yolov5"
NAME_YOLOV5_ALIGN="$PATH_WORK_TMP-$VERSION_YOLOV5"
FILENAME_YOLOV5_ALIGN="${NAME_YOLOV5_ALIGN}.tar.gz"
#############################################################
# 1. Download yolov5
if [ -f "${FILENAME_YOLOV5_ALIGN}" ];then
    echo -e "${green}File(${FILENAME_YOLOV5_ALIGN}): Exists!${none}"
    # $FILENAME_YOLOV5_ALIGN 压缩包中已经包含了ffmpeg-mlu补丁 + ffmpeg4.2
    tar zxvf $FILENAME_YOLOV5_ALIGN
    mv $NAME_YOLOV5_ALIGN $PATH_WORK_TMP
else
    echo -e "${green}File(${FILENAME_YOLOV5_ALIGN}):  non-existent!${none}"
    if [ ! -d "${PATH_WORK_TMP}" ];then
        echo -e "${green}git clone yolov5......${none}"
        git clone https://github.com/ultralytics/yolov5 -b v$VERSION_YOLOV5
    else
        echo "Directory($PATH_WORK_TMP): Exists!"
    fi
fi

# del .git
pushd $PATH_WORK_TMP
find ../ -name ".git" | xargs rm -Rf
popd
