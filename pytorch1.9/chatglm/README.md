
<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.9/chatglm">
        <img alt="chatglm-logo" src="./res/chatglm-6b.jpg" height="140" />
        <h1 align="center">ChatGLM模型移植教程</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

[TOC]

# 1. 环境准备

## 1.1. 硬件环境

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 服务器         | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-X4/X8  | 一套       | X8需使用板卡自带的8pin连接器连接主板电源 |

## 1.2. 软件环境

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                          | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.13.0-torch1.9-ubuntu18.04-py37.tar.gz         | 官方发布的 Pytorch 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.10-1.x86_64.rpm	       | 依操作系统选择                         |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| ChatGLM-6B 源码         | https://github.com/THUDM/ChatGLM-6B  | commit：82c084b1cb5f2c2973cfb2119fb154f4dbc825b6 |
| Transformers 源码         | https://github.com/huggingface/transformers  | v4.27.4                          |
| ChatGLM-6B 模型         | https://huggingface.co/THUDM/chatglm-6b  | 直接clone 速度慢，可从[Tsinghua Cloud](https://cloud.tsinghua.edu.cn/d/fb9f16d6dc8f482596c2)下载；为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **chatglm-6b** 自动获取。|

**下载地址:**
- 前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载， 也可在官方提供的专属FTP账户指定路径下载。
- 文档: https://developer.cambricon.com/index/document/index/classid/3.html
- SDK: https://sdk.cambricon.com/download?component_name=PyTorch

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
#./load-image-dev.sh ./docker/pytorch-v1.13.0-torch1.9-ubuntu18.04-py37.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

## 1.5. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
#启动Docker容器
./run-container-dev.sh
```

# 2. 模型推理
## 2.1. 安装LFS

安装 Git LFS，实现 Git 对大文件的支持.
```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/chatglm
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
```
## 2.2. 下载代码

下载 transformers 及 chatglm-6b 源码及对应版本的 chatglm-6b 模型（模型较大，下载时间比较长）。
```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/chatglm
# 1. 下载 transformers 源码: 基于 transformer 模型结构提供的预训练语言库
git clone -b v4.27.4 https://github.com/huggingface/transformers
# 2. 下载 chatglm-6b 源码
git clone https://github.com/THUDM/ChatGLM-6B
cd ChatGLM-6B && git checkout 82c084b1cb5f2c2973cfb2119fb154f4dbc825b6 && cd -
# 3. 下载 chatglm-6b 模型实现
##第一种方式： 不推荐使用以下命令。直接 git clone 大模型文件的话，下载模型时间较长.
# git clone https://huggingface.co/THUDM/chatglm-6b
##第二种方式： 采用如下方式， git clone 并手动下载或拷贝过来模型，会更方便些。
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/THUDM/chatglm-6b
# 然后从 https://cloud.tsinghua.edu.cn/d/fb9f16d6dc8f482596c2/ 手动下载的模型和参数文件，替换到本地的 chatglm-6b 目录下。
#cp -rvf /data/models/chatglm-6b/pretrained_model/chatglm-6b/pytorch_model-0000*.bin ./chatglm-6b
#cp -rvf /data/models/chatglm-6b/pretrained_model/chatglm-6b/ice_text.model ./chatglm-6b
# 注意： 如果后续操作中，有shape mismatch之类报错，多半是模型更新了，需要下载对应的模型。
##第三种方式(推荐)： 为保证与以上代码对应的模型，也可通过关注微信公众号 【AIKnight】,
# 发送关键字(不区分大小写): **chatglm-6b**, 公众号会自动回复对应下载地址.
# 下载完毕后，可把下载后的【chatglm-6b】目录拷贝到当前目录。
cp -rvf /data/baidudisk/chatglm-6b ./
#cp -rvf /data/models/chatglm-6b/ ./
#mv -f /DATA_SPACE/baidudisk/chatglm-6b ./
```

## 2.3. 模型适配
### 2.3.1. 自动迁移代码

使用工具 `torch_gpu2mlu.py` 从 GPU 模型脚本迁移至 MLU 设备运行，转换后的模型脚本只支持 MLU 设备运行。该工具可对模型脚本进行转换，对模型脚本修改位置较多，会对修改位置进行统计，实现开发者快速迁移。

- 在容器环境中，执行以下命令
```bash
cd /home/share/pytorch1.9/chatglm
#建立软连接
ln -s /torch/src/catch/tools/torch_gpu2mlu.py ./
#执行转换模型脚本, 自动修改 transformers 源码
python torch_gpu2mlu.py -i transformers
#执行转换模型脚本, 自动修改  ChatGLM-6B 源码
python torch_gpu2mlu.py -i ChatGLM-6B
#显示转换后的代码。
#ls -lh transformers transformers_mlu ChatGLM-6B ChatGLM-6B_mlu
ls -la
```

- 输出转换结果
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm# python torch_gpu2mlu.py -i transformers
copy error:  /home/share/pytorch1.9/chatglm/transformers/examples/legacy/seq2seq/test_data/test_data
# Cambricon PyTorch Model Migration Report
Official PyTorch model scripts:  /home/share/pytorch1.9/chatglm/transformers
Cambricon PyTorch model scripts:  /home/share/pytorch1.9/chatglm/transformers_mlu
Migration Report:  /home/share/pytorch1.9/chatglm/transformers_mlu/report.md
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm# python torch_gpu2mlu.py -i ChatGLM-6B
# Cambricon PyTorch Model Migration Report
Official PyTorch model scripts:  /home/share/pytorch1.9/chatglm/ChatGLM-6B
Cambricon PyTorch model scripts:  /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu
Migration Report:  /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/report.md
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm#
```

### 2.3.2. 手动修改代码

由于 chatglm-6b 要求使用 torch >=1.10，其中有 pytorch 不支持的特性包括如下。需要在【自动迁移代码】基础上再进行如下修改。

- torch.nn.utils.skip_init
- torch.c.jit_xx
- torch.concat

进入工作目录，拷贝修改后的代码到【chatglm-6b】目录。
```bash
# 进入工作目录
cd /home/share/pytorch1.9/chatglm
cp -rvf /home/share/pytorch1.9/chatglm/tools/modeling_chatglm.py ./chatglm-6b
```
也可按照以下流程，直接手动修改 modeling_chatglm.py 源码。
```bash
# 进入预训练模型路径（以实际为准）
cd ./chatglm-6b
vim modeling_chatglm.py
```

1. 注释 skip_init 相关代码（注意：不同版本可能会不同）

源码 modeling_chatglm.py 中 skip_init 不支持， skip_init 是 pytorch 1.10.0 版本增加的功能. 而 cambricon pytorch 适配的官方 pytorch 版本为 1.9.0 , 没有 skip_init 。
*以下修改涉及5处，需要全部修改。*
```bash
#from torch.nn.utils import skip_init

#if empty_init:
#    init_method = skip_init
#else:
#    init_method = default_init
init_method = default_init
```
2. 使用 torch.cat 替换 torch.concat

torch 1.9中没有torch.concat, 查询pytorch手册后发现torch 1.10中使用torch.concat替换了torch.cat，因此需要将原代码中的torch.concat改为torch.cat。
```bash
# query_layer = torch.concat([q1, q2], dim=(q1.ndim - 1))
# key_layer = torch.concat([k1, k2], dim=(k1.ndim - 1))
query_layer = torch.cat([q1, q2], dim=(q1.ndim - 1))
key_layer = torch.cat([k1, k2], dim=(k1.ndim - 1))
```
3. 注释掉 jit fusion

把jit fusion相关都注释掉，mlu不支持。
```bash
#if sys.platform != 'darwin':
#    torch._C._jit_set_profiling_mode(False)
#    torch._C._jit_set_profiling_executor(False)
#    torch._C._jit_override_can_fuse_on_cpu(True)
#    torch._C._jit_override_can_fuse_on_gpu(True)
```

### 2.3.3. 安装依赖库

```bash
# 安装 ChatGLM-6B 依赖库
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu
sed -i 's/torch/# torch/' requirements.txt
pip install -r requirements.txt
# 安装 transformers
cd ../transformers_mlu/
pip install -e .
```

## 2.4. 测试验证
```bash
# 进入ChatGLM-6B_mlu路径（以实际为准）
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu

# 根据使用的demo，修改cli_demo.py或web_demo.py或api.py中的预训练模型路径“THUDM/chatglm-6b”为实际路径，本教程中此路径修改为【../chatglm-6b】。
#tokenizer = AutoTokenizer.from_pretrained("THUDM/chatglm-6b", trust_remote_code=True)
#model = AutoModel.from_pretrained("THUDM/chatglm-6b", trust_remote_code=True).half().mlu()
#也可执行以下命令，直接拷贝修改后的文件
cp -rvf /home/share/pytorch1.9/chatglm/tools/cli_demo.py ./
# CLI测试验证
export MLU_VISIBLE_DEVICES=0
python cli_demo.py

# 或python web_demo.py 或python api.py
# 注意：如使用web_demo.py，需修改demo.queue().launch(share=False, inbrowser=True)中share=True，否则无法看到gradio地址
cp -rvf /home/share/pytorch1.9/chatglm/tools/web_demo.py ./
# WEB测试验证
python web_demo.py

# API测试验证
cp -rvf /home/share/pytorch1.9/chatglm/tools/api.py ./
python api.py
```

### 2.4.1. 测试CLI实例

使用 cli_demo.py测试。

*加载比较慢，大概需要10分钟，可耐心等待。*
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu# python cli_demo.py
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a configuration with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Loading checkpoint shards: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 8/8 [00:11<00:00,  1.41s/it]
欢迎使用 ChatGLM-6B 模型，输入内容即可进行对话，clear 清空对话历史，stop 终止程序

用户：chatGPT是啥?

ChatGLM-6B：ChatGPT是美国人工智能研究实验室OpenAI于2022年11月推出的一个人工智能聊天机器人程序，该程序基于大型语言模型GPT-3.5，使用指令微调(Instruction Tuning)和基于人类反馈的强化学习技术(RLHF)训练而成。

用户：stop
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu#
```

### 2.4.2. 测试WEB实例

使用 web_demo.py测试 ，需修改 demo.queue().launch(share=False, inbrowser=True) 中 share=True ，否则无法看到 gradio 地址。

*加载比较慢，大概需要10分钟，可耐心等待。*

```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu# python web_demo.py
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a configuration with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Loading checkpoint shards: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 8/8 [00:10<00:00,  1.29s/it]
Running on local URL:  http://127.0.0.1:7860
Running on public URL: https://6d2496501bb4bd4466.gradio.live

This share link expires in 72 hours. For free permanent hosting and GPU upgrades (NEW!), check out Spaces: https://huggingface.co/spaces
```

**Web展示效果**
<p align="left">
    <img alt="aiknight_mlu_chatglm" src="./res/aiknight_mlu_chatglm.gif" width="640" />
</p>

### 2.4.3. 测试推理性能
```bash
# 进入ChatGLM-6B_mlu路径（以实际为准）
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu
# 同步
cp -rvf /home/share/pytorch1.9/chatglm/tools/inference.py /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/
# 测试验证
python inference.py
```
**实例**
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu# python inference.py
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a configuration with custom code to ensure no malicious code has been contributed in a newer revision.
Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
Loading checkpoint shards: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 8/8 [00:10<00:00,  1.28s/it]
/home/share/pytorch1.9/chatglm/transformers_mlu/src/transformers/tokenization_utils_base.py:759: UserWarning:  MLU operators dont support 64-bit calculation. so the 64 bit data will be forcibly converted to 32-bit for calculation.  (Triggered internally at  /torch/catch/torch_mlu/csrc/aten/util/tensor_util.cpp:153.)
  self.data = {k: v.to(device=device) for k, v in self.data.items()}
The dtype of attention mask (torch.int64) is not bool
Hello! How can I assist you today?
==================================================
question:  ChatGLM-6B 是啥?
response:  ChatGLM-6B 是一个基于语言模型的人工智能助手，由清华大学 KEG 实验室和智谱 AI 公司于 2023 年共同训练的语言模型 GLM-6B 开发而成。该助手旨在为用户提供的帮助和回答。
len(response):  97
time_end-time_start:  7.061268091201782
token:  13.736909397457989
==================================================
==================================================
question:  CharGPT 是啥?
response:  CharGPT 是由 OpenAI 于 2022 年 11 月推出的一个人工智能聊天机器人程序，该程序基于大型语言模型 GPT-3.5，使用指令微调(Instruction Tuning)和基于人类反馈的强化学习技术(RLHF)训练而成。
len(response):  119
time_end-time_start:  8.150062799453735
token:  14.6011144856425
==================================================
==================================================
question:  ChatGLM-6B 与 CharGPT 有什么区别?
response:  ChatGLM-6B 和 CharGPT 都是基于语言模型的人工智能助手，但它们在以下几个方面有所不同：

1. 模型大小：ChatGLM-6B 是一个基于 GLM-6B 语言模型的人工智能助手，而 CharGPT 是一个基于 GPT-3.5 语言模型的人工智能助手。

2. 训练数据：ChatGLM-6B 和 CharGPT 的训练数据都来自于互联网上的大量文本数据，但它们的训练数据有所不同。ChatGLM-6B 的训练数据包括了多种不同的主题和语言风格，而 CharGPT 的训练数据则更加多样化，它包括了多种不同的文本类型和语言风格。

3. 功能：ChatGLM-6B 和 CharGPT 的功能也有所不同。ChatGLM-6B 是一个实时的人工智能助手，它可以帮助用户回答各种问题，提供各种帮助。而 CharGPT 则是一种聊天机器人程序，它可以与用户进行对话，回答用户的问题，并提供一些娱乐性的内容。

总的来说，ChatGLM-6B 和 CharGPT 都是基于语言模型的人工智能助手，但它们在模型大小、训练数据、功能等方面有所不同。
len(response):  476
time_end-time_start:  34.9201123714447
token:  13.631113065639516
==================================================
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu#
```

# 3. 模型训练
## 3.1. 单卡P-Tuning v2
### 3.1.1. 安装软件依赖
运行微调需要4.27.1版本的`transformers`。除 ChatGLM-6B 的依赖之外，还需要安装以下依赖
```bash
pip install rouge_chinese nltk jieba datasets
```
### 3.1.2. 下载数据集
ADGEN 数据集任务为根据输入（content）生成一段广告词（summary）。

```json
{
    "content": "类型#上衣*版型#宽松*版型#显瘦*图案#线条*衣样式#衬衫*衣袖型#泡泡袖*衣款式#抽绳",
    "summary": "这件衬衫的款式非常的宽松，利落的线条可以很好的隐藏身材上的小缺点，穿在身上有着很好的显瘦效果。领口装饰了一个可爱的抽绳，漂亮的绳结展现出了十足的个性，配合时尚的泡泡袖型，尽显女性甜美可爱的气息。"
}
```

从 [Google Drive](https://drive.google.com/file/d/13_vf0xRTQsyneRKdD1bZIr93vBGOczrk/view?usp=sharing) 或者 [Tsinghua Cloud](https://cloud.tsinghua.edu.cn/f/b3f119a008264b1cabd1/?dl=1) 下载处理好的 ADGEN 数据集，将解压后的 `AdvertiseGen` 目录放到本目录下。

```bash
#数据集下载完成后解压
tar zxvf AdvertiseGen.tar.gz
#拷贝数据集到指定目录(以下为 docker 容器内部目录)
cp -rvf AdvertiseGen /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/
```

### 3.1.3. 修改训练代码

1. 修改 trainer.py

需要把以下两个文件中的 torch.mlu.random 全部改成 torch_mlu.core.random 。否则会报错【AttributeError: module 'torch.mlu' has no attribute 'random'】。
```bash
#查找目录中所有相关文件
cd /home/share/pytorch1.9/chatglm/
grep -rn torch.mlu.random
#grep -rn torch_mlu.core.random
#2 用 torch_mlu.core.random 替代 torch.mlu.random
grep -rn "torch.mlu.random" && sed -i "s/torch.mlu.random/torch_mlu.core.random/g" `grep -rl "torch.mlu.random" | grep -E ".py"`  && grep -rn "torch_mlu.core.random"
#grep -rn "torch.mlu.core.random" && sed -i "s/torch.mlu.core.random/torch_mlu.core.random/g" `grep -rl "torch.mlu.core.random"` && grep -rn "torch_mlu.core.random"
```
主要包括如下两个文件，替换后，保存文件。
```bash
ChatGLM-6B_mlu/ptuning/trainer.py:2275:                torch_mlu.core.random.set_rng_state(checkpoint_rng_state["mlu"])
ChatGLM-6B_mlu/ptuning/trainer.py:2278:                    torch_mlu.core.random.set_rng_state_all(checkpoint_rng_state["mlu"])
ChatGLM-6B_mlu/ptuning/trainer.py:2370:                rng_states["mlu"] = torch_mlu.core.random.get_rng_state_all()
ChatGLM-6B_mlu/ptuning/trainer.py:2372:                rng_states["mlu"] = torch_mlu.core.random.get_rng_state()
transformers_mlu/src/transformers/trainer.py:2273:                torch_mlu.core.random.set_rng_state(checkpoint_rng_state["mlu"])
transformers_mlu/src/transformers/trainer.py:2276:                    torch_mlu.core.random.set_rng_state_all(checkpoint_rng_state["mlu"])
transformers_mlu/src/transformers/trainer.py:2368:                rng_states["mlu"] = torch_mlu.core.random.get_rng_state_all()
transformers_mlu/src/transformers/trainer.py:2370:                rng_states["mlu"] = torch_mlu.core.random.get_rng_state()
```

2. 训练脚本修改

基于 docker 容器中目录 /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning 下的 `train.sh` 脚本，修改并增加了一份可用于 MLU 的训练启动脚本 `train_mlu.sh`。
```bash
#拷贝脚本到指定目录
cp -rvf /home/share/pytorch1.9/chatglm/tools/train_mlu.sh /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning
```
`train_mlu.sh` 脚本中的相关参数可以根据实际情况修改，保存文件后，即可进行接下来的训练。
`train_mlu.sh` 脚本内容如下：
```bash
PRE_SEQ_LEN=128
LR=2e-2

MLU_VISIBLE_DEVICES=0 python3 main.py \
    --do_train \
    --train_file ../AdvertiseGen/train.json \
    --validation_file ../AdvertiseGen/dev.json \
    --prompt_column content \
    --response_column summary \
    --overwrite_cache \
    --model_name_or_path ../../chatglm-6b \
    --output_dir output/adgen-chatglm-6b-pt-$PRE_SEQ_LEN-$LR \
    --overwrite_output_dir \
    --max_source_length 64 \
    --max_target_length 64 \
    --per_device_train_batch_size 1 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 16 \
    --predict_with_generate \
    --max_steps 3000 \
    --logging_steps 10 \
    --save_steps 1000 \
    --learning_rate $LR \
    --pre_seq_len $PRE_SEQ_LEN
```

### 3.1.4. 执行训练

运行以下指令进行训练：

*加载比较慢，大概需要10分钟，可耐心等待。*

```bash
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning
bash train_mlu.sh
```
**实例**
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning# bash train_mlu.sh
05/25/2023 13:07:42 - WARNING - __main__ - Process rank: -1, device: mlu:0, n_gpu: 1distributed training: False, 16-bits training: False
05/25/2023 13:07:42 - INFO - __main__ - Training/evaluation parameters Seq2SeqTrainingArguments(
......
)
05/25/2023 13:07:43 - WARNING - datasets.builder - Found cached dataset json (/root/.cache/huggingface/datasets/json/default-3060c7e219b54699/0.0.0/e347ab1c932092252e717ff3f949105a4dd28b27e842dd53157d2f72e276c2e4)
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 2/2 [00:00<00:00, 626.67it/s]
[INFO|configuration_utils.py:667] 2023-05-25 13:07:43,955 >> loading configuration file ../../chatglm-6b/config.json
[WARNING|configuration_auto.py:906] 2023-05-25 13:07:43,955 >> Explicitly passing a `revision` is encouraged when loading a configuration with custom code to ensure no malicious code has been contributed in a newer revision.
[INFO|configuration_utils.py:667] 2023-05-25 13:07:43,990 >> loading configuration file ../../chatglm-6b/config.json
[INFO|configuration_utils.py:721] 2023-05-25 13:07:43,991 >> Model config ChatGLMConfig {
......
}

[WARNING|tokenization_auto.py:653] 2023-05-25 13:07:43,992 >> Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
[INFO|tokenization_utils_base.py:1801] 2023-05-25 13:07:44,030 >> loading file ice_text.model
[INFO|tokenization_utils_base.py:1801] 2023-05-25 13:07:44,030 >> loading file added_tokens.json
[INFO|tokenization_utils_base.py:1801] 2023-05-25 13:07:44,030 >> loading file special_tokens_map.json
[INFO|tokenization_utils_base.py:1801] 2023-05-25 13:07:44,030 >> loading file tokenizer_config.json
[WARNING|auto_factory.py:457] 2023-05-25 13:07:44,240 >> Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
[INFO|modeling_utils.py:2401] 2023-05-25 13:07:44,342 >> loading weights file ../../chatglm-6b/pytorch_model.bin.index.json
[INFO|configuration_utils.py:575] 2023-05-25 13:07:44,343 >> Generate config GenerationConfig {
  "_from_model_config": true,
  "bos_token_id": 130004,
  "eos_token_id": 130005,
  "pad_token_id": 3,
  "transformers_version": "4.27.4"
}

Loading checkpoint shards: 100%|██████████████████████████████████████████████████████████████████████████████████████████████████████| 8/8 [00:09<00:00,  1.19s/it]
[INFO|modeling_utils.py:3035] 2023-05-25 13:11:12,453 >> All model checkpoint weights were used when initializing ChatGLMForConditionalGeneration.

[WARNING|modeling_utils.py:3038] 2023-05-25 13:11:12,453 >> Some weights of ChatGLMForConditionalGeneration were not initialized from the model checkpoint at ../../chatglm-6b and are newly initialized: ['transformer.prefix_encoder.embedding.weight']
You should probably TRAIN this model on a down-stream task to be able to use it for predictions and inference.
[INFO|modeling_utils.py:2694] 2023-05-25 13:11:12,518 >> Generation config file not found, using a generation config created from the model config.
input_ids [5, 65421, 61, 67329, 32, 98339, 61, 72043, 32, 65347, 61, 70872, 32, 69768, 61, 68944, 32, 67329, 64103, 61, 96914, 130001, 130004, 5, 87052, 96914, 81471, 64562, 65759, 64493, 64988, 6, 65840, 65388, 74531, 63825, 75786, 64009, 63823, 65626, 63882, 64619, 65388, 6, 64480, 65604, 85646, 110945, 10, 64089, 65966, 87052, 67329, 65544, 6, 71964, 70533, 64417, 63862, 89978, 63991, 63823, 77284, 88473, 64219, 63848, 112012, 6, 71231, 65099, 71252, 66800, 85768, 64566, 64338, 100323, 75469, 63823, 117317, 64218, 64257, 64051, 74197, 6, 63893, 130005, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
inputs 类型#裤*版型#宽松*风格#性感*图案#线条*裤型#阔腿裤 宽松的阔腿裤这两年真的吸粉不少,明星时尚达人的心头爱。毕竟好穿时尚,谁都能穿出腿长2米的效果宽松的裤腿,当然是遮肉小能手啊。上身随性自然不拘束,面料亲肤舒适贴身体验感棒棒哒。系带部分增加设计看点,还
label_ids [-100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, 130004, 5, 87052, 96914, 81471, 64562, 65759, 64493, 64988, 6, 65840, 65388, 74531, 63825, 75786, 64009, 63823, 65626, 63882, 64619, 65388, 6, 64480, 65604, 85646, 110945, 10, 64089, 65966, 87052, 67329, 65544, 6, 71964, 70533, 64417, 63862, 89978, 63991, 63823, 77284, 88473, 64219, 63848, 112012, 6, 71231, 65099, 71252, 66800, 85768, 64566, 64338, 100323, 75469, 63823, 117317, 64218, 64257, 64051, 74197, 6, 63893, 130005, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100]
labels <image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100> 宽松的阔腿裤这两年真的吸粉不少,明星时尚达人的心头爱。毕竟好穿时尚,谁都能穿出腿长2米的效果宽松的裤腿,当然是遮肉小能手啊。上身随性自然不拘束,面料亲肤舒适贴身体验感棒棒哒。系带部分增加设计看点,还<image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100>
/home/share/pytorch1.9/chatglm/transformers_mlu/src/transformers/optimization.py:396: FutureWarning: This implementation of AdamW is deprecated and will be removed in a future version. Use the PyTorch implementation torch.optim.AdamW instead, or set `no_deprecation_warning=True` to disable this warning
  FutureWarning,
  0%|                                                                                                                                      | 0/3000 [00:00<?, ?it/s]/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning/trainer.py:2578: UserWarning:  MLU operators dont support 64-bit calculation. so the 64 bit data will be forcibly converted to 32-bit for calculation.  (Triggered internally at  /torch/catch/torch_mlu/csrc/aten/util/tensor_util.cpp:153.)
  return data.to(**kwargs)
05/25/2023 13:13:11 - WARNING - transformers_modules.chatglm-6b.modeling_chatglm - `use_cache=True` is incompatible with gradient checkpointing. Setting `use_cache=False`...
/torch/venv3/pytorch/lib/python3.7/site-packages/torch/cuda/amp/autocast_mode.py:134: UserWarning: If running in mlu, torch.cuda.amp is deprecated and will be removed in the future release, please use [torch.mlu.amp] instead. Ignore warning if running in cuda.
  warnings.warn("If running in mlu, torch.cuda.amp is deprecated and will be removed in the future release, please use [torch.mlu.amp] instead. Ignore warning if running in cuda.")
{'loss': 5.5885, 'learning_rate': 0.019933333333333334, 'epoch': 0.0}
{'loss': 5.1672, 'learning_rate': 0.019866666666666668, 'epoch': 0.0}
{'loss': 4.9893, 'learning_rate': 0.0198, 'epoch': 0.0}
{'loss': 4.7983, 'learning_rate': 0.019733333333333335, 'epoch': 0.01}
{'loss': 4.8502, 'learning_rate': 0.019666666666666666, 'epoch': 0.01}
  2%|██                                                                                                                         | 51/3000 [07:22<7:05:22,  8.65s/it]
......
......
......
......
......
{'loss': 4.0408, 'learning_rate': 0.0002, 'epoch': 0.41}
{'loss': 4.1562, 'learning_rate': 0.00013333333333333334, 'epoch': 0.42}
{'loss': 4.1267, 'learning_rate': 6.666666666666667e-05, 'epoch': 0.42}
{'loss': 4.06, 'learning_rate': 0.0, 'epoch': 0.42}
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3000/3000 [7:41:34<00:00,  9.44s/it]Saving PrefixEncoder
[INFO|configuration_utils.py:458] 2023-05-25 20:54:45,103 >> Configuration saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/config.json
[INFO|configuration_utils.py:362] 2023-05-25 20:54:45,107 >> Configuration saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/generation_config.json
[INFO|modeling_utils.py:1763] 2023-05-25 20:54:45,400 >> Model weights saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/pytorch_model.bin
[INFO|tokenization_utils_base.py:2164] 2023-05-25 20:54:45,401 >> tokenizer config file saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/tokenizer_config.json
[INFO|tokenization_utils_base.py:2171] 2023-05-25 20:54:45,402 >> Special tokens file saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/special_tokens_map.json
{'train_runtime': 27694.8538, 'train_samples_per_second': 1.733, 'train_steps_per_second': 0.108, 'train_loss': 4.3326422932942705, 'epoch': 0.42}
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3000/3000 [7:41:34<00:00,  9.23s/it]
***** train metrics *****
  epoch                    =       0.42
  train_loss               =     4.3326
  train_runtime            = 7:41:34.85
  train_samples            =     114599
  train_samples_per_second =      1.733
  train_steps_per_second   =      0.108
```

**训练期间MLU资源占用情况**
<p align="left">
    <img alt="aiknight_mlu_chatglm_train_cnmon" src="./res/aiknight_mlu_chatglm_train_cnmon.gif" width="640" />
</p>

## 3.2. 单机多卡P-Tuning v2

本章节基于[zero_nlp](https://github.com/yuanzhoulvpi2017/zero_nlp/tree/main/Chatglm6b_ModelParallel_ptuning)中代码，实现了单机多卡模型并行。
下载 zero_nlp 仓库
```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/chatglm
# 1. 下载 zero_nlp 源码: 基于 zero_nlp 模型结构提供的预训练语言库
git clone https://github.com/yuanzhoulvpi2017/zero_nlp
cd zero_nlp && git checkout 8b9f9d949f37ccec5dd95d9ed6cad69645cd7c66 && cd -
#执行转换模型脚本, 自动修改 zero_nlp 源码
python torch_gpu2mlu.py -i zero_nlp
cp -rvf zero_nlp_mlu/Chatglm6b_ModelParallel_ptuning ./ChatGLM-6B_mlu
```

### 3.2.1. 安装软件依赖
同单卡P-Tuning V2一样，运行微调需要4.27.1版本的`transformers`。除 ChatGLM-6B 的依赖之外，还需要安装以下依赖
```bash
pip install rouge_chinese nltk jieba datasets
```
### 3.2.2. 下载数据集
同单卡P-Tuning V2一样，使用ADGEN 数据集，该数据集任务为根据输入（content）生成一段广告词（summary）。

```json
{
    "content": "类型#上衣*版型#宽松*版型#显瘦*图案#线条*衣样式#衬衫*衣袖型#泡泡袖*衣款式#抽绳",
    "summary": "这件衬衫的款式非常的宽松，利落的线条可以很好的隐藏身材上的小缺点，穿在身上有着很好的显瘦效果。领口装饰了一个可爱的抽绳，漂亮的绳结展现出了十足的个性，配合时尚的泡泡袖型，尽显女性甜美可爱的气息。"
}
```

从 [Google Drive](https://drive.google.com/file/d/13_vf0xRTQsyneRKdD1bZIr93vBGOczrk/view?usp=sharing) 或者 [Tsinghua Cloud](https://cloud.tsinghua.edu.cn/f/b3f119a008264b1cabd1/?dl=1) 下载处理好的 ADGEN 数据集，将解压后的 `AdvertiseGen` 目录放到本目录下。

```bash
#数据集下载完成后解压
tar zxvf AdvertiseGen.tar.gz
#拷贝数据集到指定目录(以下为 docker 容器内部目录)
cp -rvf AdvertiseGen /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/
```

### 3.2.3. 修改训练代码

1. 修改 trainer.py

需要把以下两个文件中的 torch.mlu.random 全部改成 torch_mlu.core.random 。否则会报错【AttributeError: module 'torch.mlu' has no attribute 'random'】。
```bash
#查找目录中所有相关文件
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/
grep -rn torch.mlu.random
#grep -rn torch_mlu.core.random
#2 用 torch_mlu.core.random 替代 torch.mlu.random, 主要包括如下两个文件:
grep -rn "torch.mlu.random" && sed -i "s/torch.mlu.random/torch_mlu.core.random/g" Chatglm6b_ModelParallel_ptuning/trainer.py Chatglm6b_ModelParallel_ptuning/MyTrainer.py && grep -rn "torch_mlu.core.random"
```

2. 注释 skip_init 相关代码（注意：不同版本可能会不同）
源码 modeling_chatglm.py 中 skip_init 不支持， skip_init 是 pytorch 1.10.0 版本增加的功能. 而 cambricon pytorch 适配的官方 pytorch 版本为 1.9.0 , 没有 skip_init 。
参考[ChatGLM-6B-WIKI629](https://github.com/THUDM/ChatGLM-6B/issues/629)
把【from torch.nn.utils import skip_init】 换成如下代码：
```bash
def skip_init(cls, *args, **kwargs):
    return cls(*args, **kwargs)
```
搜索相关代码，按照上面方法逐个文件修改替换对应代码。
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning# grep -rn "from torch.nn.utils import skip_init"
modeling_chatglm.py:16:from torch.nn.utils import skip_init
thuglm/modeling_chatglm.py:16:from torch.nn.utils import skip_init
modeling_chatglm_parallel.py:16:from torch.nn.utils import skip_init
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning#
```
3. 使用 torch.cat 替换 torch.concat
torch 1.9中没有torch.concat, 查询pytorch手册后发现torch 1.10中使用torch.concat替换了torch.cat，因此需要将原代码中的torch.concat改为torch.cat。
```bash
# query_layer = torch.concat([q1, q2], dim=(q1.ndim - 1))
# key_layer = torch.concat([k1, k2], dim=(k1.ndim - 1))
query_layer = torch.cat([q1, q2], dim=(q1.ndim - 1))
key_layer = torch.cat([k1, k2], dim=(k1.ndim - 1))
```
搜索相关代码，按照上面方法逐个文件修改替换对应代码。
```bash
grep -rn "torch.concat" && sed -i "s/torch.concat/torch.cat/g" `grep -rl "torch.concat" ./` && grep -rn "torch.cat"
```

3. 注释掉 jit fusion

把jit fusion相关都注释掉，mlu不支持。
```bash
#if sys.platform != 'darwin':
#    torch._C._jit_set_profiling_mode(False)
#    torch._C._jit_set_profiling_executor(False)
#    torch._C._jit_override_can_fuse_on_cpu(True)
#    torch._C._jit_override_can_fuse_on_gpu(True)
```
搜索相关代码，按照上面方法逐个文件修改替换对应代码。
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning# grep -rn "torch._C._jit_"
modeling_chatglm.py:41:    torch._C._jit_set_profiling_mode(False)
modeling_chatglm.py:42:    torch._C._jit_set_profiling_executor(False)
modeling_chatglm.py:43:    torch._C._jit_override_can_fuse_on_cpu(True)
modeling_chatglm.py:44:    torch._C._jit_override_can_fuse_on_gpu(True)
thuglm/modeling_chatglm.py:41:    torch._C._jit_set_profiling_mode(False)
thuglm/modeling_chatglm.py:42:    torch._C._jit_set_profiling_executor(False)
thuglm/modeling_chatglm.py:43:    torch._C._jit_override_can_fuse_on_cpu(True)
thuglm/modeling_chatglm.py:44:    torch._C._jit_override_can_fuse_on_gpu(True)
modeling_chatglm_parallel.py:44:    torch._C._jit_set_profiling_mode(False)
modeling_chatglm_parallel.py:45:    torch._C._jit_set_profiling_executor(False)
modeling_chatglm_parallel.py:46:    torch._C._jit_override_can_fuse_on_cpu(True)
modeling_chatglm_parallel.py:47:    torch._C._jit_override_can_fuse_on_gpu(True)
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning#
```

4. 训练脚本修改

基于 docker 容器中目录 /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning 下的 `train_parallel.sh` 脚本，修改并增加了一份可用于 MLU 的训练启动脚本 `train_parallel_mlu.sh`。
```bash
#拷贝脚本到指定目录
cp -rvf /home/share/pytorch1.9/chatglm/tools/train_parallel_mlu.sh /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning
```
`train_parallel_mlu.sh` 脚本中的相关参数可以根据实际情况修改，保存文件后，即可进行接下来的训练。
`train_parallel_mlu.sh` 脚本内容如下：
```bash
PRE_SEQ_LEN=8
LR=1e-2

python3 main_parallel.py \
    --do_train \
    --train_file ../AdvertiseGen/train.json \
    --validation_file ../AdvertiseGen/dev.json \
    --prompt_column content \
    --response_column summary \
    --overwrite_cache \
    --model_name_or_path ../../chatglm-6b \
    --output_dir output/adgen-chatglm-6b-pt-$PRE_SEQ_LEN-$LR \
    --overwrite_output_dir \
    --max_source_length 64 \
    --max_target_length 64 \
    --per_device_train_batch_size 4 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --predict_with_generate \
    --max_steps 3000 \
    --logging_steps 10 \
    --save_steps 1000 \
    --learning_rate $LR \
    --pre_seq_len $PRE_SEQ_LEN
```

### 3.2.4. 执行训练

本章节基于[zero_nlp](https://github.com/yuanzhoulvpi2017/zero_nlp/tree/main/Chatglm6b_ModelParallel_ptuning)中代码，实现了**多卡模型并行**。

*加载比较慢，大概需要10分钟，可耐心等待。*

```bash
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning
export MLU_VISIBLE_DEVICES=8,9
#unset MLU_VISIBLE_DEVICES
bash train_parallel_mlu.sh
```
**实例**
```bash
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning# bash train_parallel_mlu.sh
07/06/2023 14:25:32 - WARNING - __main__ - Process rank: -1, device: mlu:0, n_gpu: 2distributed training: False, 16-bits training: False
07/06/2023 14:25:32 - INFO - __main__ - Training/evaluation parameters Seq2SeqTrainingArguments(
_n_gpu=2,
adafactor=False,
adam_beta1=0.9,
adam_beta2=0.999,
adam_epsilon=1e-08,
auto_find_batch_size=False,
bf16=False,
bf16_full_eval=False,
data_seed=None,
dataloader_drop_last=False,
dataloader_num_workers=0,
dataloader_pin_memory=True,
ddp_bucket_cap_mb=None,
ddp_find_unused_parameters=None,
ddp_timeout=1800,
debug=[],
deepspeed=None,
disable_tqdm=False,
do_eval=False,
do_predict=False,
do_train=True,
eval_accumulation_steps=None,
eval_delay=0,
eval_steps=None,
evaluation_strategy=no,
fp16=False,
fp16_backend=auto,
fp16_full_eval=False,
fp16_opt_level=O1,
fsdp=[],
fsdp_config={'fsdp_min_num_params': 0, 'xla': False, 'xla_fsdp_grad_ckpt': False},
fsdp_min_num_params=0,
fsdp_transformer_layer_cls_to_wrap=None,
full_determinism=False,
generation_max_length=None,
generation_num_beams=None,
gradient_accumulation_steps=1,
gradient_checkpointing=False,
greater_is_better=None,
group_by_length=False,
half_precision_backend=auto,
hub_model_id=None,
hub_private_repo=False,
hub_strategy=every_save,
hub_token=<HUB_TOKEN>,
ignore_data_skip=False,
include_inputs_for_metrics=False,
jit_mode_eval=False,
label_names=None,
label_smoothing_factor=0.0,
learning_rate=0.02,
length_column_name=length,
load_best_model_at_end=False,
local_rank=-1,
log_level=passive,
log_level_replica=warning,
log_on_each_node=True,
logging_dir=output/adgen-chatglm-6b-pt-128-2e-2/runs/Jul06_14-25-32_worker1,
logging_first_step=False,
logging_nan_inf_filter=True,
logging_steps=10,
logging_strategy=steps,
lr_scheduler_type=linear,
max_grad_norm=1.0,
max_steps=3000,
metric_for_best_model=None,
mp_parameters=,
no_mlu=False,
num_train_epochs=3.0,
optim=adamw_hf,
optim_args=None,
output_dir=output/adgen-chatglm-6b-pt-128-2e-2,
overwrite_output_dir=True,
past_index=-1,
per_device_eval_batch_size=1,
per_device_train_batch_size=4,
predict_with_generate=True,
prediction_loss_only=False,
push_to_hub=False,
push_to_hub_model_id=None,
push_to_hub_organization=None,
push_to_hub_token=<PUSH_TO_HUB_TOKEN>,
ray_scope=last,
remove_unused_columns=True,
report_to=[],
resume_from_checkpoint=None,
run_name=output/adgen-chatglm-6b-pt-128-2e-2,
save_on_each_node=False,
save_steps=1000,
save_strategy=steps,
save_total_limit=None,
seed=42,
sharded_ddp=[],
skip_memory_metrics=True,
sortish_sampler=False,
tf32=None,
torch_compile=False,
torch_compile_backend=None,
torch_compile_mode=None,
torchdynamo=None,
tpu_metrics_debug=False,
tpu_num_cores=None,
use_ipex=False,
use_legacy_prediction_loop=False,
use_mps_device=False,
warmup_ratio=0.0,
warmup_steps=0,
weight_decay=0.0,
xpu_backend=None,
)
07/06/2023 14:25:34 - WARNING - datasets.builder - Found cached dataset json (/root/.cache/huggingface/datasets/json/default-3060c7e219b54699/0.0.0/8bb11242116d547c741b2e8a1f18598ffdd40a1d4f2a2872c7a28b697434bc96)
100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 2/2 [00:00<00:00, 470.53it/s]
[INFO|configuration_utils.py:667] 2023-07-06 14:25:34,022 >> loading configuration file ../../chatglm-6b/config.json
[WARNING|configuration_auto.py:906] 2023-07-06 14:25:34,022 >> Explicitly passing a `revision` is encouraged when loading a configuration with custom code to ensure no malicious code has been contributed in a newer revision.
[INFO|configuration_utils.py:667] 2023-07-06 14:25:34,067 >> loading configuration file ../../chatglm-6b/config.json
[INFO|configuration_utils.py:721] 2023-07-06 14:25:34,068 >> Model config ChatGLMConfig {
  "_name_or_path": "../../chatglm-6b",
  "architectures": [
    "ChatGLMModel"
  ],
  "auto_map": {
    "AutoConfig": "configuration_chatglm.ChatGLMConfig",
    "AutoModel": "modeling_chatglm.ChatGLMForConditionalGeneration",
    "AutoModelForSeq2SeqLM": "modeling_chatglm.ChatGLMForConditionalGeneration"
  },
  "bos_token_id": 130004,
  "eos_token_id": 130005,
  "gmask_token_id": 130001,
  "hidden_size": 4096,
  "inner_hidden_size": 16384,
  "layernorm_epsilon": 1e-05,
  "mask_token_id": 130000,
  "max_sequence_length": 2048,
  "model_type": "chatglm",
  "num_attention_heads": 32,
  "num_layers": 28,
  "pad_token_id": 3,
  "position_encoding_2d": true,
  "pre_seq_len": null,
  "prefix_projection": false,
  "quantization_bit": 0,
  "torch_dtype": "float16",
  "transformers_version": "4.27.4",
  "use_cache": true,
  "vocab_size": 130528
}

[WARNING|tokenization_auto.py:653] 2023-07-06 14:25:34,069 >> Explicitly passing a `revision` is encouraged when loading a model with custom code to ensure no malicious code has been contributed in a newer revision.
[INFO|tokenization_utils_base.py:1801] 2023-07-06 14:25:34,103 >> loading file ice_text.model
[INFO|tokenization_utils_base.py:1801] 2023-07-06 14:25:34,103 >> loading file added_tokens.json
[INFO|tokenization_utils_base.py:1801] 2023-07-06 14:25:34,103 >> loading file special_tokens_map.json
[INFO|tokenization_utils_base.py:1801] 2023-07-06 14:25:34,103 >> loading file tokenizer_config.json
[WARNING|modeling_utils.py:2094] 2023-07-06 14:25:34,346 >> The argument `trust_remote_code` is to be used with Auto classes. It has no effect here and is ignored.
[INFO|modeling_utils.py:2401] 2023-07-06 14:25:34,346 >> loading weights file ../../chatglm-6b/pytorch_model.bin.index.json
[INFO|configuration_utils.py:575] 2023-07-06 14:25:34,347 >> Generate config GenerationConfig {
  "_from_model_config": true,
  "bos_token_id": 130004,
  "eos_token_id": 130005,
  "pad_token_id": 3,
  "transformers_version": "4.27.4"
}

Loading checkpoint shards: 100%|██████████████████████████████████████████████████████████████████████████████████████████| 8/8 [00:09<00:00,  1.19s/it]
[INFO|modeling_utils.py:3035] 2023-07-06 14:28:59,844 >> All model checkpoint weights were used when initializing ChatGLMForConditionalGeneration.

[WARNING|modeling_utils.py:3038] 2023-07-06 14:28:59,845 >> Some weights of ChatGLMForConditionalGeneration were not initialized from the model checkpoint at ../../chatglm-6b and are newly initialized: ['transformer.prefix_encoder.embedding.weight']
You should probably TRAIN this model on a down-stream task to be able to use it for predictions and inference.
[INFO|modeling_utils.py:2694] 2023-07-06 14:28:59,932 >> Generation config file not found, using a generation config created from the model config.
input_ids [5, 65421, 61, 67329, 32, 98339, 61, 72043, 32, 65347, 61, 70872, 32, 69768, 61, 68944, 32, 67329, 64103, 61, 96914, 130001, 130004, 5, 87052, 96914, 81471, 64562, 65759, 64493, 64988, 6, 65840, 65388, 74531, 63825, 75786, 64009, 63823, 65626, 63882, 64619, 65388, 6, 64480, 65604, 85646, 110945, 10, 64089, 65966, 87052, 67329, 65544, 6, 71964, 70533, 64417, 63862, 89978, 63991, 63823, 77284, 88473, 64219, 63848, 112012, 6, 71231, 65099, 71252, 66800, 85768, 64566, 64338, 100323, 75469, 63823, 117317, 64218, 64257, 64051, 74197, 6, 63893, 130005, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
inputs 类型#裤*版型#宽松*风格#性感*图案#线条*裤型#阔腿裤 宽松的阔腿裤这两年真的吸粉不少,明星时尚达人的心头爱。毕竟好穿时尚,谁都能穿出腿长2米的效果宽松的裤腿,当然是遮肉小能手啊。上身随性自然不拘束,面料亲肤舒适贴身体验感棒棒哒。系带部分增加设计看点,还
label_ids [-100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, 130004, 5, 87052, 96914, 81471, 64562, 65759, 64493, 64988, 6, 65840, 65388, 74531, 63825, 75786, 64009, 63823, 65626, 63882, 64619, 65388, 6, 64480, 65604, 85646, 110945, 10, 64089, 65966, 87052, 67329, 65544, 6, 71964, 70533, 64417, 63862, 89978, 63991, 63823, 77284, 88473, 64219, 63848, 112012, 6, 71231, 65099, 71252, 66800, 85768, 64566, 64338, 100323, 75469, 63823, 117317, 64218, 64257, 64051, 74197, 6, 63893, 130005, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100, -100]
labels <image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100> 宽松的阔腿裤这两年真的吸粉不少,明星时尚达人的心头爱。毕竟好穿时尚,谁都能穿出腿长2米的效果宽松的裤腿,当然是遮肉小能手啊。上身随性自然不拘束,面料亲肤舒适贴身体验感棒棒哒。系带部分增加设计看点,还<image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100><image_-100>
/home/share/pytorch1.9/chatglm/transformers_mlu/src/transformers/optimization.py:396: FutureWarning: This implementation of AdamW is deprecated and will be removed in a future version. Use the PyTorch implementation torch.optim.AdamW instead, or set `no_deprecation_warning=True` to disable this warning
  FutureWarning,
  0%|                                                                                                                          | 0/3000 [00:00<?, ?it/s]/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning/trainer.py:2592: UserWarning:  MLU operators dont support 64-bit calculation. so the 64 bit data will be forcibly converted to 32-bit for calculation.  (Triggered internally at  /torch/catch/torch_mlu/csrc/aten/util/tensor_util.cpp:153.)
  return data.to(**kwargs)
07/06/2023 14:31:01 - WARNING - thuglm.modeling_chatglm - `use_cache=True` is incompatible with gradient checkpointing. Setting `use_cache=False`...
/torch/venv3/pytorch/lib/python3.7/site-packages/torch/cuda/amp/autocast_mode.py:134: UserWarning: If running in mlu, torch.cuda.amp is deprecated and will be removed in the future release, please use [torch.mlu.amp] instead. Ignore warning if running in cuda.
  warnings.warn("If running in mlu, torch.cuda.amp is deprecated and will be removed in the future release, please use [torch.mlu.amp] instead. Ignore warning if running in cuda.")
{'loss': 4.9968, 'learning_rate': 0.019933333333333334, 'epoch': 0.0}
{'loss': 4.6767, 'learning_rate': 0.019866666666666668, 'epoch': 0.0}
{'loss': 4.4809, 'learning_rate': 0.0198, 'epoch': 0.0}
{'loss': 4.2921, 'learning_rate': 0.019733333333333335, 'epoch': 0.0}
{'loss': 4.0579, 'learning_rate': 0.019666666666666666, 'epoch': 0.0}
{'loss': 4.4641, 'learning_rate': 0.0196, 'epoch': 0.0}
{'loss': 4.1154, 'learning_rate': 0.019533333333333333, 'epoch': 0.0}
{'loss': 4.1598, 'learning_rate': 0.019466666666666667, 'epoch': 0.0}
{'loss': 4.3472, 'learning_rate': 0.0194, 'epoch': 0.0}
{'loss': 3.9942, 'learning_rate': 0.019333333333333334, 'epoch': 0.0}
{'loss': 3.9948, 'learning_rate': 0.019266666666666668, 'epoch': 0.0}
{'loss': 4.0203, 'learning_rate': 0.0192, 'epoch': 0.0}
{'loss': 3.9713, 'learning_rate': 0.019133333333333332, 'epoch': 0.0}
{'loss': 3.8516, 'learning_rate': 0.01906666666666667, 'epoch': 0.0}
{'loss': 4.0781, 'learning_rate': 0.019, 'epoch': 0.01}
{'loss': 3.94, 'learning_rate': 0.018933333333333333, 'epoch': 0.01}
{'loss': 3.9748, 'learning_rate': 0.018866666666666667, 'epoch': 0.01}
{'loss': 4.053, 'learning_rate': 0.0188, 'epoch': 0.01}
......
......
......
{'loss': 3.6416, 'learning_rate': 0.0031333333333333335, 'epoch': 0.09}
{'loss': 3.654, 'learning_rate': 0.0030666666666666663, 'epoch': 0.09}
......
......
......
{'loss': 3.6553, 'learning_rate': 0.00013333333333333334, 'epoch': 0.1}
{'loss': 3.6029, 'learning_rate': 6.666666666666667e-05, 'epoch': 0.1}
{'loss': 3.6621, 'learning_rate': 0.0, 'epoch': 0.1}
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3000/3000 [2:20:08<00:00,  2.80s/it]Saving PrefixEncoder
[INFO|configuration_utils.py:458] 2023-07-06 16:51:09,429 >> Configuration saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/config.json
[INFO|configuration_utils.py:362] 2023-07-06 16:51:09,432 >> Configuration saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/generation_config.json
[INFO|modeling_utils.py:1763] 2023-07-06 16:51:09,754 >> Model weights saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/pytorch_model.bin
[INFO|tokenization_utils_base.py:2164] 2023-07-06 16:51:09,755 >> tokenizer config file saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/tokenizer_config.json
[INFO|tokenization_utils_base.py:2171] 2023-07-06 16:51:09,755 >> Special tokens file saved in output/adgen-chatglm-6b-pt-128-2e-2/checkpoint-3000/special_tokens_map.json
{'train_runtime': 8409.2601, 'train_samples_per_second': 1.427, 'train_steps_per_second': 0.357, 'train_loss': 3.753849661509196, 'epoch': 0.1}
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████| 3000/3000 [2:20:09<00:00,  2.80s/it]
***** train metrics *****
  epoch                    =        0.1
  train_loss               =     3.7538
  train_runtime            = 2:20:09.26
  train_samples            =     114599
  train_samples_per_second =      1.427
  train_steps_per_second   =      0.357
(pytorch) root@worker1:/home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/Chatglm6b_ModelParallel_ptuning#
```

## 3.3. 单机多卡Finetune
### 3.3.1. 安装软件依赖
运行微调需要4.27.1版本的`transformers`。除 ChatGLM-6B 的依赖之外，还需要安装以下依赖
```bash
pip install rouge_chinese nltk jieba datasets
```
除此之外，Finetune前还需要安装 Deepspeed。
```bash
#pip install /home/share/pytorch1.9/dependent_files/cndsp-0.7.1-py3-none-any.whl
pip install /home/share/pytorch1.9/dependent_files/cndsp-0.8.0-py3-none-any.whl
```

### 3.3.2. 下载数据集
ADGEN 数据集任务为根据输入（content）生成一段广告词（summary）。

```json
{
    "content": "类型#上衣*版型#宽松*版型#显瘦*图案#线条*衣样式#衬衫*衣袖型#泡泡袖*衣款式#抽绳",
    "summary": "这件衬衫的款式非常的宽松，利落的线条可以很好的隐藏身材上的小缺点，穿在身上有着很好的显瘦效果。领口装饰了一个可爱的抽绳，漂亮的绳结展现出了十足的个性，配合时尚的泡泡袖型，尽显女性甜美可爱的气息。"
}
```

从 [Google Drive](https://drive.google.com/file/d/13_vf0xRTQsyneRKdD1bZIr93vBGOczrk/view?usp=sharing) 或者 [Tsinghua Cloud](https://cloud.tsinghua.edu.cn/f/b3f119a008264b1cabd1/?dl=1) 下载处理好的 ADGEN 数据集，将解压后的 `AdvertiseGen` 目录放到本目录下。

```bash
#数据集下载完成后解压
tar zxvf AdvertiseGen.tar.gz
#拷贝数据集到指定目录(以下为 docker 容器内部目录)
cp -rvf AdvertiseGen /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/
```

### 3.3.3. 修改训练代码

1. 修改 trainer.py

需要把以下两个文件中的 torch.mlu.random 全部改成 torch_mlu.core.random 。否则会报错【AttributeError: module 'torch.mlu' has no attribute 'random'】。
```bash
#查找目录中所有相关文件
cd /home/share/pytorch1.9/chatglm/
grep -rn torch.mlu.random
#grep -rn torch_mlu.core.random
#2 用 torch_mlu.core.random 替代 torch.mlu.random
grep -rn "torch.mlu.random" && sed -i "s/torch.mlu.random/torch_mlu.core.random/g" `grep -rl "torch.mlu.random" | grep -E ".py"`  && grep -rn "torch_mlu.core.random"
#grep -rn "torch.mlu.core.random" && sed -i "s/torch.mlu.core.random/torch_mlu.core.random/g" `grep -rl "torch.mlu.core.random"` && grep -rn "torch_mlu.core.random"
```

2. 训练脚本修改

基于 docker 容器中目录 /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning 下的 `ds_train_finetune.sh` 脚本，修改并增加了一份可用于 MLU 的训练启动脚本 `ds_train_finetune_mlu.sh`。
```bash
#拷贝脚本到指定目录
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning
cp -rvf /home/share/pytorch1.9/chatglm/tools/ds_train_finetune_mlu.sh ./
```
`ds_train_finetune_mlu.sh` 脚本中的相关参数可以根据实际情况修改，保存文件后，即可进行接下来的训练。
`ds_train_finetune_mlu.sh` 脚本内容如下：
```bash
LR=1e-4

MASTER_PORT=$(shuf -n 1 -i 10000-65535)

deepspeed --num_gpus=2 --master_port $MASTER_PORT main.py \
    --include localhost:2,3 \
    --deepspeed deepspeed.json \
    --do_train \
    --train_file ../AdvertiseGen/train.json \
    --test_file ../AdvertiseGen/dev.json \
    --prompt_column content \
    --response_column summary \
    --overwrite_cache \
    --model_name_or_path ../../chatglm-6b \
    --output_dir ./output/adgen-chatglm-6b-ft-$LR \
    --overwrite_output_dir \
    --max_source_length 64 \
    --max_target_length 64 \
    --per_device_train_batch_size 4 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --predict_with_generate \
    --max_steps 5000 \
    --logging_steps 10 \
    --save_steps 1000 \
    --learning_rate $LR \
    --fp16
```

3. transformers 代码与cndsp版本适配

使用cndsp需要适配transformers，才能正常调用，否则会报错。目前已测试的transformers各模块版本如下：

| 模块      | 版本   | 备注   |
| :------- | :----- | :----- |
| torch         | 1.9.0     |  |
| transformers8  | 4.28.1   |  |
| cndsp  | 0.8.0   |  |

4. cndsp代码修改
注意dsp里会重新刷visible devices，所以需要参考如下两种方式修改：
1> 指定卡需要通过在.py之前设置 --include localhost:4,5,6,7（没有测试成功）
2> 注释/torch/venv3/pytorch/lib/python3.7/site-packages/deepspeed/launcher/runner.py +380 的 del os.environ["MLU_VISIBLE_DEVICES"]


### 3.3.4. 执行训练

运行以下指令进行训练：

*加载比较慢，大概需要10分钟，可耐心等待。*

```bash
cd /home/share/pytorch1.9/chatglm/ChatGLM-6B_mlu/ptuning
cp -rvf /home/share/pytorch1.9/chatglm/tools/ds_train_finetune_mlu.sh ./
export MLU_VISIBLE_DEVICES=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
#unset MLU_VISIBLE_DEVICES
bash ds_train_finetune_mlu.sh
```

注意finetune需要的单卡内存较多，使用默认参数，内存容易起爆，注意选用内存更大的AI计算卡。

**实例**

```bash

```

*待补充*
