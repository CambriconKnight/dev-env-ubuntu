#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     aligntorch.sh
# UpdateDate:   2022/03/23
# Description:  align torch version for yolov5 .
# Example:      ./aligntorch.sh
# Depends:      >= pytorch 1.8
#               YOLOv5(git clone https://github.com/ultralytics/yolov5 -b v5.0)
#               dev-env-ubuntu(https://github.com/CambriconKnight/dev-env-ubuntu)
# Notes:
# -------------------------------------------------------------------------------
#################### main ####################
WEIGHTS_DIR=$PWD/weights			#原始模型存放路径
OUTPUT_DIR=$PWD/output				#输出模型存放路径
MODDEL_NAME_ORG=yolov5s.pt			#需要转换模型名称,如果是使用自己训练的模型，需要将模型放到weights目录，并修改MODDEL_NAME_ORG宏定义
MODDEL_NAME_OUT=yolov5s.pth			#转换后的模型

# 0.Check param
#weights
if [ ! -d "$WEIGHTS_DIR" ] ; then
	mkdir -p $WEIGHTS_DIR
	echo "Create $WEIGHTS_DIR OK !"
else
	echo "Directory ($WEIGHTS_DIR): Exist!"
fi
#output
if [ ! -d "$OUTPUT_DIR" ] ; then
	mkdir -p $OUTPUT_DIR
	echo "Create $OUTPUT_DIR OK !"
else
	echo "Directory ($OUTPUT_DIR): Exist!"
fi
#Download yolov5
./tools/download-yolov5.sh
#Download yolov5-weights
if [ ! -f "$WEIGHTS_DIR/$MODDEL_NAME_ORG" ] ; then
	echo "Model file ($WEIGHTS_DIR/$MODDEL_NAME_ORG) not exist, pleas download it or copy !"
    pushd $WEIGHTS_DIR
    ./download-yolov5-weights.sh
    popd
fi

#1. Run
cp -rvf ./tools/aligntorch.py ./yolov5/
python ./yolov5/aligntorch.py --weights "$WEIGHTS_DIR/$MODDEL_NAME_ORG" --output "$OUTPUT_DIR/$MODDEL_NAME_OUT"

#2. Result
ls -lh $OUTPUT_DIR/$MODDEL_NAME_OUT
rm -rf ./yolov5/aligntorch.py
echo "Align Torch finish !"
