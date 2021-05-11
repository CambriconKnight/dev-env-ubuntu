# 1. Overview

使用已安装Cambricon Caffe 运行环境的Docker容器中进行开发，需先执行以下步骤加载镜像并启动容器。
以下表格中内容为依赖项
|类别|文件|
|----|-------|
|驱动|[neuware-mlu270-driver-dkms_4.4.4_all.deb](ftp://download.cambricon.com:8821/product/MLU270/v1.5.0/driver)|
|镜像|[mlu270_v1.5.0_ubuntu16.04.caffe_v1.0.tar.gz](ftp://username@download.cambricon.com:8821/product/MLU270/v1.5.0/docker-images)|
|加载镜像|load-mlu200-image-ubuntu16.04.caffe.sh|
|运行容器|run-mlu200-docker-ubuntu16.04.caffe.sh|

# 2. Structure

```bash
.
├── load-mlu200-image-ubuntu16.04.caffe.sh
├── run-mlu200-docker-ubuntu16.04.caffe.sh
└── README.md
```

# 3. Load
```bash
#加载Docker镜像
./load-mlu200-image-ubuntu16.04.caffe.sh ${FULLNAME_IMAGES}
```
```bash
#加载Docker镜像
cam@cam-3630:/data/github/easy-deploy-mlu/caffe$ ./load-mlu200-image-ubuntu16.04.caffe.sh /data/ftp/v1.5.0/docker-images/mlu270_v1.5.0_ubuntu16.04.caffe_v1.0.tar.gz
[sudo] password for cam:
0
mlu270_v1.5.0_ubuntu16.04.caffe
The image is not loaded and is loading......
63f451eb9fa9: Loading layer [==================================================>]   2.56kB/2.56kB
40c7e9efb360: Loading layer [==================================================>]    510kB/510kB
39bfebde293a: Loading layer [==================================================>]   2.56kB/2.56kB
5a80ca88af1d: Loading layer [==================================================>]  4.096kB/4.096kB
15111af6fbda: Loading layer [==================================================>]  1.322GB/1.322GB
67a26de6479e: Loading layer [==================================================>]  3.072kB/3.072kB
255aee7f07e6: Loading layer [==================================================>]  4.096kB/4.096kB
c14fddc01369: Loading layer [==================================================>]  3.072kB/3.072kB
b97f0ed1d218: Loading layer [==================================================>]  3.072kB/3.072kB
73ce5852c97b: Loading layer [==================================================>]  76.28MB/76.28MB
a498fca6502d: Loading layer [==================================================>]  77.76MB/77.76MB
0415b038c6e8: Loading layer [==================================================>]  1.585MB/1.585MB
2d551522dae7: Loading layer [==================================================>]  16.01MB/16.01MB
a91442c0e04b: Loading layer [==================================================>]  2.247MB/2.247MB
a8eddd6834af: Loading layer [==================================================>]  1.402GB/1.402GB
5ddf96efdddb: Loading layer [==================================================>]  4.096kB/4.096kB
9bbae90d421a: Loading layer [==================================================>]  2.956MB/2.956MB
68c54b4d0b81: Loading layer [==================================================>]  425.5MB/425.5MB
a31dffc45248: Loading layer [==================================================>]  1.745GB/1.745GB
734491da9967: Loading layer [==================================================>]  3.584kB/3.584kB
9615d9b181ea: Loading layer [==================================================>]  3.072kB/3.072kB
Loaded image: cambricon/scm/dockerfile/mlu270_v1.5.0_ubuntu16.04.caffe:v1.0
The image information:
REPOSITORY                                                   TAG                 IMAGE ID            CREATED             SIZE
cambricon/scm/dockerfile/mlu270_v1.5.0_ubuntu16.04.caffe     v1.0                563cfd55883d        3 months ago        5.2GB
cam@cam-3630:/data/github/easy-deploy-mlu/caffe$
```

# 4. Run
```bash
#启动caffe容器
./run-mlu200-docker-ubuntu16.04.caffe.sh
```
```bash
cam@cam-3630:/data/github/easy-deploy-mlu/caffe$ ./run-mlu200-docker-ubuntu16.04.caffe.sh
0
mlu200_container-ubuntu16.04.caffe-v1.5.0
root@cam-3630:/opt/cambricon# ls
Cambricon-CNPlugin-MLU270.tar.gz  caffe  configure_caffe.sh  env_caffe.sh  run_caffe.sh
root@cam-3630:/opt/cambricon#
```

# 5. Test
```bash
#设置环境变量(该步骤每次进入docker都需要操作)
source env_caffe.sh
```

```bash
root@cam-3630:/opt/cambricon# ls -la
total 1369060
drwxr-xr-x 1 root root       4096 Aug 27 04:18 .
drwxr-xr-x 1 root root       4096 Aug 27 04:09 ..
-rw-r--r-- 1 root root 1401884819 Aug 26 16:49 Cambricon-CNPlugin-MLU270.tar.gz
drwxr-xr-x 1 root root       4096 Aug 27 04:15 caffe
-rwxr-xr-x 1 root root        323 Aug 26 16:44 configure_caffe.sh
-rw-r--r-- 1 root root       1029 Aug 26 16:44 env_caffe.sh
-rwxr-xr-x 1 root root        238 Aug 26 16:44 run_caffe.sh
root@cam-3630:/opt/cambricon# source env_caffe.sh
root@cam-3630:/opt/cambricon#
```
