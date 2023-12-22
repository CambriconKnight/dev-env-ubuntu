#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     init-cnvs.sh
# Revision:     1.0.0
# Date:         2023/04/14
# Description:  初始化cnvs运行环境。
# Example:
# Depends:      官方提供的mm Docker容器
# Notes:
# -------------------------------------------------------------------------------
source "./env.sh"

print_log_echo_info "=================================================="
#以下操作步骤均是在官方提供的Docker容器中进行
#进入测试目录
cd /home/share/mm/cnvs
##########################################################
# 安装依赖库
apt-get update
apt-get install -y libpci3 libpci3 pciutils tree
apt --fix-broken install
apt-get install -y libyaml-dev
#安装CNVS
#dpkg -i /var/cntoolkit-3.6.1/cnvs_0.12.0-1.ubuntu18.04_amd64.deb
dpkg -i /var/cntoolkit-3.7.2/cnvs_0.13.1-1.ubuntu18.04_amd64.deb
##########################################################
#结束时间
main_time_end=$(date +"%s.%N")
#计算测试所用的时间
ret=$(timediff $main_time_start $main_time_end)
print_log_echo_info "Total time: $ret s"
print_log_echo_info "=================================================="
