#/bin/bash
set -e

#加速卡峰值算力和效率测试
bash ./peak-test.sh
#GEMM矩阵计算性能和效率测试
bash ./matmul-test.sh
#PCIe传输性能测试
bash ./pcie-test.sh
#显存带宽性能测试
bash ./memory-test.sh
#稳定性压力测试（算力）-第一种方法（压测时间可通过修改yml配置文件）
bash ./mlu_stress-test.sh
#稳定性压力测试（算力）-第二种方法（压测时间可通过修改yml配置文件）
bash ./targeted_stress-test.sh
#稳定性压力测试（功耗）-第三种方法（压测时间可通过修改yml配置文件）
bash ./targeted_power-test.sh