#!/bin/bash
mlu_cnt=0
mdev_dir="/proc/driver/cambricon/mlus"
if [ ! -d "$mdev_dir" ]; then
    return
fi

for mdid in $(ls -a $mdev_dir); do
    if [ x"$mdid" != x"." -a x"$mdid" != x".." ]; then
        echo $mlu_cnt
        cnmon info -c $mlu_cnt | grep PID | awk -F '[:]' '{print $NF}' | xargs kill -9
        mlu_cnt=$((mlu_cnt + 1))
    fi
done