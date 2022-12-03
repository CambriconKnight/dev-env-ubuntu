
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录适配于官方针对寒武纪边缘侧/端侧产品发布的 MagicMind 框架 Docker 容器。 该 Docker 容器可用于各类网络模型的量化及对应生成设备侧部署的离线模型。按照以下步骤可以快速搭建基于Docker容器的开发环境。

**运行环境**

- 主机系统: Ubuntu16.04/Ubuntu18.04/CentOS7
- 软件栈版本: 0.13.0
- 深度学习框架: MagicMind
- 镜像文件: magicmind_0.13.0-1_ubuntu18.04.tar.gz
- Docker: ⽤⼾需要⾃⾏安装docker（版本要求 >= v19.03）

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       |主流配置即可；         |

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Docker Image          | magicmind_0.13.0-1_ubuntu18.04.tar.gz                 | 官方针对寒武纪边缘侧/端侧产品发布的 MagicMind 框架 Docker 容器 |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. 网络图谱
Cambricon PyTorch 支持的典型网络及移植流程。
|网络名称|操作目录|备注|
|----|-------|-------|

# 3. 下载镜像

下载官方针对寒武纪边缘侧/端侧产品发布的 MagicMind 框架 Docker 容器。 可前往寒武纪开发者社区注册账号按需下载, 也可在官方提供的专属FTP账户指定路径下载。

官方发布的镜像包命名格式: magicmind_<x.y.z>-1_ubuntu<a.b>.tar.gz , 其中 <x.y.z> 为MagicMind 版本号，<a.b> 为操作系统版本号。

# 4. 加载镜像
```bash
#加载Docker镜像
#./load-image-dev.sh /data/ftp/ce3226/mm/0.13.0/magicmind_0.13.0-1_ubuntu18.04.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 5. 启动容器
```bash
#启动容器
./run-container-dev.sh
```

# 6. 交叉编译
## 6.1. 交叉编译环境准备
参考一下操作, 根据实际SDK包位置,解压到工作目录.
```bash
# 1. 进入工作目录
cd /home/share/edge/cross_compile
# 2. 设置环境变量(首次进入容器需要设置环境变量)
source env-ce3226.sh
# 3. 更新BSP所需的系统依赖软件(mm镜像中中没有安装的依赖软件)
./update-os.sh
```
## 6.2. BSP交叉编译
**分步说明**
```bash
# 1. 进入工作目录
cd /home/share/edge/cross_compile
# 2. 拷贝或下载sdk到[../dependent_files]目录
#cp -rvf /data/ftp/ce3226/sdk/ce3226v100-sdk-1.1.0.tar.gz ../dependent_files
# 3. 解压SDK到本目录
tar zxvf ../dependent_files/ce3226v100-sdk-1.1.0.tar.gz -C ./
# 4. 解压bsp到本目录
tar zxvf ./ce3226v100-sdk-1.1.0/board/package/bsp.tar.gz -C ./
# 5. 进入bsp编译目录
cd /home/share/edge/cross_compile/bsp/ce3226v100_build/build
# 6.执行make
make all
# 7.编译完后,在out/目录下是生成所有的bsp镜像文件
ls -la ./out
# 8.设置权限,否则可能会导致tftp下载失败
chmod 644 ./out/ubootenv*
ls -la ./out
# 9.备用操作
## 9.1.如需要则修改用户权限
#sudo chown cam:cam -R ./out/*
## 9.2.拷贝到tftp目录
#cp -rvf ./out/*.bin ./out/*.img ./out/*.itb /data/tftp
```
**一键编译**
```bash
# 1. 进入工作目录
cd /home/share/edge/cross_compile
# 2. 一键编译
./build_bsp.sh
```