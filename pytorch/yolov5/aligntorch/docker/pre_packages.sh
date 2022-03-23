#!/bin/bash
#
#echo -e 'nameserver 114.114.114.114' > /etc/resolv.conf
mkdir -p /root/.pip/
cp pip.conf /root/.pip/
cp sources_18.04.list /etc/apt/sources.list
#add-apt-repository ppa:jonathonf/python-3.7
DEBIAN_FRONTEND=noninteractive
rm -rf /var/lib/apt/lists/* \
    && mkdir /var/lib/apt/lists/partial \
    && apt-get clean \
    && apt-get update --fix-missing \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        curl git wget vim build-essential cmake make ca-certificates nasm yasm \
        openssh-server libgoogle-glog-dev libgflags-dev libcurl4-openssl-dev \
        libsdl2-dev libfreetype6-dev \
        lcov apt-utils \
        libopencv-dev python3.6  python3-dev \
        python3-tk  \
        python3-pip  \
        python-pip  \
        net-tools   \
        software-properties-common \
        libgtk2.0-dev pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo -e "\033[0;32m[apt install... Done] \033[0m"

    #设置python 优先级
    update-alternatives --install /usr/bin/python python /usr/bin/python3 99 \
    && sed -i "s/\/usr\/bin\/python.*/\/usr\/bin\/python3/g" /usr/bin/pip3 \
    && ln -s /usr/bin/pip3 /usr/bin/pip -f \
    && ln -s /usr/bin/python3 /usr/bin/python -f

    #pip2&pip3安装。 第三方依赖包列表可在 PyTorch 源码主目录下的 requirements.txt 中查询。
    python -m pip install --upgrade pip \
    && pip3 install -r requirements.txt \
    && apt-get clean \
    && echo -e "\033[0;32m[pip install -r requirements.txt... Done] \033[0m"
