# 项目根路径
export ROOT_PATH=`pwd`
#####################################
# 7B
export Llama_2_7b_hf=/data/AE/tangchuang/llama2/Llama-2-7b-hf/
export chinese_llama_lora_7b=/data/AE/xiaoqi/hf_models_of_chinese_llama_alpaca/chinese-llama-2-lora-7b
export chinese_alpaca_2_lora_7b=/data/AE/xiaoqi/hf_models_of_chinese_llama_alpaca/chinese-alpaca-2-lora-7b

export chinese_alpcae_2_model_train_done_7b=/workspace/chinese_alpcae_2_model_train_done_7b
export chinese_llama_2_model_train_done_7b=/workspace/chinese_llama_2_model_train_done_7b

export chinese_alpaca_2_model_to_train_7b=/workspace/chinese_alpaca_2_model_to_train_7b
export chinese_llama_2_model_to_train_7b=/workspace/chinese_llama_2_model_to_train_7b
#####################################
# 13B
# 原版Llama-2-hf地址： https://huggingface.co/meta-llama/Llama-2-13b-hf
export Llama_2_13b_hf=/data/AE/xiaoqi/Llama-2-13b-hf/
#export chinese_llama_lora_13b=/data/AE/xiaoqi/hf_models_of_chinese_llama_alpaca/chinese-llama-2-lora-13b
# LoRA指令模型(1.5 GB)： https://huggingface.co/ziqingyang/chinese-alpaca-2-lora-13b
export chinese_alpaca_2_lora_13b=/data/AE/xiaoqi/hf_models_of_chinese_llama_alpaca/chinese-alpaca-2-lora-13b


export chinese_alpaca_2_model_to_train_13b=/workspace/chinese_alpaca_2_model_to_train_13b


export chinese_alpcae_2_model_train_done_13b=/workspace/chinese_alpcae_2_model_train_done_13b
export chinese_llama_2_model_train_done_13b=/workspace/chinese_llama_2_model_train_done_13b

export chinese_llama_2_model_to_train_13b=/workspace/chinese_llama_2_model_to_train_13b

#####################################
# 数据集路径
export DATASETS_DIR=${ROOT_PATH}/data/drama
export DATASETS_TXT_DIR=${ROOT_PATH}/data/drama_txt_data
export VAILDATION_FILE=${DATASETS_DIR=$}/drama.json
echo "${ROOT_PATH}"


