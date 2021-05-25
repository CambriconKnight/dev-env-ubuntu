#!/bin/bash
# 基于SDK-Demo 在线逐层推理 MFUS模式
#/opt/cambricon/caffe/src/caffe/build/examples/yolo_v4/yolov4_online_multicore
# Usage:
#    $ bash yolov4_online_multicore_mfus.sh

#设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
#export PATH_NETWORK="/home/share/caffe/yolov4-mish-416"
#export PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
#export PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"

#2、基于SDK-Demo 在线融合推理
#$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore
PATH_TEST_NETWORK=${PATH_NETWORK}/test/yolov4_online_multicore_mfus
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore \
    -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt \
    -weights ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel \
    -labels ${PATH_NETWORK}/label_map_coco.txt \
    -images ${PATH_NETWORK}/yolov4_file_list_coco \
    -mmode MFUS \
    -mcore MLU270 \
    -outputdir . \
    -output_dtype FLOAT16 \
    -preprocess_option 4 \
    -dump 1 \
    -simple_compile 1
#ls -la ${PATH_TEST_NETWORK}
echo "PATH_TEST_NETWORK: ${PATH_TEST_NETWORK}"
