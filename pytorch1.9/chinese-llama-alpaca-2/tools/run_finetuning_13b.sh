#!/bin/bash
set -x
#set -e
# -------------------------------------------------------------------------------
# Filename:     run_finetuning_13b.sh
# UpdateDate:   2023/10/14
# Description:  用于微调的训练脚本
# Example:      ./run_finetuning_13b.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------

pretrain_model=${chinese_alpaca_2_model_to_train_13b}
final_model=${chinese_alpcae_2_model_train_done_13b}
train_epochs=10

# 启动训练脚本
echo "Cambricon Running STEP2_TRAIN_MODEL......"
if [ -d "${train_output}" ];then
    echo "delete old train_output folder"
    rm -rvf ${train_output}
fi
# 超参数设置
lr=1e-4
lora_rank=64
lora_alpha=128
lora_trainable="q_proj,v_proj,k_proj,o_proj,gate_proj,down_proj,up_proj"
modules_to_save="embed_tokens,lm_head"
lora_dropout=0.05
pretrained_model=${pretrain_model}
chinese_tokenizer_path=${pretrain_model}
dataset_dir=${DATASETS_DIR}
per_device_train_batch_size=16
per_device_eval_batch_size=1
gradient_accumulation_steps=1
preprocessing_num_workers=16
output_dir=${train_output}
validation_file=${VAILDATION_FILE}
deepspeed_config_file=ds_zero3_no_offload.json

export CNCL_MLULINK_DISABLE=1
#配置训练用到的卡
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
#
DEVICES_NUMS=$(echo $MLU_VISIBLE_DEVICES | awk -F "," '{print NF}')
PORT=${PORT:-29501}
MASTER_ADDR=${MASTER_ADDR:-"127.0.0.1"}
# 启动训练
pushd ../scripts/training/
python -m torch.distributed.launch \
        --master_addr=$MASTER_ADDR \
        --nproc_per_node=$DEVICES_NUMS \
        --master_port=$PORT \
    run_clm_sft_with_peft.py \
        --deepspeed ${deepspeed_config_file} \
        --model_name_or_path ${pretrained_model} \
        --tokenizer_name_or_path ${chinese_tokenizer_path} \
        --dataset_dir ${dataset_dir} \
        --validation_split_percentage 0.001 \
        --per_device_train_batch_size ${per_device_train_batch_size} \
        --per_device_eval_batch_size ${per_device_eval_batch_size} \
        --do_train \
        --do_eval \
        --seed $RANDOM \
        --fp16 \
        --num_train_epochs ${train_epochs} \
        --lr_scheduler_type cosine \
        --learning_rate ${lr} \
        --warmup_ratio 0.03 \
        --weight_decay 0 \
        --logging_strategy steps \
        --logging_steps 1 \
        --save_strategy epoch \
        --save_total_limit 1 \
        --evaluation_strategy no \
        --eval_steps 100 \
        --save_steps 1 \
        --gradient_accumulation_steps ${gradient_accumulation_steps} \
        --preprocessing_num_workers ${preprocessing_num_workers} \
        --max_seq_length 1024 \
        --output_dir ${output_dir} \
        --overwrite_output_dir \
        --ddp_timeout 30000 \
        --logging_first_step True \
        --lora_alpha ${lora_alpha} \
        --gradient_checkpointing \
        --trainable ${lora_trainable} \
        --lora_dropout ${lora_dropout} \
        --torch_dtype float16 \
        --lora_rank ${lora_rank} \
        --modules_to_save ${modules_to_save} \
        --validation_file ${validation_file} \
        --ddp_find_unused_parameters False \
        --zero3_enabled True
popd
