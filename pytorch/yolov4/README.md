<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/yolov4">
        <img alt="yolo-logo" src="./res/yolov4.png" height="140" />
        <h1 align="center">MLU算法移植教程-YOLOv4</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
[YOLO](https://pjreddie.com/darknet/yolo) (You Only Look Once)系列目标检测算法(v1-v3)作者 Joe Redmon 宣布不再继续CV方向的研究，引起学术圈一篇哗然。YOLO之父宣布退出CV界，坦言无法忽视自己工作带来的负面影响。当大家以为再也见不到YOLOv4的时候，然鹅不久前YOLOv4 来了！YOLOv4的特点是集大成者，俗称堆料。但最终达到这么高的性能，是不断尝试、不断堆料、不断调参的结果，最终取得了非常好的成绩。

[YOLOv4](https://github.com/AlexeyAB/darknet)的一作是 Alexey Bochkovskiy, 这里对Alexey不过多赘述，简单说他就是Darknet另一个github版本的维护者/YOLO接棒者，大神的YOLOv4的代码库地址：https://github.com/AlexeyAB/darknet 。

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
参见《寒武纪Linux驱动安装手册-v*.*.*.pdf》
注：安装驱动前，请先安装MLU板卡，再进行驱动安装。

## 2.4. 安装Docker
Docker安装参见：https://docs.docker.com/engine/install/

## 2.5. 启动Docker
启动Docker参见：[../README.md](../README.md)

## 2.6. 设置环境变量
声明环境变量（该操作每次进入docker都需要进行）
```bash
# 设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
export PATH_NETWORK="/home/share/pytorch/yolov4"
export PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
export PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"
# 设置环境变量
export TORCH_HOME="${PATH_NETWORK_MODELS}/pytorch_models"
export DATASET_HOME=/data/datasets
export COCO_PATH_PYTORCH=$DATASET_HOME/
```

## 2.9. 准备网络模型
从官网下载配置文件及模型权重,以下以yolov4(416*416)为例进行演示.
|Name|URL|Note|
|----|-------|-------|
|`Darknet`|https://github.com/AlexeyAB/darknet.git||
|`yolov4.cfg`|https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4.cfg||
|`yolov4.weights`|https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights|Google-drive mirror [yolov4.weights](https://drive.google.com/open?id=1cewMfusmPjYWbrnuJRuKhPMwRe_b9PaT)|

```bash
#进入模型目录
cd ${PATH_NETWORK_MODELS}
#下载yolov4.cfg
wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4.cfg
#下载yolov4.weights
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights
#注：如果是自己的网络，则不用再下载。可以直接替换【${PATH_NETWORK}】目录中【yolov4.cfg】、【yolov4.weights】.
```

## 2.10. 创建模型目录
```bash
#创建SDK中模型目录
if [ ! -d "${TORCH_HOME}/origin/checkpoints/" ];then mkdir -p ${TORCH_HOME}/origin/checkpoints/;fi
if [ ! -d "${TORCH_HOME}/int16/checkpoints/" ];then mkdir -p ${TORCH_HOME}/int16/checkpoints/;fi
if [ ! -d "${TORCH_HOME}/int8/checkpoints/" ];then mkdir -p ${TORCH_HOME}/int8/checkpoints/;fi
```

## 2.12. 进入虚拟环境
```bash
source /torch/venv3/pytorch/bin/activate
```

# 3. 模型量化
## 3.1 模型结构转换
如果要在Cambricon PyTorch 上使用YOLOv4 网络，需要先将[Darknet](https://github.com/pjreddie/darknet) 官方的cfg、weights文件转换成 PyTorch 中对应的pth文件，然后手动修改相关层（增加yolo层）信息匹配Cambricon PyTorch 加速要求（此操作不影响原有YOLOv4训练流程）。相关信息参见《寒武纪PyTorch用户手册-v*.*.*.pdf》中相关章节说明。
下面以官网 YOLOv4 为示例描述如何进行网络模型转换。
```bash
# 1.修改网络输入的宽&高
# 手动修改yolov4.cfg中[net]段中width和height值默认是608*608,可根据需要修改,本例中修改为416。
cd ${PATH_NETWORK_MODELS}
vim yolov4.cfg
# 2.使用工具转换网络模型【yolov4.cfg & yolov4.weights】------>【yolov4.pth】
cd ${PATH_NETWORK_MODELS}
if [ ! -d "mlu" ];then mkdir mlu;fi
cd /torch/examples/online/yolov4
#cp ./model/yolov4.cfg ./model/yolov4.cfg-bk
cp -v ${PATH_NETWORK_MODELS}/yolov4.cfg ./model/yolov4.cfg
# 备注: 如果类别有变化,请拷贝自定义的names文件到目录/torch/examples/online/yolov4/data/
#cp -v ${PATH_NETWORK_MODELS}/x.names /torch/examples/online/yolov4/data/
python eval.py -cfgfile ${PATH_NETWORK_MODELS}/yolov4.cfg -weightfile ${PATH_NETWORK_MODELS}/yolov4.weights -darknet2pth true
#注:生成的模型在当前目录下，文件名 yolov4.pth
# 3.拷贝yolov4.pth模型到之前创建的模型目录 origin/checkpoints
rm ${TORCH_HOME}/origin/checkpoints/yolov4.pth
mv yolov4.pth ${TORCH_HOME}/origin/checkpoints/yolov4.pth
ls -la ${TORCH_HOME}/origin/checkpoints/yolov4.pth
```
注: 网络配置文件(.cfg)决定了模型架构，训练时需要在命令行指定。文件以[net]段开头，定义与训练直接相关的参数。其余区段，包括[convolutional]、[route]、[shortcut]、[maxpool]、[upsample]、[yolo]层，为不同类型的层的配置参数。

## 3.2. 模型量化
Cambricon PyTorch 提供工具帮助我们量化模型。可以将32 位浮点模型量化成int8/int16 模型。
有关量化工具的使用信息，参见《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节【模型量化工具】说明。
下面以yolov4 为示例描述如何进行模型量化。

**备注:** 如果类别有变化,需要修改 /torch/examples/online/yolov4/tool/darknet2pytorch.py 中的num_classes为对应值(默认值是80)。
/torch/examples/online/yolov4/tool/darknet2pytorch.py相关修改项如下:
```bash
231         elif use_mlu:
232             print("Use MLU Yolov4_detection op !")
233             # Extract anchors
234             anchors = [12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401]
235             num_classes = 80
236             img_size_w = self.width   # 512
237             img_size_h = self.height  # 512
```
```bash
#1.生成图片列表 file_list_datasets
#cd ${PATH_NETWORK}
#../tools/getFileList.sh ${PATH_NETWORK}/datasets file_list_datasets
# 2.模型量化
cd /torch/examples/online/yolov4
#cp ./model/yolov4.cfg ./model/yolov4.cfg-bk
cp ${PATH_NETWORK_MODELS}/yolov4.cfg ./model/yolov4.cfg
python eval.py -cfgfile ${PATH_NETWORK_MODELS}/yolov4.cfg -weightfile ${PATH_NETWORK_MODELS}/yolov4.weights -quantization true -quantized_mode 1
#注:生成的模型在当前目录下，文件名yolov4.pth
# 2.通过filelist批量图片进行量化
#cp /home/share/pytorch/tools/eval.py ./
#python eval.py -cfgfile ${PATH_NETWORK_MODELS}/yolov4.cfg -weightfile ${PATH_NETWORK_MODELS}/yolov4.weights -quantization true -quantized_mode 1 -image_list ${PATH_NETWORK}/file_list_datasets
#注:Cambricon PyTorch SDK中的eval.py中默认使用一张图片进行量化,可以参考[/home/share/pytorch/tools/eval.py]修改相关代码来通过filelist批量图片进行量化,提高量化精度。

# 3.拷贝yolov4.pth模型到int8/checkpoints 目录
rm ${TORCH_HOME}/int8/checkpoints/yolov4.pth
mv yolov4.pth ${TORCH_HOME}/int8/checkpoints/yolov4.pth
ls -la ${TORCH_HOME}/int8/checkpoints/yolov4.pth
#注:如果量化成int16 需要拷贝到int16目录
```
**有关量化：什么是量化？为什么要量化？**
量化是将float32的模型转换为int8/int16的模型，可以保证计算精度在目标误差范围内的情况下，显著减少模型占用的存储空间和处理带宽。比如int8模型是指将数值以有符号8位整型数据保存，并提供int8定点数的指数position和缩放因子scale，因此int8模型中每个8位整数i表示的实际值为：value=i*2^position/scale。另一方面进行在线推理和生成离线模型时仅支持量化后的模型。

# 4. 在线推理
在线推理指使用原生 PyTorch 提供的 Python API 直接运行网络。在线推理包括逐层模式和融合模式两
种。关于在线验证工具的使用方法，参见《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关 章节【在线推理】。
```bash
#1、基于SDK-Demo 在线推理
#${ONLINE_PATH}目录下存放的是 YOLOv4 网络的实现。在此目录下执行以下脚本即可在 MLU 上运行 YOLOv4 网络的在线融合,并将 meanAP 精度输出到终端。
cd /torch/examples/online/yolov4
#cp ./model/yolov4.cfg ./model/yolov4.cfg-bk
cp ${PATH_NETWORK_MODELS}/yolov4.cfg ./model/yolov4.cfg
# 设置成 "export TORCH_HOME=/home/share/pytorch/yolov4/models/pytorch_models"
export TORCH_HOME="${PATH_NETWORK_MODELS}/pytorch_models"
python eval.py -half_input 1 -quantized_mode 1 -datadir $COCO_PATH_PYTORCH/COCO -img_num 16
#有关该脚本的参数解释信息,参见 python eval.py 脚本的参数解释 。
```

# 5. 离线推理
## 5.1. 生成离线模型
本小节主要介绍如何使用 PyTorch 生成离线模型工具。关于离线模型的使用方法请参考《寒武纪 CNRT 开发者手册》和《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节离线推理 。在 Cambricon Catch 中新增 torch_mlu.core.mlu_model.save_as_cambricon(model_name) 接口。当调用该接口时,会在进行 jit.trace 时自动生成离线模型。生成的离线模型一般是以 model_name.cambricon命名的离线模型文件。

**修改脚本**
由于目前版本SDK中genoff.py脚本中针对YOLOv4设置为了固定的512*512,所以需要修改为yolov4.cfg文件中的输入尺寸.
- 修改文件
```bash
  /torch/examples/offline/genoff/genoff.py
```
- 修改内容
```bash
109     elif model == "yolov4":
110         sys.path.append(os.path.join(abs_path, '../../online/yolov4'))
111         from tool.darknet2pytorch import yolov4
112         #in_h = 512
113         #in_w = 512
114         net = yolov4(pretrained=True, quantize=True)
115         in_h = net.height
116         in_w = net.width
```
**生成离线模型**
```bash
cd /torch/examples/offline/yolov4
# 1.设置DUMP_CONFIG_FILE
unset DUMP_CONFIG_FILE
# 2.准备tfu配置文件
cp -v ${PATH_NETWORK_MODELS}/config.ini ./
#需要将tfu配置文件中的tfu 段 skipSimpleCase 设置成0
# 3.设置模型路径,生成离线模型完毕后,需要再改回去,否则可能会导致再次操作错误.
# 备注：TORCH_HOME 是一个全局的变量，量化模型也需要，此处修改后，如果还需要量化模型跑在线demo 需要再改回去.
# 设置成 "export TORCH_HOME=/home/share/yolov4/models/pytorch_models"
export TORCH_HOME=$TORCH_HOME/int8/
# 4.配置 CNML_OPTIMIZE
export CNML_OPTIMIZE=USE_CONFIG:./config.ini
# 5.生成离线模型
#MLU270 4CORE 4BATCH FP32
#python /torch/examples/offline/yolov4/../genoff/genoff.py -fake_device 1 -model yolov4 -mcore MLU270 -mname mlu270_yolov4_4b4c_fp32 -half_input 0 -core_number 4 -batch_size 4 -input_format 0
#MLU270 4CORE 4BATCH FP16
python /torch/examples/offline/yolov4/../genoff/genoff.py -fake_device 1 -model yolov4 -mcore MLU270 -mname mlu270_yolov4_4b4c_fp16 -half_input 1 -core_number 4 -batch_size 4 -input_format 0
#MLU220 4CORE 4BATCH FP32
#python /torch/examples/offline/yolov4/../genoff/genoff.py -fake_device 1 -model yolov4 -mcore MLU220 -mname mlu220_yolov4_4b4c_fp32 -half_input 0 -core_number 4 -batch_size 4 -input_format 0
#MLU220 4CORE 4BATCH FP16
#python /torch/examples/offline/yolov4/../genoff/genoff.py -fake_device 1 -model yolov4 -mcore MLU220 -mname mlu220_yolov4_4b4c_fp16 -half_input 1 -core_number 4 -batch_size 4 -input_format 0
#移动离线模型到模型结果目录
echo "Move models to dir..."
mv *.cambricon* ${PATH_NETWORK_MODELS_MLU}
ls -la ${PATH_NETWORK_MODELS_MLU}
echo "Complete!"
```
genoff.py脚本参数使用说明如下,详细说明见《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节【离线模型生成工具】。
- -fake_device:用于设置是否不使用 mlu 设备生成离线模型文件,使用自动检索最优模型必须使用mlu 设备,此参数必须设置为 0。
- -autotune:用于设置是否开启自动检索生成最优离线模型选项,0 表示关闭,1 表示开启,默认值为0。
- -autotune_config_path:用于设置运行自动检索优化工具时生成的环境变量配置文件路径,默认为”config.ini”。
- -autotune_time_limit:指定运行自动检索优化工具的时间上限,默认值是 120 分钟,时间越长,优化效果越好,建议此数值设置在 - 20 分钟以上。
- -model:指定网络名称。
- -mname:指定生成离线模型文件名,默认为 offline。
- -mcore:指定硬件架构版本,当前支持 MLU270。
- -core_number:指定离线模型使用的芯片核心数量,MLU270 最大值为 16。
- -batch_size:指定使用的 batch size 大小。
- -half_input:指定 input tensor 类型,half 或者 float。

## 5.2. 执行离线推理
离线推理指序列化已编译好的算子到离线文件,生成离线模型。离线模型不依赖于 PyTorch 框架,只基于 CNRT(Cambricon Neuware Runtime Library,寒武纪运行时库)单独运行。离线模型为.cambricon文件,生成离线模型可使用 Cambricon PyTorch 的 Python 接口将模型转为离线模型。
关于离线模型的使用方法，参见《寒武纪CNRT用户手册-v*.*.*.pdf》和《寒武纪 PyTorch 用户手册-v*.*.*.pdf》中相关章节【离线推理】。

```bash
cd /torch/examples/offline/yolov4
#./run_all_offline_mc.sh 1 1
# 清理
rm -v ${PATH_NETWORK}/test/offline/*.jpg
rm -v ${PATH_NETWORK}/test/offline/*.txt

# 备注: 如果类别有变化,请拷贝自定义的label_map_coco.txt文件替换/torch/examples/offline/yolov4/label_map_coco.txt
#cp -v /torch/examples/offline/yolov4/label_map_coco.txt /torch/examples/offline/yolov4/label_map_coco.txt-bk
cp -v ${PATH_NETWORK_MODELS}/label_map_coco.txt /torch/examples/offline/yolov4/label_map_coco.txt

#离线推理
echo "running offline test..."
#file_list_datasets(${PATH_NETWORK}/datasets)
#../build/yolov4/yolov4_offline_multicore -offlinemodel ${PATH_NETWORK_MODELS_MLU}/mlu270_yolov4_4b4c_fp16.cambricon -dataset_path ${PATH_NETWORK}/datasets -images ${PATH_NETWORK}/file_list_datasets -labels ./label_map_coco.txt -simple_compile 1 -outputdir ${PATH_NETWORK}/test/offline/ -input_format 0

#file_list_coco_val2017(${ROOT_HOME}/datasets/COCO/val2017/)
../build/yolov4/yolov4_offline_multicore -offlinemodel ${PATH_NETWORK_MODELS_MLU}/mlu270_yolov4_4b4c_fp16.cambricon -dataset_path $COCO_PATH_PYTORCH/COCO/val2017 -images ../../data/coco2017/file_list_for_release -labels ./label_map_coco.txt -simple_compile 1 -outputdir ${PATH_NETWORK}/test/offline/ -input_format 0
#ls -la ${PATH_NETWORK}/test/offline/ | wc -l
echo "Complete!"
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
## 7. 精度测试
```bash
#计算 meanAp 命令
#yolov4的精度衡量指标一般为mAP(mean average precision)。一般基于COCO 数据集或者VOC 数据集计算yolov4模型的mAP。
#以COCO 数据集为例，该数据集一共有80类，如"person","car","dog" 等。
#计算yolov4在COCO 数据集中的mAP过程是：输入COCO 图片，输出推理结果，推理结果需要保存在txt文件中，每张image 对应一个txt。
#然后计算总mAP的时候，会先计算每一类的mAP，然后求所有类别mAP的平均值。注意，不同的ioU范围下，mAP的值不同。
#yolov4_1b4c_simple & file_list_2014
cd ${PATH_NETWORK}/test/offline/
#批量删除文件名前缀
#for name in yolov4_offline*.jpg; do mv "$name" "${name#*yolov4_offline_}"; done
#file_list_datasets
#python /torch/examples/offline/scripts/meanAP_COCO.py --file_list ${PATH_NETWORK}/file_list_datasets --result_dir ${PATH_NETWORK}/test/offline --ann_dir $DATASET_HOME/COCO --data_type val2017 --net_name yolo_v4

#file_list_coco_val2017
python /torch/examples/offline/scripts/meanAP_COCO.py --file_list /torch/examples/data/coco2017/file_list_for_release --result_dir ${PATH_NETWORK}/test/offline --ann_dir $DATASET_HOME/COCO --data_type val2017 --net_name yolo_v4

# meanAP_COCO.py 输入参数为：
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

# 8. 附录
## 8.1. 官网yolov4.cfg中net层
```bash
[net]
# Testing # 测试时，batch和subdivisions设置为1,否则可能出错。
#batch=1 # 大一些可以减小训练震荡及训练时NAN的出现。
#subdivisions=1 # 必须为为8的倍数，显存吃紧可以设成32或64。
# Training
batch=64 # 训练过程中将64张图一次性加载进内存，前向传播后将64张图的loss累加求平均，再一次性后向传播更新权重。
subdivisions=16 # 一个batch分16次完成前向传播，即每次计算4张。
width=608 # 网络输入的宽。
height=608 # 网络输入的高。
channels=3 # 网络输入的通道数。
momentum=0.949 # 动量梯度下降优化方法中的动量参数，更新的时候在一定程度上保留之前更新的方向。
decay=0.0005 # 权重衰减正则项，用于防止过拟合。
angle=0 # 数据增强参数，通过旋转角度来生成更多训练样本。
saturation = 1.5 # 数据增强参数，通过调整饱和度来生成更多训练样本。
exposure = 1.5 # 数据增强参数，通过调整曝光量来生成更多训练样本。
hue=.1 # 数据增强参数，通过调整色调来生成更多训练样本。
learning_rate=0.001 # 学习率。
burn_in=1000 # 在迭代次数小于burn_in时，学习率的更新为一种方式，大于burn_in时，采用policy的更新方式。
max_batches = 500500 #训练迭代次数，跑完一个batch为一次，一般为类别数*2000，训练样本少或train from scratch可适当增加。
policy=steps # 学习率调整的策略。
steps=400000,450000 # 动态调整学习率，steps可以取max_batches的0.8~0.9。
scales=.1,.1 # 迭代到steps(1)次时，学习率衰减十倍，steps(2)次时，学习率又会在前一个学习率的基础上衰减十倍。
#cutmix=1 # cutmix数据增强，将一部分区域cut掉但不填充0像素而是随机填充训练集中的其他数据的区域像素值，分类结果按一定的比例分配。
mosaic=1 # 马赛克数据增强，取四张图，随机缩放、随机裁剪、随机排布的方式拼接，详见上述代码分析。
```
## 8.2. 官网yolov4.cfg中yolo层
```bash
#yolov4.cfg中有三个yolo层
[yolo]
mask = 6,7,8 #当前属于第几个预选框。
# coco数据集默认值，可通过detector calc_anchors，利用k-means计算样本anchors，但要根据每个anchor的大小(是否超过60*60或30*30)更改mask对应的索引(第一个yolo层对应小尺寸；第二个对应中等大小；第三个对应大尺寸)及上一个conv层的filters。
anchors = 12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401
#整个yolov4网络使用了9个Ancnor尺寸，都在这里，通过mask来选择该层yolo层选用哪几个anchor。
#anchor是利用k-means算法基于训练集而得到的目标统计尺寸。本层选用了最大的三个anchor，很显然，本层的目的是着眼于检测大目标。
classes=80 #网络需要识别的物体种类数。
num=9 # 预选框的个数，即anchors总数。
jitter=.3 # 通过抖动增加噪声来抑制过拟合, 利用数据抖动来产生更多的数据，这里的抖动概率是0.3
ignore_thresh = .7
#当预测框与真实框（ground truth）的IOU超过该值时，不参与loss计算，否则参与计算
truth_thresh = 1
random=1 #如果为1，每次迭代图片大小随机从320到608，步长为32，如果为0，每次训练大小与输入大小一致。也就是多尺度训练。
scale_x_y = 1.05
iou_thresh=0.213
cls_normalizer=1.0
iou_normalizer=0.07
iou_loss=ciou # CIOU损失函数，考虑目标框回归函数的重叠面积、中心点距离及长宽比。
nms_kind=greedynms
beta_nms=0.6
max_delta=5
```

## 8.3 后处理算子参数
- 修改文件：
```
tool/darknet2pytorch.py
```
- 修改点：
```
搜索下 yolov4_detection_output 算子，将后处理类别进行修改，直接从cfg 读取
```
```
#以模型实际参数进行修改
            # Extract anchors
​            anchors = [12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401]
​            #num_classes = 80
​            num_classes = self.num_classes   #修改成从网络获取
​            img_size_w = self.width   # 512
​            img_size_h = self.height  # 512
​            conf_thres = 0.1
​            nms_thres = 0.6
​            maxBoxNum = 1024
​            num_anchors = 18
​            scale_x_y = 1.05
​            beta = 0.6
            # 0:DEFAULT_NMS  1:DIOU_NMS  2:DEFAULT_SINGLE_LABEL_NMS
​            nms_type_idx = 2
```