#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    test-cnmon.sh
# Revision:    1.0.0
# Date:        2021/02/09
# Description: test for cnmon
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------

CMD_TIME=$(date +%Y%m%d%H%M%S.%N)
TIMESLEEP=1
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
    cnmon info | grep -E "Video Codec|MLU|Cluster";
    sleep 0.5;
    cnmon info | grep -E "Video Codec|MLU|Cluster" >> ${LOG_FILENAME};
    #cnmon >> ${LOG_FILENAME};
    sleep 1;
    echo "=====================" >> $LOG_FILENAME;
    cnmon | grep demo | wc -l;
    sleep 0.5;
    cnmon | grep demo | wc -l >> $LOG_FILENAME;
    echo "=====================" >> $LOG_FILENAME;
    echo "=====================";
    sleep $TIMESLEEP;
done
