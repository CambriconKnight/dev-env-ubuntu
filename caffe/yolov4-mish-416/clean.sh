#!/bin/bash
set -e
# 清理临时生成的文件
# Usage:
#    $ bash clean.sh all/test/models

usage()
{
    echo "Usage:"
    echo "  $0 all/test/models"
}

clean_all() {
    #clean test
    cd ./test
    ./clean.sh
    cd -

    #clean models
    rm -vf ./models/mlu/*
    rm -vf ./models/*.weights
}

if [[ $# -eq 0 ]];then
    usage
elif [[ $# -eq 1 ]];then
    if [[ "$1" == "all" ]];then
        #clean all
        clean_all
    elif [[ "$1" == "test" ]];then
        #clean test
        cd ./test && ./clean.sh && cd -
    elif [[ "$1" == "models" ]];then
        #clean models
        rm -vrf ./models/mlu/* && rm -vrf ./models/*.weights
    else
        usage
    fi
else
    usage
fi

