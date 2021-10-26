#!/bin/bash

set -e

export TORCH_HOME=$PWD/../pytorch_models/int8/

python ./genoff/genoff.py -fake_device 0 -model yolov4-tiny -mcore MLU270 -mname mlu270_yolov4-tiny_4b4c_fp16 -half_input 1 -core_number 4 -batch_size 4 -input_format 0

export TORCH_HOME=$PWD/../pytorch_models/

