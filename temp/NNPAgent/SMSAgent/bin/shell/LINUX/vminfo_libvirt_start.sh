#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

SH_CMD=python
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

\rm -f ../aproc/shell/LIBVirt_Gather_err

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/LIBVirt_Gather_err`
    CMD=`touch ../aproc/shell/LIBVirt_Gather.out`
    exit 255
fi

START_DATE=`date`

VMINFO_PATH=`pwd`
VMINFO_PID=`ps -e -o pid -o args | grep -v grep | grep -v vminfo_libvirt_start | grep "python ./shell/LINUX/vminfo_libvirt.py" | awk '$2 !~/grep/ && $2 !~/ps/ {print $1}'`
EXIT_CODE=0

if [ $VMINFO_PID ]; then

    #echo "[$START_DATE] already start vminfo($VMINFO_PID)"
    echo "[$START_DATE] already start vminfo_libvirt($VMINFO_PID)" >> ../aproc/shell/vminfo_libvirt.status.start

else

    nohup python ./shell/LINUX/vminfo_libvirt.py > ../aproc/shell/LIBVirt_Gather.out 2>&1 &
    echo "[$START_DATE] vminfo_libvirt start(nohup python ./shell/LINUX/vminfo_libvirt.py &)." > ../aproc/shell/vminfo_libvirt.status.start

    sleep 2
    VMINFO_PID=`ps -e -o pid -o args | grep -v grep | grep -v vminfo_libvirt_start | grep "python ./shell/LINUX/vminfo_libvirt.py" | awk '$2 !~/grep/ && $2 !~/ps/ {print $1}'`

    START_DATE=`date`
    if [ $VMINFO_PID ]; then
        #echo "[$START_DATE] started vminfo_libvirt success[$VMINFO_PID]"
        echo "[$START_DATE] started vminfo_libvirt success[$VMINFO_PID]" >> ../aproc/shell/vminfo_libvirt.status.start
        \rm -f ./nohup.out
    else
        #echo "[$START_DATE] start vminfo_libvirt failed[$VMINFO_PID]"
        echo "[$START_DATE] start vminfo_libvirt failed[$VMINFO_PID]" >> ../aproc/shell/vminfo_libvirt.status.start
        EXIT_CODE=1
    fi
fi

exit $EXIT_CODE
