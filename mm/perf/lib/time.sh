# -------------------------------------------------------------------------------
# Filename:    time.sh
# Revision:    1.0.0
# Date:        2022/09/24
# Description: time lib function
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### Basic function ####################
# Get the difference between two times
# $1: start_time
# $2: end_time
timediff() {
    # time format:date +"%s.%N", such as 1502758855.907197692
    start_time=$1
    end_time=$2

    start_s=${start_time%.*}
    start_nanos=${start_time#*.}
    end_s=${end_time%.*}
    end_nanos=${end_time#*.}

    # end_nanos > start_nanos?
    # Another way, the time part may start with 0, which means
    # it will be regarded as oct format, use "10#" to ensure
    # calculateing with decimal
    if [ "$end_nanos" -lt "$start_nanos" ];then
        end_s=$(( 10#$end_s - 1 ))
        end_nanos=$(( 10#$end_nanos + 10**9 ))
    fi

    # get timediff
    time=$(( 10#$end_s - 10#$start_s )).$(( (10#$end_nanos - 10#$start_nanos)/10**6 ))

    echo $time
}
