#!/bin/bash
# 基于SDK-Demo 离线推理
#/opt/cambricon/caffe/src/caffe/build/examples/yolo_v3/yolov3_offline_multicore
# Usage:
#    $ bash yolov3_offline_multicore.sh

#设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
#PATH_NETWORK="/home/share/yolov3-416"
#PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
#PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"

PATH_TEST_NETWORK="${PATH_NETWORK}/test/yolov3_offline_multicore"
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
#基于SDK-Demo 离线推理
/opt/cambricon/caffe/src/caffe/build/examples/yolo_v3/yolov3_offline_multicore \
    -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov3_1b4c_simple.cambricon \
    -labels ${PATH_NETWORK}/label_map_coco.txt \
    -images ${PATH_NETWORK}/yolov3_file_list_coco \
    -preprocess_option 4
#ls -la ${PATH_TEST_NETWORK}
echo "PATH_TEST_NETWORK: ${PATH_TEST_NETWORK}"