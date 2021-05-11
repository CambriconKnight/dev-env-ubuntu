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
    && apt install -y curl

    #设置python 优先级 python2-100,python3-99，python2 高
    update-alternatives --install /usr/bin/python python /usr/bin/python2 100 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 99 \
    && sed -i "s/\/usr\/bin\/python.*/\/usr\/bin\/python2/g" /usr/bin/pip2
    #链接pip 默认为pip2
    ln -s /usr/bin/pip2  /usr/bin/pip -f

    #pip2&pip3安装
    pip2 install cycler==0.9.0 \
    && pip2 install decorator==4.0.6 \
    && pip2 install future==0.18.2 \
    && pip2 install nose==1.3.7 \
    && pip2 install pyparsing==2.0.3 \
    && pip2 install Pyste==0.9.10 \
    && pip2 install python-dateutil==2.4.2 \
    && pip2 install pytz==2014.10 \
    && pip2 install six==1.10.0 \
    && pip2 install numpy==1.11.1 \
    && pip2 install scikit-build \
    && pip2 install Cython\
    && pip2 install opencv-python==4.2.0.32\
    && pip2 install psutil \
    && pip2 install graphviz \
    && pip2 install pydot \
    && pip2 install matplotlib==2.0.0 \
    && pip2 install Pillow==6.1 \
    && pip2 install scipy==1.2 \
    && pip2 install PyWavelets==1.0.1 \
    && pip2 install scikit-image==0.10.1 \
    && pip2 install protobuf==3.15.7 \
    && pip2 install virtualenv==15.1.0\
    && pip2 install dask==1.2.2\
    && pip2 install pycocotools==2.0.0\
    && pip3 install numpy==1.16 \
    && pip3 install protobuf \
    && pip3 install virtualenv==15.1.0\
    && apt-get clean
