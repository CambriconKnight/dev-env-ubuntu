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
mkdir -p /workspace/chatglm2 && cd /workspace/chatglm2
# 1. 下载 transformers 源码: 基于 transformer 模型结构提供的预训练语言库
git clone -b v4.30.2 https://github.com/huggingface/transformers
# 2. 下载 chatglm2-6b 源码
git clone https://github.com/THUDM/ChatGLM2-6B
cd ChatGLM2-6B && git checkout 3d0225f969d56c058f052f6800a21630d14a1184 && cd -

# 3.3. 模型下载
mkdir -p /workspace/chatglm2/models
cd /workspace/chatglm2/models
#GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/ziqingyang/chinese-alpaca-2-13b
cp -rvf /data/models/chatglm2/chatglm2-6b /workspace/chatglm2/models/
#显示模型列表
ls -la /workspace/chatglm2/models/chatglm2-6b

# 3.4. 模型适配
cd /workspace/chatglm2
#建立软连接
ln -s /torch/src/catch/tools/torch_gpu2mlu.py ./
#执行转换模型脚本, 自动修改 transformers 源码
python torch_gpu2mlu.py -i transformers
#执行转换模型脚本, 自动修改  ChatGLM2-6B 源码
python torch_gpu2mlu.py -i ChatGLM2-6B
#显示转换后的代码。
#ls -lh transformers transformers_mlu ChatGLM2-6B ChatGLM2-6B_mlu
ls -la

#由于 chatglm2-6b 要求使用 torch >=1.10，其中有 pytorch 不支持的特性包括如下。需要在【自动迁移代码】基础上再进行如下修改。
#进入工作目录，拷贝修改后的代码到【chatglm2-6b】目录。
# 进入工作目录  /home/share/pytorch1.9/chatglm2/tools/modeling_chatglm.py
cd /workspace/chatglm2/models
cp -rvf /home/share/pytorch1.9/chatglm2/tools/modeling_chatglm.py /workspace/chatglm2/models/chatglm2-6b

# 3.5. 安装依赖库
# 安装 transformers
cd /workspace/chatglm2/transformers_mlu/
pip install -e .

# 安装 ChatGLM2-6B 依赖库
cd /workspace/chatglm2/ChatGLM2-6B_mlu
sed -i 's/torch/# torch/' requirements.txt
sed -i 's/transformers/# transformer/' requirements.txt
#安装>=1.24.0版本会失败，当前环境下默认安装streamlit的话是安装streamlit-1.23.1-py2.py3-none-any.whl版本
sed -i 's/streamlit>=1.24.0/# streamlit>=1.24.0/' requirements.txt
pip install -r requirements.txt

#使用 pip 安装 streamlit sentencepiece gradio, 如果出现类似报错【ERROR: Could not install packages due to an OSError: 】，可尝试一个一个安装。
#pip install streamlit sse-starlette mdtex2html sentencepiece gradio
pip install mdtex2html
pip install sentencepiece
# gradio安装时间长，耐心等待。
pip install gradio
pip install streamlit

