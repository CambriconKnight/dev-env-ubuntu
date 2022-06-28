
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 TensorFlow 框架的 Docker 容器。 官方发布的 Docker 容器已经对 TensorFlow 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon TensorFlow 框架进行各类网络的部署、移植、在线/离线推理等验证工作。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7
- 软件栈版本: 1.7.602
- 深度学习框架: TensorFlow
- 镜像文件: tensorflow-1.4.0-2-tf1-ubuntu18.04-py3.tar
- Docker: ⽤⼾需要⾃⾏安装docker（版本要求 >= v19.03）

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |
| MLU270-F4/S4   | 一套       |使用板卡自带的8pin连接器连接主机电源|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                   |
| :-------------------- | :-------------------------------                      | :----------------------------------    |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                           |
| Docker Image          | tensorflow-1.4.0-2-tf1-ubuntu18.04-py3.tar            | 官方发布的 TensorFlow 框架 Docker 镜像文件 |
| Driver_MLU270         | neuware-mlu270-driver-dkms_4.9.2_all.deb              | 依操作系统选择                           |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. 网络图谱
Cambricon PyTorch 支持的典型网络及移植流程。
|网络名称|操作目录|备注|
|----|-------|-------|

# 3. 下载镜像

下载官方发布的 TensorFlow 框架 Docker 镜像文件。 可前往寒武纪开发者社区注册账号按需下载, 也可在官方提供的专属FTP账户指定路径下载。

官方发布的镜像包命名格式: tensorFlow-<x.y.z>-2-tf1-ubuntu<a.b>-py3.tar , 其中 <x.y.z> 为 TensorFlow 版本号，<a.b> 为操作系统版本号。

# 4. 加载镜像
```bash
#加载Docker镜像
#./load-image-dev.sh /data/ftp/product/MLU270/v1.7.0-2/Ubuntu18.04/TensorFlow/docker/tensorflow-1.4.0-2-tf1-ubuntu18.04-py3.tar
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 5. 启动容器
```bash
#启动容器
./run-container-dev.sh
```
