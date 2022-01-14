#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-image-ubuntu16.04-dev.sh
# UpdateDate:   2021/04/26
# Description:  Build docker images for IDE.
# Example:
#               #Build docker images: Only a basic operating system
#               ./build-image-ubuntu16.04-dev.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### function ####################
export FILENAME_IMAGE="image-ubuntu18.04-yolov5.tar.gz"
export NAME_IMAGE="ubuntu18.04-yolov5:v1.0"
export DIR_DOCKER="./"

help_info() {
    echo "
Build docker images for IDE.
Usage:
    $0 <command> [arguments]
The commands are:
    -h      Help info.
Examples:
    $0 -h
Use '$0 -h' for more information about a command.
    "
}

# Refresh global variables
refresh_global_variables() {
    echo "# Refresh global variables"
}

#################### main ####################
# Source env
#source "./env.sh"

#if [[ $# -eq 0 ]];then
#    help_info && exit 0
#fi

# Get parameters(-t 1 -s 1 -m 1 -p 1 -n 1)
while getopts "h:" opt; do
    case $opt in
    h) help_info  &&  exit 0
        ;;
    \?)
        help_info && exit 0
        ;;
    esac
done

# Refresh global variables
#refresh_global_variables

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
sudo docker build -f ./Dockerfile.18.04-yolov5 \
    -t $NAME_IMAGE .

# 3.save image
echo "====================== save image ======================"
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE
sync && sync
sudo chmod 664 $FILENAME_IMAGE
ls -la $FILENAME_IMAGE
cd ../
