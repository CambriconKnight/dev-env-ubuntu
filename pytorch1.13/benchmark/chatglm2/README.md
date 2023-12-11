
<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.13/benchmark/chatglm2">
        <img alt="chatglm2-logo" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/benchmark/chatglm2/res/chatglm2-6b.jpg" height="140" />
        <h1 align="center">ChatGLM2模型验证教程</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

[TOC]

# 1. 环境准备

## 1.1. 硬件环境

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 服务器         | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-X8     | 8卡       | X8需使用板卡自带的8pin连接器连接主板电源 |

## 1.2. 软件环境

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| Linux OS              | CentOS7                                                  | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.17.0-torch1.13.1-ubuntu20.04-py310.tar.gz     | 官方发布的 Pytorch1.13 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.22-1.x86_64.rpm        | 依操作系统选择                         |
| DeepSpeed             | cndsp-0.8.0-py3-none-any.whl                             | Cambricon DeepSpeed                 |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| Benchmark             | /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B           | 基于官方发布的 Pytorch1.13 框架 Docker 镜像容器内Benchmark |
| ChatGLM2-6B 源码       | https://github.com/THUDM/ChatGLM2-6B  | commit： 3d0225f969d56c058f052f6800a21630d14a1184 |
| Transformers 源码      | https://github.com/huggingface/transformers  | v4.28.1                         |
| ChatGLM2-6B-32K 模型         | https://huggingface.co/THUDM/chatglm2-6b-32k/tree/455746d4706479a1cbbd07179db39eb2741dc692	  | 直接clone 速度慢，并且为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **chatglm2-6b-32k** 自动获取。|
| ChatGLM2-6B 训练数据    | AdvertiseGen.tar.gz  | [Google Drive](https://drive.google.com/file/d/13_vf0xRTQsyneRKdD1bZIr93vBGOczrk/view?usp=sharing) 或者 [Tsinghua Cloud](https://cloud.tsinghua.edu.cn/f/b3f119a008264b1cabd1/?dl=1) 也可关注微信公众号 【 AIKnight 】, 发送关键字 **AdvertiseGen** 自动获取。|

**下载地址:**
- 前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载， 也可在官方提供的专属FTP账户指定路径下载。
- 文档: https://developer.cambricon.com/index/document/index/classid/3.html
- SDK: https://sdk.cambricon.com/download?component_name=PyTorch

**AIKnight公众号**
>![](../../../res/aiknight_wechat_344.jpg)

## 1.3. 下载仓库
```bash
#进入裸机工作目录，以【/data/github】工作目录为例
cd /data/github
#下载仓库
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.13
```
## 1.4. 加载镜像

请提前下载好【Docker镜像】，方便以下操作加载使用。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.13
#下载Docker镜像后，可以mv到当前docker目录
#加载Docker镜像
#./load-image-dev.sh /data/kang/ftp/docker/pytorch-v1.17.0-torch1.13.1-ubuntu20.04-py310.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

## 1.5. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.13
#启动Docker容器
./run-container-dev.sh
```

# 2. 代码适配

详见相关 [文档中心](https://developer.cambricon.com/index/document/index/classid/3.html) 适配手册：
[寒武纪 PyTorch v1.13 用户手册](https://www.cambricon.com/docs/sdk_1.15.0/cambricon_pytorch_1.17.0/user_guide_1.13/index.html)

# 3. 模型验证

以下操作均在Docker容器中。

## 3.1. 数据准备

### 3.1.1. 模型下载

以下是ChatGLM2-6B-32K模型，直接下载即可使用。推荐网络带宽充足的用户。下载完成后放置到此目录【/data/models/llm/chatglm2-6b-32k】，方便后续一键自动化环境部署脚本执行。

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| ChatGLM2-6B-32K 模型         | https://huggingface.co/THUDM/chatglm2-6b-32k/tree/455746d4706479a1cbbd07179db39eb2741dc692	  | 直接clone 速度慢，并且为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **chatglm2-6b-32k** 自动获取。|

模型权重下载完成后，还需对chatglm2-6b-32k/modeling_chatglm.py 文件做一些简单适配。方便起见，以下直接用已适配后的文件替换 modeling_chatglm.py ，如需了解差异可自行 diff。
```bash
#比较差异，了解修改内容
vimdiff /home/share/pytorch1.13/benchmark/chatglm2/tools/modeling_chatglm.py /data/models/llm/chatglm2-6b-32k/modeling_chatglm.py
#直接拷贝覆盖
cp -rvf /home/share/pytorch1.13/benchmark/chatglm2/tools/modeling_chatglm.py /data/models/llm/chatglm2-6b-32k/modeling_chatglm.py
```

### 3.1.2. 训练数据下载

从 [Google Drive](https://drive.google.com/file/d/13_vf0xRTQsyneRKdD1bZIr93vBGOczrk/view?usp=sharing) 或者 [Tsinghua Cloud](https://cloud.tsinghua.edu.cn/f/b3f119a008264b1cabd1/?dl=1) 下载处理好的 ADGEN 数据集，将解压后的 `AdvertiseGen` 目录放到本目录【/workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/data】下。
```bash
#数据集下载完成后解压
tar zxvf AdvertiseGen.tar.gz
#拷贝数据集到指定目录(以下为 docker 容器内部目录), 如果有此数据集则可不拷贝
cp -rvf AdvertiseGen /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/data
```

### 3.1.3. 依赖库安装

```bash
cd /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B
pip install -r requirements.txt
cd transformers_mlu && pip install -e . && cd ..
pip install ./cndsp-0.8.0-py3-none-any.whl
pip install peft==0.3.0 --no-deps
pip install ./flash_attn-2.1.1_mlu-cp310-cp310-linux_x86_64.whl
```

## 3.2. 模型推理
### 3.2.1. CLI推理验证
```bash
# 进入工作目录
cd /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src
#可执行以下命令，直接拷贝修改后的文件
export MLU_VISIBLE_DEVICES=0
python cli_demo.py --model_name_or_path /data/models/llm/chatglm2-6b-32k --use_v2 True
```
*加载比较慢，大概需要10分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src# python cli_demo.py --model_name_or_path /data/models/llm/chatglm2-6b-32k --use_v2 True
11/11/2023 10:21:14 - WARNING - utils.common - Checkpoint is not found at evaluation, load the original model.
Loading checkpoint shards: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 7/7 [00:09<00:00,  1.35s/it]
trainable params: 0 || all params: 6243584000 || trainable%: 0.0000
欢迎使用 ChatGLM-6B 模型，输入内容即可对话，clear清空对话历史，stop终止程序

Input: 你好

ChatGLM-6B: 你好👋！我是人工智能助手 ChatGLM2-6B，很高兴见到你，欢迎问我任何问题。

Input: stop
(pytorch) root@worker1:/workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src#
```

### 3.2.2. WEB推理验证

```bash
#安装依赖库
pip install mdtex2html
pip install gradio==3.50.0
#pip install cpm_kernels
# 进入工作目录
cd /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src
#可执行以下命令，直接拷贝修改后的文件
export MLU_VISIBLE_DEVICES=0
#直接替换web_demo.py，避免出现问题记录一。
cp -rvf /home/share/pytorch1.13/benchmark/chatglm2/tools/web_demo.py /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src
#运行web_demo.py
python web_demo.py --model_name_or_path /data/models/llm/chatglm2-6b-32k --use_v2 True
```
*加载比较慢，大概需要10分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/chatglm2/ChatGLM2-6B_mlu# python web_demo.py
Loading checkpoint shards: 100%|██████████████████████████████████████████████████████████████████████████████████| 7/7 [00:08<00:00,  1.26s/it]
Running on local URL:  http://127.0.0.1:7000
Running on public URL: https://d770ab15d67f55c617.gradio.live

This share link expires in 72 hours. For free permanent hosting and GPU upgrades, run `gradio deploy` from Terminal to deploy to Spaces (https://huggingface.co/spaces)
```
**问题记录一：**

问题描述： chatglm2 web_demo.py 在submit之后，MLU算力又有占用，chabot栏也出现了对话内容，但是一闪而过，AI的回复显示不出来。
解决措施： 删除或注释掉 web_demo.py 文件里的以下代码，修改后问题解决。

```bash
#"""Override Chatbot.postprocess"""
#
#def postprocess(self, y):
#    if y is None:
#        return []
#    for i, (message, response) in enumerate(y):
#        y[i] = (
#            None if message is None else mdtex2html.convert((message)),
#            None if response is None else mdtex2html.convert(response),
#        )
#    return y
#
#
#gr.Chatbot.postprocess = postprocess
```
或 直接使用已修改后的文件，替换web_demo.py。
```bash
cp -rvf /home/share/pytorch1.13/benchmark/chatglm2/tools/web_demo.py /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B/src
```

## 3.3. 模型训练

```bash
# 进入工作目录
cd /workspace/cair_modelzoo/Benchmark
cp -rvf /home/share/pytorch1.13/benchmark/chatglm2/tools/benchmark_demo.sh /workspace/cair_modelzoo/Benchmark/ChatGLM2-6B
#lora 此训练脚本中会自动安装依赖库 根据需要设置卡的数量，同时需要修改 test_benchmark.sh 脚本中 num_card 字段。
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
./test_benchmark.sh 11 ddp amp ./data/AdvertiseGen/ benchmark 370X8 /data/models/llm/chatglm2-6b-32k lora
#finetune 此训练脚本中会自动安装依赖库
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
./test_benchmark.sh 11 ddp amp ./data/AdvertiseGen/ benchmark 370X8 /data/models/llm/chatglm2-6b-32k finetune
```

### 3.3.1. lora训练记录

```bash
# 进入工作目录
cd /workspace/cair_modelzoo/Benchmark
#lora 此训练脚本中会自动安装依赖库
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
./test_benchmark.sh 11 ddp amp ./data/AdvertiseGen/ benchmark 370X8 /data/models/llm/chatglm2-6b-32k lora
```

lora 训练结束终端会打印如下结果：

```bash
{
    "date": "2023-11-11 11:44:07",
    "net": "ChatGLM2-6B_LoRA",
    "batch_size": 1,
    "cards": 8,
    "precision": "amp",
    "DPF_mode": "ddp",
    "batch_time_avg": 20.524971,
    "batch_time_var": 0.005009,
    "hardware_time_avg": 19.75678,
    "hardware_time_var": 0.009588,
    "throughput": 0.39,
    "device": "MLU370-X8",
    "dataset": "AdvertiseGen"
}
```
*以上数据为4卡8芯的测试数据，batch_size为1，性能比较差。只增大batch_size，其他不变情况下，会oom。*

**训练期间MLU资源占用情况**
<p align="left">
    <img alt="chatglm2_web" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/benchmark/chatglm2/res/test-x86-cnmon.gif" width="640" />
</p>

### 3.3.2. finetune训练记录

```bash
# 进入工作目录
cd /workspace/cair_modelzoo/Benchmark
#finetune 此训练脚本中会自动安装依赖库
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
./test_benchmark.sh 11 ddp amp ./data/AdvertiseGen/ benchmark 370X8 /data/models/llm/chatglm2-6b-32k finetune
```
