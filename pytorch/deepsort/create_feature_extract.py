import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms

from torchvision.models.quantization.utils import quantize_model
import torch_mlu
import cv2
import numpy as np

# ---- work around
class MLUNormalize(nn.Module):
   def __init__(self):
       super(MLUNormalize, self).__init__()
       self.qscale = torch.ones(1,1)
       self.qmode = torch.ones(1,1)
       self.scale = torch.nn.Parameter(torch.ones(1))
       self.eps = 1e-12
   def forward(self, x):
       #return torch.ops.torch_mlu.normalize(x, 2, self.scale, self.qscale, self.qmode, self.eps)
       return torch.ops.torch_mlu.normalize(x, 2, self.scale, self.eps)

class BasicBlock(nn.Module):
   def __init__(self, c_in, c_out,is_downsample=False):
       super(BasicBlock,self).__init__()
       self.is_downsample = is_downsample
       if is_downsample:
           self.conv1 = nn.Conv2d(c_in, c_out, 3, stride=2, padding=1, bias=False)
       else:
           self.conv1 = nn.Conv2d(c_in, c_out, 3, stride=1, padding=1, bias=False)
       self.bn1 = nn.BatchNorm2d(c_out)
       self.relu = nn.ReLU(True)
       self.conv2 = nn.Conv2d(c_out,c_out,3,stride=1,padding=1, bias=False)

       self.bn2 = nn.BatchNorm2d(c_out)
       if is_downsample:
           self.downsample = nn.Sequential(
               nn.Conv2d(c_in, c_out, 1, stride=2, bias=False),
               nn.BatchNorm2d(c_out)
         
	   )
       elif c_in != c_out:
           self.downsample = nn.Sequential(
               nn.Conv2d(c_in, c_out, 1, stride=1, bias=False),
               nn.BatchNorm2d(c_out)
         
	   )
           self.is_downsample = True
   def forward(self,x):
       y = self.conv1(x)
       y = self.bn1(y)
       y = self.relu(y)
       y = self.conv2(y)
       y = self.bn2(y)
       if self.is_downsample:
           x = self.downsample(x)
       return F.relu(x.add(y),True)

def make_layers(c_in,c_out,repeat_times, is_downsample=False):
   blocks = []
   for i in range(repeat_times):
       if i ==0:
           blocks += [BasicBlock(c_in,c_out, is_downsample=is_downsample),]
       else:
           blocks += [BasicBlock(c_out,c_out),]
   return nn.Sequential(*blocks)

class Net(nn.Module):
   def __init__(self, num_classes=751 ,reid=False, quantized=False):
       super(Net,self).__init__()
       # 3 128 64
       self.conv = nn.Sequential(
           nn.Conv2d(3,64,3,stride=1,padding=1),
           nn.BatchNorm2d(64),
           nn.ReLU(inplace=True),
           nn.MaxPool2d(3,2,padding=1),
     
       )
       # 64 64 32
       self.layer1 = make_layers(64,64,2,False)
       # 64 64 32
       self.layer2 = make_layers(64,128,2,True)
       # 128 32 16
       self.layer3 = make_layers(128,256,2,True)
       # 256 16 8
       self.layer4 = make_layers(256,512,2,True)
       # 512 8 4
       self.avgpool = nn.AvgPool2d((8,4),1)
       # 512 1 1
       self.reid = reid
       self.classifier = nn.Sequential(
           nn.Linear(512, 256),
           nn.BatchNorm1d(256),
           nn.ReLU(inplace=True),
           nn.Dropout(),
           nn.Linear(256, num_classes),
       )
       # ---- work around
       self.quantized = quantized
       self.mlu_norm = MLUNormalize()
   
   def forward(self, x):
       x = self.conv(x)
       x = self.layer1(x)
       x = self.layer2(x)
       x = self.layer3(x)
       x = self.layer4(x)
       x = self.avgpool(x)
       x = x.view(x.size(0), -1)
       # B x 512
       if self.reid:
           if self.quantized:
               # ---- work around
               x = self.mlu_norm(x)
               #print(x.cpu().flatten()[0:100])
           else:
               x = x.div(x.norm(p=2,dim=1,keepdim=True))
               # print(x.cpu().flatten()[0:100])
           return x
       # classifier
       x = self.classifier(x)
       return x

def create_feature_extract(need_quantized=False):
   return Net(reid=True, quantized=need_quantized)

def feature_extract(quantized, weight_dir):
   #model = nn.DataParallel(model).cuda()
   #model.load_state_dict(torch.load("C:\\Users\\83543\\Desktop\\model_best.pth.tar")['state_dict'],False)

   model = create_feature_extract(quantized)
   if quantized:
       model = quantize_model(model, inplace=True)
   if weight_dir.endswith(".pth"):
       state_dict = torch.load(weight_dir, map_location='cpu')
   elif weight_dir.endswith(".t7"):
       print("quantized:",quantized)
       print("weight file is ", weight_dir)
       state_dict = torch.load(weight_dir, map_location=lambda storage, loc:storage)['net_dict']
   else:
       print("weight file is not valid ", weight_dir)
       exit()
   # ignore inconsistent of pth and model weight
#   model = nn.DataParallel(model).cuda()
   model.load_state_dict(state_dict, strict = False)
   return model

