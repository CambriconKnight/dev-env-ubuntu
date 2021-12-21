# 1. 说明
本目录，为了帮助用户，快速构建一个用于yolov5模型降版本的容器。
生成的容器名称：


## 1.2 本目录结构
├── build-ubuntu18.04-yolov5.sh   //构建对齐版本用的容器，python:3.6.9 ,torch：1.7.0
├── clean.sh
├── Dockerfile.18.04-yolov5       // dockerfile，可以根据需要，自行修改。
├── load-ubuntu18.04-yolov5.sh    // 加载容器
├── pip.conf            
├── readme.md
├── requirements.txt-bak    
├── run-ubuntu18.04-yolov5.sh          // 运行容器
├── save-ubuntu18.04-yolov5.sh         // 保存容器          
└── sources_18.04.list          // apt-get源，默认清华源

## 1.1 构建容器
```
./build-ubuntu18.04-yolov5.sh
```

## 1.2 加载容器
```
./load-ubuntu18.04-yolov5.sh
```
注：执行构建容器时，默认已加载容器

## 1.3 运行容器
```
./run-ubuntu18.04-yolov5.sh
```
