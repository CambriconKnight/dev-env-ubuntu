#!/bin/bash
CURRENT_PATH=$(dirname $(readlink -f "$0"))
rm -rvf ${CURRENT_PATH}/core.*
rm -rvf ${CURRENT_PATH}/*.model
rm -rvf ${CURRENT_PATH}/tmp*
rm -rvf ${CURRENT_PATH}/benchmark_preprocessed
rm -rvf ${CURRENT_PATH}/mm_tmp_*
rm -rvf ${CURRENT_PATH}/compile_graph
rm -rvf ${CURRENT_PATH}/log
rm -rvf ${CURRENT_PATH}/output
