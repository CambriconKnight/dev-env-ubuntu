
<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.9/chatglm2">
        <img alt="chatglm2-logo" src="./res/chatglm2-6b.jpg" height="140" />
        <h1 align="center">ChatGLM2模型移植教程</h1>
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
| Linux OS              | Ubuntu18.04/Ubuntu20.04/CentOS7                          | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz         | 官方发布的 Pytorch 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.13-1.x86_64.rpm	       | 依实际服务器操作系统版本选择             |
| DeepSpeed             | cndsp-0.8.0-py3-none-any.whl                             | Cambricon DeepSpeed                 |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| ChatGLM2-6B 源码       | https://github.com/THUDM/ChatGLM2-6B  | commit： 3d0225f969d56c058f052f6800a21630d14a1184 |
| Transformers 源码      | https://github.com/huggingface/transformers  | v4.30.2                         |
| ChatGLM2-6B 模型         | https://huggingface.co/THUDM/chatglm2-6b	  | 直接clone 速度慢，并且为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **chatglm2-6b** 自动获取。|

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
#./load-image-dev.sh ./docker/pytorch-v1.15.0-torch1.9-ubuntu18.04-py37.tar.gz
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

# 2. 代码适配

详见相关 [文档中心](https://developer.cambricon.com/index/document/index/classid/3.html) 适配手册：
[寒武纪 PyTorch v1.9网络移植手册](https://www.cambricon.com/docs/sdk_1.13.0/cambricon_pytorch_1.15.0/porting_1.9/index.html)
[寒武纪 PyTorch v1.6⽹络移植⼿册](https://www.cambricon.com/docs/sdk_1.13.0/cambricon_pytorch_1.15.0/porting_1.6/index.html)

# 3. 模型验证
## 3.1. 环境搭建

执行一键自动化环境部署脚本即可完成基础环境搭建。

```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/chatglm2/tools/
./deploy_env.sh
#bash deploy_env.sh
# 激活环境变量
cd /workspace/chatglm2/ChatGLM2-6B_mlu
```
以下是ChatGLM2-6B模型，直接下载即可使用。推荐网络带宽充足的用户。下载完成后放置到此目录【/data/models/chatglm2/chatglm2-6b】，方便后续一键自动化环境部署脚本执行。
| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| ChatGLM2-6B 模型         | https://huggingface.co/THUDM/chatglm2-6b	  | 直接clone 速度慢，并且为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **chatglm2-6b** 自动获取。|

## 3.2. 模型推理
### 3.2.1. CLI推理验证
```bash
# 进入ChatGLM2-6B_mlu路径（以实际为准）
cd /workspace/chatglm2/ChatGLM2-6B_mlu
#可执行以下命令，直接拷贝修改后的文件
cp -rvf /home/share/pytorch1.9/chatglm2/tools/cli_demo.py ./
# CLI测试验证
export MLU_VISIBLE_DEVICES=0
python cli_demo.py
```
*加载比较慢，大概需要10分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/chatglm2/ChatGLM2-6B_mlu# python cli_demo.py
Loading checkpoint shards: 100%|██████████████████████████████████████████████████████████████████████████████████| 7/7 [00:08<00:00,  1.25s/it]
欢迎使用 ChatGLM2-6B 模型，输入内容即可进行对话，clear 清空对话历史，stop 终止程序

用户：你好

ChatGLM：/workspace/chatglm2/transformers_mlu/src/transformers/tokenization_utils_base.py:773: UserWarning:  MLU operators dont support 64-bit calculation. so the 64 bit data will be forcibly converted to 32-bit for calculation.  (Triggered internally at  /torch/catch/torch_mlu/csrc/aten/util/tensor_util.cpp:153.)
  self.data = {k: v.to(device=device) for k, v in self.data.items()}
你好👋！我是人工智能助手 ChatGLM2-6B，很高兴见到你，欢迎问我任何问题。

用户：中国的首都是哪里?

ChatGLM：中国的首都是北京市。

用户：详细介绍下这个城市吧

ChatGLM：北京，简称“京”，是中国的首都，是全国的政治中心、文化中心，是世界著名古都和现代化国际城市。

北京地处中国北部、华北平原北部，东与天津毗连，其余均与河北相邻，中心位置东经 116°20′、北纬 39°54′，是世界著名古都和现代化国际城市，

北京中国历史文化名城和古都之一，拥有许多历史名胜和现代化建筑，是中国乃至世界上最具代表性和吸引力的大都市之一。

北京是一个拥有悠久历史和丰富文化的名城，曾经是明、清两朝的国都，拥有丰富的历史遗产，如紫禁城、长城等。此外，北京还拥有许多现代化建筑和设施，如鸟巢、水立方等标志性建筑，以及高速公路、高铁、机场等交通设施。

北京是一个充满活力和吸引力的城市，吸引了来自世界各地的人们前来探索、观光、学习、交流。

用户：退下吧

ChatGLM：好的，如果您还有其他问题，请随时提出。

用户：stop
(pytorch) root@worker1:/workspace/chatglm2/ChatGLM2-6B_mlu#
```

### 3.2.2. WEB推理验证

```bash
# 进入ChatGLM2-6B_mlu路径（以实际为准）
cd /workspace/chatglm2/ChatGLM2-6B_mlu
# 或python web_demo.py 或python api.py
# 注意：如使用web_demo.py，需修改demo.queue().launch(share=False, inbrowser=True)中share=True，否则无法看到gradio地址
cp -rvf /home/share/pytorch1.9/chatglm2/tools/web_demo.py ./
# WEB测试验证
export MLU_VISIBLE_DEVICES=0
python web_demo.py
```
*加载比较慢，大概需要10分钟，可耐心等待。实例如下：*

```bash
(pytorch) root@worker1:/workspace/chatglm2/ChatGLM2-6B_mlu# python web_demo.py
Loading checkpoint shards: 100%|██████████████████████████████████████████████████████████████████████████████████| 7/7 [00:08<00:00,  1.26s/it]
Running on local URL:  http://127.0.0.1:7000
Running on public URL: https://d770ab15d67f55c617.gradio.live

This share link expires in 72 hours. For free permanent hosting and GPU upgrades, run `gradio deploy` from Terminal to deploy to Spaces (https://huggingface.co/spaces)
```

**Web展示效果**
<p align="left">
    <img alt="chatglm2_web" src="https://gitee.com/cambriconknight/dev-open-res/raw/main/dev-env-ubuntu/pytorch1.9/chatglm2/res/chatglm2_web.gif" width="640" />
</p>

## 3.3. 模型训练

*待补充*