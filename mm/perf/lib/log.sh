# -------------------------------------------------------------------------------
# Filename:    log.sh
# Revision:    1.0.0
# Date:        2022/09/24
# Description: log lib function
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
VERSION=1.0.0
#Execution directory of the main program
CURRENT_PATH=$(dirname $(readlink -f "$0"))
#echo $CURRENT_PATH
#exit 0
CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20220924290501.340166315

RUNNING_LOG_PATH="${CURRENT_PATH}/log"
RUNNING_LOG_FILE="${RUNNING_LOG_PATH}/${CMD_TIME}_running.log"

#PARALLEL_EXE_LOG_Prefix
PARALLEL_EXE_LOG_Prefix="${RUNNING_LOG_PATH}/${CMD_TIME}_parallel"
SINGLE_EXE_LOG_Prefix="${RUNNING_LOG_PATH}/single"

LOG_INFO="0"
LOG_WARNING="1"
LOG_ERROR="2"
LOG_FATAL="3"
#0:disable;1:enable
FLAG_LOG_DEBUG=0
FLAG_LOG_INFO=1
FLAG_LOG_INFO_TIME=0
FLAG_LOG_WARNING=1
FLAG_LOG_ERROR=1
FLAG_LOG_FATAL=1

# log flag(mark) in the running of the program.The default value is 0
MARK_LOG_DEBUG=0
MARK_LOG_INFO=0
MARK_LOG_INFO_TIME=0
MARK_LOG_WARNING=0
MARK_LOG_ERROR=0
MARK_LOG_FATAL=0
#################### Keyword variable ####################
#warning
RUN_WARNING_PREFIX="RUN_WARNING:"
RUN_WARNING_CHECK_DISK_SOME="${RUN_WARNING_PREFIX}Not enough space(network connection failed) on some core boards, please clean up(check) and then running!"
#failed
RUN_FAILED_PREFIX="RUN_FAILED:"
RUN_FAILED_CHECK_FILE_EXIST="${RUN_FAILED_PREFIX}File does not exist!"
RUN_FAILED_CHECK_PATH_EXIST="${RUN_FAILED_PREFIX}Path does not exist!"
RUN_FAILED_MD5SUM_FILE="${RUN_FAILED_PREFIX}Damaged File(md5sum)!"
RUN_FAILED_CHECK_NET="${RUN_FAILED_PREFIX}Network connection failed!"
RUN_FAILED_TIMEOUT="${RUN_FAILED_PREFIX}Timeout issue!"
RUN_FAILED_PASSWD="${RUN_FAILED_PREFIX}Incorrect password!"
RUN_FAILED_INVALID_IP="${RUN_FAILED_PREFIX}Invalid IP!"
#################### Color variable ####################
none="\033[0m"
black="\033[0;30m"
dark_gray="\033[1;30m"
blue="\033[0;34m"
light_blue="\033[1;34m"
green="\033[0;32m"
light_green="\033[1;32m"
cyan="\033[0;36m"
light_cyan="\033[1;36m"
red="\033[0;31m"
light_red="\033[1;31m"
purple="\033[0;35m"
light_purple="\033[1;35m"
brown="\033[0;33m"
yellow="\033[1;33m"
light_gray="\033[0;37m"
white="\033[1;37m"

#################### Basic function ####################
print_massage() {
    if [[ $# -eq 0 ]];then
        echo -e "Please enter the parameters"
    elif [[ $# -eq 1 ]];then
        echo -e "$1"
    elif [[ $# -eq 2 ]];then
        if [[ "$2" == "${LOG_INFO}" ]];then
            echo -e "${green}$1${none}"
        elif [[ "$2" == "${LOG_WARNING}" ]];then
            echo -e "${yellow}$1${none}"
        elif [[ "$2" == "${LOG_ERROR}" ]];then
            echo -e "${red}$1${none}"
        elif [[ "$2" == "${LOG_FATAL}" ]];then
            echo -e "${light_red}$1${none}"
        else
            echo -e "$1"
        fi
    fi
}

init_log() {
    if [ ! -d $RUNNING_LOG_PATH ];then
        mkdir -p $RUNNING_LOG_PATH
    fi

    if [ ! -f $RUNNING_LOG_FILE ]; then
        touch $RUNNING_LOG_FILE
    fi
    echo "$(date +%F/%H:%M:%S) ##############init_log()###############" > $RUNNING_LOG_FILE
}

print_log() {
    if [ ! -f $RUNNING_LOG_FILE ]; then
        touch $RUNNING_LOG_FILE
    fi
    echo "$(date +%F/%H:%M:%S) $1" >> $RUNNING_LOG_FILE
}

#################### Advanced function ####################

print_massage_info() {
    print_massage "$1" "${LOG_INFO}"
}

print_massage_warning() {
    print_massage "$1" "${LOG_WARNING}"
}

print_massage_error() {
    print_massage "$1" "${LOG_ERROR}"
}

print_massage_fatal() {
    print_massage "$1" "${LOG_FATAL}"
}

print_log_echo_debug() {
    if [[ "$FLAG_LOG_DEBUG" == "1" ]];then
        print_log "$1"
        print_massage_info "$1"
    fi
}

print_log_echo_info() {
    if [[ "$FLAG_LOG_INFO" == "1" ]];then
        print_log "$1"
        print_massage_info "$1"
    fi
}

print_log_echo_warning() {
    if [[ "$FLAG_LOG_WARNING" == "1" ]];then
        print_log "$1"
        print_massage_warning "$1"
    fi
}

print_log_echo_error() {
    if [[ "$FLAG_LOG_ERROR" == "1" ]];then
        print_log "$1"
        print_massage_error "$1"
    fi
}

print_log_echo_fatal() {
    if [[ "$FLAG_LOG_FATAL" == "1" ]];then
        print_log "$1"
        print_massage_fatal "$1"
    fi
}

print_log_echo_info_time() {
    if [[ "$FLAG_LOG_INFO_TIME" == "1" ]];then
        print_log_echo_info "$1"
    fi
}