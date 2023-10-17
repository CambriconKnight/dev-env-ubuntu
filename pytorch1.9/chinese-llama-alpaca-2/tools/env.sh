# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.0.0
# Date:        2023/10/13
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
# 项目根路径
export ROOT_PATH=`pwd`
#####################################
# 模型根目录
#export Model_DIR=/data/models
export Model_DIR=/workspace/chinese-llama-alpaca-2/models
# 13B
# 原版Llama-2-hf地址： https://huggingface.co/meta-llama/Llama-2-13b-hf
export Llama_2_13b_hf=${Model_DIR}/Llama-2-13b-hf
# LoRA指令模型(1.5 GB)： https://huggingface.co/ziqingyang/chinese-alpaca-2-lora-13b
export chinese_alpaca_2_lora_13b=${Model_DIR}/chinese-alpaca-2-lora-13b
# 合并后的预训练模型：预训练权重 需要将原版llama权重和中文alpca lora权重合并。
#export chinese_alpaca_2_model_to_train_13b=${Model_DIR}/chinese-alpaca-2-13b
# 聊天模型Chinese-Alpaca-2-13B地址： https://huggingface.co/ziqingyang/chinese-alpaca-2-13b
#cp -rvf /data/models/chinese-alpaca-2-13b ${Model_DIR}/chinese_alpaca_2_model_to_train_13b
export chinese_alpaca_2_model_to_train_13b=${Model_DIR}/chinese_alpaca_2_model_to_train_13b
# 经过微调并merge后的模型：微调后的模型+sample_lora_13b，merge后生成的模型。
export chinese_alpcae_2_model_train_done_13b=${Model_DIR}/chinese_alpcae_2_model_train_done_13b
#####################################
export train_output=/workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/train_output
export eval_output=/workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/eval_output
#####################################
# 数据集路径
export DATASETS_DIR=${ROOT_PATH}/data/drama
export DATASETS_TXT_DIR=${ROOT_PATH}/data/drama_txt_data
export VAILDATION_FILE=${DATASETS_DIR=$}/drama.json
echo "${ROOT_PATH}"
echo "${Model_DIR}"
echo "${train_output}"
echo "${eval_output}"


