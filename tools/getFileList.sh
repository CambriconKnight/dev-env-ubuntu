#!/bin/bash
set -e

usage()
{
    echo "Usage:"
    echo "  $0 [pathdir] [filelist]"
    echo ""
    echo "  Parameter description:"
    echo "      [pathdir]: Relative path of the directory"
    echo "      [filelist]: File name for the generated result"
    echo "  EG: ./genFileList.sh ../data/00015 file.list"
}

if [ $# -lt 1 ]; then
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

pathdir=$1
filelist=$2

function getdir(){
    #echo $1
    for file in $1/*
    do
        if test -f $file
        then
            #echo $file
            arr=(${arr[*]} $file)
        else
            getdir $file
        fi
    done
}

# Recursively call the function: save the path of all files in the folder to the array
getdir $pathdir
# Print the path of all files to file.list
if [ -f "$filelist" ];then
    rm -f $filelist
fi
length=${#arr[@]}
for((a=0;a<$length;a++))
do
  echo ${arr[$a]} >> $filelist
done

#Display filelist
cat $filelist
echo "[pathdir]: $pathdir"
echo "[filelist]: $filelist"
