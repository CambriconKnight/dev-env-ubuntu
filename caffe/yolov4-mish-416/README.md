<p align="center">
    <a href="https://github.com/CambriconKnight/easy-deploy-mlu/tree/master/caffe/yolov3-416">
        <img alt="yolov-logo" src="./res/sayit.jpg" height="140" />
        <h1 align="center">MLU算法移植教程-YOLOv4</h1>
    </a>
</p>

# 1. 概述
YOLOv4是[YOLO](https://pjreddie.com/darknet/yolo) (You Only Look Once)系列目标检测算法中的第四版，相比之前的算法，尤其是针对小目标，精度有显著提升。下面我们就来看看该算法如何在基于寒武纪MLU智能加速卡上移植开发。
整个移植过程分为环境准备、模型结构转换、模型量化、在线推理和离线推理共五个步骤，以下详细描述整个移植过程。
相关移植套件参见[dev-env-ubuntu](https://github.com/CambriconKnight/dev-env-ubuntu)。

# 2. 环境准备
准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 更新环境 >> 设置环境变量 >> 准备网络模型
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

## 2.3. 安装驱动
参见《寒武纪Linux驱动安装手册-v*.*.*.pdf》
注：安装驱动前，请先安装MLU板卡，再进行驱动安装。

## 2.4. 安装Docker
Docker安装参见：https://docs.docker.com/engine/install/

## 2.5. 启动Docker
启动Docker参见：../../

## 2.7. 更新环境
更新环境并安装依赖库
```bash
#注：使用run**.sh进入docker环境。首次进入docker容器需要执行以下命令。
apt-get update
#6[6. Asia]--->\Enter[More]--->70[70. Shanghai]
apt-get -y install python-skimage
pip install --upgrade pip
pip install protobuf
```

## 2.8. 设置环境变量
声明环境变量（该操作每次进入docker都需要进行）
```bash
#1. 修改环境变量(进入docker,位于/opt/work)
cd /opt/work
vim env_caffe.sh
#1.1. 修改DATASET_HOME路径，23行
#     23 #export DATASET_HOME=$PWD/datasets
#     24 export DATASET_HOME=/home/share/datasets
#1.2. 修改CAFFE_MODELS_DIR路径，33行
#     33 #export CAFFE_MODELS_DIR=$PWD/models/caffe
#     34 export CAFFE_MODELS_DIR=/home/share/models/caffe

#2. 声明环境变量（该操作每次进入docker都需要进行）
source env_caffe.sh
#3、设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
export PATH_NETWORK="/home/share/caffe/yolov4-mish-416"
export PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
export PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"
```

## 2.9. 准备网络模型
从官网下载配置文件及模型权重,以下以yolov4-mish-416为例进行演示.
|Name|URL|
|----|-------|
|`Darknet`|https://github.com/AlexeyAB/darknet.git|
|`yolov4-mish-416.cfg`|https://drive.google.com/open?id=1Ahmn7iI2B79jDlcKlRlD_tO5Tbr0Dq8x|
|`yolov4-mish-416.weights`|https://drive.google.com/open?id=1NuYL-MBKU0ko0dwsvnCx6vUr7970XSAR|

```bash
#注：如果是自己的网络，则不用再下载。可以直接替换【${PATH_NETWORK}】目录中【yolov4-mish-416.cfg】、【yolov4-mish-416.weights】.
```

# 3. 模型结构转换
YOLOv4没有官方的Caffe网络模型。如果要在Cambricon Caffe 上使用YOLOv4 网络，需要先将[Darknet](https://github.com/pjreddie/darknet) 官方的cfg、weights文件分别转换成Caffe 中对应的prototxt和caffemodel文件，然后手动修改相关层（增加yolo层）信息匹配Cambricon Caffe加速要求（此操作不影响原有YOLOv4训练流程）。相关信息参见《寒武纪Caffe用户手册-v*.*.*.pdf》中相关章节说明。
下面以官网 YOLOv4 为示例描述如何进行网络模型转换。
```bash
#1.使用工具转换网络模型【yolov4-mish-416.cfg & yolov4-mish-416.weights】------>【yolov4-mish-416.prototxt & yolov4-mish-416.caffemodel】
cd ${PATH_NETWORK_MODELS}
if [ ! -d "mlu" ];then mkdir mlu;fi
#export PYTHONPATH=$CAFFE_SRC/python:$PYTHONPATH
#yolov4-mish-416.cfg
python2 $CAFFE_HOME/src/caffe/python/darknet2caffe-yoloV4.py yolov4-mish-416.cfg yolov4-mish-416.weights ${PATH_NETWORK_MODELS}/mlu/yolov4-mish-416.prototxt ${PATH_NETWORK_MODELS}/mlu/yolov4-mish-416.caffemodel
ls -la ${PATH_NETWORK_MODELS}/mlu
#yolov4-leaky-416
#python2 $CAFFE_HOME/src/caffe/python/darknet2caffe-yoloV4.py yolov4-leaky-416.cfg yolov4-leaky-416.weights ${PATH_NETWORK_MODELS}/mlu/#yolov4-leaky-416.prototxt ${PATH_NETWORK_MODELS}/mlu/yolov4-leaky-416.caffemodel
#ls -la ${PATH_NETWORK_MODELS}/mlu

#2.手动修改yolov4-mish-416.prototxt: 在yolov4-mish-416.prototxt 最后添加后处理层【Yolov3Detection】。
#2.1. 【biases】值确认：如果yolov4-mish-416.cfg中，【Anchor】不一致，需要将不一致的内容修改一致。
#2.2. 【bottom】值确认：可用Netron查看yolov4-mish-416.prototxt文件，最后的三个输出的convolution层【name】，然后修改到layer里面三个【bottom】值。
#2.3. 【confidence_threshold】值确认：如果需要看图片的实际画框效果，需要把hold调大，0.4,0.5左右；如果需要看mAP值，把这个hold调小，设成0.001。
#2.4. 【num_classes】值确认：此项非必须。在yolo层添加【num_classes】项即可，根据yolov4-mish-416.cfg文件中【classes】修改类别数；没填的话，会用默认的类别，量化模型可能会有问题。
#2.5. 【im_w、im_h】值确认：此项非必须。根据实际网络输入图片宽度、高度确认【im_w、im_h】项。
vim ${PATH_NETWORK_MODELS}/mlu/yolov4-mish-416.prototxt
#vim ${PATH_NETWORK_MODELS}/mlu/yolov4-leaky-416.prototxt
```
附录1：yolov4-mish-416.prototxt中增加的yolo层
```bash
#注：在yolov4-mish-416.prototxt最后添加后处理层【Yolov3Detection】，以下是按照官网网络结构修改的：仅修改了三个【bottom】值，其他没有修改。
layer {
    bottom: "layer139-conv"
    bottom: "layer150-conv"
    bottom: "layer161-conv"
    top: "yolo_1"
    name: "yolo-layer"
    type: "Yolov3Detection"
    yolov3_param {
        im_w:416
        im_h:416
        num_box:1024
        num_classes:80
        confidence_threshold:0.5
        nms_threshold:0.45
        biases:[10,13,16,30,33,23,30,61,62,45,59,119,116,90,156,198,373,326]
    }
}
```
附录2：官网yolov3.cfg中yolo层
```bash
#yolov3.cfg中yolo
[yolo]
mask = 6,7,8 #表示该层yolo层选用那几个Anchor
anchors = 10,13,  16,30,  33,23,  30,61,  62,45,  59,119,  116,90,  156,198,  373,326
#整个yolov3网络使用了9个Ancnor尺寸，都在这里，通过mask来选择该层yolo层选用哪几个anchor。
#anchor是利用k-means算法基于训练集而得到的目标统计尺寸。本层选用了最大的三个anchor，很显然，本层的目的是着眼于检测大目标。
classes=80 #训练集的类别数
num=9 #anchor数目
jitter=.3 #利用数据抖动来产生更多的数据，这里的抖动概率是0.3
ignore_thresh = .7
#当预测框与真实框（ground truth）的IOU超过该值时，不参与loss计算，否则参与计算
truth_thresh = 1
random=1#如果为1，每次迭代图片大小随机从320到608，步长为32，如果为0，每次训练大小与输入大小一致。也就是多尺度训练。
```

# 4. 模型量化
Cambricon Caffe 提供generate_quantized_pt 工具帮助我们量化模型。可以将32 位浮点模型量化成int8/int16 模型。
有关generate_quantized_pt 量化工具的使用信息，参见《寒武纪Caffe用户手册-v*.*.*.pdf》中相关章节【int8/int16 模型生成工具】说明。
下面以yolov4-mish-416 为示例描述如何进行模型量化。
```bash
#1.生成图片列表 yolov4_file_list_coco
cd ${PATH_NETWORK}
/home/share/tools/getFileList.sh ${PATH_NETWORK}/datasets yolov4_file_list_coco
#2.generate_quantized_pt：$CAFFE_HOME/tools/generate_quantized_pt
cd ${PATH_NETWORK}
$CAFFE_HOME/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov4_quantized.ini
ls -la ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -ini_file ${PATH_NETWORK}/yolov4_quantized.ini -blobs_dtype INT16 -top_dtype FLOAT32 -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int16.prototxt
#/opt/cambricon/caffe/tools/generate_quantized_pt -blobs_dtype INT8 \
#    -ini_file ${PATH_NETWORK}/yolov4_quantized.ini \
#    -mode common \
#    -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.prototxt \
#    -weights ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel \
#    -outputmodel ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt \
#    -top_dtype FLOAT16
```
**有关量化：什么是量化？为什么要量化？**
量化是将float32的模型转换为int8/int16的模型，可以保证计算精度在目标误差范围内的情况下，显著减少模型占用的存储空间和处理带宽。比如int8模型是指将数值以有符号8位整型数据保存，并提供int8定点数的指数position和缩放因子scale，因此int8模型中每个8位整数i表示的实际值为：value=i*2^position/scale。另一方面进行在线推理和生成离线模型时仅支持量化后的模型。

# 5. 在线推理
Cambricon Caffe 提供利用随机数作为网络输入数据，实现网络在线推理功能验证工具test_forward_online。
关于在线验证工具的使用方法，参见《寒武纪Caffe用户手册-v*.*.*.pdf》中相关 章节【在线验证工具】。
以下是基于Cambricon Caffe SDK-Demo 中生成的yolov4_online_multicore 进行在线逐层/融合推理。
```bash
#1、基于SDK-Demo 在线逐层推理
#$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore
PATH_TEST_NETWORK=${PATH_NETWORK}/test/yolov4_online_multicore_mlu
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt -weights ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/yolov4_file_list_coco -mmode MLU -mcore MLU270 -outputdir . -output_dtype FLOAT16 -preprocess_option 4 -dump 1 -simple_compile 1

#$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_singlecore
#yolov4_online_singlecore
#$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_singlecore -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt -weights $#{PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/yolov4_file_list_coco -mmode #MLU -mcore MLU270 -outputdir . -output_dtype FLOAT16 -preprocess_option 4 -dump 1 -simple_compile 1

#2、基于SDK-Demo 在线融合推理
#$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore
PATH_TEST_NETWORK=${PATH_NETWORK}/test/yolov4_online_multicore_mfus
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_online_multicore -model ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416_int8.prototxt -weights ${PATH_NETWORK_MODELS_MLU}/yolov4-mish-416.caffemodel -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/yolov4_file_list_coco -mmode MFUS -mcore MLU270 -outputdir . -output_dtype FLOAT16 -preprocess_option 4 -dump 1 -simple_compile 1

#yolov4_online_multicore参数说明：
#     labels：coco数据集标签
#     images：待推理图片列表文件路径
#     mmode：表示使用逐层还是融合模式，MLU表示逐层，MFUS表示融合
#     preprocess_option：表示预处理选项，选4表示416*416
#具体参数说明可输入./yolov4_online_multicore --help进行查看
```

# 6. 离线推理
## 6.1. 生成离线模型
Cambricon Caffe 可以用Caffe 工具生成离线模型 model_name.cambricon，同时也会在终端上打印相应的子网络层信息。
关于离线模型的使用方法，参见《寒武纪CNRT用户手册-v*.*.*.pdf》和《寒武纪Caffe用户手册-v*.*.*.pdf》中相关章节【离线执行】。
下面以yolov4-mish-416 为示例描述如何生成离线模型model_name.cambricon。
```bash
#1. 命令行直接生成
#caffe genoff： $CAFFE_HOME/src/caffe/build/tools/caffe genoff
cd ${PATH_NETWORK_MODELS_MLU}
$CAFFE_HOME/src/caffe/build/tools/caffe genoff -model yolov4-mish-416_int8.prototxt \
             -weights yolov4-mish-416.caffemodel \
             -mname yolov4_1b4c_simple \
             -mcore MLU270 \
             -simple_compile 1 \
             -core_number 4 \
             -batchsize 1 \
             -output_dtype FLOAT16
ls -la *.cambricon
#2. 采用脚本工具生成多种类型离线模型
cd ${PATH_NETWORK_MODELS_MLU}
#yolov4_1b4c_simple.cambricon
/home/share/caffe/tools/genOfflineModels.sh yolov4-mish-416_int8.prototxt yolov4-mish-416.caffemodel yolov4 4 1
#yolov4_4b4c_simple.cambricon
/home/share/caffe/tools/genOfflineModels.sh yolov4-mish-416_int8.prototxt yolov4-mish-416.caffemodel yolov4 4 4
ls -la *.cambricon
```

## 6.2. 执行离线推理
Cambricon Caffe 提供利用随机数作为网络输入数据，实现离线网络模型推理功能验证工具test_forward_offline。
关于在线验证工具的使用方法，参见《寒武纪Caffe用户手册-v*.*.*.pdf》中相关章节【离线验证工具】。
```bash
#基于SDK-Demo 离线推理
PATH_TEST_NETWORK=${PATH_NETWORK}/test/yolov4_offline_multicore
if [ ! -d ${PATH_TEST_NETWORK} ];then mkdir -p ${PATH_TEST_NETWORK};fi
cd ${PATH_TEST_NETWORK}
#yolov4_1b4c_simple
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov4_1b4c_simple.cambricon -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/yolov4_file_list_coco -preprocess_option 4 -outputdir . -simple_compile 1 -dump 1
#yolov4_4b4c_simple
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov4_4b4c_simple.cambricon -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/yolov4_file_list_coco -preprocess_option 4 -outputdir . -simple_compile 1 -dump 1
```
推理结果摘选：
<table>
    <tr>
        <td ><center><img alt="yolov3_000000000785.jpg" src="./res/yolov3_000000000785.jpg" height="250" </center></td>
        <td ><center><img alt="yolov3_000000013348.jpg" src="./res/yolov3_000000013348.jpg" height="250" </center></td>
    </tr>
    <tr>
        <td ><center><img alt="yolov3_000000007108.jpg" src="./res/yolov3_000000007108.jpg" height="250" </center></td>
        <td ><center><img alt="yolov3_000000018380.jpg" src="./res/yolov3_000000018380.jpg" height="250" </center></td>
    </tr>
</table>

## 6.3. 性能测试
```bash
#cnrtexec为离线模型的性能测试程序，利用随机数来测试离线模型的demo.
cd ${PATH_TEST_NETWORK}
#yolov4_1b4c_simple
/home/share/test/cnrtexec/cnrtexec ${PATH_NETWORK_MODELS_MLU}/yolov4_1b4c_simple.cambricon 0 100 8 0
#yolov4_4b4c_simple
/home/share/test/cnrtexec/cnrtexec ${PATH_NETWORK_MODELS_MLU}/yolov4_4b4c_simple.cambricon 0 100 8 0
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
## 6.4. 精度测试
```bash
#计算 meanAp 命令
#yolov4的精度衡量指标一般为mAP(mean average precision)。一般基于COCO 数据集或者VOC 数据集计算yolov4模型的mAP。
#以COCO 数据集为例，该数据集一共有80类，如"person","car","dog" 等。
#计算yolov4在COCO 数据集中的mAP过程是：输入COCO 图片，输出推理结果，推理结果需要保存在txt文件中，每张image 对应一个txt。
#然后计算总mAP的时候，会先计算每一类的mAP，然后求所有类别mAP的平均值。注意，不同的ioU范围下，mAP的值不同。
#yolov4_1b4c_simple & file_list_2014
cd ${PATH_TEST_NETWORK}
$CAFFE_HOME/src/caffe/build/examples/yolo_v4/yolov4_offline_multicore -offlinemodel ${PATH_NETWORK_MODELS_MLU}/yolov4_1b4c_simple.cambricon -labels ${PATH_NETWORK}/label_map_coco.txt -images ${PATH_NETWORK}/file_list_2014 -preprocess_option 4 -outputdir . -simple_compile 1 -dump 1
#meanAP_COCO.py
cd ${PATH_TEST_NETWORK}
python2 $CAFFE_HOME/src/caffe/scripts/meanAP_COCO.py --file_list ${PATH_NETWORK}/file_list_2014 --result_dir . --ann_dir /home/share/datasets/COCO --data_type val2014
#输入参数为：
#file_list   ：保存了image的完整路径，代码内会解析image_name（不包含路径），如1234.jpg   会解析出  1234，然后去 result_dir里寻找 1234.txt
#result_dir： 保存了txt 文件的路径
#ann_dir：COCO 数据集中包含annotations 目录的路径，如/home/COCO/中有 annotations 目录，则传入/home/COCO 即可
#data_type： val2014   val2017  test2017，COCO 数据集名称，推理用的什么数据集，这里就传什么数据集名称
#其他注意事项：
#使用COCO 推理时，需要将框的阈值尽量调低，例如0.0000001。否则一张图只有很少的框，大部分的框都没画出来，这样计算的mAP 会很低.
#因为meanAP_COCO.py 计算的时候使用的框的阈值很低。
#如果mAP 异常：通常的原因有：
#    推理时画的框的坐标不准确，例如没按照left, top, right, bot的方式保存坐标
#    类别id 转换错误
#    推理使用的图片和计算mAP 使用的图片集合不一样。如果先计算100张COCO val2017，但是发现计算得到的mAP都是0，可发现meanAP_COCO.py 中默认计算所有的data_type内的图片。
#    推理使用的图片集合与meanAP_COCO.py中指定的data_type 不一致。
```

# 7. 附录
## 7.1. darknet2caffe-yoloV23.py/darknet2caffe-yoloV4.py参数说明
```bash
#$CAFFE_HOME/src/caffe/python/darknet2caffe-yoloV23.py
python darknet2caffe-yoloV23.py 3 yolov3.cfg yolov3.weights yolov3.prototxt yolov3.caffemodel
```
|Parameter|Description|
|----|-------|
|`3`|`针对不同yolov网络的选项 2代表yolov2 3代表yolov3`|
|`yolov3.cfg`|`yolov3配置文件 全路径名称`|
|`yolov3.weights`|`yolov3权重 全路径名称`|
|`yolov3.prototxt`|`即将生成的.prototxt 全路径名称`|
|`yolov3.caffemodel`|`即将生成的.caffemodel 全路径名称`|

## 7.2. convert_quantized.ini文件中参数说明
|Parameter|Description|
|----|-------|
|`originl_models_path`|`待量化的原始网络 全路径名称`|
|`save_model_path`|`量化后的网络 全路径名称`|
|`images_list_path`|`图片列表文件路径，images.lst存储了量化时需要的图片路径，量化时使用一张图片即可`|
|`used_images_num`|`迭代的次数，网络的batch为1，used_images_num为8，共迭代8次，读取8 张图。网络的batch为4，used_images_num为8，共迭代8次，读取32张图`|
|`mean`|`均值`|
|`std`|`缩小倍数`|
|`scale`|`输入图像的高度和宽度`|
|`crop`|`裁剪的高度和宽度`|
|`use_firstconv`|`是否使用到第一层卷积`|

注意：如果使用量化后的模型进行推理时，发现推理结果不对，那么很有可能是量化时的mean和std参数设置的不对。

## 7.3. YOLOV3/V5网络结构及cfg文件
```bash
#cfg文件主要参数说明
[net]
# Testing #推理时才用的到Testing
# batch=1
# subdivisions=1
# Training #训练时使用以下参数
batch=64 #每次载入的批次大小，这里是每次载入64张图片
subdivisions=16 #这里将batch张图片分为16次送入，为了避免显存不够导致溢出
width=608 #训练时的图片宽度
height=608 #训练时的图片高度
#这里注意：训练集中的图片可以是各种尺度的，darknet框架下的训练会自动将图片resize成此大小
#也可以提前自己resize再作为训练集，这样训练速度会快一些
channels=3 #三通道的图像yolov3次时，学习率不变，多于burn_in次时采用policy的学习率更新策略
max_batches = 500200 #最大训练的batch数，超过该数就停止训练
policy=steps #使用policy的训练策略，训练策略有:CONSTANT, STEP, EXP, POLY, STEPS, SIG, RANDOM这几种
steps=300000,450000 #训练次数达到300000次时，学习率衰减第一个scale倍(10倍)，450000次时同样衰减10倍
scales=.1,.1 #与steps配合

[convolutional]
batch_normalize=1 #是否使用bn层，1代表是
filters=32 #该卷积层滤波器的个数
size=3 #滤波器大小，这里是3x3
stride=1 #滑动步长
pad=1 #是否需要padding补0
activation=leaky #激活函数，leaky_Relu

# Downsample 下采样过程，这里代表下一层卷积层运算过后，特征图的x，y维度会变为原来的stride倍

[convolutional]
batch_normalize=1
filters=64
size=3
stride=2 #滑动步长为2，这里实现了下采样
pad=1
activation=leaky

......

#最后一个shortcut（共计23个）
[shortcut]
from=-3
activation=linear

###################### 从这里开始，三个yolo层共用的网络结构到此结束

[convolutional]
batch_normalize=1
filters=512
size=1
stride=1
pad=1
activation=leaky

......

[yolo]
mask = 6,7,8 #表示该层yolo层选用那几个Anchor
anchors = 10,13,  16,30,  33,23,  30,61,  62,45,  59,119,  116,90,  156,198,  373,326
#整个yolov3网络使用了9个Ancnor尺寸，都在这里，通过mask来选择该层yolo层选用哪几个anchor。
#anchor是利用k-means算法基于训练集而得到的目标统计尺寸。本层选用了最大的三个anchor，很显然，本层的目的是着眼于检测大目标。
classes=80 #训练集的类别数
num=9 #anchor数目
jitter=.3 #利用数据抖动来产生更多的数据，这里的抖动概率是0.3
ignore_thresh = .7
#当预测框与真实框（ground truth）的IOU超过该值时，不参与loss计算，否则参与计算
truth_thresh = 1
random=1#如果为1，每次迭代图片大小随机从320到608，步长为32，如果为0，每次训练大小与输入大小一致。也就是多尺度训练。

[route]
layers = -4
#用于特征融合，这里表示从上一层开始数的倒数第4层作为本层。

[convolutional]
batch_normalize=1
filters=256
size=1
stride=1
pad=1
activation=leaky

[upsample]
stride=2 #上采样过程，特征图的x，y维度变为上一层的2倍

[route]
layers = -1, 61
#特征融合，倒数第1层（上一层开始算）与第61层融合，也就是滤波器直接叠加。

......


##最后一个yolo（共计3个）
[yolo]
mask = 0,1,2
anchors = 10,13,  16,30,  33,23,  30,61,  62,45,  59,119,  116,90,  156,198,  373,326
classes=80
num=9
jitter=.3
ignore_thresh = .7
truth_thresh = 1
random=1
```