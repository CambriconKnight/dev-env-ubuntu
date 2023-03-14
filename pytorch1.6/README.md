
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 Pytorch 框架的 Docker 容器。 官方发布的 Docker 容器已经对 Pytorch 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon PyTorch 框架进行各类网络的模型推理和训练等验证工作。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7
- 软件栈版本: 1.10.0
- 深度学习框架: Pytorch
- 镜像文件: pytorch-v1.10.0-torch1.6-ubuntu18.04-py37.tar.gz
- Docker: ⽤⼾需要⾃⾏安装docker（版本要求 >= v19.03）

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 服务器         | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-S4/X4/x8  | 一套       |使用板卡自带的8pin连接器连接主机电源|

**软件环境准备:**

| 名称                   | 版本/文件                                                 | 备注                                 |
| :-------------------- | :-------------------------------                         | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                          | 宿主机操作系统                         |
| Docker Image          | pytorch-v1.10.0-torch1.6-ubuntu18.04-py37.tar.gz         | 官方发布的 Pytorch 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_4.20.18_amd64.deb  | 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. 网络图谱
Cambricon PyTorch 支持的典型网络及移植流程.
|网络名称|操作目录|备注|
|----|-------|-------|
|`yolact`|./yolact| |

# 3. 下载镜像

下载官方发布的 Pytorch 框架 Docker 镜像文件。 可前往寒武纪开发者社区注册账号按需下载, 也可在官方提供的专属FTP账户指定路径下载。

以下准备步骤以 pytorch-<xx.xx.xx>-ubuntu18.04.tar.gz 镜像文件为例，其中 <xx.xx.xx> 表示PyTorch的版本号，例如 pytorch-1.0.0-ubuntu18.04.tar.gz 。

# 4. 加载镜像
```bash
#加载Docker镜像
#./load-image-dev.sh /DATA_SPACE/kang/ftp/docker/pytorch-v1.10.0-torch1.6-ubuntu18.04-py37.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 5. 启动容器
```bash
#启动容器
./run-container-dev.sh
```
