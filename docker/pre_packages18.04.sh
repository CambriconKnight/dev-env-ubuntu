#!/bin/bash
apt update
#add-apt-repository ppa:jonathonf/python-3.7
DEBIAN_FRONTEND=noninteractive
apt install --no-install-recommends -y \
    && apt install software-properties-common -y \
    && apt install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libopenblas-dev libhdf5-serial-dev protobuf-compiler -y\
    && apt install libgflags-dev libgoogle-glog-dev liblmdb-dev -y\
    && apt install libopenmpi-dev  -y \
    && apt install libatlas-base-dev -y \
    && apt install libopenblas-dev -y \
    && apt install libboost-all-dev -y \
    && apt install vim -y\
    && apt install cmake -y\
    && apt install python3 -y\
    && apt install python3-dev -y\
    && apt install python3-tk  -y\
    && apt install python3-pip -y \
    && apt install python-opencv -y \
    && apt install python-pip -y \
    && apt install python2.7 -y \
    && apt install python2.7-dev -y \
    && apt install python2.7-tk -y \
    && apt install python2.7-skimage -y \
    && apt install tzdata -y \
    && apt install git -y \
    && apt install wget -y \
    && apt install -y g++-multilib \
    && apt install -y autogen \
    && apt install -y automake \
    && apt install -y libtool \
    && apt install -y curl \
    && echo -e "\033[0;32m[apt install... Done] \033[0m"

    #设置python 优先级 python2-100,python3-99，python2 高;#链接pip 默认为pip2
    update-alternatives --install /usr/bin/python python /usr/bin/python2 100 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 99 \
    && sed -i "s/\/usr\/bin\/python.*/\/usr\/bin\/python2/g" /usr/bin/pip2 \
    && ln -s /usr/bin/pip2  /usr/bin/pip -f

    #pip2&pip3安装。 第三方依赖包列表可在 PyTorch 源码主目录下的 requirements.txt 中查询。
    pip install -r requirements.txt \
    && apt-get clean \
    && echo -e "\033[0;32m[pip install -r requirements.txt... Done] \033[0m"