#!/bin/bash
#set -x
# MM Benchmark env
export TEST_SUITES=${CURRENT_PATH}/testsuites
export NEUWARE_HOME=/usr/local/neuware/
export MODEL_PATH=/data/models/test_models/
export DATASET_PATH=/data/datasets
export DEVICE_NAME="mlu370_S4"
export DEVICE_ID=0
DEVICE_NAME_GET=$(cnmon info -c "${DEVICE_ID}" -t | grep "Product Name"| awk -F ': ' '{print $2}')
if [ -n "$DEVICE_NAME_GET" ];then
    if  [ $DEVICE_NAME_GET = "MLU370-S4" ] ; then
        export DEVICE_NAME="mlu370_S4"
    elif [ $DEVICE_NAME_GET = "MLU370-X4" ]  ; then
        export DEVICE_NAME="mlu370_X4"
    elif [ $DEVICE_NAME_GET = "MLU370-X8" ] ; then
        export DEVICE_NAME="mlu370_X8"
    fi
fi

export MM_CPP_MIN_LOG_LEVEL=3
export CNNL_MIN_LOG_LEVEL=3

#echo "CURRENT_PATH:${CURRENT_PATH}"
#echo "MODEL_PATH:${MODEL_PATH}"
#echo "DATASET_PATH:${DATASET_PATH}"
#echo "DEVICE_NAME:${DEVICE_NAME}"
#echo "NEUWARE_HOME:${NEUWARE_HOME}"
