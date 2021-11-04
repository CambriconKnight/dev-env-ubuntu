<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/XXX">
        <h1 align="center">MLU算法移植教程-XXX模型名称</h1>
    </a>
</p>

**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

<!-- TOC -->

- [1.概述](#1概述)
- [2.环境准备](#2环境准备)
- [3.一键移植](#3一键移植)
  - [3.1.脚本说明](#31脚本说明)
  - [3.2.脚本和样例代码](#32脚本和样例代码)
  - [3.3.脚本参数](#33脚本参数)
- [4.分步移植](#4分步移植)
  - [4.1.模型量化](#41模型量化)
  - [4.2.在线推理](#42在线推理)
  - [4.3.转换模型](#43转换模型)
  - [4.4.离线推理](#44离线推理)
  - [4.5.性能测试](#45性能测试)
    - [4.5.1.推理性能](#451推理性能)
  - [4.6.精度测试](#46精度测试)
    - [4.6.1.推理精度](#461推理精度)
- [5.常见问题](#5常见问题)
- [6.参考模板](#6参考模板)
- [7.贡献指南](#7贡献指南)
  - [7.1.贡献者](#71贡献者)
- [8.仓库主页](#8仓库主页)

<!-- TOC -->

# 1.概述

> 该模型通用介绍

下面我们就来看看该模型如何在基于寒武纪MLU智能加速卡上移植开发。

整个移植过程大体可分为环境准备、模型量化、在线推理、生成离线模型、离线推理、性能测试、精度测试共七个步骤，以下详细描述整个移植过程。相关移植套件参见[dev-env-ubuntu](https://gitee.com/cambriconknight/dev-env-ubuntu)。

- **相关开发资料可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载，也可在官方提供的专属FTP账户指定路径下载。**
- **有关寒武纪产品开发资料的公开链接汇总参见[cam-dev-info](https://gitee.com/cambriconknight/cam-dev-info)。**

# 2.环境准备

> 提供运行该代码前需要的环境配置，包括：
>
> * python第三方库，在模型root文件夹下添加一个'requirements.txt'文件，文件内说明模型依赖的第三方库
> * 必要的第三方代码
> * 其他的系统依赖
> * 在模型转换&推理前额外的操作

一般优先选择Docker上执行, 包括如下几步环境准备操作, 如有特殊请自行删减：

准备物理环境 >> 获取开发资料 >> 安装MLU驱动 >> 安装Docker >> 加载镜像 >> 启动容器 >> 设置环境变量 >> 准备网络模型 >> 准备数据集 >> 创建模型目录 >> 进入虚拟环境

# 3.一键移植

为了实现可重复,高鲁棒性的操作, 本章节提供一键转换网络模型脚本。

> 使用一条什么样的命令/脚本可以直接运行, 实现一键转换网络模型的目的。

## 3.1.脚本说明

> 提供实现的细节

## 3.2.脚本和样例代码

> 描述项目中每个文件的作用

## 3.3.脚本参数

> 注释模型中的每个参数

# 4.分步移植

为了更深入的了解网络模型移植过程, 本章节提供分步移植网络模型的各个步骤。

分步移植移植过程大体可分为模型量化、在线推理、转换模型、离线推理、性能测试、精度测试共六个步骤，以下详细描述整个移植过程。

## 4.1.模型量化

> 提供模型量化步骤

## 4.2.在线推理

> 提供在线推理步骤

## 4.3.转换模型

> 提供转换离线模型步骤

## 4.4.离线推理

> 提供离线推理步骤及推理结果确认

## 4.5.性能测试

> 提供性能测试步骤及结果汇总

### 4.5.1.推理性能

> 提供推理性能的详细描述，包括耗时，吞吐等

> 你可以参照如下模板

| Parameters          | MLU                         |
| ------------------- | --------------------------- |
| Model Version       | ResNet18                    |
| Resource            | MLU270-F4; Ubuntu16.04      |
| Uploaded Date       | 11/04/2021 (month/day/year) |
| Driver Version      | 4.9.8                       |
| Neuware Version     | 1.7.0                       |
| Dataset             | CIFAR-10                    |
| batch_size          | 4                           |
| outputs             | throughput                  |
| Accuracy            | 10000fps                    |
| Model for inference | 21M (.cambricon file)       |

## 4.6.精度测试

> 提供精度测试步骤及结果汇总

### 4.6.1.推理精度

> 提供推理精度的详细描述，包括 mAP 等

你可以参照如下模板

| Parameters          | MLU                         |
| ------------------- | --------------------------- |
| Model Version       | MaskRCNN                    |
| Resource            | MLU270-F4; Ubuntu16.04      |
| Uploaded Date       | 11/04/2021 (month/day/year) |
| Driver Version      | 4.9.8                       |
| Neuware Version     | 1.7.0                       |
| Dataset             | CIFAR-10                    |
| batch_size          | 4                           |
| outputs             | mAP                         |
| Accuracy            | IoU=0.50:0.95 32.4%         |
| Model for inference | 219M (.cambricon file)      |

# 5.常见问题

> 说明该项目执行过程中有可能出现的常见问题或随机事件

# 6.参考模板

[ResNet-50_README](https://gitee.com/cambriconknight/dev-env-ubuntu/tree/master/pytorch/resnet50/README.md)

# 7.贡献指南

如果你想参与贡献本仓库的工作当中，请阅读[贡献指南](https://gitee.com/cambriconknight/dev-env-ubuntu/blob/master/CONTRIBUTING.md)和[how_to_contribute](https://gitee.com/cambriconknight/dev-env-ubuntu/blob/master/how_to_contribute)

## 7.1.贡献者

- 在模型量化上，工作贡献者是 'XXX'
- 在在线推理上，工作贡献者是 'XXX'
- 在转离线模型上，工作贡献者是 'XXX'
- 在离线推理上，工作贡献者是 'XXX'
- 在性能测试上，工作贡献者是 'XXX'
- 在精度测试上，工作贡献者是 'XXX'
- ...

# 8.仓库主页

请浏览本仓库[主页](https://gitee.com/cambriconknight/dev-env-ubuntu)。
