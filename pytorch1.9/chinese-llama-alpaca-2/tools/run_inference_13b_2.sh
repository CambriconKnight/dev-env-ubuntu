#!/bin/bash
set -ex
#set -e
# -------------------------------------------------------------------------------
# Filename:     run_inference_13b_2.sh
# UpdateDate:   2023/10/14
# Description:  推理脚本
# Example:      ./run_inference_13b_2.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
# fp16
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7

#微调+Merge后的模型
model_path=${chinese_alpaca_2_model_train_done_13b}
#model_path=/workspace/chinese-llama-alpaca-2/models/chinese_alpaca_2_model_train_done_13b

cd ../scripts/inference/
python gradio_demo.py --base_model ${model_path} --gpus 0,1
# --gpu自动分配，根据：scripts/inference/mlu_load_model.py 中配置的单卡最大内存容量 mlu_memory = "18GiB"

cd -
