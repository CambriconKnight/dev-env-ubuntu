#/bin/bash
set -e

bash ./targeted_stress-test.sh
bash ./mlu_stress-test.sh
bash ./targeted_power-test.sh
bash ./memory-test.sh
bash ./matmul-test.sh
bash ./peak-test.sh
bash ./pcie-test.sh