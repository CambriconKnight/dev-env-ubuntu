
**该教程仅仅用于学习，打通流程； 不对效果负责，不承诺商用。**

# 1. 环境说明
参考[../README.md](../README.md)

# 2. 模型推理

## 2.1. 下载代码
```bash
# 进到容器后，切换到工作目录
cd /home/share/pytorch1.9/stdc-seg
# Clone
git clone https://github.com/MichaelFan01/stdc-seg.git -b master
cd stdc-seg && git checkout 59ff37fbd693b99972c76fcefe97caa14aeb619f
# Install dependencies, 忽略错误
pip install --upgrade pip
pip install -r requirements.txt
```

## 2.2. 迁移代码
使用该工具 `torch_gpu2mlu.py` 从GPU模型脚本迁移至MLU设备运行，转换后的模型脚本只支持MLU设备运行。该工具可对模型脚本进行转换，对模型脚本修改位置较多，会对修改位置进行统计，实现开发者快速迁移。
- 在容器环境中，执行以下命令
```bash
cd /home/share/pytorch1.9/stdc-seg
#建立软连接
ln -s /torch/src/catch/tools/torch_gpu2mlu.py ./
#执行转换模型脚本
python torch_gpu2mlu.py -i stdc-seg
#显示,【stdc-seg_mlu】文件夹是转换后的代码。
ls -la stdc-seg stdc-seg_mlu
```

- 输出转换结果
```bash
# Cambricon PyTorch Model Migration Report
Official PyTorch model scripts:  /home/share/pytorch1.9/stdc-seg/stdc-seg
Cambricon PyTorch model scripts:  /home/share/pytorch1.9/stdc-seg/stdc-seg_mlu
Migration Report:  /home/share/pytorch1.9/stdc-seg/stdc-seg_mlu/report.md
```

## 2.3. 下载模型


## 2.4. 模型推理

