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
# 0.Check param
#1. cpu 推理
python3 convertmodel.py --arg cpu

#2. 模型量化
python3 convertmodel.py --arg quant

#3. mlu融合推理及生成离线模型
python3 convertmodel.py --arg mfus --genoff true

#2.result
echo "======== convert model finish ! ======== "
