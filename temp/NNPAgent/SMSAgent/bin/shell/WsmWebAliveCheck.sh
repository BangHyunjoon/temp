#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

INDEX=$1
l_strTmpPort=$2

WSM_NETSTAT_FILE="../aproc/shell/WsmNetstat.out"
WSM_PORT_NETSTAT_RESULT="../aproc/shell/WsmPortNetstat_"$INDEX".out"

#WSM_NETSTAT_FILE="./WsmNetstat.out"
#WSM_PORT_NETSTAT_RESULT="./WsmPortNetstat.out"

PORT_LISTS=`echo $l_strTmpPort | sed -e 's/,/ /g'`

for PORT in $PORT_LISTS
do
    l_nAlive=999
    cat $WSM_NETSTAT_FILE | grep $PORT | grep LISTEN > $WSM_PORT_NETSTAT_RESULT

    l_nFoundFlag=0
    while read l_strReadBuf
    do
        if [ $l_nFoundFlag -eq 1 ] ; then
            continue
        fi
        l_strIp_Port=`echo $l_strReadBuf | awk '{print $4}'`
        l_strPort=`echo $l_strIp_Port | awk -F':' '{print $2}'`
        if [ "$PORT" = "$l_strPort" ] ; then
            l_nAlive=1
            l_nFoundFlag=1
        fi
    done < $WSM_PORT_NETSTAT_RESULT

    if [ $l_nAlive -eq 999 ] ; then
        break
    fi
done
echo $l_nAlive > ../aproc/shell/WebAliveStatus_$INDEX.out
