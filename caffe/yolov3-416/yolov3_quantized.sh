#!/bin/bash
# 模型量化
# Usage:
#    $ bash yolov3_quantized.sh

#1.生成图片列表 yolov3_file_list_coco
/home/share/tools/getFileList.sh ${PATH_NETWORK}/datasets yolov3_file_list_coco
#2.generate_quantized_pt：/opt/cambricon/caffe/tools/generate_quantized_pt
cd ${PATH_NETWORK}
/opt/cambricon/caffe/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov3_quantized.ini
ls -la ${PATH_NETWORK_MODELS_MLU}/yolov3_int8.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov3_quantized.ini -blobs_dtype INT16 -top_dtype FLOAT32 -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov3_int16.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -blobs_dtype INT8 \
#    -ini_file ${PATH_NETWORK}/yolov3_quantized.ini \
#    -mode common \
#    -model ${PATH_NETWORK_MODELS_MLU}/yolov3.prototxt \
#    -weights ${PATH_NETWORK_MODELS_MLU}/yolov3.caffemodel \
#    -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov3_int8.prototxt \
#    -top_dtype FLOAT16