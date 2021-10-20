import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms

import torch_mlu.core.mlu_quantize as mlu_quantize
import torch_mlu
# 如果需要使用仓库内置网络 
import models
import torchvision.models as models

import cv2
import numpy as np

import os
import sys
# 网络定义在当前目录下的 create_feature_extract.py 文件中
net_dir = os.getcwd()
sys.path.append(net_dir)
from create_feature_extract import feature_extract

# 传入 一张图,原始权重,和量化后的权重存放的位置
if len(sys.argv) is not 4:
   print("Please input an image, weight file and where to store quantized weight file!")
   print("e.g., python forward_feature_extract.py ./6.png ./ckpt.t7 ./feature_extract_quantized.pth")
   exit()
img_dir = sys.argv[1]
weight_dir = sys.argv[2]
quantized_weight_dir = sys.argv[3]

#获得 Net 网络及加载原始权重
torch.set_grad_enabled(False)

# 实例化一个 net
net = feature_extract(False, weight_dir)
net = net.to(torch.device('cpu'))
net.eval()

#读取一张图片,并进行前处理
#读取一张图片
img = cv2.imread(img_dir)[:,:,(2,1,0)]

# preprc 前处理, resize ,量化到 0-1 ,减均值除方差
size = (64, 128)
resized_img = cv2.resize(img.astype(np.float32)/255., size)
norm = transforms.Compose([
           transforms.ToTensor(),
           transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
     
])  
input_img = norm(resized_img).unsqueeze(0).float()

# 调用量化接口
# 设置均值和标准差
mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]

# 实例化量化 net
quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(net,
{'mean':mean, 'std':std}, dtype='int8', gen_quant=True)

# 执行推理,以生成量化值
# 执行量化 net
output_cpu = quantized_net(input_img)

# 保存量化模型
# 保存量化权重
torch.save(quantized_net.state_dict(), quantized_weight_dir)


