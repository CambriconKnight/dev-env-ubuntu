#!/bin/bash
#source env.sh

usage()
{
    echo "Usage:"
    echo "  $0 [1|2|3]"
    echo ""
    echo "  Parameter description:"
    echo "			[1]: prototxt file"
    echo "			[2]: caffemodel file"
    echo "			[3]: offline file name"
    echo "			[4]: core number"
    echo "			[5]: batch size"
}
if [ $# -lt 4 ]; then
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

coreN=4
btsize=1

if [ $# -eq 4 ]; then
	coreN=$4
fi
if [ $# -eq 5 ]; then
	coreN=$4
	btsize=$5
fi

$CAFFE_HOME/src/caffe/build/tools/caffe genoff --model $1 \
	--weights $2  \
	--mname ${3}_${btsize}b${coreN}c"_simple" \
	--mcore MLU270 \
	--simple_compile 1 \
	--core_number $coreN \
	--batchsize $btsize

echo "genoffline models(${3}_${btsize}b${coreN}c_simple.cambricon) done!!"
echo "param number: $#"
echo "core number: $coreN"
echo "batch size: $btsize"
ls -la ${3}_${btsize}b${coreN}c"_simple".cambricon*
