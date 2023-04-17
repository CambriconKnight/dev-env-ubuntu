#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     mlu_stress-test.sh
# Revision:     1.0.0
# Date:         2023/04/14
# Description:  可根据用户设置的参数，通过调整矩阵乘算子的规模，让设备的每秒负载达到用户期望的目标性能值。 该插件可用于观测在目标负载情况下，设备的功耗、温度等表现。
#               mlu_stress插件统计的性能，是根据计算量除以执行时间得到，但该执行时间不包括输入、输出数据在HOST和MLU之间进行拷贝的时间，这是mlu_stress插件和targeted_stress插件的区别。
# Example:
# Depends:      官方提供的mm Docker容器
# Notes:
# -------------------------------------------------------------------------------
source "./env.sh"
TEST_PLUGIN="mlu_stress"
TEST_TITLE="cnvs_${TEST_PLUGIN}"

print_log_echo_info "=================================================="
#以下操作步骤均是在官方提供的Docker容器中进行
#进入测试目录
cd /home/share/mm/cnvs
# 0. 配置待测试板卡
export MLU_VISIBLE_DEVICES=2
# 1.开始测试前，打印cnmon信息
#cnmon && sleep 1
cnmon >> $RUNNING_LOG_FILE
# 2. 执行cnvs测试
##########################################################
print_log_echo_info "[# ${TEST_TITLE}: "
#压入后台执行cnvs。
cnvs -r ${TEST_PLUGIN} -c "./config/${TEST_TITLE}.yml" -v >> ${RUNNING_LOG_FILE} 2>&1 &
#进程压入队列
push_queue_processes $! && sleep 0.1
##########################################################
#启动【进度条】显示执行进度。直到后台进程执行完成。
print_queue_processes && echo -en "${green}[#" && check_queue_processes_bar 0 0 && echo "]" && echo -en "${none}" && sync && sync
#结束时间
main_time_end=$(date +"%s.%N")
#计算测试所用的时间
ret=$(timediff $main_time_start $main_time_end)
print_log_echo_info "Total time: $ret s"
print_log_echo_info "=================================================="

# 3.打印测试结果
echo -en "${yellow}"
RUNNING_LOG_FILE_NEW="${RUNNING_LOG_FILE%/*}/${TEST_TITLE}-${RUNNING_LOG_FILE##*/}"
#修改文件名： 根据测试内容，追加前缀
mv $RUNNING_LOG_FILE $RUNNING_LOG_FILE_NEW
cat $RUNNING_LOG_FILE_NEW
ls -la $RUNNING_LOG_FILE_NEW
echo -en "${none}"
