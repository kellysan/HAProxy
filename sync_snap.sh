#!/bin/bash

date=`date '+%Y%m%d'`
#date=`date -d '1 day ago' +%Y%m%d`

# 快照目录
user=$(/usr/bin/whoami)
if test "$user" == "service";then
   snapPath="/opt/home/service/log/datacenter/snap/${date}/role_day_info"
else
   snapPath="/data/home/user00/log/datacenter/snap/${date}/role_day_info"
fi

# 目标目录
targetDir="/data/log_data"

# 获取游戏名、平台、收集机内网地址
#game=$(cat ~/kof/filecache/meta/base.ini |grep game=|awk -F "=" '{print $2}')
game='icx'
#platform=$(cat ~/kof/filecache/meta/base.ini |grep platform=|awk -F "=" '{print $2}')
platform='appstore'
if test "$platform" == "traditional" ;then
    dip="10.51.4.8"
elif test "$platform" == "korea" ;then
    dip="10.200.4.72"
elif test "$platform" == "product" ;then
    dip="10.8.227.159"
elif test "$platform" == "appstore" ;then
    dip="10.8.227.167"
else
    dip="10.2.0.30"
fi

######################
for file in `ls $snapPath/*.log`
   do
     if [[ -e $file ]] && [[ -e $file.md5 ]];then
         /usr/bin/rsync -avzP $file $dip:$targetDir/$game/$platform/$date/role_day_info/ && /usr/bin/rsync -avzP $file.md5 $dip:$targetDir/$game/$platform/$date/role_day_info/
     fi
done
