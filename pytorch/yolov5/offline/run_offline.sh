#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run_offline.sh
# UpdateDate:   2021/09/29
# Description:  offline inference .
# Example:      ./run_offline.sh
# Depends:      >= pytorch 1.8
# Notes:
# -------------------------------------------------------------------------------
#################### main ####################

OUTPUT_DIR=$PWD/output		#推理输出结果存放路径
MODDEL_NAME=yolov5s_int8_4b_4c.cambricon		#离线模型名称

# 0.Check param
if [ ! -d "$OUTPUT_DIR" ] ; then
	mkdir -p $OUTPUT_DIR
	echo "Create $OUTPUT_DIR ok !"
else
	echo "Directory ($OUTPUT_DIR): Exist!"
fi

if [ ! -f "$MODDEL_NAME" ] ; then
	echo "Model file ($MODDEL_NAME) not exist, pleas download it or copy !"
	cp ../convertmodel/${MODDEL_NAME} ./
fi

#1.make
make clean
make

#2. run
./yolov5_offline ${MODDEL_NAME} ./image.jpg ./${OUTPUT_DIR}/offline_result.jpg
ls -la $OUTPUT_DIR/

#3.results
echo "offline test finish !"
