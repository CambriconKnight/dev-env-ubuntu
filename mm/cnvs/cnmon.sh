#/bin/bash
set -e
# 0. 配置待测试板卡
export MLU_VISIBLE_DEVICES=0,1
watch -d -n -1 'cnmon'