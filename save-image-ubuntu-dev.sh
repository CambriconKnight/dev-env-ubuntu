#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     save-image-ubuntu-dev.sh
# UpdateDate:   2021/07/26
# Description:  1. commit: 提交容器到镜像，实现容器持久化；
#               2. save: 导出镜像文件，实现镜像内容持久化。
# Example:
#               ./save-image-ubuntu-dev.sh
#               ./save-image-ubuntu-dev.sh 16.04
#               ./save-image-ubuntu-dev.sh 18.04
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20210402230402.403666251
CMD_TIME=$(date +%Y%m%d%H%M%S) # eg:20210402230402

#Dockerfile(16.04/18.04/CentOS)
OSVer="16.04"
if [[ $# -ne 0 ]];then OSVer="${1}";fi
# Source env
source ./env.sh $OSVer
#New Docker image name
NAME_IMAGE_NEW="$MY_IMAGE:$VERSION-$CMD_TIME"
FILENAME_IMAGE_NEW="image-$OS-$PATH_WORK-$VERSION-$CMD_TIME.tar.gz"

# 2.commit docker container
echo -e "${green}[# Docker images: ${none}"
sudo docker images | grep ${MY_IMAGE}
num_images=`sudo docker images | grep ${MY_IMAGE} | grep $VERSION-$CMD_TIME | awk '{print $3}'`
if [ $num_images ];then
    echo -e "${green}[# Save docker image: ${none}"
    sudo docker save -o $FILENAME_IMAGE_NEW $NAME_IMAGE_NEW
    ls -lh $FILENAME_IMAGE_NEW
    echo -e "${green}   Completed!${none}" && exit 0
else
    echo -e "${green}   Images does not exist!${none}"
    echo -e "${green}[# Docker container: ${none}"
    sudo docker ps -a | grep ${MY_CONTAINER}
    num_container=`sudo docker ps -a | grep ${MY_CONTAINER} | awk '{print $1}'`
    if [ $num_container ];then
        echo -e "${green}[# Commit docker container: ${none}"
        sudo docker commit $num_container $NAME_IMAGE_NEW
        echo -e "${green}   Completed!${none}"
    else
        echo -e "${red}   Container does not exist!${none}" && exit -1
    fi
fi

# 3.save docker image
echo -e "${green}[# Docker images: ${none}"
sudo docker images | grep ${MY_IMAGE}
num_images=`sudo docker images | grep ${MY_IMAGE} | grep $VERSION-$CMD_TIME | awk '{print $3}'`
if [ $num_images ];then
    echo -e "${green}[# Save docker image: ${none}"
    sudo docker save -o $FILENAME_IMAGE_NEW $NAME_IMAGE_NEW
    ls -lh $FILENAME_IMAGE_NEW
    echo -e "${green}   Completed!${none}"
else
    echo -e "${red}   Images does not exist!${none}" && exit -1
fi
