# 1. Overview
使用Docker容器，按照以下步骤可快速基于 Cambricon PyTorch 框架进行各类网络的部署、移植、在线/离线推理等验证工作。

# 2. Structure
Cambricon PyTorch 支持的典型网络及移植流程.
|网络名称|操作目录|备注|
|----|-------|-------|
|`YOLOv4-416`|./yolov4-416|416*416|

# 3 部署PyTorch
## 3.1 部署Cambricon PyTorch
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/PyTorch/src
tar zxvf pytorch-v0.15.0.tar.gz -C /opt/work/
```

## 3.2 编译与安装Cambricon PyTorch
此章节包含Cambricon PyTorch的编译\安装\验证.
## 3.2.1 环境设置
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

## 3.2.2 一键编译
```bash
#以下操作都在容器中操作
#进入以下路径，运行脚本编译Cambricon PyTorch
cd $ROOT_HOME
#脚本包含包含后面的分步编译中1~4步骤
./configure_pytorch.sh 0
```

## 3.2.3 分步编译
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
