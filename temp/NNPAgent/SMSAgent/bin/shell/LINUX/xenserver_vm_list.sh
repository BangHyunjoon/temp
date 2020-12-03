#!/bin/bash

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

SH_CMD=xe
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/xe_err`
    #CMD=`echo "not found command($SH_CMD)" > ./xe_err`
    exit 255
fi


FILE_DAT=../aproc/shell/xe_vm-list.dat
#FILE_DAT=./xe_vm-list.dat
T_FILE_DAT="$FILE_DAT"_

EXIT_VAL=`xe vm-list params=all > $T_FILE_DAT  2> ../aproc/shell/xe_vm-list.err;echo $?`
#EXIT_VAL=`xe vm-list params=all > $T_FILE_DAT  2> ./xe_vm-list.err;echo $?`
#EXIT_VAL=`cat ./vm-list_parmas-all.dat > $T_FILE_DAT  2> ./xe_vm-list.err;echo $?`

CMD=`\rm -f $FILE_DAT 2> /dev/null`
CMD=`mv $T_FILE_DAT $FILE_DAT 2> /dev/null`

VM_INDEX=0
VM_PARAM_CHECK=""
VM_PARAM_VALUE=""
VM_NAME=""
VM_UUID=""
VM_FLAG=0
VM_IS=0

VM_LIST_FILE=../aproc/shell/vm-list.dat
#VM_LIST_FILE=./vm-list.dat
T_VM_LIST_FILE="$VM_LIST_FILE"_

VM_LIST_INFO_FILE=../aproc/shell/vm-list-info.dat
#VM_LIST_INFO_FILE=./vm-list-info.dat
T_VM_LIST_INFO_FILE="$VM_LIST_INFO_FILE"_

VM_LIST_GATHER_FAILED=../aproc/shell/vm-list_error
#VM_LIST_GATHER_FAILED=./vm-list_error

CMD=`\rm -f $T_VM_LIST_FILE`
CMD=`\rm -f $T_VM_LIST_INFO_FILE`
CMD=`\rm -f $VM_LIST_GATHER_FAILED`

#date
while read line
do
    #echo "read line = $line"
    #uuid, name-label, other-config, start-time, last_shutdown_time

#uuid ( RO)            : 97ebcda9-1bca-e75a-9859-6efd4dffae68
#      name-label ( RW): linux-64bit-dev-sms
#    other-config (MRW): last_shutdown_time: 20120329T05:00:02Z; last_shutdown_action: Restart; last_shutdown_initiator: internal; last_shutdown_reason: rebooted; mac_seed: 64baf37e-3fa7-b525-f3ac-6feffdd97dd6
#      start-time ( RO): 20120329T05:00:10Z

#    if [ $VM_FLAG = 0 ] ; then
        VM_PARAM_CHECK=`echo $line | awk -F"^uuid " '{print $1}'`
        if [ "$VM_PARAM_CHECK" = "" ] ; then
            VM_PARAM_CHECK=`echo  $line | sed '1,$s/^ *$//'`
            if [ "$VM_PARAM_CHECK" != "" ] ; then
                if [ "$VM_START_TIME" = "" ] ; then
                    VM_START_TIME="-"
                fi
                
                if [ "$VM_LAST_SHUTDOWN_TIME" = "" ] ; then
                    VM_LAST_SHUTDOWN_TIME="-"
                fi
                
                if [ $VM_FLAG = 4 ] ; then
                    if [ "$VM_NAME" != "Control domain on host" ] ; then
                        CMD=`echo $VM_NAME >> $T_VM_LIST_FILE`
                        CMD=`echo "$VM_INDEX, $VM_UUID, $VM_START_TIME, $VM_LAST_SHUTDOWN_TIME, $VM_NAME" >> $T_VM_LIST_INFO_FILE`
                        echo "VM INDEX[$VM_INDEX], UUID[$VM_UUID], NAME[$VM_NAME], START TIME[$VM_START_TIME], LAST SHUTDOWN TIME=[$VM_LAST_SHUTDOWN_TIME]"
                    fi
                fi

                let "VM_INDEX = $VM_INDEX + 1"
                VM_UUID=`echo $line | awk -F": " '{print $2}' | sed '1,$s/^ *//' | sed '1,$s/ *$//'`
                VM_NAME=""
                VM_START_TIME=""
                VM_LAST_SHUTDOWN_TIME=""
                VM_FLAG=1
                #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG],  UUID[$VM_UUID], uuid"
            fi
        fi
#    else
        VM_PARAM_CHECK=`echo $line | awk -F"^name-label " '{print $1}'`
        if [ "$VM_PARAM_CHECK" = "" ] ; then
            VM_PARAM_CHECK=`echo  $line | sed '1,$s/^ *$//'`
            if [ "$VM_PARAM_CHECK" != "" ] ; then
                VM_NAME=`echo $line | awk -F": " '{print $2}' | sed '1,$s/^ *//' | sed '1,$s/ *$//'`

                let "VM_FLAG = $VM_FLAG + 1"
                #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG],  UUID[$VM_UUID], NAME[$VM_NAME], name-label"
            fi
        else
            VM_PARAM_CHECK=`echo $line | awk -F"^other-config " '{print $1}'`
            if [ "$VM_PARAM_CHECK" = "" ] ; then
                VM_PARAM_CHECK=`echo  $line | sed '1,$s/^ *$//'`
                if [ "$VM_PARAM_CHECK" != "" ] ; then
                    let "VM_FLAG = $VM_FLAG + 1"
                    VM_PARAM_VALUE=`echo $line | grep "HideFromXenCenter: true" | wc -l`
                    if [ "$VM_PARAM_VALUE" = "0" ] ; then
                        #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG], UUID[$VM_UUID], HideFromXenCenter: false"
                        if [ "$VM_NAME" != "Control domain on host" ] ; then
                            VM_PARAM_VALUE=`echo $line | awk -F"last_shutdown_time: " '{print $2}' | sed '1,$s/^ *//' | sed '1,$s/ *$//'`
                            #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG], UUID[$VM_UUID], last_shutdown_time-1=[$VM_PARAM_VALUE]"

                            VM_LAST_SHUTDOWN_TIME=`echo $VM_PARAM_VALUE | awk -F"; " '{print $1}' | sed '1,$s/^ *//' | sed '1,$s/ *$//'`
                            #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG], UUID[$VM_UUID], last_shutdown_time-2=[$VM_LAST_SHUTDOWN_TIME]"
                        #else
                            #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG], UUID[$VM_UUID], Control domain on host ~~"
                        fi
                    #else
                        #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG],  UUID[$VM_UUID], HideFromXenCenter: true"
                    fi
                fi
            else
                VM_PARAM_CHECK=`echo $line | awk -F"^start-time " '{print $1}'`
                if [ "$VM_PARAM_CHECK" = "" ] ; then
                    let "VM_FLAG = $VM_FLAG + 1"

                    VM_PARAM_CHECK=`echo  $line | sed '1,$s/^ *$//'`
                    if [ "$VM_PARAM_CHECK" != "" ] ; then
                        VM_START_TIME=`echo $line | awk -F": " '{print $2}' | sed '1,$s/^ *//' | sed '1,$s/ *$//'`
                        #echo "VM INDEX[$VM_INDEX], VM FLAG[$VM_FLAG], UUID[$VM_UUID], NAME[$VM_NAME], START TIME[$VM_START_TIME]"
                    fi
                fi
            fi
        fi
#    fi

done <$FILE_DAT
#date

if [ $VM_INDEX = 0 ] ; then
    CMD=`touch $VM_LIST_GATHER_FAILED`
    CMD=`\rm -f $T_VM_LIST_FILE 2> /dev/null`
    CMD=`\rm -f $T_VM_LIST_INFO_FILE 2> /dev/null`
    EXIT_VAL=255
else
    if [ $VM_FLAG = 4 ] ; then
        if [ "$VM_NAME" != "Control domain on host" ] ; then
            CMD=`echo $VM_NAME >> $T_VM_LIST_FILE`
            CMD=`echo "$VM_INDEX, $VM_UUID, $VM_START_TIME, $VM_LAST_SHUTDOWN_TIME, $VM_NAME" >> $T_VM_LIST_INFO_FILE`
            echo "VM INDEX[$VM_INDEX], UUID[$VM_UUID], NAME[$VM_NAME], START TIME[$VM_START_TIME], LAST SHUTDOWN TIME=[$VM_LAST_SHUTDOWN_TIME]"
        fi
    fi

    CMD=`\rm -f $VM_LIST_FILE 2> /dev/null`
    CMD=`mv $T_VM_LIST_FILE $VM_LIST_FILE 2> /dev/null`

    CMD=`\rm -f $VM_LIST_INFO_FILE 2> /dev/null`
    CMD=`mv $T_VM_LIST_INFO_FILE $VM_LIST_INFO_FILE 2> /dev/null`

    EXIT_VAL=0
fi 

exit $EXIT_VAL
