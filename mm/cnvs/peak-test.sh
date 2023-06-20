#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     peak-test.sh
# Revision:     1.0.0
# Date:         2023/04/14
# Description:  测试加速卡执行一个特定规模的conv计算，以便用户得到MLU设备的峰值运算性能。
# Example:
# Depends:      官方提供的mm Docker容器
# Notes:
# -------------------------------------------------------------------------------
source "./env.sh"
TEST_PLUGIN="peak_performance"
TEST_TITLE="cnvs_${TEST_PLUGIN}_float"
#TEST_TITLE="cnvs_${TEST_PLUGIN}_half"
#TEST_TITLE="cnvs_${TEST_PLUGIN}_int16"
#TEST_TITLE="cnvs_${TEST_PLUGIN}_int8"

print_log_echo_info "=================================================="
#以下操作步骤均是在官方提供的Docker容器中进行
#进入测试目录
cd /home/share/mm/cnvs
# 0. 配置待测试板卡
export MLU_VISIBLE_DEVICES=0,1
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
