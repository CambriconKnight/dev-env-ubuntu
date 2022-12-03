#!/bin/bash
export ABI_MODE=1
export BIN_DIR_WORK="/opt/cambricon"
export BIN_DIR_GCC_Linaro="/tmp/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin"
export PATH="$BIN_DIR_GCC_Linaro:$PATH"
export NEUWARE_HOME=/usr/local/neuware/edge/