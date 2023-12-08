# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.0.0
# Date:        2023/12/08
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### version ####################
## 以下信息,根据各个版本中文件实际名词填写.
#pytorch镜像的版本号，如【pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310.tar.gz】则取作【1.17.0】。
VER="1.17.0"
Owner="kang"
#TestModel="-ChatGLM"
TestModel=""
#################### docker ####################
#Work
PATH_WORK="pytorch"
#Dockerfile(16.04/18.04/CentOS)
OSVer="18.04"
#Operating system，如【pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310.tar.gz】则取作【ubuntu18.04-py310】。
OS="ubuntu${OSVer}-py310"
#FrameVersion，如【pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310.tar.gz】则取作【v1.17.0-torch1.13.1】。
FrameVer="v${VER}-torch1.13.1"
#(Dockerfile.16.04/Dockerfile.18.04/Dockerfile.CentOS)
FILENAME_DOCKERFILE="Dockerfile.${OSVer}"
DIR_DOCKER="docker"
#Version
VERSION="${FrameVer}-${OS}${TestModel}"
#Organization
ORG="yellow.hub.cambricon.com/$PATH_WORK"
#Docker image
#MY_IMAGE="yellow.hub.cambricon.com/pytorch/pytorch"
MY_IMAGE="${ORG}/${PATH_WORK}"
#Docker image name
NAME_IMAGE="$MY_IMAGE:$VERSION"
#FileName DockerImage
#FILENAME_IMAGE="pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310.tar.gz"
FILENAME_IMAGE="$PATH_WORK-$FrameVer-$OS${TestModel}.tar.gz"
#FILENAME_IMAGE="pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310-ChatGLM.tar.gz"
FULLNAME_IMAGE="./docker/${FILENAME_IMAGE}"
#Docker container name  container-pytorch-v1.17.0-torch1.13.1-ubuntu18.04-py310-kang
MY_CONTAINER="container-${PATH_WORK}-${VERSION}-${Owner}"
#################### color ####################
#Font color
none="\033[0m"
black="\033[0;30m"
dark_gray="\033[1;30m"
blue="\033[0;34m"
light_blue="\033[1;34m"
green="\033[0;32m"
light_green="\033[1;32m"
cyan="\033[0;36m"
light_cyan="\033[1;36m"
red="\033[0;31m"
light_red="\033[1;31m"
purple="\033[0;35m"
light_purple="\033[1;35m"
brown="\033[0;33m"
yellow="\033[1;33m"
light_gray="\033[0;37m"
white="\033[1;37m"
