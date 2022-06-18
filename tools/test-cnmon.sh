#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:     test-cnmon.sh
# Revision:     1.0.0
# Date:         2021/02/09
# Description:  1.监测以下模块信息: VPU、MLU、CPU、溫度、板卡主頻、Memory、DDR主頻等
#               2.运行后会在当前目录下生成个log目录及对应时间戳后缀的log文件。
#                如:./log/test-cnmon-20210122165216.225126059.log
# Example:      運行腳本: ./test-cnmon.sh 0;./test-cnmon.sh all
# Depends:      cnmon命令
# Notes:
# -------------------------------------------------------------------------------
#一个循环时间 = 4 * TimeSleep4Middle + TimeSleep4While
TimeSleep4While=1
TimeSleep4Middle=0.5
StringGrep="Video|MLU|Cluster|Board|Device CPU Chip|DDR"
StringError="Error: You must provide [a card number]/[all] as \$1 "
DEMO_NAME="demo"
CMD_TIME=$(date +%Y%m%d%H%M%S.%N)
LOG_PACH="log"
DEVICE_ID="all"

if [[ $# -eq 1 ]];then
    #判断参数$1是否为数字或者字符串[all]
    echo "$1"|[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ]
    if [ "$?" != "0" ] && [ "$1" != "all" ]; then
        echo "${StringError}" && exit 0
    fi
    DEVICE_ID=$1
else
    echo "${StringError}" && exit 0
fi

if [ ! -d $LOG_PACH ];then
    mkdir -p $LOG_PACH
fi
LOG_FILENAME="${LOG_PACH}/test-cnmon-${CMD_TIME}.log"

while true;
do
    date;
    date >> ${LOG_FILENAME};
    sleep ${TimeSleep4Middle};
    echo "==========================================";
    echo "==========================================" >> $LOG_FILENAME;
    if [[ "$DEVICE_ID" == "all" ]];then
        cnmon info | grep -E "${StringGrep}";
        sleep ${TimeSleep4Middle};
        cnmon info | grep -E "${StringGrep}" >> ${LOG_FILENAME};
        sleep ${TimeSleep4Middle};
    else
        cnmon info -c ${DEVICE_ID} | grep -E "${StringGrep}";
        sleep ${TimeSleep4Middle};
        cnmon info -c ${DEVICE_ID} | grep -E "${StringGrep}" >> ${LOG_FILENAME};
        sleep ${TimeSleep4Middle};
    fi
    echo "=====================";
    echo "=====================" >> $LOG_FILENAME;
    cnmon | grep $DEMO_NAME | wc -l;
    sleep ${TimeSleep4Middle};
    cnmon | grep $DEMO_NAME | wc -l >> $LOG_FILENAME;
    sleep $TimeSleep4While;
    echo "==========================================";
    echo "==========================================" >> $LOG_FILENAME;
done
