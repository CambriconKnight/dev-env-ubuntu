#!/bin/bash

export ATEN_CNML_COREVERSION="MLU200"
export mcore="MLU200"

export PYTHONPATH=$PYTHONPATH
export PYTORCH_HOME=$PWD/pytorch/src/pytorch
export CATCH_HOME=$PWD/pytorch/src/catch
export VISION_HOME=$PWD/pytorch/src/vision

export ROOT_HOME=$PWD
export TORCH_HOME=$ROOT_HOME/pytorch/models/pytorch_models

export NEUWARE_HOME=/usr/local/neuware
export PATH=$PATH:$NEUWARE_HOME/bin
export LD_LIBRARY_PATH=$NEUWARE_HOME/lib64:$LD_LIBRARY_PATH

export DATASET_HOME=$PWD/datasets
export IMAGENET_PATH=$DATASET_HOME/imagenet/
export VOC2012_PATH_PYTORCH=$DATASET_HOME/
export VOC2007_PATH_PYTORCH=$DATASET_HOME/
export COCO_PATH_PYTORCH=$DATASET_HOME/
export FDDB_PATH_PYTORCH=$DATASET_HOME/
export IMAGENET_PATH_PYTORCH=$DATASET_HOME/
export ICDAR_PATH_PYTORCH=$DATASET_HOME/ICDAR_2015/test_img
export VOC_DEVKIT=$DATASET_HOME/

export GLOG_alsologtostderr=true
# Set log level which is output to stderr, 0: INFO/WARNING/ERROR/FATAL, 1: WARNING/ERROR/FATAL, 2: ERROR/FATAL, 3: FATAL,
export GLOG_minloglevel=0

export PYTHON_VERSION=python3
