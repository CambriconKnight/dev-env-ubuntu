
<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.9/chinese-llama-alpaca-2">
        <img alt="chinese-llama-alpaca-2" src="./res/chinese-llama-alpaca-2.gif" height="140" />
        <h1 align="center">Chinese-LLaMA-Alpaca-2模型验证教程</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

[TOC]

# 1. 环境准备

[中文LLaMA&Alpaca大模型2](https://github.com/ymcui/Chinese-LLaMA-Alpaca-2)是基于Meta发布的可商用大模型[Llama-2](https://github.com/facebookresearch/llama)开发，是[中文LLaMA&Alpaca大模型](https://github.com/ymcui/Chinese-LLaMA-Alpaca)的第二期项目，开源了**中文LLaMA-2基座模型和Alpaca-2指令精调大模型**。这些模型**在原版Llama-2的基础上扩充并优化了中文词表**，使用了大规模中文数据进行增量预训练，进一步提升了中文基础语义和指令理解能力，相比一代相关模型获得了显著性能提升。相关模型**支持FlashAttention-2训练**。标准版模型支持4K上下文长度，**长上下文版模型支持16K上下文长度**，并可通过NTK方法最高扩展至24K+上下文长度。

## 1.1. 硬件环境

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 服务器         | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-X8     | 8卡       | X8需使用板卡自带的8pin连接器连接主板电源 |

## 1.2. 软件环境

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| Linux OS              | Ubuntu18.04/Ubuntu20.04/CentOS7                          | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz         | 官方发布的 Pytorch 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.13-1.x86_64.rpm	       | 依实际服务器操作系统版本选择             |
| DeepSpeed             | cndsp-0.8.0-py3-none-any.whl                             | Cambricon DeepSpeed                 |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| Chinese-LLaMA-Alpaca-2 官网源码 | https://github.com/ymcui/Chinese-LLaMA-Alpaca-2          | commit：84b4c3ef3689c3ef76016895ccaa1b28c56ef6a4 |
| Chinese-LLaMA-Alpaca-2 适配链接 | https://gitee.com/xiaoqi25478/Chinese-LLaMA-Alpaca-2_mlu  | MLU 源码                         |
| Transformers 适配链接  | https://gitee.com/xiaoqi25478/open-codes-mlu.git           | 原始链接版本：v4.30.0                          |
| Peft 适配链接          | https://gitee.com/xiaoqi25478/open-codes-mlu.git                    | 原始链接版本：v0.3.0                          |
| Accelerate 适配链接    | https://gitee.com/xiaoqi25478/open-codes-mlu.git              | 原始链接版本：v0.20.3                          |
| 中文LLaMA-2基座7B模型   | https://huggingface.co/ziqingyang/chinese-llama-2-7b  | 可关注微信公众号 【 AIKnight 】, 发送关键字 **中文LLaMA-2基座7B模型** 自动获取。|
| 中文Alpaca-2聊天7B模型 | https://huggingface.co/ziqingyang/chinese-alpaca-2-7b  | 可关注微信公众号 【 AIKnight 】, 发送关键字 **中文Alpaca-2聊天7B模型** 自动获取。|
| 中文LLaMA-2基座13B模型 | https://huggingface.co/ziqingyang/chinese-llama-2-13b  | 可关注微信公众号 【 AIKnight 】, 发送关键字 **中文LLaMA-2基座13B模型** 自动获取。|
| 中文Alpaca-2聊天13B模型 | https://huggingface.co/ziqingyang/chinese-alpaca-2-13b  | 可关注微信公众号 【 AIKnight 】, 发送关键字 **中文Alpaca-2聊天13B模型** 自动获取。|

*注：以下步骤以Alpaca-2聊天13B模型为例，其他模型操作类似。*

**下载地址:**
- 前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载， 也可在官方提供的专属FTP账户指定路径下载。
- 文档: https://developer.cambricon.com/index/document/index/classid/3.html
- SDK: https://sdk.cambricon.com/download?component_name=PyTorch
- 完整模型下载: https://github.com/ymcui/Chinese-LLaMA-Alpaca-2#完整模型下载

**AIKnight公众号**
>![](../../res/aiknight_wechat_344.jpg)

## 1.3. 下载仓库
```bash
#进入裸机工作目录，以【/data/github】工作目录为例
cd /data/github
#下载仓库
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
```
## 1.4. 加载镜像

请提前下载好【Docker镜像】，方便以下操作加载使用。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
#下载Docker镜像后，可以mv到当前docker目录
#加载Docker镜像
#./load-image-dev.sh ./docker/pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz
sudo ./load-image-dev.sh ${FULLNAME_IMAGES}
#加载打包好验证环境的Docker镜像
#./load-image-dev.sh ./docker/pytorch-v1.15.0-torch1.9-ubuntu18.04-py37-CLA2.tar.gz
```

## 1.5. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
#启动Docker容器
sudo ./run-container-dev.sh
```

# 2. 代码适配

详见相关 [文档中心](https://developer.cambricon.com/index/document/index/classid/3.html) 适配手册：
[寒武纪 PyTorch v1.9网络移植手册](https://www.cambricon.com/docs/sdk_1.13.0/cambricon_pytorch_1.15.0/porting_1.9/index.html)
[寒武纪 PyTorch v1.6⽹络移植⼿册](https://www.cambricon.com/docs/sdk_1.13.0/cambricon_pytorch_1.15.0/porting_1.6/index.html)

# 3. 模型验证
## 3.1. 环境搭建

执行一键自动化环境部署脚本即可完成基础环境搭建。

```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/
./deploy_env.sh
#bash deploy_env.sh
# 激活环境变量
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu
# 激活环境变量，请注意下载模型，并根据实际环境，修改模型路径。
source env.sh
```
以下是完整版Chinese-Alpaca-2-13B模型，直接下载即可使用，无需其他合并步骤。推荐网络带宽充足的用户。下载完成后放置到此目录【/data/models/chinese-alpaca-2-13b】，方便后续一键自动化环境部署脚本执行。

| 模型名称                  |   类型   | 大小 |                    下载地址                    |
| :------------------------ | :------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| Chinese-Alpaca-2-13B | 指令模型 | 24.7 GB | [[百度]](https://pan.baidu.com/s/1MT_Zlap1OtdYMgoBNTS3dg?pwd=9xja) [[Google]](https://drive.google.com/drive/folders/1MTsKlzR61xmbTR4hBWzQas_MOpUZsogN?usp=share_link) [[🤗HF]](https://huggingface.co/ziqingyang/chinese-alpaca-2-13b) |

## 3.2. 模型推理
## 3.2.1. 推理验证
```bash
# gradio 推理对话
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
# model_path=/workspace/chinese-llama-alpaca-2/models/chinese-alpaca-2-13b
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_inference_13b.sh ./
bash run_inference_13b.sh
```

**Web展示效果**
<p align="left">
    <img alt="aiknight_cla2_inference_web" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.9/chinese-llama-alpaca-2/res/aiknight_cla2_inference_web.gif" width="640" />
</p>

**推理期间MLU资源占用情况**
<p align="left">
    <img alt="aiknight_cla2_inference_web_cnmon" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.9/chinese-llama-alpaca-2/res/aiknight_cla2_inference_web_cnmon.gif" width="640" />
</p>

## 3.2.2. 精度验证
```bash
# 跑精度, 13b测试需要2卡。
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_mlu_eval.sh ./
bash run_mlu_eval.sh
#查看精度结果
cat ${eval_output}/take0/summary.json
```

## 3.3. 指令精调
### 3.3.1. 微调训练
训练代码参考了[Stanford Alpaca](https://github.com/tatsu-lab/stanford_alpaca)项目中数据集处理的相关部分，使用方法见[📖指令精调脚本Wiki](https://github.com/ymcui/Chinese-LLaMA-Alpaca-2/wiki/sft_scripts_zh)
```bash
# 微调训练
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_finetuning_13b.sh ./
bash run_finetuning_13b.sh
#ls -lh ${train_output_finetuning_13b}
ls -lh ${train_output_finetuning_13b}/checkpoint-*/pytorch_model.bin
```

**训练期间MLU资源占用情况**
<p align="left">
    <img alt="aiknight_cla2_cnmon" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.9/chinese-llama-alpaca-2/res/aiknight_cla2_cnmon.gif" width="640" />
</p>

### 3.3.2. 模型合并

```bash
# 合并lore权重：微调后的模型+sample_lora_13b，merge后生成的模型。
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/merge_trainmodel_13b.sh ./
bash merge_trainmodel_13b.sh
ls -lh ${chinese_alpaca_2_model_train_done_13b}
```

### 3.3.3. 推理验证

微调训练后推理验证与之前推理流程类似，注意确认对应模型位置。以下推理脚本已经修改为微调+Merge后的模型位置了，直接运行推理即可验证。
```bash
# gradio 推理对话
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_inference_13b_2.sh ./
bash run_inference_13b_2.sh
```

### 3.3.4. 精度验证
```bash
# 跑精度, 13b测试需要2卡
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_mlu_eval_2.sh ./
bash run_mlu_eval_2.sh
#查看精度结果
cat ${eval_output}/take0/summary.json
```


## 3.4. 预训练
### 3.4.1. LoRA预训练
训练代码参考了🤗transformers中的[run_clm.py](https://github.com/huggingface/transformers/blob/main/examples/pytorch/language-modeling/run_clm.py)，使用方法见[📖预训练脚本Wiki](https://github.com/ymcui/Chinese-LLaMA-Alpaca-2/wiki/pt_scripts_zh)
```bash
# LoRA预训练
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_pretraining_13b.sh ./
bash run_pretraining_13b.sh
#ls -lh ${train_output_pretraining_13b}
ls -lh ${train_output_pretraining_13b}/checkpoint-*/pytorch_model.bin
```

**训练期间MLU资源占用情况**
<p align="left">
    <img alt="aiknight_cla2_cnmon" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.9/chinese-llama-alpaca-2/res/aiknight_cla2_cnmon.gif" width="640" />
</p>

### 3.3.2. 模型合并

```bash
# 合并lore权重：微调后的模型+sample_lora_13b，merge后生成的模型。
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/merge_pretrain_model_13b.sh ./
bash merge_pretrain_model_13b.sh
ls -lh ${chinese_alpaca_2_model_pretrain_done_13b}
```

### 3.3.3. 推理验证

预训练后推理验证与之前推理流程类似，注意确认对应模型位置。以下推理脚本已经修改为预训练+Merge后的模型位置了，直接运行推理即可验证。
```bash
# gradio 推理对话
cd /workspace/chinese-llama-alpaca-2/Chinese-LLaMA-Alpaca-2_mlu/cambricon
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_inference_13b_2_pretrain.sh ./
bash run_inference_13b_2_pretrain.sh
```

### 3.3.4. 精度验证
```bash
# 跑精度, 13b测试需要2卡
cp -rvf /home/share/pytorch1.9/chinese-llama-alpaca-2/tools/run_mlu_eval_2_pretrain.sh ./
bash run_mlu_eval_2_pretrain.sh
#查看精度结果
cat ${eval_output_pretrain}/take0/summary.json
```
