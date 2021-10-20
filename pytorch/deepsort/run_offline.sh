#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run_quantize.sh
# UpdateDate:   2021/10/09
# Description:  Deepsort convert model for cambricon .
# Example:      ./run_convertmodel.sh
# Notes:
# -------------------------------------------------------------------------------
#################### main ####################

MODDEL_FILE_NAME_OFFLINE=genoff.py      			#offline model file name

# 0.Check param
#if [ ! -d "$WEIGHTS_DIR" ] ; then
#	mkdir -p $WEIGHTS_DIR
#	echo "Create $WEIGHTS_DIR ok !"
#else
#	echo "Directory ($WEIGHTS_DIR): Exist!"
#fi

if [ ! -f "$PWD/$MODDEL_FILE_NAME_OFFLINE" ] ; then
        echo "Model file ($PWD/$MODDEL_NAME_OFFLINE) not exist, pleas download it or copy !"
fi

#1. run offline
python "$PWD/$MODDEL_FILE_NAME_OFFLINE" -fake_device 0 -model feature_extract -mcore MLU270 -core_number 1 -batch_size 1 -half_input 1 -input_format 1 -mname feature_extract_1b1c_half

#2. offline result
echo "offline finish !"
