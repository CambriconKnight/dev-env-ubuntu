#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     save-ubuntu18.04-yolov5.sh
# UpdateDate:   2021/12/16
# Description:  1. commit: 提交容器到镜像，实现容器持久化；
#               2. save: 导出镜像文件，实现镜像内容持久化。
# Example:      ./save-image-ubuntu18.04-xxx.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20210402230402.403666251
CMD_TIME=$(date +%Y.%m.%d) # eg:20210402230402

# 1.Source env
NAME_IMAGE="ubuntu18.04-yolov5:v1.0"
MY_IMAGE="ubuntu18.04-yolov5"
#New Docker image name
NAME_IMAGE_NEW="$MY_IMAGE-$CMD_TIME"
FILENAME_IMAGE="$MY_IMAGE_$CMD_TIME.tar.gz"


num_container=`sudo docker ps -a | grep ${NAME_IMAGE} | awk '{print $1}'`
echo $num_container
sudo docker commit $num_container $NAME_IMAGE_NEW
sudo docker images
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE_NEW
ls -lh $FILENAME_IMAGE



