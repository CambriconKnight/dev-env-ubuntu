
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
CNVS（Cambricon Validation Suite，寒武纪验证套件）用于如下场景：
- 在实际的业务执行前，快速、便捷地检查设备的软硬件工作环境是否正常。
- 集成了一系列功能、性能、稳定性插件，以便于发现部署、系统软件、硬件配置等方面的故障，以及可能存在的性能问题。

## 1.1. 硬件环境

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-S4     | 一套       |机箱风扇需满足MLU370板卡被动散热要求|

## 1.2. 软件环境

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_5.10.13_amd64.deb | 依操作系统选择                         |
| Docker Image          | magicmind_1.6.0-1_ubuntu18.04.tar.gz                 | 官方发布的 MagicMind 框架 Docker 镜像文件 |
| SDK                   | cntoolkit_3.6.1-1.ubuntu18.04_amd64.deb              | SDK需联系寒武纪技术服务人员获取 |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**依赖库下载方式**

关注微信公众号 AIKnight , 发送文字消息, 包含关键字(不区分大小写): `cnvs`, 公众号会自动回复cnvs相关依赖库的下载地址；

**AIKnight公众号**
>![](../../res/aiknight_wechat_344.jpg)

请把下载后的依赖库放置到目录 [dependent_files](../dependent_files),方便根据脚本提示进行后续操作，完成目录结构如下：

```bash
.
├── cambricon-mlu-driver-ubuntu18.04-dkms_5.10.13_amd64.deb
├── cambricon-mlu-driver-ubuntu18.04-dkms_5.10.13_amd64.deb.md5sum
├── cntoolkit_3.6.1-1.ubuntu18.04_amd64.deb
├── cntoolkit_3.6.1-1.ubuntu18.04_amd64.deb.md5sum
├── magicmind_1.6.0-1_ubuntu18.04.tar.gz
├── magicmind_1.6.0-1_ubuntu18.04.tar.gz.md5sum
└── README.md

0 directories, 7 files
```

## 1.3. 下载仓库
```bash
#进入裸机工作目录，以【/data/github】工作目录为例
cd /data/github
#下载仓库
git clone https://github.com/CambriconKnight/dev-env-ubuntu.git
#进入【工具包目录】
cd ./dev-env-ubuntu/mm
```
## 1.4. 加载镜像

请提前下载好【Docker镜像】，方便以下操作加载使用。

```bash
#进入【工具包目录】
cd ./dev-env-ubuntu/mm
#加载Docker镜像
#./load-image-dev.sh ./dependent_files/magicmind_1.6.0-1_ubuntu18.04.tar.gz
./load-image-dev.sh ${FULLNAME_IMAGES}
```

## 1.5. 启动容器

镜像加载完成后，运行脚本，进入Docker容器。

```bash
#进入【mm工具集目录】
cd ./dev-env-ubuntu/mm
#启动容器
./run-container-dev.sh
```
**操作实例**
```bash
[kangshaopeng@worker1 mm]$ ./run-container-dev.sh
[sudo] password for kangshaopeng:
0
container-magicmind-1.6.0-x86_64-ubuntu18.04-py_3_7-kang
WARNING: Published ports are discarded when using host network mode
root@worker1:/home/share#
```

以上基于官方正式发布的Docker镜像，方便后续直接测试验证。

# 2. 安装
## 2.1. 一键执行
```bash
#以下操作步骤均是在官方提供的Docker容器中进行
#进入测试目录
cd /home/share/mm/cnvs
#一键安装依赖库及CNVS工具包
./init-cnvs.sh
```

## 2.2. 分步执行
一键执行后，就不需要分步执行了。以下为分步操作：
```bash
# 安装依赖库
apt-get update
apt-get install libpci3 libpci3 pciutils
apt --fix-broken install
apt-get install libyaml-dev
#安装CNVS
dpkg -i /var/cntoolkit-3.6.1/cnvs_0.12.0-1.ubuntu18.04_amd64.deb
```

# 3. 测试
## 3.1. 检查软硬件环境

software插件可用于检查当前的软硬件环境是否配置正确，以便于执行用户的应用程序。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "software" -v
```
**实例**
```bash
root@worker1:/home/share/mm/cnvs# cnvs -r "software" -v
[INFO 22192 main.cpp:91] CNVS version: 0.12.1
[INFO 22192 plugin_manager.cpp:99] running plugin [software] ...
[INFO 22192 plugin_manager.cpp:115] plugin [software]: PASS

root@worker1:/home/share/mm/cnvs#
```
## 3.2. targeted_stress

targeted_stress插件可根据用户设置的参数，通过调整矩阵乘算子的规模，让设备的每秒负载达到用户期望的目标性能值。该插件可用于观测在目标负载情况下设备的功耗、温度等表现。

>![](../../res/note.gif) **备注：**
>- targeted_stress插件统计的性能，是根据计算量除以执行时间得到，该执行时间包括输入、输出数据在HOST和MLU之间进行拷贝的时间。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "targeted_stress" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./targeted_stress-test.sh
```

## 3.3. mlu_stress

mlu_stress插件可根据用户设置的参数，通过调整矩阵乘算子的规模，让设备的每秒负载达到用户期望的目标性能值。 该插件可用于观测在目标负载情况下，设备的功耗、温度等表现。

>![](../../res/note.gif) **备注：**
>- mlu_stress插件统计的性能，是根据计算量除以执行时间得到，但该执行时间不包括输入、输出数据在HOST和MLU之间进行拷贝的时间，这是mlu_stress插件和targeted_stress插件的区别。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "mlu_stress" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./mlu_stress-test.sh
```

## 3.4. targeted_power

targeted_power插件可根据用户设置的参数，通过逐步增加计算任务的负载，使设备运行在用户期望的功耗下。 该插件可用于帮助用户发现特定功耗下是否可能出现超温降频等问题。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "targeted_power" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./targeted_power-test.sh
```

## 3.5. memory_bandwidth

memory_bandwidth插件会在MLU Core上执行读写GDRAM的内存带宽测试。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "memory_bandwidth" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./memory-test.sh
```

## 3.6. matmul_performance

matmul_performance插件会执行一个特定规模的矩阵乘算子，以便用户得到MLU设备的矩阵乘算子性能。

**命令**
```bash
cd /home/share/mm/cnvs
#使用默认值进行测试
cnvs -r "matmul_performance" -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./matmul-test.sh
```

## 3.7. peak_performance

peak_performance插件会执行一个特定规模的conv计算，以便用户得到MLU设备的峰值运算性能。

**命令**
```bash
cd /home/share/mm/cnvs
#使用默认值进行测试
cnvs -r "peak_performance" -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./peak-test.sh
```

## 3.8. pcie

pcie插件用于测试各种情况下的PCIe拷贝带宽及延迟。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "pcie" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./peak-test.sh
```

## 3.9. mlulink

mlulink插件用于测试mlulink性能，报告异常数据。该插件统计单主机下，多设备之间的mlulink单向、双向拷贝带宽，以及单向拷贝延迟。

**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "mlulink" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

**实例**
```bash
cd /home/share/mm/cnvs
#执行测试脚本
./mlulink-test.sh
```

>![](../../res/note.gif) **备注：**
>- 有关各个测试插件的详细使用，请参考CNVS手册： https://www.cambricon.com/docs/sdk_1.14.0/cntoolkit_3.6.1/cnvs_0.12.0/index.html
