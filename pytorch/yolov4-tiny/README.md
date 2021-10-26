<p align="center">
<a href="https://github.com/CambriconKnight/easy-deploy-mlu/tree/master/pytorch/yolov4">
<h1 align="center">YOLOv4-tiny算法移植教程</h1>
</a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
YOLOv4-tiny是YOLOv4的压缩版本。它是基于YOLOv4使网络结构更加简单，降低参数，使之成为在移动和嵌入式设备开发可行的建议。

- **相关开发资料可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载，也可在官方提供的专属FTP账户指定路径下载。**
- **有关寒武纪产品开发资料的公开链接汇总参见[cam-dev-info](https://gitee.com/cambriconknight/cam-dev-info)。**

# 2. 环境准备
准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 设置环境变量 >> 准备网络模型 >> 创建模型目录 >> 进入虚拟环境

# 3. YOLOv4-tiny 网络环境准备

## 3.1.版本信息

| 框架 | pytorch |
| :-------------------- | :------------------------------- |
| 模型 | yolov4-tiny |
| MLU SDK | v1.7.604 |
| MLU Docker 镜像 | pytorch-0.15.604-ubuntu18.04.tar.gz |
| 数据集 | coco val2017 |
| 数据集路径 | ftp://product/datasets/MLU270_datasets_COCO.tar.gz |


注: 如果使用1.7.602，yolov4-tiny 需要打补丁。


## 3.2.操作步骤
### 3.2.1 加载容器
```bash
#加载Docker镜像
#./load-image-ubuntu18.04-pytorch.sh /data/ftp/product/GJD/MLU270/1.7.604/Docker/pytorch-0.15.604-ubuntu18.04.tar
./load-image-ubuntu18.04-pytorch.sh ${FULLNAME_IMAGES}
```

### 3.2.2 进入容器
```bash
#启动容器
./run-container-ubuntu18.04-pytorch.sh
```
**以下操作都是在docker容器中进行的**

### 3.2.3 torch 工程目录
- 确认torch 目录
```bash
#发布容器默认是下面目录
cd /torch/
```

### 3.2.4 进入虚拟环境
- 进入pytorch虚拟环境
```bash
#源码编译的activate 路径
source /torch/venv3/pytorch/bin/activate
```
- torch 环境验证
```bash
python3 -c "import torch;print(torch.__version__,torch.__file__)"
```
返回信息如下：
```bash
1.3.0a0+b8d5360 /torch/venv3/pytorch/lib/python3.6/site-packages/torch/__init__.py
```
- 安装pip 依赖
```bash
/torch/venv3/pytorch/bin/python -m pip install --upgrade pip
pip install matplotlib
pip install opencv-python
```

# 4.模型准备
## 4.1.1. 下载YOLOv4-tiny代码，放到Docker中. 设置环境变量, 解压COCO数据集到yolov4-tiny目录下。

- 进入yolov4-tiny 工作目录下 
```bash
cd /home/share/yolov4-tiny/
```

### 4.1.2. 设置环境变量
```bash
export TORCH_HOME=$PWD/pytorch_models
export DATASET_HOME=/data/datasets
export COCO_PATH_PYTORCH=$DATASET_HOME/
```
- **注: 必须进入yolov4-tiny文件夹下,设置环境变量**

### 4.1.3. 准备测试数据集

测试 YOLOv4-Tiny 需要依赖 COCO 数据集并且放到 $DATASET_HOME[/data/datasets] 文件夹下。数据集可以直接用COCO官方数据集，也可以从ftp上下载/product/datasets/MLU270_datasets_COCO.tar.gz. 
```bash
#进入模型目录
cd $DATASET_HOME
#解压数据集
tar -zxvf MLU270_datasets_COCO.tar.gz -C .
```

## 4.2. 准备网络模型
从官网下载配置文件及模型权重,以下以 yolov4-tiny(416*416) 为例进行演示.
|Name|URL|Note|
|----|-------|-------|
|`Darknet`|https://github.com/AlexeyAB/darknet.git||
|`yolov4-tiny.cfg`|https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg||
|`yolov4-tiny.weights`|https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights||

```bash
#进入模型目录
cd /home/share/yolov4-tiny/online/yolov4/model
#下载 yolov4-tiny.cfg
wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg
#下载 yolov4-tiny.weights
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights
#注：如果是自己的网络，则不用再下载。可以直接替换目录中【yolov4.cfg】、【yolov4.weights】.
```
以上操作也可直接运行脚本，一键下载网络模型和权重。
```bash
./download_weights.sh
```
## 4.3. 模型量化

基于上一个步骤中准备好的网络模型，生成量化模型。可以使用脚本一键量化也可以分步执行。

### 4.3.1. 一键量化：
```bash
#进入操作目录
cd /home/share/yolov4-tiny/online/yolov4
#一键生成 int8 量化模型
./run_quant.sh
```

### 4.3.2. 分步量化
分步量化，可根据具体需求修改量化参数。
- 生成 pytorch 框架网络模型
```bash
# 生成pytorch 网络模型
python eval.py -cfgfile model/yolov4-tiny.cfg -weightfile model/yolov4-tiny.weights -darknet2pth true
#拷贝模型到origin/checkpoints 目录
mv yolov4-tiny.pth $TORCH_HOME/origin/checkpoints/yolov4-tiny.pth
```

- 模型量化
```bash
#INT8 Quantize
python eval.py -quantized_mode 1 -quantization True -yolov4_version yolov4-tiny
```
- 参数说明
```bash
• ‑quantized_mode：设置使用的权重为原始权重、 int8、 int16、分通道 int8 和分通道 int16 量化的权重。
• ‑quantization：设置是否使能量化模式。
• yolov4_version
#拷贝模型到int8/checkpoints 目录
mv yolov4-tiny.pth $TORCH_HOME/int8/checkpoints/
```
备注：如果int16 量化，注意模型存放目录，int16 需要拷贝到int16目录 $TORCH_HOME/int16/checkpoints/


# 5.在线运行
```bash
#进入操作目录
#cd /home/share/yolov4-tiny/online/yolov4
#INT8 Inference,for float16 input
python eval.py -half_input 1 -quantized_mode 1 -datadir $COCO_PATH_PYTORCH/COCO -yolov4_version yolov4-tiny
```
- 参数说明
```bash
• ‑image_number：设置实际希望运行的样本数量。
• ‑quantized_mode：设置使用的权重为原始权重、 int8、 int16、分通道 int8 和分通道 int16 量化的权
重。
• ‑half_input：设置输入 tensor 为 Float 或 Half 类型。
```
备注：测试精度需要使用5000张以上图片，测试图片太少，测试精度值不准确。

# 6. 离线运行
```bash
#进入操作目录
cd /home/share/yolov4-tiny/offline
export TORCH_HOME=$TORCH_HOME/int8/
#
python ./genoff/genoff.py -fake_device 0 -model yolov4-tiny -mcore MLU270 -mname mlu270_yolov4-tiny_4b4c_fp16 -half_input 1 -core_number 4 -batch_size 4 -input_format 0
```
genoff.py脚本参数使用说明如下,详细说明见《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节【离线模型生成工具】。
- -fake_device:用于设置是否不使用 mlu 设备生成离线模型文件,使用自动检索最优模型必须使用mlu 设备,此参数必须设置为 0。
- -model:指定网络名称。
- -mcore:指定硬件架构版本,当前支持 MLU270。
- -mname:指定生成离线模型文件名,默认为 offline。
- -half_input:指定 input tensor 类型,half 或者 float。
- -core_number:指定离线模型使用的芯片核心数量,MLU270 最大值为 16。
- -batch_size:指定使用的 batch size 大小。


# 7.性能测试
