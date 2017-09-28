#/*==================================
#*   Copyright (C) 2017 All rights reserved.
#*   
#*   文件名称：newcut.sh
#*   创 建 者：WangJian
#*   创建日期：2017年03月22日
#*   描    述：日志收集切割脚本
#*
#================================================================*/
#!/bin/bash

# 日志目录
logPath="/data/home/user00/log/datacenter/logic"

# 切割行数存放目录
lineDir="/tmp/report/"
if [ ! -d ${lineDir} ];then
    mkdir ${lineDir}
fi
# 目标目录
targetDir="/data/log_data"

# 获取唯一标示
if [ -s /data/home/user00/.op/wxsn ];then
   #ip=$(cat /home/playcrab/ip.txt)
   #wxsn=$(cat /data/home/user00/.op/wxsn |grep $ip |awk -F ":" '{print $2}')
   wxsn=$(cat /data/home/user00/.op/wxsn)
else
   echo "wxsn is empty or not exists"
fi
# 时间日期
yesterday=$(date "+%Y-%m-%d" -d yesterday)
fileyesterday=$(date "+%Y-%m-%d" -d yesterday)
destfileyesterday=$(date "+%Y%m%d" -d yesterday)
destdateNameDir=$(date "+%Y%m%d")
dateNameDir=$(date "+%Y-%m-%d")
dateTime=$(date "+%H%M")
dateFormat=$(date "+%Y-%m-%d")
dateTimeLog=$(date "+%Y/%m/%d %H:%M")
delTimeLog=$(date -d '7 day ago' +%Y-%m-%d)

# 删除7天前切割的日志目录
/bin/rm -rf ${logPath}/${delTimeLog}

# 获取游戏名和平台
#game=`cat /etc/sysinfo |awk -F "_" '{print $1}'`
game=`cat /data/home/user00/.op/main_category`
#platform=`cat /etc/sysinfo |awk -F "_" '{print $2}'`
clusters=`cat /data/home/user00/.op/clusters`

# 收集机ip
dip="10.8.227.167"

# 日志列表

gold_consume_log="gold_consume_log"
role_upvip_status="role_upvip_status"
account_info="account_info"
action_log="action_log"
gold_recharge_log="gold_recharge_log"
role_day_info="role_day_info"
role_info="role_info"
role_login_log="role_login_log"
role_uplevel_status="role_uplevel_status"
#fileList=($action_log $role_day_info $gold_consume_log $role_upvip_status $account_info $gold_recharge_log $role_info $role_login_log $role_uplevel_status)
fileList=($action_log $role_day_info $gold_consume_log $role_upvip_status $account_info $gold_recharge_log $role_info $role_login_log $role_uplevel_status)

# 检查存储处理后的目录与每天零点主动创建生产log文件
function checkFileDir(){
    if [[ "${dateTime}" -eq 0000 ]] || [[ ! -d "${logPath}/${dateNameDir}" ]];then
        for i in ${fileList[@]};do
            mkdir -p "${logPath}/${dateNameDir}/${i}"
        done
    fi


    if [[ "${dateTime}" -ge 0000 ]] && [[ "${dateTime}" -lt 0005 ]];then
        for x in ${fileList[@]};do
            touch "${logPath}/${x}_${dateFormat}.log"
        done
    fi
}

# 记录行数切割日志并发送到收集机
function cutSendFile(){
    for list in ${fileList[@]};do

        if [[ "${dateTime}" -eq "0000" ]];then

             echo "[${dateTimeLog}] Record_line: 0" >> ${lineDir}/${list}_${dateFormat}.txt
             echo  "" > ${logPath}/${dateNameDir}/${list}/${list}_${wxsn}_${dateTime}.log
	else
             if [ ! -f "${lineDir}/${list}_${dateFormat}.txt" ]; then
       	         echo "[${dateTimeLog}] Record_line: 0" >> ${lineDir}/${list}_${dateFormat}.txt
             fi

	     lineNum=$(wc -l ${logPath}/${list}_${dateFormat}.log | cut -d" " -f1)
             echo "[${dateTimeLog}] Record_line: ${lineNum}" >> ${lineDir}/${list}_${dateFormat}.txt
             oldline=$(tail -2 ${lineDir}/${list}_${dateFormat}.txt |awk 'NR==1{print $4}')
             newline=$(tail -1 ${lineDir}/${list}_${dateFormat}.txt |awk '{print $4}')
             prline=$(expr ${oldline} + 1)

             sed -n "${prline}, ${newline}p" ${logPath}/${list}_${dateFormat}.log > ${logPath}/${dateNameDir}/${list}/${list}_${wxsn}_${dateTime}.log
             md5sum ${logPath}/${dateNameDir}/${list}/${list}_${wxsn}_${dateTime}.log > ${logPath}/${dateNameDir}/${list}/${list}_${wxsn}_${dateTime}.log.md5
        fi


        if [[ "${dateTime}" -eq "0000" ]];then

            yesttday=$(tail -1 ${lineDir}/${list}_${fileyesterday}.txt |awk '{print $4}')
            ttfile=`wc -l ${logPath}/${list}_${fileyesterday}.log |awk 'END{print}'|awk '{print $1}'`
            echo "[${dateTimeLog}] Record_line: ${ttfile}" >> ${lineDir}/${list}_${fileyesterday}.txt
            epline=$(expr ${yesttday} + 1)

            sed -n "$epline,$ttfile p" ${logPath}/${list}_${fileyesterday}.log > ${logPath}/${yesterday}/${list}/${list}_${wxsn}_2400.log
            md5sum ${logPath}/${yesterday}/${list}/${list}_${wxsn}_2400.log > ${logPath}/${yesterday}/${list}/${list}_${wxsn}_2400.log.md5
            rsync -avzP  ${logPath}/${yesterday}/${list}/ ${dip}:${targetDir}/${game}/${clusters}/${destfileyesterday}/${list}
        fi

        rsync -avzP ${logPath}/${dateNameDir}/${list}/ ${dip}:${targetDir}/${game}/${clusters}/${destdateNameDir}/${list}
    done
}

function main(){
    checkFileDir
    cutSendFile
}
main
