
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 环境说明
参考[../README.md](../README.md)

# 2. 模型推理

## 2.1. 下载代码
```bash
cd /home/share/pytorch1.6/yolact
# Clone
git clone https://github.com/dbolya/yolact.git -b master
cd yolact && git checkout 57b8f2d95e62e2e649b382f516ab41f949b57239 && cd -
# Cython needs to be installed before pycocotools
pip install cython
pip install opencv-python pillow pycocotools matplotlib
```

## 2.2. 迁移代码
使用该工具 `torch_gpu2mlu.py` 从GPU模型脚本迁移至MLU设备运行，转换后的模型脚本只支持MLU设备运行。该工具可对模型脚本进行转换，对模型脚本修改位置较多，会对修改位置进行统计，实现开发者快速迁移。
- 在容器环境中，执行以下命令
```bash
cd /home/share/pytorch1.6/yolact
#建立软连接
ln -s /torch/src/catch/tools/torch_gpu2mlu.py ./
#执行转换模型脚本
python torch_gpu2mlu.py -i yolact
#显示
ls -la yolact yolact_mlu
#yolact_mlu 文件夹是转换后的代码。
```
- 输出转换结果
```bash
# Cambricon PyTorch Model Migration Report
Official PyTorch model scripts:  /home/share/pytorch1.6/yolact/yolact
Cambricon PyTorch model scripts:  /home/share/pytorch1.6/yolact/yolact_mlu
Migration Report:  /home/share/pytorch1.6/yolact/yolact_mlu/report.md
```

## 2.3. 下载模型
```bash
cd /home/share/pytorch1.6/yolact/yolact_mlu
mkdir -p weights
cd weights
#下载模型权重到weights目录
```
下载模型权重文件并放置到 `./weights` 目录下。

YOLACT models (released on April 5th, 2019):

| Image Size | Backbone      | Weights                                                                                                              |  |
|:----------:|:-------------:|----------------------------------------------------------------------------------------------------------------------|--------|
| 550        | Resnet50-FPN  | [yolact_resnet50_54_800000.pth](https://drive.google.com/file/d/1yp7ZbbDwvMiFJEq4ptVKTYTI2VeRDXl0/view?usp=sharing)  | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/EUVpxoSXaqNIlssoLKOEoCcB1m0RpzGq_Khp5n1VX3zcUw) |
| 550        | Darknet53-FPN | [yolact_darknet53_54_800000.pth](https://drive.google.com/file/d/1dukLrTzZQEuhzitGkHaGjphlmRJOjVnP/view?usp=sharing) | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/ERrao26c8llJn25dIyZPhwMBxUp2GdZTKIMUQA3t0djHLw)
| 550        | Resnet101-FPN | [yolact_base_54_800000.pth](https://drive.google.com/file/d/1UYy3dMapbH1BnmtZU4WH1zbYgOzzHHf_/view?usp=sharing)      | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/EYRWxBEoKU9DiblrWx2M89MBGFkVVB_drlRd_v5sdT3Hgg)
| 700        | Resnet101-FPN | [yolact_im700_54_800000.pth](https://drive.google.com/file/d/1lE4Lz5p25teiXV-6HdTiOJSnS7u7GBzg/view?usp=sharing)     | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/Eagg5RSc5hFEhp7sPtvLNyoBjhlf2feog7t8OQzHKKphjw)

YOLACT++ models (released on December 16th, 2019):

| Image Size | Backbone      | Weights                                                                                                              |  |
|:----------:|:-------------:|----------------------------------------------------------------------------------------------------------------------|--------|
| 550        | Resnet50-FPN  | [yolact_plus_resnet50_54_800000.pth](https://drive.google.com/file/d/1ZPu1YR2UzGHQD0o1rEqy-j5bmEm3lbyP/view?usp=sharing)  | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/EcJAtMiEFlhAnVsDf00yWRIBUC4m8iE9NEEiV05XwtEoGw) |
| 550        | Resnet101-FPN | [yolact_plus_base_54_800000.pth](https://drive.google.com/file/d/15id0Qq5eqRbkD-N3ZjDZXdCvRyIaHpFB/view?usp=sharing) | [Mirror](https://ucdavis365-my.sharepoint.com/:u:/g/personal/yongjaelee_ucdavis_edu/EVQ62sF0SrJPrl_68onyHF8BpG7c05A8PavV4a849sZgEA)


## 2.4. 模型推理
推理前需要修改一些代码：
1. yolact.py 480行  修改为 【state_dict = torch.load(path,map_location='cpu')】
2. 如果SSH运行的话，会提示不能显示。可以直接保存推理后的效果图片。可以修改 eval.py 606行，增加 【cv2.imwrite("./result.png", img_numpy)】

```bash
cd /home/share/pytorch1.6/yolact/yolact_mlu
#根据实际模型名称与测试图片修改参数
python eval.py --trained_model=./weights/yolact_im700_54_800000.pth --score_threshold=0.15 --top_k=15 --image=../../../data/bus.jpg
ls -la ./result.png
```
