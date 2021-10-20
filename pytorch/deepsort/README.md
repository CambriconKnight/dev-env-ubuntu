<p align="center">
    <a href="https://github.com/CambriconKnight/easy-deploy-mlu/tree/master/pytorch/yolov5">
        <h1 align="center">DeepSort算法移植教程-YOLOv5</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
Deep SORT 是多目标跟踪 (Multi-Object Tracking) 中常用到的一种算法，是一个 Detection Based Tracking 的方法。这个算法工业界关注度非常高，很多都是使用了 Deep SORT 进行工程部署。Deep SORT算法的前身是SORT, 全称是Simple Online and Realtime Tracking。简单介绍一下，SORT最大特点是基于Faster R-CNN的目标检测方法，并利用卡尔曼滤波算法+匈牙利算法，极大提高了多目标跟踪的速度，同时达到了SOTA的准确率。DeepSort中最大的特点是加入外观信息，借用了ReID领域模型来提取特征，减少了ID switch的次数。Deep SORT算法在SORT算法的基础上增加了级联匹配(Matching Cascade)+新轨迹的确认(confirmed)。

- **相关开发资料可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载，也可在官方提供的专属FTP账户指定路径下载。**
- **有关寒武纪产品开发资料的公开链接汇总参见[cam-dev-info](https://gitee.com/cambriconknight/cam-dev-info)。**

# 2. 环境准备
准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 设置环境变量 >> 准备网络模型 >> 创建模型目录 >> 进入虚拟环境

# 3. DeepSort 网络环境准备
## 3.1.下载deepsort代码，并且放到Docker中.
下载地址：https://github.com/tianzang/dev-env-ubuntu ,下载的文件包括：
- 6.png deepsort需要的图片
- create_feature_extract.py 网络定义文件
- quantize_feature_extract.py 量化文件
- forward_feature_extract.py 在线推理文件
- run_convertmodel.sh 模型转换脚本
- run_offline.sh 生成离线模型脚本
- clean.sh clean脚本
- genoff.py-example genoff 样例
  
## 3.2.把原始权重ckpt.t7 下载到deepsort文件夹下
- DeepSort原始权重下载地址：https://drive.google.com/drive/folders/1xhG0kRH1EX5B9_Iz8gQJb7UNnn_riXi6   权重为ckpt.t7
## 3.3.传入依赖的文件
- 把/torch/examples/online/yolov5/models文件夹拷贝到deepsort文件夹下
- 把/torch/examples/offline/genoff/genoff.py拷贝到deepsort文件夹下

# 4. 模型转化
## 4.1. 量化模型和在线推理
- 所有操作都在deepsort文件夹进行操作
- 生成量化模型：
python quantize_feature_extract.py ./6.png ./ckpt.t7 ./feature_extract_quantized.pth

- 在线推理运行：
python forward_feature_extract.py ./6.png ./ckpt.t7 ./feature_extract_quantized.pth

## 4.2. 模型转换-简略版：
执行脚本：
```bash
./run_convertmodels.sh
#说明：该脚本，默认转换原始权重ckpt.t7
#用户转换自己训练的模型时，替换原始权重。
```

# 5. 离线推理
## 5.1. 生成离线模型需求
- 修改deepsort文件夹下genoff.py文件

- 修改内容
```bash
1，载⼊⾃定义的⽹络
import sys
# ⾃定义⽹络定义在当前⽬录下
net_dir = os.getcwd()
sys.path.append(net_dir)
from create_feature_extract import feature_extract

2，support中添加⽹络名称'feature_extract'
support = ['resnet50', 'resnext50_32x4d', ..., 'feature_extract']

3，在genoff函数中，添加条件选项，并实例化⾃定义模型。quantized置为True，使⽤量化权重。

elif model == "feature_extract":
	in_h = 128
	in_w = 64
	# 量化权重放在当前⽬录下
	net = feature_extract(True, net_dir + "/feature_extract_quantized.pth")
```
注: 如有问题可以参考样例genoff.py-example文件

## 5.2. 生成离线模型
```bash
#MLU270 4CORE 4BATCH FP32
#python genoff.py -fake_device 0 -model feature_extract -mcore MLU270 -core_number 4 -batch_size 4 -half_input 0 -input_format 1 -mname feature_extract
#MLU270 1CORE 1BATCH FP16
python genoff.py -fake_device 0 -model feature_extract -mcore MLU270 -core_number 1 -batch_size 1 -half_input 1 -input_format 1 -mname feature_extract
#MLU220 4CORE 4BATCH FP32
#python genoff.py -fake_device 0 -model feature_extract -mcore MLU220 -core_number 4 -batch_size 4 -half_input 0 -input_format 1 -mname feature_extract
#MLU220 1CORE 1BATCH FP16
#python genoff.py -fake_device 0 -model feature_extract -mcore MLU220 -core_number 1 -batch_size 1 -half_input 1 -input_format 1 -mname feature_extract
```

```bash
genoff.py脚本参数使用说明如下,详细说明见《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节【离线模型生成工具】。
- -fake_device:用于设置是否不使用 mlu 设备生成离线模型文件,使用自动检索最优模型必须使用mlu 设备,此参数必须设置为 0。
- -autotune:用于设置是否开启自动检索生成最优离线模型选项,0 表示关闭,1 表示开启,默认值为0。
- -autotune_config_path:用于设置运行自动检索优化工具时生成的环境变量配置文件路径,默认为”config.ini”。
- -autotune_time_limit:指定运行自动检索优化工具的时间上限,默认值是 120 分钟,时间越长,优化效果越好,建议此数值设置在 - 20 分钟以上。
- -model:指定网络名称。
- -mname:指定生成离线模型文件名。
- -mcore:指定硬件架构版本,当前支持 MLU270。
- -core_number:指定离线模型使用的芯片核心数量,MLU270 最大值为 16。
- -batch_size:指定使用的 batch size 大小。
- -half_input:指定 input tensor 类型,half 或者 float。
```

## 5.3. 生成离线模型-简略版
执行脚本：
```bash
./run_offline.sh
#说明：该脚本，基于上一步生成的离线模型文件【feature_extract_1b1c_half.cambricon】
```
