#!/bin/bash
# Parameter1 non-simple_mode: 0; simple_mode:1
CURRENT_DIR=$(dirname $(readlink -f $0))
EXAMPLE_DIR=$CURRENT_DIR/../build/yolov4
OFFLINE_DIR=${CURRENT_DIR}/..

usage()
{
  echo "Usage:"
  echo "---------------------------------------------------------------------"
  echo "|  $0 [1|2|3|4] [1|2]"
  echo "|  parameter1: int8, int16, channel_int8, channel_int16 mode "
  echo "   parameter2: dev select MLU270 or MLU220"
  echo "|  eg. ./run_all_offline_mc.sh 1 1"
  echo "|      which means running int8 offline model on MLU270."
  echo "--------------------------------------------------------------------"
}

int8_mode=$1
if [ -z $TORCH_HOME ]; then
    echo "[ERROR] Please set TORCH_HOME."
    exit 1
fi

if [ -z $COCO_PATH_PYTORCH ]; then
    echo "[ERROR] Please set COCO_PATH_PYTORCH."
    exit 1
fi

if [[ $int8_mode -eq 1 ]]; then
    export TORCH_HOME=$TORCH_HOME/int8/
elif [[ $int8_mode -eq 2 ]]; then
    export TORCH_HOME=$TORCH_HOME/int16/
elif [[ $int8_mode -eq 3 ]]; then
    export TORCH_HOME=$TORCH_HOME/c_int8/
elif [[ $int8_mode -eq 4 ]]; then
    export TORCH_HOME=$TORCH_HOME/c_int16/
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

# configure target device
slec_device=$2
mcore=""
if [[ $slec_device -eq 1 ]]; then
  mcore="MLU270"
elif [[ $slec_device -eq 2 ]]; then
  mcore="MLU220"
else
  echo "[ERROR] Unknown parameter."
  usage
  exit 1
fi

# configure target network_list
network_list=(
    yolov4
)

# select input format rgba argb bgra or abgr
# 0-rgba 1-argb 2-bgra 3-abgr
channel_order='0'

# configure batch_size and core_number for mlu270
bscn_list_MLU270=(
  # '1  1'
  #'1  4'
  '4  4'
  #'1  16'
  # '4  16'
  # '8  16'
)

# configure batch_size and core_number for mlu220
bscn_list_MLU220=(
   '1  1'
  #  '4  4'
)

file_list=$CURRENT_DIR/../../data/coco2017/file_list_for_release
#file_list=./file_list_datasets
#file_list=/home/share/pytorch/yolov4-416/file_list_coco_val2017
#file_list=/home/share/pytorch/yolov4-416/testdev2017.txt

# including: generate *.cambricon model and run *.cambricon model in MLU
do_run()
{
    echo "----------------------"
    echo "batch_size: $batch_size, core_number: $core_number, channel_order: $channel_order"
    # first remove any offline model
    ####
    /bin/rm *.cambricon* &> /dev/null

    log_file="${network}_multicore_thread.log"

    echo > $CURRENT_DIR/$log_file
    genoff_cmd="python ${OFFLINE_DIR}/genoff/genoff.py -fake_device 1 -model $network -mcore $mcore -mname $network -half_input 0 -core_number $core_number -batch_size $batch_size -input_format $channel_order&>> $CURRENT_DIR/$log_file"

    # run offline.cambricon model command
    run_cmd="${EXAMPLE_DIR}/yolov4_offline_multicore$SUFFIX -offlinemodel $CURRENT_DIR/${network}.cambricon -images $file_list -labels $CURRENT_DIR/label_map_coco.txt -outputdir $CURRENT_DIR -dump 1 -simple_compile 1 -dataset_path $COCO_PATH_PYTORCH/COCO/val2017  -input_format $channel_order &>> $CURRENT_DIR/$log_file"
    #run_cmd="${EXAMPLE_DIR}/yolov4_offline_multicore$SUFFIX -offlinemodel $CURRENT_DIR/${network}.cambricon -images $file_list -labels $CURRENT_DIR/label_map_coco.txt -outputdir $CURRENT_DIR -dump 1 -simple_compile 1 -dataset_path $COCO_PATH_PYTORCH/COCO/test2017  -input_format $channel_order &>> $CURRENT_DIR/$log_file"
    #run_cmd="${EXAMPLE_DIR}/yolov4_offline_multicore$SUFFIX -offlinemodel $CURRENT_DIR/${network}.cambricon -images $file_list -labels $CURRENT_DIR/label_map_coco.txt -outputdir $CURRENT_DIR -dump 1 -simple_compile 1 -dataset_path /home/share/pytorch/yolov4-416/datasets  -input_format $channel_order &>> $CURRENT_DIR/$log_file"

    check_cmd="python $OFFLINE_DIR/scripts/meanAP_COCO.py --file_list $file_list --result_dir $CURRENT_DIR --ann_dir $COCO_PATH_PYTORCH/COCO --data_type val2017 &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"
    echo "Complete!"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        echo "Complete!"
        tail -n 3  $CURRENT_DIR/$log_file
        grep "yolov4_detection() execution time:" -A 2 $CURRENT_DIR/$log_file
        eval "$check_cmd"
        echo "Complete!"
        tail -n 12 $CURRENT_DIR/$log_file
    else
        echo "generating offline model failed!"
    fi
}

clean(){
    /bin/rm 000000*.txt &> /dev/null
    /bin/rm yolov4*.jpg &> /dev/null
}

clean

/bin/rm *.log &> /dev/null

if [ $# -ne 2 ]; then
    echo "[ERROR] unknow parameter!"
    usage
    exit 1
fi

for network in "${network_list[@]}"; do
    echo -e "\n===================================================="
    echo "running ${network} offline multiple core ..."
    if [[ $slec_device -eq 1 ]]; then
        for bscn in "${bscn_list_MLU270[@]}"; do
          batch_size=${bscn:0:2}
          core_number=${bscn:3:2}
          do_run
        done
    else
        for bscn in "${bscn_list_MLU220[@]}"; do
          batch_size=${bscn:0:2}
          core_number=${bscn:3:2}
          do_run
        done
    fi
done
#clean
