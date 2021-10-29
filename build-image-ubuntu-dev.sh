#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-image-ubuntu-dev.sh
# UpdateDate:   2021/09/27
# Description:  Build docker images for IDE.
# Example:
#               #Build docker images: Only a basic operating system, default 16.04.
#               ./build-image-ubuntu-dev.sh
#               ./build-image-ubuntu-dev.sh 16.04
#               ./build-image-ubuntu-dev.sh 18.04
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#Dockerfile(16.04/18.04/CentOS)
OSVer="16.04"
if [[ $# -ne 0 ]];then OSVer="${1}";fi
# Source env
source ./env.sh $OSVer
#################### main ####################
# 0.check
if [ ! -d "$DIR_DOCKER" ];then
    echo "Directory($DIR_DOCKER): Does Not Exist!"
    exit -1
fi
cd "${DIR_DOCKER}"

# 1.Copy the dependent packages into the directory of $PATH_WORK
# To supplement......

# 2.build image
echo "====================== build image ======================"
sudo docker build -f ./$FILENAME_DOCKERFILE \
    -t $NAME_IMAGE .

# 3.save image
echo "====================== save image ======================"
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE
sync && sync
sudo chmod 664 $FILENAME_IMAGE
ls -la $FILENAME_IMAGE
cd ../
