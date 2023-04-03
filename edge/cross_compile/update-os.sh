#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:    update-os.sh
# Revision:    1.0.0
# Date:        2022/12/06
# Description: 基于官网提供的mm容器还需要安装以下软件及配置,否则会编译BSP会报一些错误.
# Example:
# Depends:      magicmind_0.13.0-1_ubuntu18.04.tar.gz
# Notes:
# -------------------------------------------------------------------------------

#apt-get install
apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends \
    device-tree-compiler bc \
    minicom tftpd-hpa nfs-kernel-server nfs-common

#pip install
pip install openpyxl
pip install bc

#编辑 tftpd-hpa && nfs 设置
#sudo vi /etc/default/tftpd-hpa
echo '# /etc/default/tftpd-hpa' > /etc/default/tftpd-hpa && \
echo 'TFTP_USERNAME="tftp"' >> /etc/default/tftpd-hpa && \
echo 'TFTP_DIRECTORY="/data/tftp"' >> /etc/default/tftpd-hpa && \
echo 'TFTP_ADDRESS="0.0.0.0:69"' >> /etc/default/tftpd-hpa && \
echo 'TFTP_OPTIONS="-l -c -s"' >> /etc/default/tftpd-hpa && \
echo '/data/nfs *(rw,sync,no_root_squash)' >> /etc/exports
#sudo service tftpd-hpa restart
