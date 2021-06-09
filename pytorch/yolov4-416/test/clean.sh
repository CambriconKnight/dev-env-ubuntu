#!/bin/bash
set -e

#clean test
for dir in $(ls)
do
    if [ -d "./${dir}" ]; then  #先判断是否是目录，然后再执行clean
        echo $dir && cd $dir && ./clean.sh && cd -
    fi
done