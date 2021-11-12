<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu">
        <img alt="cambricon" src="./res/cambricon.jpg" height="140" />
        <h1 align="center">MLU常用算法移植及验证工具集</h1>
    </a>
</p>

# 1. 概述
本[工具集](https://gitee.com/cambriconknight/dev-env-ubuntu)主要基于寒武纪MLU进行移植环境的搭建及常用算法的移植与验证。力求压缩寒武纪MLU环境搭建与功能验证的时间成本, 以便快速上手[寒武纪MLU设备](https://www.cambricon.com/)。

>![](./res/note.gif) **功能说明：**
>- 可基于 Dockerfile 编译镜像，也可直接加载官网提供的镜像。
>- 支持 Caffe、PyTorch、TensorFlow 深度学习框架。
>- 支持常用算法的部署、移植、在线/离线推理等验证。

*本工具集仅用于个人学习，打通流程； 不对效果负责，不承诺商用。*

## 网络移植图谱

*以下仅为常用网络MLU移植教程，并未包含寒武纪支持的全部网络, 如有新网络需求, 可在 [issue](https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/issues) 区讨论。*
*在Cambricon Caffe/TF/Pytorch 框架下可支持CPU、MLU（逐层模式）和MFUS（融合模式）三种模式上运行。*


|  AI框架 | 应用领域  | 原始网络  | 网络移植教程   | CPU | MLU | MFUS | OFFLINE |
|:----  |:-------  |:----   |:----   |:----:    |:----: |:----: |:----: |
| Caffe | 图像分类  | [AlexNet](https://github.com/BVLC/caffe/tree/master/models/bvlc_alexnet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/alexnet)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 图像分类  | [ResNet-18](https://github.com/HolmesShuan/ResNet-18-Caffemodel-on-ImageNet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/resnet18)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 图像分类  | [ResNet-50](https://github.com/KaimingHe/deep-residual-networks)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/resnet50)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 图像分类  | [VGG16](https://www.robots.ox.ac.uk/~vgg/research/very_deep/)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/vgg16)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 图像分类  | [MobileNetV1](https://github.com/chuanqi305/MobileNet-SSD)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/mobilenetv1)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 图像分类  | [MobileNetV2](https://github.com/eric612/MobileNet-SSD-windows/tree/master/models/MobileNetV2)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/mobilenetv2)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [Faster R-CNN](https://github.com/rbgirshick/py-faster-rcnn)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/faster-rcnn)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [RFCN](https://github.com/YuwenXiong/py-R-FCN)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/rfcn)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [MTCNN](https://github.com/kpzhang93/MTCNN_face_detection_alignment)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/mtcnn)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [SSD-VGG16](https://github.com/weiliu89/caffe/tree/ssd)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/ssd-vgg16)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [YOLOv3](https://github.com/pjreddie/darknet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/yolov3-416)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 目标检测  | [YOLOv4](https://github.com/pjreddie/darknet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/yolov4‑mish‑416)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 语义分割  | [SegNet](https://github.com/alexgkendall/SegNet-Tutorial)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/segnet)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Caffe | 关键点检测  | [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/caffe/openpose)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [ResNet-34](https://github.com/pytorch/vision)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/resnet34)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [ResNet-50](https://github.com/pytorch/vision)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/resnet50)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [ResNet-101](https://github.com/pytorch/vision)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/resnet101)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [VGG16](https://github.com/pytorch/vision)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/vgg16)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [MobileNetV1](https://modelzoo.co/model/pytorch-mobilenet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/mobilenetv1)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [MobileNetV2](https://modelzoo.co/model/mobilenetv2)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/mobilenetv2)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 图像分类  | [DenseNet121](https://github.com/pytorch/vision/blob/main/torchvision/models/densenet.py)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/densenet121)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [Faster R-CNN](https://github.com/pytorch/vision)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/faster-rcnn)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [Mask R-CNN](https://github.com/facebookresearch/maskrcnn-benchmark)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/mask-rcnn)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [SSD-VGG16](https://github.com/amdegroot/ssd.pytorch)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/ssd-vgg16)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [YOLOv3](https://modelzoo.co/model/pytorch-yolov3-pytorch)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/yolov3)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [YOLOv4](https://github.com/AlexeyAB/darknet.git)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/yolov4)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [YOLOv4-Tiny](https://github.com/AlexeyAB/darknet.git)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/yolov4-tiny)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [YOLOv5](https://github.com/ultralytics/yolov5.git)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/yolov5)  |  ✅ |  ✅ |  ✅ |  ✅ |
| Pytorch | 目标检测  | [CenterNet](https://github.com/xingyizhou/CenterNet)  | [移植教程](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/centernet)  |  ✅ |  ✅ |  ✅ |  ✅ |


## 硬件环境准备

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |
| MLU270-F4/S4   | 一套       |使用板卡自带的8pin连接器连接主机电源|

## 软件环境准备

| 名称                   | 版本/文件                                              | 备注                                  |
| :-------------------- | :-------------------------------                      | :----------------------------------  |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Driver_MLU270         | neuware-mlu270-driver-aarch64-4.9.8.tar.gz            | 依操作系统选择                         |
| CNToolkit_MLU270      | cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb               | 依操作系统选择                         |
| CNML_MLU270           | cnml_7.10.3-1.ubuntu16.04_amd64.deb                   | 依操作系统选择                         |
| CNPlugin_MLU270       | cnplugin_1.12.4-1.ubuntu16.04_amd64.deb               | 依操作系统选择                         |
| CNNL_MLU270           | cnnl_1.3.0-1.ubuntu16.04_amd64.deb                    | 依操作系统选择                         |
| CNCL_MLU270           | cncl_0.8.0-1.ubuntu16.04_amd64.deb                    | 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

## 资料下载

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

Ubuntu18.04: http://mirrors.aliyun.com/ubuntu-releases/18.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. Structure

以下基于 Dockerfile 自行编译各个框架镜像。也可进入对应AI框架目录(如:caffe/pytorch目录)直接运行脚本加载官网提供的镜像。

## 2.1. 脚本
```bash
.
├── build-image-ubuntu-dev.sh
├── load-image-ubuntu-dev.sh
├── run-container-ubuntu-dev.sh
└── save-image-ubuntu-dev.sh
```
## 2.2. 依赖项
`driver`: [neuware-mlu270-driver-aarch64-4.9.8.tar.gz](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/Driver/neuware-mlu270-driver-aarch64-4.9.8.tar.gz)

`cntoolkit`: [cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNToolkit/cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb)

`cnml`: [cnml_7.10.3-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNML/cnml_7.10.3-1.ubuntu16.04_amd64.deb)

`cnplugin`: [cnplugin_1.12.4-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNPlugin/cnplugin_1.12.4-1.ubuntu16.04_amd64.deb)

`cnnl`: [cnnl_1.3.0-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNNL/cnnl_1.3.0-1.ubuntu16.04_amd64.deb)

`cncl`: [cncl_0.8.0-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNCL/cncl_0.8.0-1.ubuntu16.04_amd64.deb)

# 3. Clone
```bash
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
```

# 4. Build
```bash
#编译Docker镜像 Ubuntu16.04,默认编译Ubuntu16.04,Docker镜像
./build-image-ubuntu-dev.sh
#./build-image-ubuntu-dev.sh 16.04
#编译Docker镜像 Ubuntu18.04
#./build-image-ubuntu-dev.sh 18.04
```

# 5. Load
```bash
#加载Docker镜像
./load-image-ubuntu-dev.sh
```

# 6. Run
```bash
#启动容器
./run-container-ubuntu-dev.sh
```

# 7. Install Dependent

Caffe/Pytorch 框架编译安装前，需要安装CNToolkit 软件包和 CNML、CNNL、CNPlugin、CNCL 等组件。具体安装步骤，参见《寒武纪CNToolkit 软件包安装升级使用手册》和相应的寒武纪用户手册。

## 7.1. CNToolkit
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNToolkit
dpkg -i cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb
cd /var/cntoolkit-1.7.5/
dpkg -i *.deb
```
## 7.2. CNML
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNML
dpkg -i cnml_7.10.3-1.ubuntu16.04_amd64.deb
```

## 7.3. CNPlugin
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNPlugin
dpkg -i cnplugin_1.12.4-1.ubuntu16.04_amd64.deb
```

## 7.4. CNNL
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNNL
dpkg -i cnnl_1.3.0-1.ubuntu16.04_amd64.deb
```

## 7.5. CNCL
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/CNCL
dpkg -i cncl_0.8.0-1.ubuntu16.04_amd64.deb
```

# 8. Deploy SDK
## 8.1 CaffeSDK
### 8.1.1 部署Cambricon Caffe
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/Caffe/src
tar zxvf caffe-v5.4.0.tar.gz -C /opt/work/
#Version:1.6.602
#cd /home/ftp/mlu270/1.6.602/caffe/src
#tar zxvf caffe-v5.3.604.tar.gz -C /opt/work/
```

### 8.1.2 编译Cambricon Caffe
```bash
#以下操作都在容器中操作
#设置压缩包解压后的根目录
export ROOT_HOME=/opt/work
cd $ROOT_HOME
#创建数据集和模型软链接目录(以实际目录为准):DATASET_HOME, CAFFE_MODELS_DIR
ln -s /data/datasets datasets
ln -s /data/models models
#设置环境变量
source $ROOT_HOME/env_caffe.sh
#进入以下路径，运行脚本编译Cambricon Caffe
cd ${CAFFE_HOME}/src/caffe/scripts
bash build_caffe_mlu270_cambricon_release.sh
#编译完成后,结果确认:
#打开目录build/lib，若编译生成了libcaffe.so 和_caffe.so 两个文件，
#则说明Cambricon Caffe 编译成功。
ls -la ${CAFFE_HOME}/src/caffe/build/lib
```

### 8.1.3 安装Cambricon Caffe
Cambricon Caffe 编译完成以后，进入build 目录执行以下命令即可完成Cambricon Caffe 的安装
```bash
#以下操作都在容器中操作
cd ${CAFFE_HOME}/src/caffe/build
make install
```

### 8.1.4 验证Cambricon Caffe
Cambricon Caffe编译及安装完成后,可在build 目录执行以下命令验证安装。
该命令必须在MLU 服务器上运行。若结果全通过，说明Cambricon Caffe 安装成功。
```bash
#以下操作都在容器中操作
cd ${CAFFE_HOME}/src/caffe/build
make runtest
#注:如果遇到错误,可以暂时忽略.
```

## 8.2 PyTorchSDK
### 8.2.1 部署Cambricon PyTorch
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version: 1.7.602
cd /home/ftp/product/GJD/MLU270/1.7.602/Ubuntu16.04/PyTorch/src
tar zxvf pytorch-v0.15.602.tar.gz -C /opt/work/
```

### 8.2.2 编译与安装Cambricon PyTorch
此章节包含Cambricon PyTorch的编译\安装\验证.
### 8.2.2.1 环境设置
```bash
#以下操作都在容器中操作
#设置压缩包解压后的根目录
export ROOT_HOME=/opt/work/cambricon_pytorch
cd $ROOT_HOME
#创建数据集和模型软链接目录(以实际目录为准):DATASET_HOME, CAFFE_MODELS_DIR
ln -s /data/datasets datasets
ln -s /data/models models
#设置环境变量
cd $ROOT_HOME
source env_pytorch.sh
```

### 8.2.2.2 一键编译
```bash
#以下操作都在容器中操作
#进入以下路径，运行脚本编译Cambricon PyTorch
cd $ROOT_HOME
#脚本包含包含后面的分步编译中1~4步骤
./configure_pytorch.sh 0
```

### 8.2.2.3 分步编译
```bash
#分步编译（建议使用）
# 1.在 Cambricon PyTorch 或 Cambricon Catch 源码目录下安装 Virtualenv 并激活虚拟环境。本例使用Cambricon Catch 目录。
cd $ROOT_HOME/pytorch/src/catch
# 安装虚拟环境,此处 Python 3 可按需更换为指定版本
virtualenv -p /usr/bin/python3 venv/pytorch
# 激活虚拟环境(source pytorch/src/catch/venv/pytorch/bin/activate)
source venv/pytorch/bin/activate
# 2.将 Cambricon Catch 中所包含的 Cambricon PyTorch 的 Patch 打到 Cambricon PyTorch 仓库中
cd script
bash apply_patches_to_pytorch.sh
# 3.安装 Cambricon PyTorch 所依赖的第三方包，并编译 Cambricon PyTorch。
cd ../../pytorch/
pip install -r requirements.txt
rm -rf build
python setup.py install
# 4.安装 Cambricon Catch 所依赖的第三方包，并编译 Cambricon Catch。第三方依赖包列表可在 Catch 源码主目录下的 requirements.txt 中查询。
cd ../catch
pip install -r requirements.txt
rm -rf build
python setup.py install
###################################################
# 5.编译并安装 Cambricon Vision. 在 Cambricon Vision 目录下清理环境，然后编译并安装 Cambricon Vision。
cd ../vision/
#cd ${VISION_HOME}
rm -rf dist
# 激活虚拟环境(source pytorch/src/catch/venv/pytorch/bin/activate)
#编译 TorchVision
python setup.py bdist_wheel
#安装该版本 release 所对应的 torchvision 版本
pip install dist/torchvision-*.whl

# 6.设置以下环境变量
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/neuware/lib64

# 7.确认编译结果
#对于 Cambricon PyTorch,打开目录 build/lib,若编译生成了 libtorch_pytorch.so 和 libtorch.so等文件,则说明 Cambricon PyTorch 编译成功。
#对于 Cambricon Catch,打开 build/lib.linux‐* 目录,若编译生成了 _MLUC.so 等文件,则说明#Cambricon Catch 编译成功。
#也可在 Python 中引用 Cambricon PyTorch 与 Cambricon Catch 测试是否编译成功。
#检测是否编译成功。如果可以import torch_mlu，不出现找不到的错误则代表编译成功.如果编译成功,将会输出 CNML 与 CNRT 的版本信息
python
import torch_mlu

# 如需退出虚拟环境，可以暂不退出，后续步骤继续在虚拟环境中进行
# 退出后，使用命令 source $ROOT_HOME/pytorch/src/catch/venv/pytorch/bin/activate 重新进入虚拟环境
#source $ROOT_HOME/pytorch/src/catch/venv/pytorch/bin/activate
deactivate

# 更多详细信息,请查看<Cambricon-PyTorch-User-Guide-CN-v*.*.*.pdf>
```

# 9.Save

保存当前容器到镜像文件, 实现镜像内容持久化。

```bash
#保存当前容器到镜像文件, 实现镜像内容持久化。
./save-image-ubuntu-dev.sh
```