#!/bin/bash
set -ex
#set -e
# -------------------------------------------------------------------------------
# Filename:     deploy_env.sh
# UpdateDate:   2023/12/12
# Description:  一键搭建验证环境
# Example:      ./deploy_env.sh
# Depends:
# Notes:
# -------------------------------------------------------------------------------

# 3.1. 安装依赖库
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

# 3.2. 下载代码
# 进到容器后，切换到工作目录
mkdir -p /workspace/chatglm3 && cd /workspace/chatglm3
# 1. 下载 transformers 源码: 基于 transformer 模型结构提供的预训练语言库
git clone -b v4.30.2 https://github.com/huggingface/transformers
# 2. 下载 ChatGLM3 源码
git clone https://github.com/THUDM/ChatGLM3 && cd ChatGLM3 && git checkout 35f21dda9f567 && cd -

# 3.3. 模型下载
mkdir -p /workspace/chatglm3/models && cd /workspace/chatglm3/models
#GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/ziqingyang/chinese-alpaca-2-13b
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/THUDM/chatglm3-6b && cd chatglm3-6b && git checkout e46a14881eae && cd -
cp -rvf /data/models/llm/chatglm3-6b /workspace/chatglm3/models/
#显示模型列表
ls -la /workspace/chatglm3/models/chatglm3-6b

# 3.4. 代码适配
# 1. 修改transformers
cd /workspace/chatglm3
python /torch/src/catch/tools/torch_gpu2mlu/torch_gpu2mlu.py -i transformers/
cd transformers_mlu && pip install -e . && cd -
# 2. 修改ChatGLM3
python /torch/src/catch/tools/torch_gpu2mlu/torch_gpu2mlu.py -i ChatGLM3/
cd ChatGLM3_mlu
sed -i 's/torch/# torch/' requirements.txt
sed -i 's/transformers/# transformer/' requirements.txt
pip install -r requirements.txt
cd -

# 3.5. 修改模型文件
# 进入工作目录，拷贝修改后的代码到【chatglm3-6b】目录。
cp -rvf /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm-bk-e46a14881eae.py
cp -rvf /home/share/pytorch1.13/chatglm3/tools/modeling_chatglm_mlu_infer.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py
#cp -rvf /home/share/pytorch1.13/chatglm3/tools/modeling_chatglm_mlu_training.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py



##使用 pip 安装 streamlit sentencepiece gradio, 如果出现类似报错【ERROR: Could not install packages due to an OSError: 】，可尝试一个一个安装。
##pip install streamlit sse-starlette mdtex2html sentencepiece gradio
#pip install mdtex2html
#pip install sentencepiece
## gradio安装时间长，耐心等待。
#pip install gradio
#pip install streamlit

