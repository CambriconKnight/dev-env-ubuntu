# 1. Overview
使用Docker容器，按照以下步骤可快速进行部署、移植、在线/离线推理等验证工作。

# 2. Structure
## 2.1. 脚本
```bash
.
├── build-image-ubuntu16.04-dev.sh
├── load-image-ubuntu16.04-dev.sh
└── run-container-ubuntu16.04-dev.sh
```
## 2.2. 依赖项
`driver`: [neuware-mlu270-driver-dkms_4.9.2_all.deb](ftp://download.cambricon.com:8821/product/MLU270/1.6.602/driver)

`cntoolkit`: [cntoolkit_1.7.2-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/MLU270/1.6.602/cntoolkit/X86_64/ubuntu16.04)

`cnml`: [cnml_7.9.4-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/MLU270/1.6.602/cnml/ubuntu16.04)

`cnplugin`: [cnplugin_1.10.106-1.ubuntu16.04_amd64.deb](ftp://download.cambricon.com:8821/product/MLU270/1.6.602/cnplugin/ubuntu16.04)

# 3. Clone
```bash
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
```

# 4. Build
```bash
#编译Docker镜像
./build-image-ubuntu16.04-dev.sh
```

# 5. Load
```bash
#加载Docker镜像
./load-image-ubuntu16.04-dev.sh ${FULLNAME_IMAGES}
```

# 6. Run
```bash
#启动容器
./run-container-ubuntu16.04-dev.sh
```

# 7. Install Dependent
## 7.1. CNToolkit
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/CNToolkit
dpkg -i cntoolkit_1.7.3-1.ubuntu16.04_amd64.deb
cd /var/cntoolkit-1.7.3/
dpkg -i *.deb
#Version:1.6.602
#cd /home/ftp/mlu270/1.6.602/cntoolkit/X86_64/ubuntu16.04
#dpkg -i cntoolkit_1.7.2-1.ubuntu16.04_amd64.deb
#cd /var/cntoolkit-1.7.2/
#dpkg -i *.deb

```
## 7.2. CNML
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/CNML
dpkg -i cnml_7.10.2-1.ubuntu16.04_amd64.deb
#Version:1.6.602
#cd /home/ftp/mlu270/1.6.602/cnml/ubuntu16.04
#dpkg -i cnml_7.9.4-1.ubuntu16.04_amd64.deb
```

## 7.3. CNPlugin
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/CNPlugin
dpkg -i cnplugin_1.12.1-1.ubuntu16.04_amd64.deb
#Version:1.6.602
#cd /home/ftp/mlu270/1.6.602/cnplugin/ubuntu16.04
#dpkg -i cnplugin_1.10.106-1.ubuntu16.04_amd64.deb
```

## 7.4. CNNL
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/CNNL
dpkg -i cnnl_1.3.0-1.ubuntu16.04_amd64.deb
#Version:1.6.602
#
```

## 7.5. CNCL
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/CNCL
dpkg -i cncl_0.8.0-1.ubuntu16.04_amd64.deb
#Version:1.6.602
#
```

# 8. Deploy SDK
## 8.1 CaffeSDK
### 8.1.1 部署Cambricon Caffe
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
#Version:v1.7.0
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/Caffe/src
tar zxvf caffe-v5.4.0.tar.gz -C /opt/work/
#Version:1.6.602
#cd /home/ftp/mlu270/1.6.602/caffe/src
#tar zxvf caffe-v5.3.604.tar.gz -C /opt/work/
```

### 8.1.2 编译Cambricon Caffe
```bash
#以下操作都在容器中操作
#设置压缩包解压后的根目录
export ROOT_HOME=/opt/work
cd $ROOT_HOME
#创建数据集和模型软链接目录(以实际目录为准):DATASET_HOME, CAFFE_MODELS_DIR
ln -s /data/datasets datasets
ln -s /data/models models
#设置环境变量
source $ROOT_HOME/env_caffe.sh
#进入以下路径，运行脚本编译Cambricon Caffe
cd ${CAFFE_HOME}/src/caffe/scripts
bash build_caffe_mlu270_cambricon_release.sh
#编译完成后,结果确认:
#打开目录build/lib，若编译生成了libcaffe.so 和_caffe.so 两个文件，
#则说明Cambricon Caffe 编译成功。
ls -la ${CAFFE_HOME}/src/caffe/build/lib
```

### 8.1.3 安装Cambricon Caffe
Cambricon Caffe 编译完成以后，进入build 目录执行以下命令即可完成Cambricon Caffe 的安装
```bash
#以下操作都在容器中操作
cd ${CAFFE_HOME}/src/caffe/build
make install
```

### 8.1.4 验证Cambricon Caffe
Cambricon Caffe编译及安装完成后,可在build 目录执行以下命令验证安装。
该命令必须在MLU 服务器上运行。若结果全通过，说明Cambricon Caffe 安装成功。
```bash
#以下操作都在容器中操作
cd ${CAFFE_HOME}/src/caffe/build
make runtest
#注:如果遇到错误,可以暂时忽略.
```

## 8.2 PyTorchSDK
### 8.2.1 部署Cambricon PyTorch
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
cd /home/ftp/mlu270/v1.7.0/Ubuntu16.04/PyTorch/src
tar zxvf pytorch-v0.15.0.tar.gz -C /opt/work/
```

### 8.2.2 编译与安装Cambricon PyTorch
此章节包含Cambricon PyTorch的编译\安装\验证.
### 8.2.2.1 环境设置
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

### 8.2.2.2 一键编译
```bash
#以下操作都在容器中操作
#进入以下路径，运行脚本编译Cambricon PyTorch
cd $ROOT_HOME
#脚本包含包含后面的分步编译中1~4步骤
./configure_pytorch.sh 0
```

### 8.2.2.3 分步编译
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
