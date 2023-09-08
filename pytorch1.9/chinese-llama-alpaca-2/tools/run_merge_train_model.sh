#!/bin/bash
set -x

echo "Cambricon Running STEP3_MERGE_TRAIN_MODEL......"
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon/sample_lora_13b /workspace/chinese-llama-alpaca-2/models/
cp -rvf /workspace/chinese-llama-alpaca-2/models/train_output/checkpoint-40/pytorch_model.bin /workspace/chinese-llama-alpaca-2/models/sample_lora_13b/adapter_model.bin
cd /home/share/pytorch1.9/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu
python scripts/merge_llama2_with_chinese_lora_low_mem.py \
    --base_model /workspace/chinese-llama-alpaca-2/models/chinese-alpaca-2-13b \
    --lora_model /workspace/chinese-llama-alpaca-2/models/sample_lora_13b \
    --output_type huggingface \
    --output_dir /workspace/chinese-llama-alpaca-2/models/chinese-alpaca-2-13b-lora-train-done

