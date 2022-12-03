#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:    build_bsp.sh
# Revision:    1.0.0
# Date:        2022/12/06
# Description: 基于官网提供的mm容器一键编译生成所有镜像文件.
# Example:
# Depends:      magicmind_0.13.0-1_ubuntu18.04.tar.gz
#               env_ce3226.sh
#               update-os.sh
# Notes:
# -------------------------------------------------------------------------------

# 1. 环境准备
## 1.1. 进入工作目录
cd /home/share/edge/cross_compile
## 1.2. 拷贝或下载sdk到[../dependent_files]目录
#cp -rvf /data/ftp/ce3226/sdk/ce3226v100-sdk-1.1.0.tar.gz ../dependent_files
## 1.3. 解压SDK到本目录
tar zxvf ../dependent_files/ce3226v100-sdk-1.1.0.tar.gz -C ./
## 1.4. 解压bsp到本目录
tar zxvf ./ce3226v100-sdk-1.1.0/board/package/bsp.tar.gz -C ./
## 1.5. 进入bsp编译目录
cd /home/share/edge/cross_compile/bsp/ce3226v100_build/build
# 2.执行make
make all
# 3.编译完后,在out/目录下是生成所有的bsp镜像文件
ls -la ./out
# 4.设置权限,否则可能会导致tftp下载失败
chmod 644 ./out/ubootenv*
ls -la ./out
# 5.备用操作
## 5.1.如需要则修改用户权限
#sudo chown cam:cam -R ./out/*
## 5.2.拷贝到tftp目录
#cp -rvf ./out/*.bin ./out/*.img ./out/*.itb /data/tftp