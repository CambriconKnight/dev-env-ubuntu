import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import torch_mlu.core.mlu_quantize as mlu_quantize
import torch_mlu.core.mlu_model as ct
import torch_mlu
import cv2
import numpy as np
import os
import sys
net_dir = os.getcwd()
sys.path.append(net_dir)
from create_feature_extract import feature_extract

if len(sys.argv) is not 4:
    print("Please input an image, weight file and quantized weight file!")
    print("e.g., python forward_feature_extract.py ./6.png ./ckpt.t7 ./feature_extract_quantized.pth")
    exit()

img_dir = sys.argv[1]
weight_dir = sys.argv[2]
quantized_weight_dir = sys.argv[3]
torch.set_grad_enabled(False)

#读取一张图片
img = cv2.imread(img_dir)[:,:,(2,1,0)]
# resize
size = (64, 128)

#实例化一个 feature_extract 网络
net = feature_extract(False, weight_dir)
net = net.to(torch.device('cpu'))
net.eval()

# preproc
resized_img = cv2.resize(img.astype(np.float32)/255., size)
norm = transforms.Compose([
           transforms.ToTensor(),
           transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
     
       ])  
input_img = norm(resized_img).unsqueeze(0).float()

# cpu forward
output_cpu = net(input_img)

#设置均值和标准差
mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]

#实例化量化 net
quantized_net = torch_mlu.core.mlu_quantize.quantize_dynamic_mlu(net,{'mean':mean, 'std':std}, dtype='int8', gen_quant=True)

# cpu quantized forward
output_quantized_cpu = quantized_net(input_img)

#实例化一个 feature_extract 网络 , quantized=Ture
mlu_net = feature_extract(True, quantized_weight_dir)
mlu_net = mlu_net.to(ct.mlu_device())

# preproc 
# 前处理,由于我们使用了 firstconv ,并传入了均值和标准差,因此只需要 resize 操作,不需要归一化等操作。
#
resized_img = cv2.resize(img, size)

# HWC -> CHW
input_img = torch.from_numpy(resized_img.transpose(2,0,1)).unsqueeze(0).float()

#拷⻉到 mlu
input_img_mlu = input_img.to(ct.mlu_device())

# mlu forward
output_mlu = mlu_net(input_img_mlu)


