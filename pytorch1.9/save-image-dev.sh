#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     save-image-dev.sh
# UpdateDate:   2021/07/26
# Description:  1. commit: 提交容器到镜像，实现容器持久化；
#               2. save: 导出镜像文件，实现镜像内容持久化。
# Example:      ./save-image-dev.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20210402230402.403666251
CMD_TIME=$(date +%Y%m%d%H%M%S) # eg:20210402230402
# 0.Check param
if [[ $# -eq 1 ]];then CMD_TIME="${1}";fi

# 1.Source env
source "./env.sh"
#New Docker image name
NAME_IMAGE_NEW="$MY_IMAGE:$VERSION-$CMD_TIME"
FILENAME_IMAGE_NEW="$PATH_WORK-$VERSION-$CMD_TIME.tar.gz"

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
