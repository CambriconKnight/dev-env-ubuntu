#!/bin/bash

cmd_time=$(date +%Y%m%d%H%M%S.%N)
filename="test-cnmon-${cmd_time}.log"
timesleep=1

while true;
do 
    date;
    date >> ${filename};
    sleep 1; 
    echo "====================="; 
    cnmon info | grep -E "Video Codec|MLU";
    sleep 0.5;
    cnmon info | grep -E "Video Codec|MLU" >> ${filename};
    #cnmon >> ${filename}; 
    sleep 1; 
    echo "=====================" >> $filename; 
    cnmon | grep demo | wc -l; 
    sleep 0.5;
    cnmon | grep demo | wc -l >> $filename; 
    echo "=====================" >> $filename; 
    echo "====================="; 
    sleep $timesleep;
done
