
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
CNVS（Cambricon Validation Suite，寒武纪验证套件）用于如下场景：
- 在实际的业务执行前，快速、便捷地检查设备的软硬件工作环境是否正常。
- 集成了一系列功能、性能、稳定性插件，以便于发现部署、系统软件、硬件配置等方面的故障，以及可能存在的性能问题。

**硬件环境准备:**

| 名称           | 数量      | 备注                  |
| :------------ | :--------- | :------------------ |
| 开发主机/服务器  | 一台       | 采用已完成适配的服务器；PCIe Gen.4 x16 |
| MLU370-S4     | 一套       |机箱风扇需满足MLU370板卡被动散热要求|

**软件环境准备:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| Driver_MLU370         | cambricon-mlu-driver-ubuntu18.04-dkms_4.20.18_amd64.deb| 依操作系统选择                         |
| Docker Image          | magicmind_1.1.0-1_ubuntu18.04.tar.gz                 | 官方发布的 MagicMind 框架 Docker 镜像文件 |
| SDK                   | cntoolkit_3.2.2-1.ubuntu18.04_amd64.deb              | SDK需联系寒武纪技术服务人员获取 |

注: 以上软件环境中文件名词, 如有版本升级及名称变化, 可以在 [env.sh](./env.sh) 中进行修改。

**依赖库下载方式**

关注微信公众号 AIKnight , 发送文字消息, 包含关键字(不区分大小写): `cnvs`, 公众号会自动回复cnvs相关依赖库的下载地址；

**AIKnight公众号**
>![](../../res/aiknight_wechat_344.jpg)

请把下载后的依赖库放置到目录 [dependent_files](../dependent_files),方便根据脚本提示进行后续操作，完成目录结构如下：

```bash
.
├── cambricon-mlu-driver-ubuntu18.04-dkms_4.20.18_amd64.deb
├── cambricon-mlu-driver-ubuntu18.04-dkms_4.20.18_amd64.deb.md5sum
├── cntoolkit_3.2.2-1.ubuntu18.04_amd64.deb
├── cntoolkit_3.2.2-1.ubuntu18.04_amd64.deb.md5sum
├── magicmind_1.1.0-1_ubuntu18.04.tar.gz
├── magicmind_1.1.0-1_ubuntu18.04.tar.gz.md5sum
└── README.md

0 directories, 7 files
```

# 2. 安装
```bash
# 安装依赖库
apt-get update
apt-get install libpci3 libpci3 pciutils
apt --fix-broken install
apt-get install libyaml-dev
#安装CNVS
dpkg -i /var/cntoolkit-3.2.2/cnvs_0.8.1-rc1.ubuntu18.04_amd64.deb
```

# 3. 测试
## 3.1. 检查软硬件环境
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "software" -v
```
**实例**
```bash
root@worker1:/home/share/mm/cnvs# cnvs -r "software" -v
[INFO 22192 main.cpp:91] CNVS version: 0.8.1 c82b454
[INFO 22192 plugin_manager.cpp:99] running plugin [software] ...
[INFO 22192 plugin_manager.cpp:115] plugin [software]: PASS

root@worker1:/home/share/mm/cnvs#
```

## 3.2. targeted_stress
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "targeted_stress" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

## 3.3. mlu_stress
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "mlu_stress" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

## 3.4. targeted_power
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "targeted_power" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

## 3.5. memory_bandwidth
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "memory_bandwidth" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

## 3.6. matmul_performance
**命令**
```bash
cd /home/share/mm/cnvs
#使用默认值进行测试
cnvs -r "matmul_performance" -v
```

## 3.7. peak_performance
**命令**
```bash
cd /home/share/mm/cnvs
#使用默认值进行测试
cnvs -r "peak_performance" -v
```

## 3.8. pcie
**命令**
```bash
cd /home/share/mm/cnvs
cnvs -r "pcie" -c /usr/local/neuware/bin/cnvs.example.yml -v
```

详细使用请参考CNVS手册： https://www.cambricon.com/docs/sdk_1.10.0/cntoolkit_3.2.2/cnvs_0.8.1/index.html
