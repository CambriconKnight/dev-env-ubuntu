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
cd /home/ftp/mlu270/1.6.602/cntoolkit/X86_64/ubuntu16.04
dpkg -i cntoolkit_1.7.2-1.ubuntu16.04_amd64.deb
cd /var/cntoolkit-1.7.2/
dpkg -i *.deb
```
## 7.2. CNML
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
cd /home/ftp/mlu270/1.6.602/cnml/ubuntu16.04
dpkg -i cnml_7.9.4-1.ubuntu16.04_amd64.deb
```

## 7.2. CNPlugin
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
cd /home/ftp/mlu270/1.6.602/cnplugin/ubuntu16.04
dpkg -i cnplugin_1.10.106-1.ubuntu16.04_amd64.deb
```

# 8. Deploy SDK
## 8.1 Caffe
### 8.1.1 部署Cambricon Caffe
```bash
#以下操作都在容器中操作
#Docker容器映射目录[/home/ftp/],以实际目录为准
cd /home/ftp/mlu270/1.6.602/caffe/src
tar zxvf caffe-v5.3.604.tar.gz -C /opt/work/
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

