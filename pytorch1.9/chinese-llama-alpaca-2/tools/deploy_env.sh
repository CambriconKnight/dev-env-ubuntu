#!/bin/bash
set -ex
#set -e
# -------------------------------------------------------------------------------
# Filename:     deploy_env.sh
# UpdateDate:   2023/10/14
# Description:  一键搭建验证环境
# Example:      ./deploy_env.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------

# 3.1. 下载适配代码
# 创建工作目录
mkdir -p /workspace/chinese-llama-alpaca-2
# 进到容器后，切换到工作目录
#cd /home/share/pytorch1.9/chinese-llama-alpaca-2
cd /workspace/chinese-llama-alpaca-2
# 1. 下载 chinese-llama-alpaca-2-13B 源码
git clone https://gitee.com/xiaoqi25478/Chinese-LLaMA-Alpaca-2_mlu.git
# 2. 下载适配后的依赖库源码 accelerate_mlu、transformers_mlu、peft_mlu
git clone https://gitee.com/xiaoqi25478/open-codes-mlu.git

# 3.2. 安装依赖库
# **安装第三方依赖库**
apt-get update
# 安装 Git LFS，实现 Git 对大文件的支持
apt-get install git-lfs
#yum install git-lfs
# Silence all safe.directory warnings
git config --global --add safe.directory '*'
# 执行如下命令后，如果显示Git LFS initialized说明安装成功
git lfs install
# 升级numpy版本
pip install numpy --upgrade
# 安装 gradio
#pip install gradio

# **安装MLU适配后的代码依赖库**
# 安装 accelerate 依赖库
cd /workspace/chinese-llama-alpaca-2/open-codes-mlu/accelerate_0.20.3_mlu
pip install -e .
# 安装 transformers 依赖库
#cd /workspace/chinese-llama-alpaca-2/open-codes-mlu/transformers_4.30.0_mlu
cd /workspace/chinese-llama-alpaca-2/open-codes-mlu/transformers_4.30.0_llama_mlu
pip install -e .
# 安装 peft 依赖库
cd /workspace/chinese-llama-alpaca-2/open-codes-mlu/peft_0.3.0.dev0_mlu
pip install -e .
# 安装 cndsp(Cambricon DeepSpeed）
cd /workspace/chinese-llama-alpaca-2
wget https://sdk.cambricon.com/static/Basis/MLU370_X86_ubuntu18.04/cndsp-0.8.0-py3-none-any.whl
pip install cndsp-0.8.0-py3-none-any.whl
# 安装 Chinese-LLaMA-Alpaca-2 依赖库
#cd /home/share/pytorch1.9/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu
pip install -r requirements.txt

# 3.3. 模型下载
mkdir -p /workspace/chinese-llama-alpaca-2/models
cd /workspace/chinese-llama-alpaca-2/models
#GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/ziqingyang/chinese-alpaca-2-13b
cp -rvf /data/models/chinese-alpaca-2-13b /workspace/chinese-llama-alpaca-2/models/chinese_alpaca_2_model_to_train_13b

# 3.4. 激活环境变量
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu
# 激活环境变量，请注意下载模型，并根据实际环境，修改模型路径。
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/env.sh ./
source env.sh