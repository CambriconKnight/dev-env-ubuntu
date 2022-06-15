# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.0.0
# Date:        2022/06/06
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### version ####################
## 以下信息,根据各个版本中文件实际名词填写.
#Version
VER="0.10.0"
#################### docker ####################
#Work
PATH_WORK="magicmind"
#Dockerfile(16.04/18.04/CentOS)
OSVer="18.04"
#(Dockerfile.16.04/Dockerfile.18.04/Dockerfile.CentOS)
FILENAME_DOCKERFILE="Dockerfile.${OSVer}"
DIR_DOCKER="docker"
#Version
#VERSION="v${VER}"  0.10.0-x86_64-ubuntu18.04-py_3_7
VERSION="${VER}-x86_64-ubuntu$OSVer-py_3_7"
#Organization
ORG="yellow.hub.cambricon.com/magicmind/release/x86_64"
#Operating system
OS="ubuntu$OSVer"
#Docker image
#MY_IMAGE="$ORG/$OS-$PATH_WORK"
#MY_IMAGE="yellow.hub.cambricon.com/magicmind/release/x86_64/magicmind"
MY_IMAGE="${ORG}/${PATH_WORK}"
#Docker image name
NAME_IMAGE="$MY_IMAGE:$VERSION"
#FileName DockerImage  magicmind_0.10.0-1_ubuntu18.04.tar.gz
FILENAME_IMAGE="${PATH_WORK}_${VER}-1_ubuntu$OSVer.tar.gz"
FULLNAME_IMAGE="./${FILENAME_IMAGE}"
#Docker container name  container-magicmind-0.10.0-x86_64-ubuntu18.04-py_3_7
MY_CONTAINER="container-${PATH_WORK}-${VERSION}"
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
