#!/bin/bash
set -ex
#set -e
# -------------------------------------------------------------------------------
# Filename:     run_mlu_eval.sh
# UpdateDate:   2023/10/14
# Description:  精度评测脚本
# Example:      ./run_mlu_eval.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
set -ex
# 请注意 7b模型指定1芯即可 7b以上模型需要指定2芯.，13b测试需要2卡，目前测试还有问题。
export MLU_VISIBLE_DEVICES=0,1
pushd ../scripts/ceval

# 官方模型
model_path=${chinese_alpaca_2_model_to_train_13b}
# 训练后模型
#model_path=${chinese_alpaca_2_model_train_done_13b}

python eval.py \
    --model_path ${model_path} \
    --cot False \
    --few_shot False \
    --with_prompt True \
    --constrained_decoding True \
    --temperature 0.2 \
    --n_times 1 \
    --ntrain 5 \
    --do_save_csv False \
    --do_test False \
    --output_dir ${eval_output}
popd


