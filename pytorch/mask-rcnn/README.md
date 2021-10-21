<p align="center">
    <a href="https://github.com/CambriconKnight/easy-deploy-mlu/tree/master/pytorch/yolov4">
        <h1 align="center">mask-rcnn算法移植教程</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
Mask R-CNN是在Faster R-CNN的基础上添加了一个预测分割mask的分支。通过在 Faster-RCNN 的基础上添加一个分支网络，在实现目标检测的同时，把目标像素分割出来。

- **相关开发资料可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载，也可在官方提供的专属FTP账户指定路径下载。**
- **有关寒武纪产品开发资料的公开链接汇总参见[cam-dev-info](https://gitee.com/cambriconknight/cam-dev-info)。**

# 2. 环境准备
准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 设置环境变量 >> 准备网络模型 >> 创建模型目录 >> 进入虚拟环境

# 3. mask-rcnn环境准备
## 3.1 版本信息

| 框架 | pytorch |
| --------------- | ------------------------------------------------------------ |
| 模型 | maskrcnn |
| MLU SDK | v1.7.602 |
| MLU Docker 镜像 | pytorch:0.15.602-ubuntu18.04 |
| 数据集 | coco val2017 |
| 数据集路径 | ftp://product/datasets/MLU270_datasets_COCO.tar.gz |
| 模型参考链接 | https://github.com/facebookresearch/maskrcnn-benchmark/blob/main/MODEL_ZOO.md |
| 模型yaml | e2e_mask_rcnn_R_50_FPN_1x_caffe2.yaml |
| 模型权重 | [https://download.pytorch.org/models/maskrcnn/e2e_mask_rcnn_R_50_FPN_1x.pth]() |



## 3.2. 下载容器

- **路径**

```shell
ftp://product/GJD/MLU270/1.7.602/Ubuntu18.04/PyTorch/docker/pytorch-0.15.602-ubuntu18.04.tar
```

## 3.3. 加载容器

```
sudo docker load -i pytorch-0.15.602-ubuntu18.04.tar
```

## 3.4. 进入容器

- 模型脚本run-mlu270_ubuntu18.04.torch_yolov4.sh

```shell
#/bin/bash
export MY_CONTAINER="mlu270_ubuntu18.04.pytorh_`whoami`"
num=`sudo docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`
echo $num
echo $MY_CONTAINER
if [ 0 -eq $num ];then
sudo xhost +
sudo docker run \
-e DISPLAY=unix$DISPLAY \
--ipc=host \
--net=host \
--pid=host \
-it \
--privileged \
--name $MY_CONTAINER \
-v /home/songmingyu/workspace/datasets/:/datasets/ \
-v /home/songmingyu/workspace/models/:/models/ \
-v $PWD:/home/share/ \
yellow.hub.cambricon.com/pytorch/pytorch:0.15.602-ubuntu18.04 /bin/bash
else
sudo docker start $MY_CONTAINER
sudo docker exec -ti $MY_CONTAINER /bin/bash
fi
```

- 进入容器

```shell
bash run-mlu270_ubuntu18.04.torch_yolov4.sh
```

## 3.5 torch 工程目录

```
cd /torch/
```

## 3.6 设置环境变量

```
export TORCH_HOME=/models/pytorch_models
export DATASET_HOME=/datasets
export COCO_PATH_PYTORCH=$DATASET_HOME/
```

## 3.7 查看 $TORCH_HOME 目录

```
echo $TORCH_HOME
echo $DATASET_HOME
echo $COCO_PATH_PYTORCH
```

```
(pytorch) root@cam:/# echo $TORCH_HOME
/models/pytorch_models
(pytorch) root@cam:/# echo $DATASET_HOME
/datasets
(pytorch) root@cam:/# echo $COCO_PATH_PYTORCH
/datasets/
```

**备注：**测试 需要依赖 COCO数据集。数据集可以直接用COCO官方数据集，也可以从ftp下载。

## 3.8 创建模型目录

```
mkdir -p $TORCH_HOME/origin/checkpoints/
mkdir -p $TORCH_HOME/int16/checkpoints/
mkdir -p $TORCH_HOME/int8/checkpoints/
```

## 3.9 进入虚拟环境

```
source /torch/venv3/pytorch/bin/activate
```

## 3.10 工程目录

```
cd /torch/examples/online/mask-rcnn
```

## 3.11 编译mask-rcnn

```
bash build_mask-rcnn.sh
```

# 4.模型准备

## 4.1 模型准备

- 下载模型

```
wget https://download.pytorch.org/models/maskrcnn/e2e_mask_rcnn_R_50_FPN_1x.pth
```

- 下载的模型放到origin/checkpoints 目录

```
cp e2e_mask_rcnn_R_50_FPN_1x.pth /models/pytorch_models/origin/checkpoints/mask_rcnn.pth
```

## 4.2 模型量化

```
python test_mask-rcnn.py --min-image-size 800 --mlu false --jit false --image_number 16 --batch_size 1 --half_input 0 --coco_path $COCO_PATH_PYTORCH --quantization true --quantized_mode 1 --ann_dir $COCO_PATH_PYTORCH/COCO --dump true MODEL.DEVICE cpu

#量化后需要将模型拷贝到 /models/pytorch_models//int8/checkpoints/mask_rcnn.pth 目录
mv mask_rcnn.pth /models/pytorch_models//int8/checkpoints/mask_rcnn.pth
```

## 4.3 参数说明

脚本参数使用说明：

- --min-image-size：图片尺寸，默认800
- --mlu：是否使用mlu，true 或者flase （量化是在CPU运行，需要配置false）
- --jit：是否融合，true 或者flase
- ‑-mcore：指定硬件架构版本，如设置设备名： MLU270。
- --core_number：指定离线模型使用的芯片核心数量， MLU270 最大值为 16。
- --batch_size：指定使用的 batch size 大小。（当前版本最大1）
- --half_input：指定 input tensor 类型， half 或者 float。
- --dump：是否保存图片，true 或者flase
- --ann_dir：数据集 ann 目录
- --coco_path：coco 数据集路径
- --quantization：是否是量化模式
- -- quantized_mode：选择权重的量化模式。可设置为 0、 1、 2、 3、 4，分别表示原始网络权重、 int8量化、 int16 网络、分通道 int8 网络、分通道 int16 网络。默认值为 1。

# 5.运行示例

## 5.1 在线运行（MLU）

```
python test_mask-rcnn.py --min-image-size 800 --mlu true --jit true --image_number 16 --batch_size 1 --half_input 0 --coco_path $COCO_PATH_PYTORCH --quantization false --quantized_mode 1 --ann_dir $COCO_PATH_PYTORCH/COCO --dump true --core_number 4 MODEL.DEVICE mlu
```

# 6. 生成离线模型

## 6.1 生成离线模型命令

```
#4core-1batch-half_input
python test_mask-rcnn.py --min-image-size 800 --batch_size 1 --half_input 1 --quantized_mode 1 --core_number 4 --genoff true --fake_device 1 --mcore MLU270 MODEL.DEVICE mlu

#4core-1batch-fp32_input
python test_mask-rcnn.py --min-image-size 800 --batch_size 1 --half_input 0 --quantized_mode 1 --core_number 4 --genoff true --fake_device 1 --mcore MLU270 MODEL.DEVICE mlu
```

## 6.2 运行脚本参看

```
#!/bin/bash

set -x
echo "test"

CUR_DIR=$(dirname $(readlink -f $0))

echo "$CUR_DIR"

rm -rf *.jpg

export TORCH_HOME=/models/pytorch_models/
export DATASET_HOME=/datasets
export COCO_PATH_PYTORCH=$DATASET_HOME/

echo "TORCH_HOME:$TORCH_HOME"
echo "DATASET_HOME:$DATASET_HOME"
echo "COCO_PATH_PYTORCH:$COCO_PATH_PYTORCH"

#下载模型

#wget https://download.pytorch.org/models/maskrcnn/e2e_mask_rcnn_R_50_FPN_1x.pth

#CPU 量化
python test_mask-rcnn.py --min-image-size 800 --mlu false --jit false --image_number 16 --batch_size 1 --half_input 0 --coco_path $COCO_PATH_PYTORCH --quantization true --quantized_mode 1 --ann_dir $COCO_PATH_PYTORCH/COCO --dump true MODEL.DEVICE cpu

mv mask_rcnn.pth /models/pytorch_models//int8/checkpoints/mask_rcnn.pth

#MLU 推理
python test_mask-rcnn.py --min-image-size 800 --mlu true --jit true --image_number 16 --batch_size 1 --half_input 0 --coco_path $COCO_PATH_PYTORCH --quantization false --quantized_mode 1 --ann_dir $COCO_PATH_PYTORCH/COCO --dump true --core_number 4 MODEL.DEVICE mlu

#gen offline model 生成离线模型

#1core1batch
#python test_mask-rcnn.py --min-image-size 800 --batch_size 1 --half_input 0 --quantized_mode 1 --core_number 1 --genoff true --fake_device 1 --mcore MLU270 MODEL.DEVICE mlu

#1core4batch
#python test_mask-rcnn.py --min-image-size 800 --batch_size 1 --half_input 1 --quantized_mode 1 --core_number 4 --genoff true --fake_device 1 --mcore MLU270 MODEL.DEVICE mlu
```

