#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     load-image-ffmpeg-mlu.sh
# UpdateDate:   2022/02/08
# Description:  Loading docker image for IDE.
# Example:
#               ./load-image-ffmpeg-mlu.sh
#               ./load-image-ffmpeg-mlu.sh 16.04
#               ./load-image-ffmpeg-mlu.sh 18.04
# Depends:      image-$OS-$PATH_WORK-$VERSION.tar.gz
# Notes:
# -------------------------------------------------------------------------------
#Dockerfile(16.04/18.04/CentOS)
OSVer="18.04"
if [[ $# -ne 0 ]];then OSVer="${1}";fi
# Source env
source ./env.sh $OSVer
#################### main ####################
# 0.Check param
#if [[ $# -eq 0 ]];then
#    echo -e "${yellow}WARNING: Load images(${FULLNAME_IMAGE}) by default. ${none}"
#else
#    FULLNAME_IMAGE="${1}"
#fi
# 0.Check File Images
if [[ ! -f ${FULLNAME_IMAGE} ]]; then
    echo -e "${red}ERROR: Images(${FULLNAME_IMAGE}) does not exist! ${none}" &&  exit -1
fi
if [[ ! ${FULLNAME_IMAGE} =~ ${FILENAME_IMAGE} ]]; then
    echo -e "${red}ERROR: Images(${FULLNAME_IMAGE}), please use images(fileName:${FILENAME_IMAGE})! ${none}" &&  exit -1
fi
# 0.Check Docker Images
num=`sudo docker images | grep -w "$MY_IMAGE" | grep -w "$VERSION" | wc -l`
echo $num
echo $NAME_IMAGE

# 1.Load Docker Images
if [ 0 -eq $num ];then
    echo "The image($NAME_IMAGE) is not loaded and is loading......"
    #load image
    sudo docker load < ${FULLNAME_IMAGE}
else
    echo "The image($NAME_IMAGE) is already loaded!"
fi

#echo "All image information:"
#sudo docker images
echo "The image($NAME_IMAGE) information:"
sudo docker images | grep -e "REPOSITORY" -e $MY_IMAGE
