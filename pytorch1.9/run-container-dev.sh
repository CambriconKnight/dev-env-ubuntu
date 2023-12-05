#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run-container-dev.sh
# UpdateDate:   2023/03/13
# Description:  Run docker image for IDE.
# Example:      ./run-container-dev.sh
# Depends:      container-${PATH_WORK}-${VERSION}-${Owner}
# Notes:
# -------------------------------------------------------------------------------
# Source env
source "./env.sh"
######Modify according to your development environment#####
#Share path on the host
PATH_SHARE_HOST="$PWD/../"
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
[ ! -z $(docker images -q $NAME_IMAGE) ] || (echo -e "${red}ERROR: Images(${NAME_IMAGE}) does not exist! ${none}" &&  exit -1)

#Check docker container
num=`docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`
echo $num
echo $MY_CONTAINER

#Run docker
if [ 0 -eq $num ];then
    #sudo xhost +
    docker run -e DISPLAY=unix$DISPLAY --privileged=true \
        --device /dev/cambricon_ctl \
        --device /dev/cambricon_ipcm0 \
        --net=host --ipc=host --pid=host \
        -v /usr/bin/cnmon:/usr/bin/cnmon \
        -v /sys/kernel/debug:/sys/kernel/debug \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /mnt/data/opt/share:/opt/share \
        -p 8888:8888 \
        -p 5025:22 \
        -w $PATH_SHARE_DOCKER \
        -it -v $PATH_SHARE_HOST:$PATH_SHARE_DOCKER \
        -it -v $PATH_FTP_HOST:$PATH_FTP_DOCKER \
        -it -v $PATH_DATASETS_HOST:$PATH_DATASETS_DOCKER \
        -it -v $PATH_MODELS_HOST:$PATH_MODELS_DOCKER \
        --name $MY_CONTAINER $NAME_IMAGE /bin/bash
else
    docker start $MY_CONTAINER
    docker exec -ti $MY_CONTAINER /bin/bash
fi
