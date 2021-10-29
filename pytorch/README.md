
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 Pytorch 框架的 Docker 容器。 官方发布的 Docker 容器已经对 Pytorch 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon PyTorch 框架进行各类网络的部署、移植、在线/离线推理等验证工作。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7(以下重点以Ubuntu16.04为例说明)
- 软件栈版本: 1.7.602
- 深度学习框架: Pytorch
- 镜像文件: pytorch-0.15.602-ubuntu16.04.tar
-
**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |
| MLU270-F4/S4   | 一套       |使用板卡自带的8pin连接器连接主机电源|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Docker Image          | pytorch-0.15.602-ubuntu16.04.tar                      | 官方发布的 Pytorch 框架 Docker 镜像文件 |
| Driver_MLU270         | neuware-mlu270-driver-dkms_4.9.2_all.deb              | 依操作系统选择                         |
| CNToolkit_MLU270      | cntoolkit_1.7.3-2.ubuntu16.04_amd64.deb               | 依操作系统选择                         |
| CNML_MLU270           | cnml_7.10.3-1.ubuntu16.04_amd64.deb                   | 依操作系统选择                         |
| CNPlugin_MLU270       | cnplugin_1.12.4-1.ubuntu16.04_amd64.deb               | 依操作系统选择                         |
| CNNL_MLU270           | cnnl_1.3.0-1.ubuntu16.04_amd64.deb                    | 依操作系统选择                         |
| CNCL_MLU270           | cncl_0.8.0-1.ubuntu16.04_amd64.deb                    | 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. Structure
Cambricon PyTorch 支持的典型网络及移植流程.
|网络名称|操作目录|备注|
|----|-------|-------|
|`YOLOv4`|./yolov4|以输入 416 * 416 为例|
|`YOLOv4-Tiny`|./yolov4-tiny|以输入 416 * 416 为例|
|`YOLOv5`|./yolov5|以 YOLOv5s 模型输入 640 * 640 为例|

# 3. Load
```bash
#加载Docker镜像
#./load-image-dev.sh /data/ftp/product/GJD/MLU270/1.7.602/Docker/pytorch-0.15.602-ubuntu18.04.tar
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 4. Run
```bash
#启动容器
./run-container-dev.sh
```
