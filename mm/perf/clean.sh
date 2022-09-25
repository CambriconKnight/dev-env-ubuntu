#!/bin/bash
CURRENT_PATH=$(dirname $(readlink -f "$0"))
rm -rf ${CURRENT_PATH}/core.*
rm -rf ${CURRENT_PATH}/*.model
rm -rf ${CURRENT_PATH}/tmp*
rm -rf ${CURRENT_PATH}/benchmark_preprocessed
rm -rf ${CURRENT_PATH}/mm_tmp_*
rm -rf ${CURRENT_PATH}/compile_graph
rm -rf ${CURRENT_PATH}/log
rm -rf ${CURRENT_PATH}/output
