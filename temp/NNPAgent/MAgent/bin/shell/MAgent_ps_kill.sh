#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

PS_OUT_FILE="../aproc/shell/ps_kill_file.out"

OS_TYPE=`uname`
if [ $OS_TYPE = "HP-UX" ] ; then
    export UNIX95=ps
fi

ps -e -o pid -o args > $PS_OUT_FILE

while read l_strBuf
do
    l_strCOMM=`echo $l_strBuf | awk '{print $2}'`
    if [ "$l_strCOMM" = "$1" ] ; then
        l_strPID=`echo $l_strBuf | awk '{print $1}'`
        echo "kill  "$l_strPID
        kill -9 $l_strPID
    fi
done <$PS_OUT_FILE


