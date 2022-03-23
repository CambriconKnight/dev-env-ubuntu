## 适配链接：https://github.com/ultralytics/yolov5

## 1.cpu推理原始模型
```
python3 convertmodel.py --arg cpu
```

## 2.模型量化
```
python3 convertmodel.py --arg quant
```

## 3.mlu融合推理及生成离线模型
```
python3 convertmodel.py --arg mfus --genoff true
```
执行后会在当前路径下生成.cambricon离线模型文件，可在yolov5-off_test-20210727中使用

## 4.FAQ
1) 使用自己训练的模型，需要注意替换使用的yaml及pth文件
--convertmodel.py
```
class DetectMark():
    def __init__(self, opt):
        # initialize models
        ModelPath = None
        self.running_mode = opt.arg
        self.gen_off = opt.genoff
        if ModelPath is not None:
                self.model_path = ModelPath
        else:
            if self.running_mode == 'cpu' or self.running_mode == 'quant':
                #self.model_path = './weights/nozip.pt'
                self.model_path = './yolov5m-state-31.pth'
            else:
                self.model_path = './yolov5_quant.pth'
        self.model = Model('./models/yolov5m.yaml')
```

2) 依照自己的代码，修改/models下yolo.py及common.py的参数