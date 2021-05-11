#!/bin/bash

#声明环境变量（该操作每次进入docker都需要进行）
cd $CAFFE_HOME/../
source env_caffe.sh
cd -
#设置以下操作步骤中用到的全局变量（请保证在进行以下各个步骤之前设置）
export PATH_NETWORK="${PWD}"
export PATH_NETWORK_MODELS="${PATH_NETWORK}/models"
export PATH_NETWORK_MODELS_MLU="${PATH_NETWORK_MODELS}/mlu"
