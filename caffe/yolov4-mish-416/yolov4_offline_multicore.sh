#!/bin/bash
# 基于SDK-Demo 离线推理
#/opt/cambricon/caffe/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore
# Usage:
#    $ bash yolov4_offline_multicore.sh

#设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
#export PATH_NETWORK="/home/share/caffe/yolov4-mish-416"
#export PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
#export PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"

#基于SDK-Demo 离线推理
PATH_TEST_NETWORK=${PATH_NETWORK}/test/yolov4_offline_multicore
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
#yolov4_1b4c_simple
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore \
    -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov4_1b4c_simple.cambricon \
    -labels ${PATH_NETWORK}/label_map_coco.txt \
    -images ${PATH_NETWORK}/yolov4_file_list_coco \
    -preprocess_option 4 \
    -outputdir . \
    -simple_compile 1 \
    -dump 1
#yolov4_4b4c_simple
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore \
    -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov4_4b4c_simple.cambricon \
    -labels ${PATH_NETWORK}/label_map_coco.txt \
    -images ${PATH_NETWORK}/yolov4_file_list_coco \
    -preprocess_option 4 \
    -outputdir . \
    -simple_compile 1 \
    -dump 1