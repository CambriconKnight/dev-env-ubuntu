# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.0.0
# Date:        2023/03/13
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### version ####################
## 以下信息,根据各个版本中文件实际名词填写.
#pytorch镜像的版本号，如【pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz】则取作【1.15.0】。
VER="1.15.0"
Owner="kang"
#TestModel="-ChatGLM"
TestModel=""
#################### docker ####################
#Work
PATH_WORK="pytorch"
#Dockerfile(16.04/18.04/CentOS)
OSVer="18.04"
#Operating system，如【pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz】则取作【ubuntu18.04-py37】。
OS="ubuntu${OSVer}-py37"
#OS="ubuntu$OSVer-py37-20230531210906-20230531220906"
#FrameVersion，如【pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz】则取作【v1.15.0-torch1.9】。
FrameVer="v${VER}-torch1.9"
#(Dockerfile.16.04/Dockerfile.18.04/Dockerfile.CentOS)
FILENAME_DOCKERFILE="Dockerfile.${OSVer}"
DIR_DOCKER="docker"
#Version
#VERSION="v${VER}"
#VERSION="$FrameVer-$OS"
VERSION="${FrameVer}-${OS}${TestModel}"
#Organization
ORG="yellow.hub.cambricon.com/$PATH_WORK"
#Docker image
#MY_IMAGE="$ORG/$OS-$PATH_WORK"
#MY_IMAGE="yellow.hub.cambricon.com/pytorch/pytorch"
MY_IMAGE="${ORG}/${PATH_WORK}"
#Docker image name
NAME_IMAGE="$MY_IMAGE:$VERSION"
#FileName DockerImage
#FILENAME_IMAGE="$PATH_WORK-$FrameVer-$OS.tar.gz"
#FILENAME_IMAGE="pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz"
FILENAME_IMAGE="$PATH_WORK-$FrameVer-$OS${TestModel}.tar.gz"
#FILENAME_IMAGE="pytorch-v1.15.0-torch1.9-ubuntu18.04-py37-ChatGLM.tar.gz"
FULLNAME_IMAGE="./docker/${FILENAME_IMAGE}"
#Docker container name
#Docker container name  container-pytorch-v1.15.0-torch1.9-ubuntu18.04-py37-kang
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
