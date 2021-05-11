#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run-container-ubuntu16.04-dev.sh
# UpdateDate:   2021/04/26
# Description:  Run docker image for IDE.
# Example:      ./run-container-ubuntu16.04-dev.sh
# Depends:      container-$OS-$PATH_WORK-$VERSION
# Notes:
# -------------------------------------------------------------------------------
# Source env
source "./env.sh"
######Modify according to your development environment#####
#Share path on the host
PATH_SHARE_HOST="$PWD"
#Share path on the docker container
PATH_SHARE_DOCKER="/home/share"
#SDK path on the host
PATH_FTP_HOST="/data/ftp"
#Work path on the docker container
PATH_FTP_DOCKER="/home/ftp"
#Datasets path on the host
PATH_DATASETS_HOST="/data/datasets"
#Datasets path on the docker container
PATH_DATASETS_DOCKER="/data/datasets"
#Models path on the host
PATH_MODELS_HOST="/data/models"
#Models path on the docker container
PATH_MODELS_DOCKER="/data/models"

##########################################################
#Check docker images
[ ! -z $(sudo docker images -q $NAME_IMAGE) ] || (echo -e "${red}ERROR: Images(${NAME_IMAGE}) does not exist! ${none}" &&  exit -1)

#Check docker container
num=`sudo docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`
echo $num
echo $MY_CONTAINER

#Run docker
if [ 0 -eq $num ];then
    #sudo xhost +
    sudo docker run -e DISPLAY=unix$DISPLAY --privileged=true \
        --device /dev/cambricon_dev0 \
        --net=host --ipc=host --pid=host \
        -v /sys/kernel/debug:/sys/kernel/debug \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -it -v $PATH_SHARE_HOST:$PATH_SHARE_DOCKER \
        -it -v $PATH_FTP_HOST:$PATH_FTP_DOCKER \
        -it -v $PATH_DATASETS_HOST:$PATH_DATASETS_DOCKER \
        -it -v $PATH_MODELS_HOST:$PATH_MODELS_DOCKER \
        --name $MY_CONTAINER $NAME_IMAGE /bin/bash
else
    sudo docker start $MY_CONTAINER
    sudo docker exec -ti $MY_CONTAINER /bin/bash
fi
