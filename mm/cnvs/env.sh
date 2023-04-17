#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.0.0
# Date:        2023/04/14
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### Function ####################
# Init
init_env() {
    source "../lib/time.sh"
    source "../lib/log.sh"
    init_log
    source "../lib/base.sh"
}

#################### environment variable ####################
#配置测试的板卡编号：举例说明，如果配置值为【1,0】则按照1,0的顺序打开设备，cnmon显示顺序也为1,0。
#export MLU_VISIBLE_DEVICES=0,1

#################### main ####################
main_time_start=$(date +"%s.%N")
#初始化
init_env
