#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

SH_CMD=python
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

\rm -f ../aproc/shell/RHEV_Gather_err 

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/RHEV_Gather_err`
    CMD=`touch ../aproc/shell/RHEV_Gather.out`
    exit 255
fi

START_DATE=`date`

VMINFO_PATH=`pwd`
VMINFO_PID=`ps -e -o pid -o args | grep -v grep | grep -v vminfo_start | grep "python ./shell/LINUX/vminfo.py" | awk '$2 !~/grep/ && $2 !~/ps/ {print $1}'`
EXIT_CODE=0

if [ $VMINFO_PID ]; then

    #echo "[$START_DATE] already start vminfo($VMINFO_PID)"
    echo "[$START_DATE] already start vminfo($VMINFO_PID)" >> ../aproc/shell/vminfo.status.start

else

    nohup python ./shell/LINUX/vminfo.py > ../aproc/shell/RHEV_Gather.out 2>&1 &
    echo "[$START_DATE] vminfo start(nohup python ./shell/LINUX/vminfo.py &)." > ../aproc/shell/vminfo.status.start

    sleep 2
    VMINFO_PID=`ps -e -o pid -o args | grep -v grep | grep -v vminfo_start | grep "python ./shell/LINUX/vminfo.py" | awk '$2 !~/grep/ && $2 !~/ps/ {print $1}'`

    START_DATE=`date`
    if [ $VMINFO_PID ]; then
        #echo "[$START_DATE] started vminfo success[$VMINFO_PID]"
        echo "[$START_DATE] started vminfo success[$VMINFO_PID]" >> ../aproc/shell/vminfo.status.start
        \rm -f ./nohup.out
    else
        #echo "[$START_DATE] start vminfo failed[$VMINFO_PID]"
        echo "[$START_DATE] start vminfo failed[$VMINFO_PID]" >> ../aproc/shell/vminfo.status.start
        EXIT_CODE=1
    fi
fi

exit $EXIT_CODE
