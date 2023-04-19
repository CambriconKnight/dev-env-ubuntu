# Parser&Builder API usage example

Table Of Contents
- [内容描述](#description)
- [工作原理](#how-does-this-sample-work)
- [运行准备](#preparing-sample-data)
  * [数据预处理](#data-preprocessing)
- [编译运行](#compiling-and-running-the-sample)
  * [命令行参数](#sample-options)
  * [运行示例](#bash-command-example)

## 内容描述

本示例以四个框架Caffe/PyTorch/Tensorflow/ONNX为例,展示如何使用MagicMind的C++API进行运行部署前的模型编译工作，包括：
- 通过人工智能框架模型接口解析模型。
- 使用当前MagicMind支持的量化统计算法，和数据预处理后的量化校准数据集进行浮点模型量化校准。
- 使用模型编译功能生成供MagicMind运行时部署可在寒武纪人工智能硬件上使用的网络结构图和网络数据文件。

## 工作原理

本示例以一个人工智能学习框架模型和其权值文件作为输入，程序按如下步骤执行：
- 初始化MagicMind，并使用解析器和用户命令行参数解析提供的模型。
- 如果用户提供了校准集数据和校准参数，将按照该输入进行模型校准，这个过程需要寒武纪人工智能加速卡。
- 编译模型并在指定目录输出可部署于MagicMind运行时的网络结构图/网络数据文件。
如需运行本示例生成的网络部署文件，可以使用寒武纪对外提供的MagicMind模型部署工具mm_run或用户自行根据手册调用MagicMind运行时。

## 运行准备

运行本示例前，用户需自行配置对应的人工智能框架模型和数据集，寒武纪提供了部分可用于benchmark的网络模型/数据集列表，见《寒武纪MagicMind Benchmark指南》模型和数据集章节。

### 数据预处理

示例提供了简单的数据预处理模块在目录`samples/tools/preprocess`下，入口文件为 `samples/tools/preprocess/preprocess.py`，用户可以直接调用当前文件来对`imagenet`数据集进行处理，具体使用方式见`samples/tools/preprocess/README.md`。
假定标定数据集处理后存储目录为`result`, 存储目录中的`file_list`包含所有标定数据集文件名，预处理后的数据可以用于量化校准：
```bash
./caffe_build \
  --prototxt ${MODEL_NAME}.prototxt \
  --caffemodel ${MODEL_NAME}.caffemodel \
  --calibration 1 \
  --file_list file_list \
  --calibration_data_path ./result/ \
  --precision qint8_mixed_float16
```
用户亦可以直接使用calibration模式，但不给入任何数据集，此模式编译产物仅用于性能测试。
```bash
./caffe_build \
  --prototxt ${MODEL_NAME}.prototxt \
  --caffemodel ${MODEL_NAME}.caffemodel \
  --calibration 1 \
  --precision qint8_mixed_float16
```
具体命令行参数配置见下。

## 编译运行

本示例提供了命令行编译和脚本编译功能，具体而言，可使用通过命令行输入：
```bash
bash samples/build_template.sh samples/mm_build
```
或
```bash
mkdir build
cd build
cmake ..
make
```
build目录下生成如下可执行文件：
```bash
caffe_build  onnx_build  pytorch_build  tensorflow_build
```
run.sh内以Resnet50为示例提供了最基本的运行命令，用户可以根据自身准备的运行文件和命令行参数进行进一步调整。

### 命令行参数

```bash
*_build --help
```
显示命令行语法与具体备选输入。

#### 通用参数

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| precision             | 否 | --precision mode                  | 网络精度模式 | 默认使用forced_float32，具体支持配置语义同MagicMind::IBuilderConfig文档。 |
| calibration           | 否 | --calibration 0/1/True/False      | 量化校准开关 | 默认关，如果打开可以配合量化校准数据集路径和文件列表，亦可以不给入任何数据集和路径直接填入默认量化参数（只保证编译，不保证精度）。 |
| rpc_server            | 否 | --rpc_server address:port         | 远端校准地址 | 默认空，如果填入可以使用远端设备进行量化校准。 |
| calibration_algo      | 否 | --calibration_algo linear/eqnm    | 量化校准算法 | 默认linear，选择量化校准时使用的量化算法。 |
| file_list             | 否 | --file_list path/to/file          | 量化校准文件列表 | 文件包含所有已经处理过的标定数据集文件列表，用来做量化校准使用。多输入之间以空格作为分隔符。[^1] |
| calibration_data_path | 否 | --calibration_data_path path      | 表示量化校准用数据集目录。| - |
| random_calib_range    | 否 | --random_calib_range min,max      | 量化校准使用随机数据，决定随机数据的分布上下界。优先级高于文件。 |
| batch_size            | 否 | --batch_size batch                | 设置生成的模型的所有输入的batch数目。| 默认可以不设置，优先级高于输入形状。 |
| input_dims            | 否 | --input_dims a,b,c,d e,f,g,h...   | 模型输入维度 | 单输入维度间以”,“作为分隔符，多输入之间以空格作为分隔符，PyTorch与TensorFlow模型中没有明确的输入维度信息，如果不填入此参数，则需要运行期指定。 |
| input_layout          | 否 | --input_layout layout1 layout2    | 编译后模型输入布局 | 编译过程中将输入布局由通道后置转为通道前置（或者反过来），给定的参数即为转换后的布局，举例：给如NTC，代表希望将模型输入由NCT转为NTC。 |
| input_dtypes          | 否 | --input_dtypes type1 type2...     | 模型输入类型 | 多输入之间以空格作为分隔符，默认为浮点类型。 |
| dynamic_shape         | 否 | --dynamic_shape 0/1/True/False    | 模型可变编译 | 是否编译可变模型，默认为可变。 |
| vars                  | 否 | --var a,b,c d,e,f                 | 模型输入各通道的方差, 做除标准差操作：(input - mean) / std，方差val就是std² | 多输入之间以空格作为分隔符，默认为浮点类型, 具体配置方式见《寒武纪MagicMind用户手册》。 |
| means                 | 否 | --mean a,b,c d,e,f                | 模型输入各通道的均值, 做减均值操作：(input - mean) | 多输入之间以空格作为分隔符，默认为浮点类型，具体支持配置语义同MagicMind::IBuilderConfig文档。 |
| output_layout         | 否 | --output_layout layout1 layout2   | 编译后模型输出布局 | 编译过程中将输出布局由通道后置转为通道前置（或者反过来），给定的参数即为转换后的布局，举例：给如NTC，代表希望将模型输出由NCT转为NTC。 |
| output_dtypes         | 否 | --output_dtypes dtype             | 模型输出类型 | 多输出之间以空格作为分隔符，默认为浮点类型。 |
| mlu_arch              | 否 | --mlu_arch mtp_1 mtp_2            | 指定部署的MLU设备平台 | 默认进行全平台编译，多平台编译以空格分隔，具体支持配置语义同MagicMind::IBuilderConfig文档。 |
| plugin                | 否 | --plugin /path/to/pluginop        | 指定plugin算子的库地址 | 多输入之间以空格作为分隔符。 |
| magicmind_model       | 否 | --magicmind_model path/to/file    | 输出离线模型数据文件 | 默认为./model。 |
| build_config          | 否 | --build_config path/to/file       | BuildConfig配置json文件 | 具体支持配置语义同MagicMind::IBuilderConfig文档。 |
| toolchain_path        | 否 | --toolchain_path /path/to/toochain| 指定交叉编译工具链的路径 | 默认指向/tmp/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/。 |
| rgb2bgr               | 否 | --rgb2bgr 0/1/True/False          | 将Conv卷积网络首层权重从RGB格式转为BGR格式，若首层Conv前有乘加算子，同样会进行转换。不能对非卷积网络使用。 | - |
| cluster_num           | 否 | --cluster_num a,b,c d,e,f         | 指定模型使用的cluster_num | cluster_num可以配置多个值，如果用户设置的cluster_num的值小于或等于实际获得的cluster_num，它将首先匹配完全相等的值，然后选择最接近的值。如果用户设置的cluster_num的所有值都大于实际获得的cluster_num，将在运行时阶段报告错误。|

[^1]: 可使用的filelist有两种格式，其一为每行内容即前处理后的数据文件地址，此时进行量化校准使用网络输入作为量化校准数据的形状。其二为每行内容在数据文件地址之后，以空格分割数据形状，即`filepath shape[a,b,c,d]`，逐文件可以不一样，此时量化校准使用文件内形状作为量化校准数据的形状，即可变校准。在不提供数据文件规模的情况下，每行数据文件默认认为属于单张输入（输入最高维1）。

#### caffe_build参数

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| prototxt              | 是 | --prototxt path/to/file           | Caffe框架模型文件路径 | 仅caffe_build有效，需要和caffemodel一起提供。 |
| caffemodel            | 是 | --caffemodel path/to/file         | Caffe框架权值文件路径 | 仅caffe_build有效，需要和prototxt一起提供。 |

#### onnx_build参数

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| onnx                  | 是 | --onnx path/to/file               | ONNX框架模型文件路径 | 仅onnx_build有效。 |

#### pytorch_build参数

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| pytorch_pt            | 是 | --pytorch_pt path/to/file         | PyTorch框架模型文件路径 | 仅pytorch_build有效，用户可以参照手册和示例添加PyTorch其他模型格式。 |
| pt_input_dtypes       | 否 | --pt_input_dtypes dtype1 dtype2...| PyTorch框架模型文件输入类型 | 仅pytorch_build有效，默认为FLOAT（单输入）。 |

#### tf_build参数

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| tf_pb                 | 是 | --tf_pb path/to/file              | TensorFlow框架模型文件路径 | 仅tf_build有效，用户可以参照手册和示例添加TensorFlow其他模型格式，pb模型格式原生没有输入输出信息，需要和input_names/output_names一起提供。 |
| input_names           | 是 | --input_names_name1 name2...      | TensorFlow框架模型文件输入 | 仅tf_build有效，pb模型格式输入信息，多输入以空格分隔，需要和tf_pb/output_names一起提供。 |
| output_names          | 是 | --output_names_name1 name2...     | TensorFlow框架模型文件输出 | 仅tf_build有效，pb模型格式输出信息，多输出以空格分隔，需要和tf_pb/input_names一起提供。 |

### 运行示例

常见参数组合见`run.sh`。
具体框架限制见《寒武纪MagicMind用户手册》导入框架模型章节。
- Caffe

  ```bash
  ./caffe_build \
    --prototxt ${MODEL_NAME}.prototxt \
    --caffemodel ${MODEL_NAME}.caffemodel \
  ```

  - Caffe模型带有明确的输入输出节点名称、维度、数据类型信息。

- PyTorch

  ```bash
  ./pytorch_build \
    --pytorch_pt ${MODEL_NAME}.pt \
    --input_dims ${INPUT_DIMS} \
    --pt_input_dtypes ${INPUT_DTYPES}
  ```

  - PyTorch模型带有明确的输入输出节点名称信息，没有维度与数据类型信息。

- ONNX

  ```bash
  ./onnx_build \
    --onnx ${MODEL_NAME}.onnx
  ```

  - ONNX模型带有明确的输入输出节点名称、维度、数据类型信息。

- TensorFlow

  ```bash
  ./tensorflow_build \
    --tf_pb ${MODEL_NAME}.pb \
    --input_names ${INPUT_NAMES} \
    --output_names ${OUTPUT_NAMES} \
    --input_dims ${INPUT_DIMS}
  ```

  - TensorFlow pb模型带有明确的输入输出节点数据类型信息，没有名称与维度信息。
