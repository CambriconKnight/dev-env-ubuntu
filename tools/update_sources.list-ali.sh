#/bin/bash
set -e
CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20190402230402.403666251
#备份软件源
#if [ ! -f "/etc/apt/sources.list.backup" ]; then
#    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
#fi
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$CMD_TIME
#修改软件源
#sudo vim /ect/apt/sources.list,以下直接echo入文件
sudo sh -c "sudo echo deb 'http://mirrors.aliyun.com/ubuntu/ xenial main restricted' > /etc/apt/sources.list && \
sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial universe' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted' >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe'  >> /etc/apt/sources.list && \
sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse' >> /etc/apt/sources.list"

#sudo sh -c "sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted' > /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial universe' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates universe' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial multiverse' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates multiverse' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security universe' >> /etc/apt/sources.list && \
#sudo echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security multiverse' >> /etc/apt/sources.list"

sync
sync

#让软件源生效
sudo apt-get update


#阿里云
# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
#deb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties
#deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
#deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties
#deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
#deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties
#deb http://mirrors.aliyun.com/ubuntu/ xenial universe
#deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
#deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
#deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
#deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties
#deb http://archive.canonical.com/ubuntu xenial partner
#deb-src http://archive.canonical.com/ubuntu xenial partner
#deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
#deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties
#deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
#
#清华大学
# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial universe
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates universe
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial multiverse
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates multiverse
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security universe
#deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security multiverse
