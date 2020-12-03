#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

SH_CMD=python
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/LIBVirt_Gather_err`
    CMD=`touch ../aproc/shell/LIBVirt_Gather.out`
    exit 255
fi

STOP_DATE=`date`
VMINFO_PATH=`pwd`
echo "[$STOP_DATE] vminfo_libvirt stop." > ../aproc/shell/vminfo_libvirt.status.stop

VMINFO_PID=`ps -e -o pid -o args | grep -v grep | grep -v vminfo_libvirt_stop | grep "python ./shell/LINUX/vminfo_libvirt.py"| awk '$2 !~/grep/ && $2 !~/ps/ {print $1}'`
if [ $VMINFO_PID ]; then
    echo "[$STOP_DATE] stoped vminfo_libvirt[$VMINFO_PID]"
    echo "[$STOP_DATE] stoped vminfo_libvirt[$VMINFO_PID]" >> ../aproc/shell/vminfo_libvirt.status.stop
    kill -9 $VMINFO_PID
else
    echo "[$STOP_DATE] already stop vminfo_libvirt"
    echo "[$STOP_DATE] already stop vminfo_libvirt" >> ../aproc/shell/vminfo_libvirt.status.stop
fi

exit 0
