
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 MagicMind 框架的 Docker 容器。 官方发布的 Docker 容器已经对 MagicMind 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon MagicMind 框架进行各类网络的模型推理等验证工作。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7
- 软件栈版本: 1.1.0
- 深度学习框架: MagicMind
- 镜像文件: magicmind_1.1.0-1_ubuntu18.04.tar.gz
- Docker: ⽤⼾需要⾃⾏安装docker（版本要求 >= v19.03）

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-S4     | 一套       |机箱风扇需满足MLU370板卡被动散热要求|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Docker Image          | magicmind_1.1.0-1_ubuntu18.04.tar.gz                 | 官方发布的 MagicMind 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_4.20.18_amd64.deb| 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载， 也可在官方提供的专属FTP账户指定路径下载。

文档: https://developer.cambricon.com/index/document/index/classid/3.html

SDK: https://sdk.cambricon.com/download?component_name=MagicMind

# 2. 网络图谱
Cambricon PyTorch 支持的典型网络及移植流程。
|网络名称|操作目录|备注|
|----|-------|-------|

# 3. 下载镜像

下载官方发布的 MagicMind 框架 Docker 镜像文件。 可前往寒武纪开发者社区注册账号按需下载, 也可在官方提供的专属FTP账户指定路径下载。

官方发布的镜像包命名格式: magicmind_<x.y.z>-1_ubuntu<a.b>_docker.tar.gz , 其中 <x.y.z> 为MagicMind 版本号，<a.b> 为操作系统版本号。

# 4. 加载镜像
```bash
#加载Docker镜像
#./load-image-dev.sh /DATA_SPACE/kang/ftp/docker/magicmind_1.1.0-1_ubuntu18.04.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 5. 启动容器
```bash
#启动容器
./run-container-dev.sh
```

# 6. 环境确认
容器中，默认已安装 magicmind 和 benchmark 模块，验证方式如下：
```bash
#环境确认命令
pip list |grep benchmark && pip list |grep magicmind
```
输出结果如下，说明环境正常。
```bash
root@localhost:/# pip list |grep benchmark && pip list |grep magicmind
benchmark               0.10.0
WARNING: You are using pip version 22.0.4; however, version 22.2.2 is available.
You should consider upgrading via the '/usr/bin/python3.7 -m pip install --upgrade pip' command.
magicmind               0.10.0
WARNING: You are using pip version 22.0.4; however, version 22.2.2 is available.
You should consider upgrading via the '/usr/bin/python3.7 -m pip install --upgrade pip' command.
root@localhost:/#
```
如果没有以上输出，可自行安装 magicmind 和 benchmark
```bash
pip3 install magicmind_<x.y.z>-cp37-cp37m-linux_<arch>.whl
#pip install magicmind-0.10.0-cp37-cp37m-linux_x86_64.whl
#pip install benchmark-0.10.0-cp37-cp37m-linux_x86_64.whl
```
<x.y.z> 为MagicMind 版本号，<arch> 为CPU 架构。