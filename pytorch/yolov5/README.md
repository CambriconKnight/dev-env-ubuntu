<p align="center">
    <a href="https://github.com/CambriconKnight/easy-deploy-mlu/tree/master/pytorch/yolov5">
        <img alt="yolo-logo" src="./res/yolov5.jpg" height="60" />
        <h1 align="center">MLU算法移植教程-YOLOv5</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
[YOLO](https://pjreddie.com/darknet/yolo) (You Only Look Once)系列目标检测算法(v1-v3)是一种快速紧凑的开源对象检测模型，与其它网络相比，同等尺寸下性能更强，并且具有很不错的稳定性，是第一个可以预测对象的类别和边界框的端对端神经网络。2020年2月YOLO之父Joseph Redmon宣布退出计算机视觉研究领域，2020 年 4 月 Alexey Bochkovskiy 发布了 YOLOv4 ，2020 年 6 月 Ultralytics发布了 YOLOv5。

[YOLOv5](https://github.com/ultralytics/yolov5)使用 Pytorch 框架，而 YOLO V4采用的还是 Darknet 框架。并且 YOLOv5 并不是一个单独的模型，而是一个模型家族，包括了YOLOv5s、YOLOv5m、YOLOv5l、YOLOv5x、YOLOv5x+TTA, 详细性能与精度数据如下图[./res/yolov5-performance.jpg](./res/yolov5-performance.jpg)。YOLOv4的代码库地址：https://github.com/ultralytics/yolov5 。

下面我们就来看看该算法如何在基于寒武纪MLU智能加速卡上移植开发。

整个移植过程大体可分为环境准备、模型量化、在线推理、生成离线模型、离线推理、性能测试、精度测试共七个步骤，以下详细描述整个移植过程。相关移植套件参见[dev-env-ubuntu](https://github.com/CambriconKnight/dev-env-ubuntu)。

- **相关开发资料可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载，也可在官方提供的专属FTP账户指定路径下载。**
- **有关寒武纪产品开发资料的公开链接汇总参见[cam-dev-info](https://gitee.com/cambriconknight/cam-dev-info)。**

# 2. 环境准备
准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 设置环境变量 >> 准备网络模型 >> 创建模型目录 >> 进入虚拟环境
## 2.1. 物理环境
准备服务器/PC机 >> 安装MLU卡 >> 检测MLU卡是否识别 >> 检测PCIE资源分配是否正常
```bash
#检测MLU卡是否识别
lspci | grep cabc
#检测PCIE资源分配是否正常
lspci -d:270 -vvv
```

## 2.2. 获取资料
开通FTP账号，使用filezilla登录并下载所需开发资料。
主要资料有：MLU开发文档，Driver安装包，Docker镜像，数据集，模型。

**下载地址:**

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

## 2.3. 安装驱动
驱动安装手册在线文档: https://www.cambricon.com/docs/driver/index.html
注：安装驱动前，请先安装MLU板卡，再进行驱动安装。

## 2.4. 安装Docker
Docker安装参见：https://docs.docker.com/engine/install/

# 3. 对齐Torch版本
由于官方 YOLOv5 依赖 PyTorch 版本 >=1.6， 寒武纪版本为1.3. 所以在进行模型转换操作前，需要在标准pytorch 环境中（非MLU版本）， 将网络模型转换为 Torch 版本为1.3的模型文件。该操作可以有两种方式实现：  1、主机环境；2、Docker环境。操作之前需要从官网或者自训练工程中，准备网络模型。

## 3.1. 准备网络模型
从官网下载配置文件及模型权重,以下以yolov5(416*416)为例进行演示.
|Name|URL|Note|
|----|-------|-------|
|`YOLOv5`|https://github.com/ultralytics/yolov5.git|Ultralytics官网GitHub地址|
|`yolov5s.yaml`|https://github.com/ultralytics/yolov5/blob/master/models/yolov5s.yaml|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5s.pt`|https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5s.pt|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5m.yaml`|https://github.com/ultralytics/yolov5/blob/master/models/yolov5m.yaml|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5m.pt`|https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5m.pt|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5l.yaml`|https://github.com/ultralytics/yolov5/blob/master/models/yolov5l.yaml|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5l.pt`|https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5l.pt|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5x.yaml`|https://github.com/ultralytics/yolov5/blob/master/models/yolov5x.yaml|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|
|`yolov5x.pt`|https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5x.pt|[v5.0](https://github.com/ultralytics/yolov5/releases/tag/v5.0)|

## 3.2 对齐Torch版本
### 3.2.1 主机环境

以下操作基于HOST主机环境，实现网络模型版本对齐。步骤如下：

1. 确认Host主机，已安装pytorch，版本>=1.6；
pytorch安装方法参考：https://pytorch.org/get-started/locally/

2. 复制目录【aligntorch】到Host主机任意目录，并进入【aligntorch】目录；
```bash
cp -rf aligntorch ./
cd aligntorch
```

3. 执行脚本完成Torch版本对齐，得到1.3版本网络模型：
```bash
./run_aligntorch.sh
```
**说明：该脚本，默认转换 YOLOv5 官方的 yolov5s.pt 模型，输出路径为【output】。用户转换自己训练的模型时， 替换【weights】目录下的模型文件和修改脚本中需要转换的模型名称的宏定义 MODDEL_NAME_ORG。**

```bash
#################### main ####################
WEIGHTS_DIR=$PWD/weights			#原始模型存放路径
MODDEL_NAME_ORG=yolov5s.pt		#需要转换的模型名称,如果是使用自己训练的模型，需要将模型放到weights目录，并修改MODDEL_NAME_ORG宏定义
```

### 3.2.2 Docker环境
使用目录[./aligntorch/docker](./aligntorch/docker)下的文件，可以快速构建一个用于yolov5模型降版本的容器。

使用说明，请参考[./aligntorch/docker/readme.md](./aligntorch/docker/readme.md)文件。

加载容器后，进入当前目录，执行上一节版本对齐脚本。

# 4. 模型转换
模型转换操作基于上一步生成的模型文件，进行后续模型量化、在线推理、转离线模型操作。操作完成后，会生成.cambricon后缀的离线模型。
**此操作建议在官方提供的Docker容器中进行。**
## 4.1. 启动Docker
有关加载与启动Docker参见：[../README.md](../README.md)

## 4.2 环境准备

**以下步骤以yolov5s为例, 介绍如何在基于寒武纪MLU智能加速卡上移植开发。**
  1、复制目录convertmodel到Docker中任意工作目录，并进入目录convertmodel；
```bash
cp -rf convertmodel ./
cd convertmodel
```
  2、复制第3章得到的模型文件yolov5s.pth到当前目录,yaml文件到model目录
```bash
cp yolov5s.pth ./
cp yolov5s.yaml ./models
```

## 4.3 模型转换-简略版
  3、执行脚本：
```bash
./run_convertmodel.sh
#说明：该脚本，默认转换YOLOv5官方的yolov5s.pt模型，输出名称为：yolov5s.carmbrcion
#用户转换自己训练的模型时，替换模型文件和yaml文件即可。
```

## 4.4 模型转换-单步执行版
注：4.3节和4.4节二选一执行即可。
### 4.4.1. cpu推理原始模型
```
python3 convertmodel.py --arg cpu
```
### 4.4.2. 模型量化
```
python3 convertmodel.py --arg quant
```

### 4.4.3. mlu融合推理及生成离线模型
```
python3 convertmodel.py --arg mfus --genoff true
```
# 5. 离线推理
离线推理，基于上一步生成的离线模型文件进行操作，生成推理结果。
操作环境与上一步一致。
1、复制目录offline到Docker中任意工作目录，并进入目录offline。
```bash
cd offline
```
2、离线推理：
```bash
./run_offline.sh
#说明：该脚本，基于上一步生成的离线模型文件【yolov5s_int8_4b_4c.cambricon】和样例图片【image.jpg】，
# 推理输出结果为：./output/offline_result
```

# 6. 性能测试
```bash
#cnrtexec为离线模型的性能测试程序，利用随机数来测试离线模型的demo.
cd ${PATH_NETWORK_MODELS_MLU}
#mlu270_yolov4_4b4c_fp16
/home/share/test/cnrtexec/cnrtexec ${PATH_NETWORK_MODELS_MLU}/mlu270_yolov4_4b4c_fp16.cambricon 0 96 8 0
#mlu270_yolov4_4b4c_fp32
#/home/share/test/cnrtexec/cnrtexec ${PATH_NETWORK_MODELS_MLU}/mlu270_yolov4_4b4c_fp32.cambricon 0 96 8 0
#cnrtexec传参有以下几个：
#--offline_model：指定离线模型
#--dev_id：声明使用的mlu-device，只有一块为0，默认为0；
#--sample_count：测试使用的sample数
#--nTaskCount：测试启用的线程数
#--affinity：内存通道亲和性设置，通常设置为0即可
#使用时可参考传参使用，裁减掉这些传参，使用固定值即可，简化调用。
#cnrtexec 参数举例说明
#cnrtexec resnet18_intx.cambricon 0 500 2 0
#argv[1]    resnet18_intx.cambricon   #离线模型文件
#argv[2]    0                         #device id
#argv[3]    500                       #batch数，500表示的500*N batch张图片，不是500张图片
#argv[4]    2                         #线程数
#argv[5]    0                         #affinity
#注意事项：
#1.该demo未包含前处理，需要在推理前添加C++前处理，确认与在线推理使用的前处理保持一致，否则会影响结果；
#2.如模型量化使用了firstconv，则推理前不再需要做前处理，与在线一致；
#3.生成离线模型后，可通过查看模型描述文件.cambricon_twins，获取离线模型的输入信息；
#4.该demo使用的是分配的随机数进行推理，在Cnrtexec.cpp中，MLUInfer::Detect传入的data并没有被使用，实际使用时，需将输入数据拷入，进行后续推理；
#5.对于FLOAT32类型的输出结果，可以直接使用。但对于FLOAT16的输出，需要将数据类型转换为FLOAT32才可以在CPU上使用；
```
# 7. 精度测试


# 8. 性能优化

