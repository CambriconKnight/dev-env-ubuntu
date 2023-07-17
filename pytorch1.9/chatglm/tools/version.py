# -*- encoding:utf-8 -*-
import os
import torch
import subprocess
import numpy as np
import transformers

# 设置环境变量
#os.environ['MLU_VISIBLE_DEVICES']="8,9"
# 获取环境变量方法1
#os.environ.get('WORKON_HOME')
#获取环境变量方法2(推荐使用这个方法)
#os.getenv('path')
# 删除环境变量
del os.environ['MLU_VISIBLE_DEVICES']

print(f"torch version: {torch.__version__}")
print(f"transformers version: {transformers.__version__}")
os.system("cnmon version")
version_cndsp = subprocess.check_output("pip show cndsp | grep -E Version | awk -F ': ' '{print $2}'", shell=True)
#os.system("pip show cndsp | grep -E Version | awk -F ': ' '{print $2}'")
print(f"cndsp version: {version_cndsp}")

