#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-image-yolov5-align.sh
# UpdateDate:   2022/02/08
# Description:  Build docker images for yolov5-align.
# Example:      ./build-image-yolov5-align.sh
# Depends:
#               YOLOv5(git clone https://github.com/ultralytics/yolov5 -b v5.0)
#               https://github.com/ultralytics/yolov5/archive/refs/tags/v5.0.tar.gz
# Notes:
# -------------------------------------------------------------------------------
#Dockerfile(16.04/18.04/CentOS)
OSVer="18.04"
if [[ $# -ne 0 ]];then OSVer="${1}";fi
# 0. Source env
source ./env.sh $OSVer
#################### main ####################
# 1. check
#if [ ! -d "$PATH_WORK" ];then
#    mkdir -p $PATH_WORK
#else
#    echo "Directory($PATH_WORK): Exists!"
#fi

# 2. Download yolov5
./tools/download-yolov5.sh

# 3. Build image
echo "====================== build image ======================"
sudo docker build -f ./docker/$FILENAME_DOCKERFILE \
    -t $NAME_IMAGE .

# 4. Save image
echo "====================== save image ======================"
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE
sudo chmod 664 $FILENAME_IMAGE
mv $FILENAME_IMAGE ./docker/
ls -lh ./docker/$FILENAME_IMAGE
