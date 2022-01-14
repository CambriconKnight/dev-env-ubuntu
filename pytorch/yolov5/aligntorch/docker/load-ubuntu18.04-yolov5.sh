#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     load-ubuntu18.04-yolov5.sh
# UpdateDate:   2021/12/16
# Description:  Loading docker image for IDE.
# Example:      ./load-ubuntu18.04-yolov5.sh
# Depends:      image-$OS-$PATH_WORK-$VERSION.tar.gz
# Notes:
# -------------------------------------------------------------------------------
# Source env
#source "./env.sh"
#################### main ####################
export FILENAME_IMAGE="image-ubuntu18.04-yolov5.tar.gz"
export NAME_IMAGE="ubuntu18.04-yolov5"
# 0.Check param
if [[ $# -eq 0 ]];then
    echo -e "${yellow}WARNING: Load images(${FILENAME_IMAGE}) by default. ${none}"
else
    FILENAME_IMAGE="${1}"
fi
# 0.Check File Images
if [[ ! -f ${FILENAME_IMAGE} ]]; then
    echo -e "${red}ERROR: Images(${FILENAME_IMAGE}) does not exist! ${none}" &&  exit -1
fi
if [[ ! ${FILENAME_IMAGE} =~ ${FILENAME_IMAGE} ]]; then
    echo -e "${red}ERROR: Images(${FILENAME_IMAGE}), please use images(fileName:${FILENAME_IMAGE})! ${none}" &&  exit -1
fi
# 0.Check Docker Images
num=`sudo docker images | grep -w "$NAME_IMAGE"  | wc -l`
echo $num
echo $NAME_IMAGE

# 1.Load Docker Images
if [ 0 -eq $num ];then
    echo "The image($NAME_IMAGE) is not loaded and is loading......"
    #load image
    sudo docker load < ${FILENAME_IMAGE}
else
    echo "The image($NAME_IMAGE) is already loaded!"
fi

#echo "All image information:"
#sudo docker images
echo "The image($NAME_IMAGE) information:"
sudo docker images | grep -e "REPOSITORY" -e $NAME_IMAGE
