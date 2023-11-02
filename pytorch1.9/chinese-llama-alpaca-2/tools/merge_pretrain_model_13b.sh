#!/bin/bash
set -x
#set -e
# -------------------------------------------------------------------------------
# Filename:     merge_pretrain_model_13b.sh
# UpdateDate:   2023/10/14
# Description:  合并lora权重 得到最终权重 用于推理。final_model == pretrain_model + train_output_pretraining_13b(sample_lora_pt_13b/adapter_model.bin)
# Example:      ./merge_pretrain_model_13b.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#export Model_DIR=/workspace/chinese-llama-alpaca-2/models
#export chinese_alpaca_2_model_pretrain_done_13b=${Model_DIR}/chinese_alpaca_2_model_pretrain_done_13b
pretrain_model=${chinese_alpaca_2_model_to_train_13b}
final_model=${chinese_alpaca_2_model_pretrain_done_13b}

# 合并lora权重 得到最终权重 用于推理
echo "Cambricon Running STEP3_MERGE_TRAIN_MODEL......"
checkpoints=`ls -l ${train_output_pretraining_13b} | awk '{print $9}' |  grep "checkpoint"`
#mv ${train_output_pretraining_13b}/${checkpoints}/pytorch_model.bin sample_lora_pt_13b/adapter_model.bin
mv ${train_output_pretraining_13b}/${checkpoints}/pytorch_model.bin sample_lora_13b/adapter_model.bin

echo "Debug INFO:mv done!"
pushd ../
python scripts/merge_llama_with_chinese_lora_low_mem.py \
    --base_model ${pretrain_model} \
    --lora_model cambricon/sample_lora_13b \
    --output_type huggingface \
    --output_dir ${final_model}
popd
