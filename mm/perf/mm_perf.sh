#!/bin/bash
#set -e
# -------------------------------------------------------------------------------
# Filename:     mm_perf.sh
# UpdateDate:   2022/09/25
# Description:  测试整机所有板卡的性能.
# Example:      ./mm_perf.sh
# Depends:
#               ${TEST_SUITES_FILE};${MODEL_PATH};${DATASET_PATH};
# Notes:
# -------------------------------------------------------------------------------
# Get card list
CARD_LIST=(`cnmon info | grep Card | awk -F ' ' '{print $2}'`)
CARD_NUM=${#CARD_LIST[@]}
#################### Function ####################
# Init
init() {
    bash clean.sh
    source "./lib/time.sh"
    source "./lib/log.sh"
    init_log
    source "./lib/base.sh"
    source "./env.sh"
    # check env
    if [ -z $DATASET_PATH ] || [ -z $MODEL_PATH ]; then
        print_log_echo_fatal "DATASET_PATH or MODEL_PATH not exists, please set it ..."
        exit -1;
    fi
}

# Update test card_list
update_test_card_list() {
    unset CARD_LIST
    if [[ $# -eq 0 ]];then
        # Get all card list
        CARD_LIST=(`cnmon info | grep Card | awk -F ' ' '{print $2}'`)
    else
        # Update
        CARD_LIST[0]="${1}"
    fi
    CARD_NUM=${#CARD_LIST[@]}
    # Print
    print_log_echo_info "CARD_NUM: ${CARD_NUM}"
    num=0
    for element in "${CARD_LIST[@]}";do
        print_log_echo_info "CARD_LIST[${num}]: ${element}"
        let "num+=1"
    done
}

# Test card (all/single)
test_card_all() {
    # Update test card_list
    if [[ $# -eq 0 ]];then update_test_card_list; else update_test_card_list $1; fi
    ############ MLU performance ############
    for cardid in "${CARD_LIST[@]}";do
        print_log_echo_info "[# Test MLU performance Card ${cardid}:"
        export MLU_VISIBLE_DEVICES=${cardid}
        mm_perf_benchmark --csv ${TEST_SUITES_FILE} \
            --dataset_path $DATASET_PATH --model_path $MODEL_PATH \
            --device_name $DEVICE_NAME > "${TEST_LOG}_${cardid}.log" 2>&1 &
        # Add processes to the queue
        push_queue_processes $!
        sleep 0.1
    done
    echo -en "${green}[#"
    check_queue_processes_bar 0
    echo "]"
    echo -en "${none}"
    sync
    sync
    ############ Print Result ############
    for cardid in "${CARD_LIST[@]}";do
        print_log_echo_info "### Print Result Card ${cardid}:"
        echo -en "${yellow}"
        cat "${TEST_LOG}_${cardid}.log"
        echo -en "${none}"
        cat "${TEST_LOG}_${cardid}.log" >> $RUNNING_LOG_FILE
        sleep 1
    done
}

# Help
help_info() {
    echo "
Usage:
    $0 [Target]

    [Target]:
    all              All card
    cardid           Single Card id

Examples:

    $0
    $0 all
    $0 0
    "
}
#################### main ####################
main_time_start=$(date +"%s.%N")
init
######Modify according to your development environment#####
# Test suites file
TEST_SUITES_FILE="${CURRENT_PATH}/testsuites/csv_cases/performance_resnet50.csv"
#TEST_SUITES_FILE=${CURRENT_PATH}/testsuites/csv_cases/performance_yolov3.csv
# Model path
MODEL_PATH="/data/models/test_models"
# Datasets path
DATASET_PATH="/data/datasets"
###########################################################
# Test log
TEST_MODEL="MM"
OUTPUT_DIR="output"
TEST_LOG="${OUTPUT_DIR}/${TEST_MODEL}_benchmark_card"
if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir -p ${OUTPUT_DIR}
fi
print_log_echo_info "=================================================="
print_log_echo_info "NEUWARE_HOME:${NEUWARE_HOME}"
print_log_echo_info "CURRENT_PATH:${CURRENT_PATH}"
print_log_echo_info "TEST_SUITES_FILE:${TEST_SUITES_FILE}"
print_log_echo_info "MODEL_PATH:${MODEL_PATH}"
print_log_echo_info "DATASET_PATH:${DATASET_PATH}"
print_log_echo_info "DEVICE_NAME:${DEVICE_NAME}"
print_log_echo_info "TEST_LOG:${TEST_LOG}_*.log"
# Test
if [[ $# -eq 0 ]];then
    test_card_all
elif [[ $# -eq 1 ]];then
    if [ -n "$(echo ${1}| sed -n "/^[0-9]\+$/p")" ];then
        test_card_all ${1}
    elif [[ "$1" == "all" ]];then
        test_card_all
    else
        help_info
    fi
else
    help_info
fi
print_log_echo_info "=================================================="
main_time_end=$(date +"%s.%N")
# here give the values
ret=$(timediff $main_time_start $main_time_end)
print_log_echo_info "Total time: $ret s"
