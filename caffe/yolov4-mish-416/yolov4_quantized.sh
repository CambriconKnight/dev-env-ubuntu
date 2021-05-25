#!/bin/bash
# 模型量化
# Usage:
#    $ bash yolov4_quantized.sh

#1.生成图片列表 yolov4_file_list_coco
cd ${PATH_NETWORK}
/home/share/tools/getFileList.sh ${PATH_NETWORK}/datasets yolov4_file_list_coco
#2.generate_quantized_pt：/opt/cambricon/caffe/tools/generate_quantized_pt
cd ${PATH_NETWORK}
/opt/cambricon/caffe/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov4_quantized.ini
ls -la ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov4_quantized.ini -blobs_dtype INT16 -top_dtype FLOAT32 -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int16.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -blobs_dtype INT8 \
#    -ini_file ${PATH_NETWORK}/yolov4_quantized.ini \
#    -mode common \
#    -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.prototxt \
#    -weights ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel \
#    -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt \
#    -top_dtype FLOAT16