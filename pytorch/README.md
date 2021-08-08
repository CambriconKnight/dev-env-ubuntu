
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. Overview
本目录下脚本适配于官方发布的 Pytorch 框架的 Docker 容器。 官方发布的 Docker 容器已经对 Pytorch 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon PyTorch 框架进行各类网络的部署、移植、在线/离线推理等验证工作。

**运行环境**

- 版本: 1.7.602
- 框架: Pytorch
- 镜像: pytorch-0.15.602-ubuntu16.04.tar

# 2. Structure
Cambricon PyTorch 支持的典型网络及移植流程.
|网络名称|操作目录|备注|
|----|-------|-------|
|`YOLOv4`|./yolov4|以输入416*416为例|

# 3. Load
```bash
#加载Docker镜像
./load-image-ubuntu16.04-pytorch.sh ${FULLNAME_IMAGES}
```

# 4. Run
```bash
#启动容器
./run-container-ubuntu16.04-pytorch.sh
```
