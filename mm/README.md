
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 MagicMind 框架的 Docker 容器。 官方发布的 Docker 容器已经对 MagicMind 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon MagicMind 框架进行各类网络的部署、移植、在线/离线推理等验证工作。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7(以下重点以Ubuntu18.04为例说明)
- 软件栈版本: 0.10.1
- 深度学习框架: MagicMind
- 镜像文件: magicmind_0.10.0-1_ubuntu18.04.tar.gz
-
**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.4 x16; 机箱风扇需满足板卡被动散热要求 |
| MLU370-S4     | 一套       |机箱风扇需满足MLU370板卡被动散热要求|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Docker Image          | magicmind_0.10.0-1_ubuntu18.04.tar.gz                 | 官方发布的 MagicMind 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_4.20.6_amd64.deb| 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

Ubuntu18.04: http://mirrors.aliyun.com/ubuntu-releases/18.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. Structure
Cambricon PyTorch 支持的典型网络及移植流程.
|网络名称|操作目录|备注|
|----|-------|-------|


# 3. Load
```bash
#加载Docker镜像
#./load-image-dev.sh /data/ftp/product/MLU370/inference/1.4.0/magicmind_v0.10.0/Ubuntu/18.04/abiold/docker/magicmind_0.10.0-1_ubuntu18.04.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 4. Run
```bash
#启动容器
./run-container-dev.sh
```
