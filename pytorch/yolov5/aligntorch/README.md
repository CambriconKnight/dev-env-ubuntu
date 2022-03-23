<p align="center">
    <a href="https://github.com/CambriconKnight/dev-env-ubuntu/tree/master/pytorch/yolov5/aligntorch">
        <h1 align="center">YOLOv5环境搭建与对齐模型版本</h1>
    </a>
</p>

# 1. 概述

由于官方 [YOLOv5](https://github.com/ultralytics/yolov5) 依赖 PyTorch 版本 >=1.6， 而寒武纪版本为1.3。 所以在进行YOLOv5模型转换操作前，需要在标准pytorch 环境中（非MLU版本），将模型权重转换为 Torch 版本为1.3的模型文件， 本文基于Docker环境进行环境搭建与对齐操作说明。

*本工具集仅用于个人学习，打通流程； 不对效果负责，不承诺商用。*

**说明:**

操作之前需要从官网或者自训练工程中，准备YOLOv5模型权重文件。

## 1.1. 硬件环境准备

| 名称            | 数量       | 备注                |
| :-------------- | :--------- | :------------------ |
| 开发主机/服务器 | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |

## 1.2. 软件环境准备

| 名称                   | 版本/文件                                    | 备注            |
| :-------------------- | :-------------------------------             | :--------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7   | 宿主机操作系统   |
| YOLOv5                | v5.0   | 自动[下载](https://github.com/ultralytics/yolov5/archive/refs/tags/v5.0.tar.gz)    |
| yolov5s.pt            | v5.0   | 自动[下载](https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5s.pt)    |
| yolov5m.pt            | v5.0   | 自动[下载](https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5m.pt)    |
| yolov5l.pt            | v5.0   | 自动[下载](https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5l.pt)    |
| yolov5x.pt            | v5.0   | 自动[下载](https://github.com/ultralytics/yolov5/releases/download/v5.0/yolov5x.pt)    |

*以上软件包可下载到本地[dependent_files](./dependent_files)目录下,方便对应以下步骤中的提示操作。*

## 1.3. 资料下载

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

Ubuntu18.04: http://mirrors.aliyun.com/ubuntu-releases/18.04

# 2. Structure

*当前仓库默认基于Docker 进行YOLOv5环境搭建与对齐模型版本。按照以下章节步骤即可快速实现YOLOv5环境搭建与对齐模型版本*

```bash
..
├── aligntorch.sh                       #此脚本用于对齐模型版本
├── build-image-yolov5-align.sh         #此脚本用于编译Docker 镜像用于搭建YOLOv5环境
├── clean.sh                            #清理Build出来的临时目录或文件,包括镜像文件,已加载的镜像,已加载的容器等
├── docker                              #此目录主要用于存储编译Docker 镜像所需依赖文件
│   ├── clean.sh                        #清理当前目录下新编译生存的Docker 镜像文件
│   ├── Dockerfile.18.04                #用于编译Docker 镜像的Dockerfile 文件
│   ├── pip.conf                        #切换python的pip源
│   ├── pre_packages.sh                 #安装基于操作系统所需依赖包, 也可用于裸机下环境搭建
│   ├── requirements.txt                #用于记录所有依赖包及其精确的版本号,以便新环境部署
│   └── sources_18.04.list              #Ubuntu18.04 sources文件
├── env.sh                              #用于设置全局环境变量
├── load-image-yolov5-align.sh          #加载Docker 镜像
├── README.md                           #README
├── run-container-yolov5-align.sh       #启动Docker 容器
├── save-image-yolov5-align.sh          #导出镜像文件，实现镜像内容持久化
├── tools                               #常用工具存放目录
└── weights                             #原始模型权重存放目录
```

*如需在裸机HOST上进行环境搭建, 也可以利用本目录下[aligntorch.sh](./aligntorch.sh)脚本实现快速搭建。*

# 3. Build
```bash
#编译 Docker 镜像
./build-image-yolov5-align.sh
```

# 4. Load
```bash
#加载 Docker 镜像
./load-image-yolov5-align.sh
```

# 5. Run
```bash
#启动 Docker 容器
./run-container-yolov5-align.sh
```

# 6. Align

*该脚本默认会自动下载并转换 YOLOv5 官方的 yolov5s.pt 模型，输出路径为【output】,输出文件默认名称为yolov5s.pth。*
*用户转换自己训练的模型时， 替换【weights】目录下的模型文件或修改[aligntorch.sh](./aligntorch.sh)脚本中需要转换的模型名称的宏定义 MODDEL_NAME_ORG。*

```bash
#执行测试脚本
#将高Torch版本 YOLOv5 模型权重转为 Torch 版本为1.3的模型权重文件。
cd /home/share/
./aligntorch.sh
```
