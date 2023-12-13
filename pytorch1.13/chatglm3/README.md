
<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.13/chatglm3">
        <h1 align="center">ChatGLM3-6B模型验证教程</h1>
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
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.22-1.x86_64.rpm        | 依操作系统选择，[驱动安装教程](https://sdk.cambricon.com/download?component_name=Driver)                         |
| Docker Image          | pytorch-v1.17.0-torch1.13.1-ubuntu20.04-py310.tar.gz     | 官方镜像 [下载地址](https://sdk.cambricon.com/download?sdk_version=V1.15.0&component_name=PyTorch) |
| DeepSpeed             | deepspeed_mlu-0.9.0-py3-none-any.whl                     | 官方安装包 [下载地址](https://sdk.cambricon.com/static/Basis/MLU370_X86_ubuntu18.04/deepspeed_mlu-0.9.0-py3-none-any.whl)                |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| ChatGLM3-6B 源码       | https://github.com/THUDM/ChatGLM3  | commit： 35f21dda9f567 |
| Transformers 源码      | https://github.com/huggingface/transformers  | v4.30.2 |
| ChatGLM3-6B 模型         | https://huggingface.co/THUDM/chatglm3-6b	  | commit： e46a14881eae； 直接clone 速度慢，并且为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **ChatGLM3-6B** 自动获取。|
| ChatGLM3-6B 训练数据    | ToolAlpaca.tar.gz  | [下载地址](https://github.com/tangqiaoyu/ToolAlpaca.git) 也可关注微信公众号 【 AIKnight 】, 发送关键字 **ToolAlpaca** 自动获取。|

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

## 2.1. 下载代码
```bash
# 进到容器后，切换到工作目录
mkdir -p /workspace/chatglm3 && cd /workspace/chatglm3
# 1. 下载 transformers 源码: 基于 transformer 模型结构提供的预训练语言库
git clone -b v4.30.2 https://github.com/huggingface/transformers
# 2. 下载 ChatGLM3 源码
git clone https://github.com/THUDM/ChatGLM3 && cd ChatGLM3 && git checkout 35f21dda9f567 && cd -

# 3. 下载 chatglm-6b 模型实现
mkdir -p /workspace/chatglm3/models && cd /workspace/chatglm3/models
#GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/ziqingyang/chinese-alpaca-2-13b
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/THUDM/chatglm3-6b && cd chatglm3-6b && git checkout e46a14881eae && cd -
cp -rvf /data/models/llm/chatglm3-6b /workspace/chatglm3/models/
#显示模型列表
ls -la /workspace/chatglm3/models/chatglm3-6b
```

## 2.2. 推理代码适配

```bash
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
```

## 2.3. 修改模型文件

修改模型文件 modeling_chatglm.py

```bash
# 进入预训练模型路径（以实际为准）
# 进入工作目录，拷贝修改后的代码到【chatglm3-6b】目录。
cp -rvf /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm-bk-e46a14881eae.py
cp -rvf /home/share/pytorch1.13/chatglm3/tools/modeling_chatglm_mlu_infer.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py
#cp -rvf /home/share/pytorch1.13/chatglm3/tools/modeling_chatglm_mlu_training.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py
```

# 3. 模型验证

以下操作均在Docker容器中进行。

## 3.1. 模型推理
### 3.1.1. 运行推理demo
```bash
# 进入工作目录
cd /workspace/chatglm3/ChatGLM3_mlu
cp -rvf /home/share/pytorch1.13/chatglm3/tools/demo.py ./
#可执行以下命令，直接拷贝修改后的文件
export MLU_VISIBLE_DEVICES=0,1
#根据实际环境修改demo.py 中模型路径。
python demo.py
```
*加载比较慢，大概需要5分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu# python demo.py
Loading checkpoint shards: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 7/7 [00:04<00:00,  1.56it/s]
/workspace/chatglm3/transformers_mlu/src/transformers/tokenization_utils_base.py:773: UserWarning:  MLU operators dont support 64-bit calculation. so the 64 bit data will be forcibly converted to 32-bit for calculation.  (Triggered internally at /torch/catch/torch_mlu/csrc/aten/utils/tensor_util.cpp:159.)
  self.data = {k: v.to(device=device) for k, v in self.data.items()}
[2023-12-12 15:55:6] [CNNL] [Warning]:[cnnlStridedSlice] is deprecated and will be removed in the future release, please use [cnnlStridedSlice_v2] instead.
[2023-12-12 15:55:6] [CNNL] [Warning]:[cnnlRandCreateGenerator_v2] will be deprecated.
你好！我是人工智能助手 ChatGLM3-6B，很高兴见到你，欢迎问我任何问题。
晚上睡不着时，你可以尝试以下方法来帮助自己入睡：

1. 保持冷静：尽量放松身心，避免焦虑和紧张情绪。

2. 调整环境：确保你的卧室温度、光线和噪音舒适，这有助于入睡。

3. 控制饮水：晚上尽量减少饮水量，避免因夜间尿频影响睡眠。

4. 规律作息：尽量保持每天相同的入睡和起床时间，帮助身体建立生物钟。

5. 适当运动：白天进行适量运动，有助于晚上更好地入睡。但避免在临近睡觉前进行剧烈运动。

6. 放松身心：尝试采用深呼吸、冥想或渐进性肌肉松弛等方法来放松身心。

7. 避免使用电子产品：尽量在睡前一小时避免使用手机、电脑等电子产品，以免蓝光影响你的睡眠。

8. 睡前禁止刺激性食物和饮料：睡前避免摄入咖啡因、茶、巧克力等刺激性食物和饮料。

9. 尝试睡前的传统活动：如阅读、听轻音乐等，有助于入睡。

10. 如果长时间睡不着，请寻求专业医生的帮助。

希望这些建议能对你有所帮助。祝你早日入睡，拥有一个好梦！
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu#
```

### 3.1.2. 运行官方demo

```bash
# 进入工作目录
cd /workspace/chatglm3/ChatGLM3_mlu/composite_demo
#安装jupyter内核
ipython kernel install --name chatglm3-demo --user
#设置环境变量，根据实际环境修改模型路径
export MODEL_PATH=/workspace/chatglm3/models/chatglm3-6b
#运行官方综合demo
streamlit run main.py
```
*加载比较慢，大概需要5分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu# cd composite_demo
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu/composite_demo#
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu/composite_demo# pwd
/workspace/chatglm3/ChatGLM3_mlu/composite_demo
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu/composite_demo# ipython kernel install --name chatglm3-demo --user
Installed kernelspec chatglm3-demo in /root/.local/share/jupyter/kernels/chatglm3-demo
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu/composite_demo# export MODEL_PATH=/workspace/chatglm3/models/chatglm3-6b
(pytorch) root@worker1:/workspace/chatglm3/ChatGLM3_mlu/composite_demo# streamlit run main.py

      👋 Welcome to Streamlit!

      If you’d like to receive helpful onboarding emails, news, offers, promotions,
      and the occasional swag, please enter your email address below. Otherwise,
      leave this field blank.

      Email:

  You can find our privacy policy at https://streamlit.io/privacy-policy

  Summary:
  - This open source library collects usage statistics.
  - We cannot see and do not store information contained inside Streamlit apps,
    such as text, charts, images, etc.
  - Telemetry data is stored in servers in the United States.
  - If youd like to opt out, add the following to ~/.streamlit/config.toml,
    creating that file if necessary:

    [browser]
    gatherUsageStats = false


  You can now view your Streamlit app in your browser.

  Local URL: http://localhost:8501
  Network URL: http://10.10.129.11:8501
```
*启动完成后，根据提示打开网址，进行操作，实例如下：*

<p align="left">
    <img alt="chatglm3-6b-streamlit-demo" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-streamlit-demo.gif" width="640" />
</p>

*MLU占用率如下：*

<p align="left">
    <img alt="chatglm3-6b-streamlit-demo-cnmon" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-streamlit-demo-cnmon.gif" width="640" />
</p>

## 3.2. 模型训练

### 3.2.1. 安装依赖库
| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| deepspeed        | [deepspeed_mlu-0.9.0-py3-none-any.whl](https://sdk.cambricon.com/static/Basis/MLU370_X86_ubuntu18.04/deepspeed_mlu-0.9.0-py3-none-any.whl)    | 0.9.0 |
| flash-attention        | 联系技术支持人员获取	  | 2.1.1 |
| accelerate_mlu        | 联系技术支持人员获取	  |  |

```bash
# 进入工作目录
mkdir -p /workspace/chatglm3/tools && cd /workspace/chatglm3/tools
# 1. 下载并安装cndsp
wget https://sdk.cambricon.com/static/Basis/MLU370_X86_ubuntu18.04/deepspeed_mlu-0.9.0-py3-none-any.whl
pip install deepspeed_mlu-0.9.0-py3-none-any.whl

# 2. 下载并安装flash-attn2.1.1 。联系技术支持人员，获取 flash-attn2.1.1（暂未公开发布）
#wget https://sdk.cambricon.com/static/Basis/MLU370_X86_ubuntu18.04/flash_attn-2.1.1_mlu-cp310-cp310-linux_x86_64.whl
#cp -rvf /home/share/pytorch1.13/chatglm3/tools/flash_attn-2.1.1_mlu-cp310-cp310-linux_x86_64.whl ./
# 使用提供的flash_attn-2.1.1_mlu-cp310-cp310-linux_x86_64.whl进行安装
pip install flash_attn-2.1.1_mlu-cp310-cp310-linux_x86_64.whl

# 3. 下载并安装 accelerate_mlu 。联系技术支持人员，获取 accelerate_mlu 并手动安装
#cp -rvf /home/ftp/accelerate_mlu.tar.gz ./
tar -zxvf accelerate_mlu.tar.gz && cd accelerate_mlu
pip install -e .
```

### 3.2.2. 训练代码适配

```bash
# 1. 修改accelerate_mlu
#将使用cndsp的地方，替换为deepspeed-mlu。以下使用已经修改后的文件，直接拷贝替换。如需请自行查看差异
cd /workspace/chatglm3/tools
cp -rvf /home/share/pytorch1.13/chatglm3/tools/accelerator.py /workspace/chatglm3/tools/accelerate_mlu/src/accelerate/accelerator.py
cp -rvf /home/share/pytorch1.13/chatglm3/tools/imports.py /workspace/chatglm3/tools/accelerate_mlu/src/accelerate/utils/imports.py

# 2. 修改transfomers_mlu
#修改对deepspeed指定的软件为deepspeed-mlu>=0.9.0
cd /workspace/chatglm3
#vim transformers_mlu/src/transformers/dependency_versions_table.py
#使用已经修改后的文件，直接拷贝替换。如需请自行查看差异
cp -rvf /home/share/pytorch1.13/chatglm3/tools/dependency_versions_table.py /workspace/chatglm3/transformers_mlu/src/transformers/dependency_versions_table.py

# 3. 修改模型权重源码：chatglm3-6b/modeling_chatglm.py，方便期间备份原有文件并直接拷贝修改后的代码到【chatglm3-6b】目录。
cp -rvf /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm_mlu_infer-bk-e46a14881eae.py
cp -rvf /home/share/pytorch1.13/chatglm3/tools/modeling_chatglm_mlu_training.py /workspace/chatglm3/models/chatglm3-6b/modeling_chatglm.py
```

### 3.2.3. P-Tuning

```bash
# 进入工作目录
cd /workspace/chatglm3/ChatGLM3_mlu/finetune_demo
# 1. 下载 ToolAlpaca 数据集（多轮对话格式）
git clone https://github.com/tangqiaoyu/ToolAlpaca.git
# 2. 转换数据
python ./scripts/format_tool_alpaca.py --path ./ToolAlpaca/data/train_data.json

# 3. 修改P-Tuning脚本 scripts/finetune_pt_multiturn.sh，修改以下几处：
#1）使用卡数 NUM_GPUS，MAX_SEQ_LEN，MAX_STEP，SAVE_INTERVAL；本实例卡数为一卡双芯；
#2）设置模型路径 BASE_MODEL_PATH；本实例修改为： /workspace/chatglm3/models/chatglm3-6b；
#3）修改分布式调用方式；
# 修改后的脚本放置在如下路径： /home/share/pytorch1.13/chatglm3/tools/finetune_pt_multiturn.sh
# 使用已经修改后的文件，直接拷贝替换。如需请自行查看差异
cp -rvf /home/share/pytorch1.13/chatglm3/tools/finetune_pt_multiturn.sh /workspace/chatglm3/ChatGLM3_mlu/finetune_demo/scripts
# 4. 完成脚本内容修改后，执行P-Tuning训练
bash scripts/finetune_pt_multiturn.sh
```
*注：打印中显示oom训练可正常运行可暂忽略*

**训练开始**
<p align="left">
    <img alt="chatglm3-6b-p-tuning-0s" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-p-tuning-0s.gif" width="640" />
</p>

**训练过程**
<p align="left">
    <img alt="chatglm3-6b-p-tuning-2s" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-p-tuning-2s.gif" width="640" />
</p>

**训练期间MLU资源占用情况**
<p align="left">
    <img alt="chatglm3-6b-p-tuning-cnmon" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-p-tuning-cnmon.gif" width="640" />
</p>

**训练结束**
<p align="left">
    <img alt="chatglm3-6b-p-tuning-3s" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.13/chatglm3/res/chatglm3-6b-p-tuning-3s.gif" width="640" />
</p>


### 3.2.4. Fine-tuning

*测试资源有限，待补充......，如需可联系对应技术支持人员。*
