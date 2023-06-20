#/bin/bash
set -e

# clean 适配后的代码
rm -rvf baichuan-7B_mlu transformers_mlu
# 删除适配前的源码
rm -rvf baichuan-7B transformers
