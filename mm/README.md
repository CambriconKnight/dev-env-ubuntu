
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于官方发布的 MagicMind 框架的 Docker 容器。 官方发布的 Docker 容器已经对 MagicMind 框架进行了编译安装。可按照以下步骤可快速基于 Cambricon MagicMind 框架进行各类网络的模型推理等验证工作。

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-S4     | 一套       |机箱风扇需满足MLU370板卡被动散热要求|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Docker Image          | magicmind_1.6.0-1_ubuntu18.04.tar.gz                  | 官方发布的 MagicMind 框架 Docker 镜像文件 |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_5.10.13_amd64.deb | 依操作系统选择                         |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**下载地址:**

前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载， 也可在官方提供的专属FTP账户指定路径下载。

文档: https://developer.cambricon.com/index/document/index/classid/3.html

SDK: https://sdk.cambricon.com/download?component_name=MagicMind

# 2. 目录结构

```bash
.
├── clean.sh                                #清理脚本,包括清理临时目录或文件,已加载的容器等
├── cnvs                                    #用于cnvs的快速应用
├── dependent_files                         #依赖库及工具下载说明.
├── env.sh                                  #脚本全局环境变量,使用时需要根据实际修改.
├── load-image-dev.sh                       #用作加载docker镜像的脚本
├── README.md                               #目录说明
└── run-container-dev.sh                    #用作启动docker容器的脚本
```

# 3. 下载依赖库

**下载方式**
1. 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载到本目录；
2. 可通过官方技术对接人员提供的专属FTP账户指定路径下载；
3. 关注微信公众号 AIKnight , 发送文字消息, 包含关键字(不区分大小写): **mm依赖库**, 公众号会自动回复对应下载地址；

请把下载后的依赖库放置到目录(dependent_files)下, 方便进行后续操作。

```bash
./dependent_files/
├── magicmind_1.6.0-1_ubuntu18.04.tar.gz        #MagicMind 框架 Docker镜像
├── magicmind_1.6.0-1_ubuntu18.04.tar.gz.md5sum #Docker镜像MD5值
└── README.md
```

# 4. 下载仓库
```bash
#下载仓库
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
#进入对应目录
cd ./dev-env-ubuntu/mm
```

# 5. 加载镜像
```bash
#加载Docker镜像
#./load-image-dev.sh ./dependent_files/magicmind_1.6.0-1_ubuntu18.04.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

# 6. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【mm工具集目录】
cd ./dev-env-ubuntu/mm
#启动容器
./run-container-dev.sh
```

# 7. 环境确认
容器中，默认已安装 magicmind 和 benchmark 模块，验证方式如下：
```bash
#环境确认命令
pip list |grep benchmark && pip list |grep magicmind
```
输出结果如下，说明环境正常。
```bash
root@localhost:/# pip list |grep benchmark && pip list |grep magicmind
benchmark               1.6.0
[notice] A new release of pip available: 22.3.1 -> 23.2.1
[notice] To update, run: pip install --upgrade pip
magicmind               1.6.0
[notice] A new release of pip available: 22.3.1 -> 23.2.1
[notice] To update, run: pip install --upgrade pip
root@localhost:/#
```
如果没有以上输出，可自行安装 magicmind 和 benchmark
```bash
pip3 install magicmind_<x.y.z>-cp37-cp37m-linux_<arch>.whl
#pip install magicmind-1.6.0-cp37-cp37m-linux_x86_64.whl
#pip install benchmark-1.1.0-cp37-cp37m-linux_x86_64.whl
```
<x.y.z> 为MagicMind 版本号，<arch> 为CPU 架构。

# 8. ModelZoo验证

本章节基于 [寒武纪官方ModelZooCloud](https://gitee.com/cambricon/magicmind_cloud) 在上述启动的mm容器中进行模型验证。以下操作及所处目录，都是在docker容器环境下操作。

**下载ModelZoo仓库**
```bash
#进入对应目录
cd /home/share/mm
#下载仓库
git clone https://gitee.com/cambricon/magicmind_cloud.git
#进入对应目录
cd /home/share/mm/magicmind_cloud
```
仓库下载完成后，参考仓库中 [README.md](https://gitee.com/cambricon/magicmind_cloud) 进行各个网络移植验证。
