#!/bin/bash
# 基于SDK-Demo 在线逐层推理 MLU模式
#/opt/cambricon/caffe/src/caffe/build/examples/yolo_v3/yolov3_online_multicore
# Usage:
#    $ bash yolov3_online_multicore_mlu.sh

#设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
#PATH_NETWORK="/home/share/yolov3-416"
#PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
#PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"

PATH_TEST_NETWORK="${PATH_NETWORK}/test/yolov3_online_multicore_mlu"
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
#基于SDK-Demo 在线逐层推理
/opt/cambricon/caffe/src/caffe/build/examples/yolo_v3/yolov3_online_multicore \
    -model ${PATH_NETWORK_MODELS_MLU}/yolov3_int8.prototxt \
    -weights ${PATH_NETWORK_MODELS_MLU}/yolov3.caffemodel \
    -labels ${PATH_NETWORK}/label_map_coco.txt \
    -images ${PATH_NETWORK}/yolov3_file_list_coco \
    -mcore MLU270 \
    -mmode MLU \
    -preprocess_option 4
#ls -la ${PATH_TEST_NETWORK}
echo "PATH_TEST_NETWORK: ${PATH_TEST_NETWORK}"
