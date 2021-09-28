#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run_convertmodel.sh
# UpdateDate:   2021/09/24
# Description:  convert model to cambricon .
# Example:      ./run_convertmodel.sh
# Depends:       pytorch 1.3 docker 18.04
# Notes:
# -------------------------------------------------------------------------------
#################### main ####################

WEIGHTS_DIR=$PWD/weights			#原始模型存放路径
OUTPUT_DIR=$PWD/output				#输出模型存放路径
MODDEL_NAME_ORG=yolov5s.pth			#需要转换模型名称,如果是使用自己训练的模型，需要将模型放到weights目录，并修改MODDEL_NAME_ORG宏定义
MODDEL_NAME_OUT=yolov5s.pth			#转换后的模型

# 0.Check param
#1. cpu 推理
python3 convertmodel.py --arg cpu

#2. 模型量化
python3 convertmodel.py --arg quant

#3. mlu融合推理及生成离线模型
python3 convertmodel.py --arg mfus --genoff true

#2.result
echo "======== convert model finish ! ======== "
