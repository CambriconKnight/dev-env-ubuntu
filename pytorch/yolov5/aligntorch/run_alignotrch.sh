#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run_aligntorch.sh
# UpdateDate:   2021/09/24
# Description:  align torch version for cambricon .
# Example:      ./run_alignotrch.sh
# Depends:      >= pytorch 1.8
# Notes:
# -------------------------------------------------------------------------------
#################### main ####################

WEIGHTS_DIR=$PWD/weights			#原始模型存放路径
OUTPUT_DIR=$PWD/output				#输出模型存放路径
MODDEL_NAME_ORG=yolov5s.pt			#需要转换模型名称,如果是使用自己训练的模型，需要将模型放到weights目录，并修改MODDEL_NAME_ORG宏定义
MODDEL_NAME_OUT=yolov5s.pth			#转换后的模型

# 0.Check param
if [ ! -d "$WEIGHTS_DIR" ] ; then
	mkdir -p $WEIGHTS_DIR
	echo "Create $WEIGHTS_DIR ok !"
else
	echo "Directory ($WEIGHTS_DIR): Exist!"
fi

if [ ! -d "$OUTPUT_DIR" ] ; then
	mkdir -p $OUTPUT_DIR
	echo "Create $OUTPUT_DIR ok !"
else
	echo "Directory ($OUTPUT_DIR): Exist!"
fi

if [ ! -f "$WEIGHTS_DIR/$MODDEL_NAME_ORG" ] ; then
	echo "Model file ($WEIGHTS_DIR/$MODDEL_NAME_ORG) not exist, pleas download it or copy !"
fi

#1. run
python aligntorch.py --weights "$WEIGHTS_DIR/$MODDEL_NAME_ORG" --output "$OUTPUT_DIR/$MODDEL_NAME_OUT"
ls -la $OUTPUT_DIR/$MODDEL_NAME_OUT

#2.result
echo "align torch finish !"
