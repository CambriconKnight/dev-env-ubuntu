#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:     test-cnmon.sh
# Revision:     1.0.0
# Date:         2021/02/09
# Description:  1.监测以下模块信息: VPU、MLU、CPU、溫度、板卡主頻、Memory、DDR主頻等
#               2.运行后会在当前目录下生成个log目录及对应时间戳后缀的log文件。
#                如:./log/test-cnmon-20210122165216.225126059.log
# Example:      直接運行腳本: ./test-cnmon.sh
# Depends:      cnmon命令
# Notes:
# -------------------------------------------------------------------------------

TIMESLEEP=1
DEMO_NAME="demo"
CMD_TIME=$(date +%Y%m%d%H%M%S.%N)
LOG_PACH="log"
if [ ! -d $LOG_PACH ];then
    mkdir -p $LOG_PACH
fi
LOG_FILENAME="${LOG_PACH}/test-cnmon-${CMD_TIME}.log"

while true;
do
    date;
    date >> ${LOG_FILENAME};
    sleep 1;
    echo "=====================";
    cnmon info | grep -E "Video Codec|MLU|Cluster|Board|Device CPU Chip|DDR";
    sleep 0.5;
    cnmon info | grep -E "Video Codec|MLU|Cluster|Board|Device CPU Chip|DDR" >> ${LOG_FILENAME};
    #cnmon >> ${LOG_FILENAME};
    sleep 1;
    echo "=====================" >> $LOG_FILENAME;
    cnmon | grep $DEMO_NAME | wc -l;
    sleep 0.5;
    cnmon | grep $DEMO_NAME | wc -l >> $LOG_FILENAME;
    echo "=====================" >> $LOG_FILENAME;
    echo "=====================";
    sleep $TIMESLEEP;
done
