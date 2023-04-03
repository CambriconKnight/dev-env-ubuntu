#/bin/bash
#set -e
# -------------------------------------------------------------------------------
# Filename:    build-cnstream-ce3226.sh
# Revision:    1.0.0
# Date:        2023/03/30
# Description: 基于官网提供的mm容器一键编译生成所有镜像文件.
# Example:
# Depends:      magicmind_0.13.0-1_ubuntu18.04.tar.gz
#               env_ce3226.sh
#               update-os.sh
#               https://github.com/Cambricon/cnstream.git -b v7.1.0
#
# Notes:
# -------------------------------------------------------------------------------

#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"

# 1. 下载EDGE包： 下载edge.tar.gz（EDGE fro CNStream 一体包 ）
cd /home/share/edge/dependent_files
#wget http://video.cambricon.com/models/edge.tar.gz
if [ ! -f "edge.tar.gz" ];then wget http://video.cambricon.com/models/edge.tar.gz; fi
tar zxvf edge.tar.gz

# 2. 下载SDK： 下载并解压mps.tar.gz inference.tar.gz
cd /home/share/edge/dependent_files
##拷贝或下载sdk到[dependent_files]目录
#cp -rvf /data/ftp/ce3226/sdk/ce3226v100-sdk-1.1.0.tar.gz ../dependent_files
tar zxvf ./ce3226v100-sdk-1.1.0.tar.gz
cd /home/share/edge/dependent_files/ce3226v100-sdk-1.1.0/board/package/
## 2.1. 解压mps.tar.gz并设置环境变量MPS_HOME
tar zxvf mps.tar.gz
export MPS_HOME=/home/share/edge/dependent_files/ce3226v100-sdk-1.1.0/board/package/mps/out
## 2.2. inference.tar.gz并同步lib库
tar zxvf inference.tar.gz
# 同步lib库（mm docker镜像环境中 /usr/local/neuware/edge/目录下与inference.tar.gz目录中内容还是有些差异，需要解压后更新过去）
cp -rvf /home/share/edge/dependent_files/ce3226v100-sdk-1.1.0/board/package/inference/* /usr/local/neuware/edge
cp -rvf /home/share/edge/dependent_files/ce3226v100-sdk-1.1.0/board/package/inference/lib64/* $MPS_HOME/lib
cp -rvf /home/share/edge/dependent_files/ce3226v100-sdk-1.1.0/board/package/inference/include/* $MPS_HOME/include

# 3. 编译并安装第三方依赖库
cd /home/share/edge/dependent_files/edge
#source install_edge.sh
# To build opencv with ffmpeg for videoIO
source install_edge.sh opencv_with_ffmpeg

# 4. 设置必要的环境变量
source env.sh

# 5. 下载 CNStream 源码
cd /home/share/edge/cross_compile
git clone https://github.com/Cambricon/cnstream.git -b v7.1.0
cd cnstream && git submodule update --init && cd -

# 6. 编译并打包 CNStream
cd /home/share/edge/dependent_files/edge
export cnstream_dir="/home/share/edge/cross_compile/cnstream"
export target_dir="${cnstream_dir}/cnstream_deploy_ce3226"
./install_cnstream.sh ${cnstream_dir} ${target_dir}

# 7. 微调并重新打包部署文件
cd ${cnstream_dir}
rm -rvf cnstream_deploy_ce3226.tar.gz
#生成环境变量配置文件
TimePackage=$(date +%Y%m%d%H%M%S) # eg:20210131230402.403666251
echo '#!/bin/bash' > ${target_dir}/env.sh
echo "#TimePackage:${TimePackage}" >> ${target_dir}/env.sh
echo 'export LD_LIBRARY_PATH="$PWD/lib:$LD_LIBRARY_PATH"' >> ${target_dir}/env.sh
#重新打包，避免包括上层目录
tar -zcvf cnstream_deploy_ce3226.tar.gz ./cnstream_deploy_ce3226
#查看打包文件
echo -e "${green}========================================"
ls -la ${cnstream_dir}/cnstream_deploy_ce3226.tar.gz
echo -e "========================================${none}"
