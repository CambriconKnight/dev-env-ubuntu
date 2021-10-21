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

| 框架                  | pytorch                                               |
| :-------------------- | :-------------------------------                      |
| 模型                  | yolov4-tiny                                           |
| MLU SDK               | v1.7.604                                              |
| MLU Docker 镜像       | pytorch-0.15.604-ubuntu18.04.tar.gz                   |
| 数据集                | coco val2017                                          |
| 数据集路径            | ftp://product/datasets/MLU270_datasets_COCO.tar.gz    |


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
### 3.2.4 设置环境变量
```bash
export TORCH_HOME=/models/pytorch_models
export DATASET_HOME=/datasets
export COCO_PATH_PYTORCH=$DATASET_HOME/
export CATCH_HOME=/torch/src/catch
```
备注:生成离线模型依赖上述路径

### 3.2.5 查看 $TORCH_HOME 目录
```bash
echo $TORCH_HOME
echo $DATASET_HOME
echo $COCO_PATH_PYTORCH
echo $CATCH_HOME
```
```bash
(pytorch) root@cam:/# echo $TORCH_HOME
/models/pytorch_models
(pytorch) root@cam:/# echo $DATASET_HOME
/datasets
(pytorch) root@cam:/# echo $COCO_PATH_PYTORCH
/datasets/
(pytorch) root@cam:/# echo $CATCH_HOME
/torch/src/catch
```
备注：测试 yolov4-tiny 需要依赖 COCO数据集。数据集可以直接用COCO官方数据集，也可以从ftp下载。

### 3.2.6 创建模型目录
```bash
#原始模型存放路径
mkdir -p $TORCH_HOME/origin/checkpoints/

#int16 量化模型存放路径
mkdir -p $TORCH_HOME/int16/checkpoints/

#int8 量化模型存放路径
mkdir -p $TORCH_HOME/int8/checkpoints/
```
### 3.2.7 进入虚拟环境
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
### 3.2.8 yolov4-tiny online 目录
```bash
cd $CATCH_HOME/examples/online/yolov4/

#创建推理输出目录
mkdir -p output/cpu_res/
mkdir -p output/mlu_res/
```

# 4.模型准备
## 4.1. 下载yolov4-tiny 模型准备
- 下载链接
```bash
https://github.com/AlexeyAB/darknet

#model zoo ，选择对应版本的模型
https://github.com/AlexeyAB/darknet/wiki/YOLOv4-model-zoo
#model tiny
https://github.com/AlexeyAB/darknet
```

- 下载的模型放到model 目录
```bash
cd $CATCH_HOME/examples/online/yolov4
mv yolov4-tiny.cfg yolov4-tiny.weights model
```

## 4.2. 生成yolov4-tiny pth文件

- yolov4-tiny
```bash
#yolov4-tiny
python eval.py -cfgfile model/yolov4-tiny.cfg -weightfile model/yolov4-tiny.weights -darknet2pth true
```

## 4.3. 拷贝模型到origin/checkpoints 目录
- yolov4-tiny
```bash
mv yolov4-tiny.pth $TORCH_HOME/origin/checkpoints/yolov4-tiny.pth
```

## 4.4. 模型量化
- yolov4-tiny
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
备注：

- 生成的模型在当前目录下，文件名yolov4-tiny.pth。
- 其它参数 可以参看$CATCH_HOME/examples/online/README.md 文件。
## 4.5 拷贝模型到int8/checkpoints 目录

- yolov4-tiny
```bash
#yolov4-tiny
mv yolov4-tiny.pth $TORCH_HOME/int8/checkpoints/
```
备注：如果int16 量化，注意模型存放目录，int16 需要拷贝到int16目录 $TORCH_HOME/int16/checkpoints/

# 5.运行示例
## 5.1. 在线运行yolov4-tiny demo（MLU)

- yolov4-tiny
```bash
#INT8 Inference,for float16 input
python eval.py -half_input 0 -quantized_mode 1 -datadir $COCO_PATH_PYTORCH/COCO -yolov4_version yolov4-tiny
```
- 参数说明
```bash
• ‑image_number：设置实际希望运行的样本数量。
• ‑quantized_mode：设置使用的权重为原始权重、 int8、 int16、分通道 int8 和分通道 int16 量化的权
重。
• ‑half_input：设置输入 tensor 为 Float 或 Half 类型。
```
备注：测试精度需要使用5000张以上图片，测试图片太少，测试精度值不准确。

## 5.2. 离线运行yolov4-tiny demo（MLU)
- 运行脚本
```bash
cd $CATCH_HOME/examples/offline/yolov4
./run_all_offline_mc.sh 1 1

#测试yolov4-tiny，以更改上面脚本
network_list=(
	#yolov4
	yolov4-tiny
)
```
备注：默认运行完程序会clean掉运行结果，想看结果可以注释掉 run_all_offline_mc.sh 最后一行的#clean；

- ./run_all_offline_mc.sh 参数说明：
```bash
---------------------------------------------------------------------
|  ./run_all_offline_mc.sh [1|2|3|4] [1|2]
|  parameter1: int8, int16, channel_int8, channel_int16 mode 
   parameter2: dev select MLU270 or MLU220
|  eg. ./run_all_offline_mc.sh 1 1
|      which means running int8 offline model on MLU270.
--------------------------------------------------------------------
```
备注：
```bash
运行离线demo 时，模型是从$TORCH_HOME 目录获取，注意 $TORCH_HOME 路径；
```

## 5.3. 离线demo 编译
- 备注：如果需要修改源码或者没有yolov4_offline_multicore 可执行程序，可以采用下面方式进行编译
```bash
cd $CATCH_HOME/examples/offline/
mkdir build
cmake .. && make -j
```