
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 概述
本目录下脚本适配于基于CNML的一些实例测试。

**测试环境搭建参考** [../README.md](../README.md)

**相关依赖下载方式** 关注微信公众号 AIKnight , 发送: `cnml`, 会得到 `cnml相关依赖包`的下载地址；

>![](../../res/aiknight_wechat_344.jpg)

# 2. 编译
编译cnmml测试程序.
```bash
cd /usr/local/neuware/samples/cnml/script
#编译
./compileSP_cnml.sh
```

# 3. 测试
## 3.1. 算力测试
使用cnml压测最大算力, 由于软硬件因素限制,可能与实际算力值有偏差.
**命令**
```bash
cd /usr/local/neuware/samples/cnml/script
#算力测试
./runExampleTests.sh 8 1
```
**实例**
如下所示实例, 测试日志中`compute TOPS `为 测试出的MLU270算力数值.
```bash
root@cam-3630:/usr/local/neuware/samples/cnml/script# ./runExampleTests.sh 8 1
/usr/bin/gcc
/usr/local/neuware/samples/cnml/build /usr/local/neuware/samples/cnml/script
-- Running cambricon release cnml test cases.
cnml test, test_code = 8 coreVersion = 1
CNML: 7.10.3 85350b141
CNRT: 4.10.4 41e356b
computing conv op on MLU...
compile cost 244.388 ms
compute forward cost 1.419 ms
compute MAC = 167772160000.000000
compute TOPS = 118.233 T
dumping mlu result to file mlu_output...
/usr/local/neuware/samples/cnml/script
root@cam-3630:/usr/local/neuware/samples/cnml/script#
```
