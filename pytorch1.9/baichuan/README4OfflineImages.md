<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch1.9/baichuan">
        <img alt="baichuan-7B-logo" src="./res/baichuan-7B.jpg" height="140" />
        <h1 align="center">BaiChuan-7B模型MLU验证流程-基于离线验证镜像</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

[TOC]

# 1. 环境准备

​为方便 BaiChuan-7B 快速验证，可直接按照以下方式，基于已配置并集成好的 BaiChuan-7B 镜像进行推理和训练验证。

## 1.1. 硬件环境

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 服务器         | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-X4/X8  | 一套       | X8需使用板卡自带的8pin连接器连接主板电源 |

## 1.2. 软件环境

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                          | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.13.0-torch1.9-ubuntu18.04-py37-BaiChuan-7B.tar.gz         | 环境已配置并集成好的 Docker 镜像文件(不包含BaiChuan-7B 模型，需要自行下载后，按照下面步骤说明放置到指定路径)；此镜像文件可关注微信公众号 【 AIKnight 】, 发送关键字 **baichuan-7b-image** 自动获取；镜像文件大约9G，请安排时间下载； |
| Driver_MLU370         | cambricon-mlu-driver-centos7-5.10.10-1.x86_64.rpm	       | 依操作系统选择                         |
| 工具包                 | https://github.com/CambriconKnight/dev-env-ubuntu        | [Github地址](https://github.com/CambriconKnight/dev-env-ubuntu) |
| BaiChuan-7B 源码       | https://github.com/baichuan-inc/baichuan-7B  | commit：4247c4ab03f6cd5baa7c752e057662f9e4bb4a2c |
| Transformers 源码     | https://github.com/huggingface/transformers  | v4.29.1                          |
| BaiChuan-7B 模型       | https://huggingface.co/baichuan-inc/baichuan-7B  | 直接clone 速度慢，为保持版本对应，也可关注微信公众号 【 AIKnight 】, 发送关键字 **baichuan-7B-Model** 自动获取。。|

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
#拷贝针对baichuan大模型的env.sh文件到当前目录(非必须，也可手动修改)
cp -rvf ./baichuan/tools/env.sh ./
```
## 1.4. 加载镜像

请提前下载好【Docker镜像】，方便以下操作加载使用。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
#下载Docker镜像后，可以mv到当前docker目录
#加载Docker镜像
./load-image-dev.sh ./docker/pytorch-v1.13.0-torch1.9-ubuntu18.04-py37-BaiChuan-7B.tar.gz
```

## 1.5. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/pytorch1.9
#启动Docker容器
./run-container-dev.sh
```
操作实例
```bash
[kangshaopeng@worker1 pytorch1.9]$ ./run-container-dev.sh
[sudo] password for kangshaopeng:
0
container-pytorch-v1.13.0-torch1.9-ubuntu18.04-py37-BaiChuan-7B-kang
WARNING: Published ports are discarded when using host network mode
(pytorch) root@worker1:/home/share#
```

以上基于已经搭建好的Docker镜像，方便后续直接测试验证。

# 2. 模型推理
## 2.1. 准备模型

准备好 transformers 及 baichuan-7B 对应版本的 baichuan-7B 模型（模型较大，下载时间比较长），放置到指定 docker 容器目录。
```bash
# 进到容器后，切换到工作目录
cd /workspace/baichuan/baichuan-7B_mlu
##第一种方式： 不推荐使用以下命令。直接 git clone 大模型文件的话，下载模型时间较长.
# git clone https://huggingface.co/baichuan-inc/baichuan-7B
##第二种方式(推荐)： 为保证与以上代码对应的模型，也可通过关注微信公众号 【AIKnight】,
# 发送关键字(不区分大小写): **baichuan-7B**, 公众号会自动回复对应下载地址.
# 下载完毕后，可把下载后的【baichuan-7B】目录拷贝到当前目录。
cp -rvf /home/share/pytorch1.9/baichuan/baichuan-7B/baichuan-7B ./
```

## 2.2. 测试验证
```bash
# 进入测试路径（以实际为准）
cd /workspace/baichuan/baichuan-7B_mlu
#也可执行以下命令，直接拷贝修改后的文件
#cp -rvf /home/share/pytorch1.9/baichuan/tools/inference.py ./
# CLI测试验证，根据实际MLU硬件资源选择测试卡
export MLU_VISIBLE_DEVICES=0
python inference.py
```

### 2.2.1. 测试实例

使用 inference.py测试。

*加载比较慢，大概需要10分钟，可耐心等待。*
```bash
(pytorch) root@worker1:/workspace/baichuan/baichuan-7B_mlu# python inference.py
User：chatGPT是啥?
chatGPT是啥?
最近,一款名为“ChatGPT”的聊天机器人软件火了。这款由人工智能技术驱动的对话式AI产品一经推出就迅速走红网络,成为科技圈和社交媒体上的热门话题。那么,“chatGPT是什么意思呢?它又有什么功能特点呢?下面我们就来了解一下吧! 1.什么是chatGPT “chatGPT”是一种基于自然语言处理(NLP)技术的聊天机器人系统,可以帮助用户与之进行交互并提供相应的服务或信息。该系统使用机器学习算法对大量文本数据进行训练,从而能够理解人类语言、回答问题以及提出建议等。此外,由于其强大的计算能力,chatGPT还可以根据用户输入的信息自动生成相应的内容。因此,对于需要快速获取信息的用户来说,chatGPT是一个非常有用的工具。 2.如何使用chatGPT 在开始使用chatGPT之前,首先需要安装一个支持它的应用程序或者浏览器插件。然后就可以通过以下几种方式与之互动: (1)在搜索引擎中输入关键词; (2)点击网站上提供的链接进入到chatGPT界面; (3)直接访问网址https://www.chathgpt.
```

*待补充*
