# -------------------------------------------------------------------------------
# Filename:    base.sh
# Revision:    1.0.0
# Date:        2022/09/24
# Description:
# Example:
# Depends:     log.sh: Can only use this function print_log()
# Notes:
# -------------------------------------------------------------------------------

#################### Global variable ####################
##### Parallel Run #####
# Parallel number, too many parallels may cause system crash
MAX_PARALLEL=5
# Queue of parallel
QARR_PARALLEL=();
# Number of running processes
NUM_RUN_PARALLEL=0
# Maximum timeout
TIMEOUT_MAX_SECOND=900

#################### Common function ####################
#Find if the directory contains a string
grep_if_included_string_on_dir() {
    #grep -rq $1 $2
    grep -irq $1 $2
    # 0:include;1:not included
    echo $?
}

# Add processes to the queue
push_queue_processes() {
    QARR_PARALLEL=(${QARR_PARALLEL[@]} $1)
    NUM_RUN_PARALLEL=${#QARR_PARALLEL[@]}
}

# Check the process in the queue
check_queue_processes() {
    oldQ=(${QARR_PARALLEL[@]})
    QARR_PARALLEL=()
    for p in "${oldQ[@]}";do
        if [[ -d "/proc/$p" ]];then
            QARR_PARALLEL=(${QARR_PARALLEL[@]} $p)
        fi
    done
    NUM_RUN_PARALLEL=${#QARR_PARALLEL[@]}
}

# Check the process in the queue and echo bar
check_queue_processes_bar() {
    num_parallel=();
    if [[ $# -eq 1 ]];then
        num_parallel=$1
    else
        num_parallel=$MAX_PARALLEL
    fi
    while [[ $NUM_RUN_PARALLEL -gt $num_parallel ]];do
        #echo -n "$NUM_RUN_PARALLEL#"
        echo -n "#"
        check_queue_processes
        sleep 2
    done
}

# Check the process in the queue and echo bar
check_queue_processes_bar() {
    num_parallel=();
    if [[ $# -eq 1 ]];then
        num_parallel=$1
    else
        num_parallel=$MAX_PARALLEL
    fi
    #Timeout:15min=900s=450*2s
    sleep_second=1
    num_max=`expr ${TIMEOUT_MAX_SECOND} / ${sleep_second}`
    #num_max=450
    num_bar=0
    while [[ $NUM_RUN_PARALLEL -gt $num_parallel ]];do
        #echo -n "$NUM_RUN_PARALLEL#"
        echo -n "#"
        check_queue_processes
        sleep ${sleep_second}
        let "num_bar+=1"
        #echo -n "$num_bar"
        if [[ $num_bar -gt $num_max ]];then
            echo ""
            echo -en "${none}"
            num_second=`expr $num_max / 5`
            print_log_echo_fatal "${RUN_FAILED_TIMEOUT}(${num_second}s)"
            exit -1
        fi
    done
}

# Sleep and echo bar
sleep_echo_bar() {
    echo -en "${green}[#"
    num_=();
    if [[ $# -eq 1 ]];then
        num_=$1
    else
        num_=1 		#Default
    fi
    sleep $num_ &
    # Add processes to the queue
    push_queue_processes $!
    check_queue_processes_bar 0
    echo "]"
    echo -en "${none}"
}
