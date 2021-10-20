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

MODDEL_NAME_IMAGE=6.png				        #quantize image
MODDEL_NAME_ORG=ckpt.t7 			        #Originate weights
MODDEL_NAME_OUT=feature_extract_quantized.pth	        #quantize后的模型
MODDEL_FILE_NAME_QUANTIZE=quantize_feature_extract.py   #quantize file name
MODDEL_FILE_NAME_ONLINE=forward_feature_extract.py      #online model file name

# 0.Check param
if [ ! -f "$PWD/$MODDEL_NAME_ORG" ] ; then
	echo "Model file ($PWD/$MODDEL_NAME_ORG) not exist, pleas download it or copy !"
fi

if [ ! -f "$PWD/$MODDEL_NAME_IMAGE" ] ; then
        echo "Model file ($PWD/$MODDEL_NAME_IMAGE) not exist, pleas download it or copy !"
fi

if [ ! -f "$PWD/$MODDEL_FILE_NAME_QUANTIZE" ] ; then
        echo "Model file ($PWD/$MODDEL_FILE_NAME_QUANTIZE) not exist, pleas download it or copy !"
fi

if [ ! -f "$PWD/$MODDEL_FILE_NAME_ONLINE" ] ; then
        echo "Model file ($PWD/$MODDEL_NAME_IMAGE) not exist, pleas download it or copy !"
fi

#1. run quantize
python "$PWD/$MODDEL_FILE_NAME_QUANTIZE" "$PWD/$MODDEL_NAME_IMAGE" "$PWD/$MODDEL_NAME_ORG" "$PWD/$MODDEL_NAME_OUT"
ls -la $MODDEL_NAME_OUT

#2.quantize result
echo "quantize finish !"

#3. run online
python "$PWD/$MODDEL_FILE_NAME_ONLINE" ./6.png ./ckpt.t7 "$PWD/$MODDEL_NAME_OUT"

#4. online result
echo "online finish !"

