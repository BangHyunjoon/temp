#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG
PS_OUT_FILE="../aproc/shell/libinv_disk_ps.out"

#cpu, disk, interface
invtype=$1
#name inv gather, all inv gather, name chanage check
gathertype=$2

OS_TYPE=`uname`
if [ $OS_TYPE = "HP-UX" ] ; then
    export UNIX95=ps
fi

#./libinvinfo $invtype $gathertype &

#process checking
l_strProcName="./libinvinfo $invtype"
l_nProcessCheck=0
ps -e -o pid -o args | grep "$l_strProcName" | grep -v grep > $PS_OUT_FILE
while read l_strBuf
do
    l_strCOMM=`echo $l_strBuf | awk '{print $2}'`
    if [ "$l_strCOMM" = "./libinvinfo" ] ; then
        l_strPID=`echo $l_strBuf | awk '{print $1}'`
        #echo "kill1  "$l_strPID
        kill -9 $l_strPID
        l_nProcessCheck=1
    fi
done <$PS_OUT_FILE

#process checkingi.  kill sometimes does not work
if [ $l_nProcessCheck -eq 1 ] ; then
    l_nProcessCheck=0
    ps -e -o pid -o args | grep "$l_strProcName" | grep -v grep > $PS_OUT_FILE
    while read l_strBuf
    do
        l_strCOMM=`echo $l_strBuf | awk '{print $2}'`
        if [ "$l_strCOMM" = "./libinvinfo" ] ; then
            l_strPID=`echo $l_strBuf | awk '{print $1}'`
            #echo "kill2  "$l_strPID
            kill -9 $l_strPID
            l_nProcessCheck=1
        fi
    done <$PS_OUT_FILE

    if [ $l_nProcessCheck -eq 1 ] ; then
        exit 0;
    else 
        ./libinvinfo $invtype $gathertype &
    fi 
else 
    ./libinvinfo $invtype $gathertype &
fi

exit 0

