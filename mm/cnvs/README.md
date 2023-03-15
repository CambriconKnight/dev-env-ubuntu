
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
CNVS（Cambricon Validation Suite，寒武纪验证套件）用于如下场景：
- 在实际的业务执行前，快速、便捷地检查设备的软硬件工作环境是否正常。
- 集成了一系列功能、性能、稳定性插件，以便于发现部署、系统软件、硬件配置等方面的故障，以及可能存在的性能问题。

**测试环境搭建参考** [../README.md](../README.md)

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
