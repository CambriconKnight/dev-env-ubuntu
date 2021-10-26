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
sudo docker load -i pytorch-0.15.604-ubuntu18.04.tar.gz
```
### 3.2.2 进入容器
- 模型脚本run-mlu270_ubuntu18.04.torch.docker.sh

```bash
#/bin/bash
export MY_CONTAINER="mlu270_v1.7.604_ubuntu18.04_yolov4.pytorh_`whoami`"
num=`sudo docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`
echo $num
echo $MY_CONTAINER
if [ 0 -eq $num ];then
sudo xhost +
sudo docker run \
-e DISPLAY=unix$DISPLAY \
--ipc=host --net=host --pid=host \
-it --privileged --name $MY_CONTAINER \
-v /home/cam/workspace/datasets/:/datasets/ \
-v /home/cam/workspace/models/:/models/ \
-v $PWD:/home/share/ yellow.hub.cambricon.com/pytorch/pytorch:0.15.604-ubuntu18.04 /bin/bash
else
sudo docker start $MY_CONTAINER
sudo docker exec -ti $MY_CONTAINER /bin/bash
fi
```
- 进入容器
```bash
./run-mlu270_ubuntu18.04.torch.docker.sh
```
### 3.2.3 torch 工程目录
- 确认torch 目录
```bash
#发布容器默认是下面目录
cd /torch/
```

### 3.2.5 进入虚拟环境
- 进入虚拟环境
```bash
#源码编译的activate 路径
source /torch/venv3/pytorch/bin/activate
```
- torch 环境验证
```bash
python3 -c "import torch;print(torch.__version__,torch.__file__)"
```
```bash
1.3.0a0 /cambricon_pytorch/pytorch/src/catch/venv/pytorch/lib/python3.6/site-packages/torch/__init__.py
```
- 安装pip 依赖
```bash
pip install matplotlib
pip install opencv-python
```

# 4.模型准备
## 4.1.1下载YOLOv4-tiny代码，放到Docker中.设置环境变量,解压COCO数据集到yolov4-tiny目录下。
下载地址：https://github.com/tianzang/dev-env-ubuntu/tree/master/pytorch/yolov4-tiny,

-进入yolov4-tiny文件夹下 eg :cd xxx/yolov4-tiny

### 4.1.2 设置环境变量
```bash
export TORCH_HOME=$PWD/pytorch_models
export DATASET_HOME=$PWD/
export COCO_PATH_PYTORCH=$DATASET_HOME/
```
- 注: 必须进入yolov4-tiny文件夹下,设置环境变量

### 4.1.3.

- 测试 yolov4 需要依赖 COCO数据集并且放到yolov4-tiny文件夹下。数据集可以直接用COCO官方数据集，也可以从ftp下载。 

## 4.2. 下载yolov4-tiny 模型
- cd ./online/yolov4/model

- 可以参考4.2.1一键下载或者参考4.2.2 手动下载
### 4.2.1 一键下载：
```bash
./download_weights.sh
```
### 4.2.2 手动下载
```bash
#下载yolov4-tiny.cfg
wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg

#下载yolov4-tiny.weights
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights
```

## 4.3. 生成yolov4-tiny 量化模型pth文件
- 返回上级目录：cd ..
- 生成量化模型可以参考：4.3.1. 一键生成量化模型或者4.3.2. 手动生成量化模型

### 4.3.1. 一键生成量化模型：
```bash
./run_quant.sh
```

### 4.3.2. 手动生成量化模型
- 生成pytorch 网络模型
```bash
#生成yolov4-tiny网络模型
python eval.py -cfgfile model/yolov4-tiny.cfg -weightfile model/yolov4-tiny.weights -darknet2pth true

#拷贝模型到origin/checkpoints 目录
mv yolov4-tiny.pth $TORCH_HOME/origin/checkpoints/yolov4-tiny.pth
```

- yolov4-tiny模型量化
```bash
#int8
#INT8 Quantize
python eval.py -quantized_mode 1 -quantization True -yolov4_version yolov4-tiny
```
- 参数说明
```bash
• ‑quantized_mode：设置使用的权重为原始权重、 int8、 int16、分通道 int8 和分通道 int16 量化的权重。
• ‑quantization：设置是否使能量化模式。
• ‑yolov4_version:yolov4-tiny
```

```bash
拷贝模型到int8/checkpoints 目录
mv yolov4-tiny.pth $TORCH_HOME/int8/checkpoints/
```
备注：如果int16 量化，注意模型存放目录，int16 需要拷贝到int16目录 $TORCH_HOME/int16/checkpoints/

# 5.在线运行yolov4-tiny demo（MLU)
- 在线运行可以参考5.1.一键运行或者参考5.2 手动运行
## 5.1. 一键在线运行yolov4-tiny demo（MLU)
```bash
./run_online.sh
```

## 5.2. 手动在线运行yolov4-tiny demo

```bash
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

# 6. 离线运行yolov4-tiny demo（MLU)
- 进入目录
cd ../../offline
- 可以参考6.1.一键生成离线模型或者参考6.2. 手动生成离线模型
## 6.1. 一键生成离线模型
```bash
./run_offline.sh
```
## 6.2. 手动生成离线模型
- 
```bash
export TORCH_HOME=$TORCH_HOME/int8/

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