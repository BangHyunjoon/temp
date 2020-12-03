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


FILE_DAT=../aproc/shell/xe_info.dat
#FILE_DAT=./xe_info.dat
T_FILE_DAT="$FILE_DAT"_

EXIT_VAL=`xe host-cpu-list | grep uuid > $T_FILE_DAT  2> ../aproc/shell/xe_host-cpu-list.err;echo $?`
#EXIT_VAL=`xe host-cpu-list | grep uuid > $T_FILE_DAT  2> ./xe_host-cpu-list.err;echo $?`

#################################################################################
#uuid ( RO)           : 17e90e9d-5ca8-db96-7630-d29b1a3c73af
#uuid ( RO)           : 3b615d83-e7ae-4bc7-9190-90bf3ffe5759
#uuid ( RO)           : 56742013-fdaa-b5a4-0a62-754b8235dacd
#uuid ( RO)           : c323d7a9-e562-f51d-15c6-af0828f0ae1c
#uuid ( RO)           : 16c8ec99-d853-6f1d-d34f-7f4c90b10207
#uuid ( RO)           : 2ec31c1e-a342-463c-eb56-b68475f570b2
#uuid ( RO)           : e6fabc0c-fef0-a2ac-cb93-ab4433a1f026
#uuid ( RO)           : c0da80f8-754b-d867-3914-53f182b1be4c
#################################################################################

CMD=`\rm -f $FILE_DAT`
CMD=`mv $T_FILE_DAT $FILE_DAT`

#xe host-cpu-param-get uuid=<CPU UUID> param-name=utilisation

CPU_INDEX=0
CPU_USED=0.0
CPU_SUM_USED=0.0
CPU_AVG_USED=0.0
while read line
do
    #echo "read line = $line"

    CPU_INDEX=`expr ${CPU_INDEX} + 1`
    CPU_UUID=`echo $line | awk -F": " '{print $2}'`
    #echo "CPU_UUID [$CPU_INDEX] = [$CPU_UUID]"

    CPU_USED=`xe host-cpu-param-get uuid=$CPU_UUID param-name=utilisation | awk -F" " '{print $1}'`

    CPU_SUM_USED=$(echo "scale=3; $CPU_SUM_USED + $CPU_USED" | bc)
    #echo "CPU [$CPU_INDEX] --> SUM=[$CPU_SUM_USED], USED=[$CPU_USED]"

done <$FILE_DAT

#CPU_AVG_USED=$(echo "scale=3; $CPU_SUM_USED / $CPU_INDEX" | bc)
CPU_AVG_USED=`awk -v x=$CPU_SUM_USED -v y=$CPU_INDEX 'BEGIN{printf "%0.2f", x/y}'`

CPU_USED_PRINT=`echo $CPU_AVG_USED > ../aproc/shell/xenserver_host_cpu_used.dat`
#CPU_USED_PRINT=`echo $CPU_AVG_USED > ./xenserver_host_cpu_used.dat`

if [ $CPU_INDEX = 0 ] ; then
    EXIT_VAL=`echo "cpu count is zero(error)." 2>> ../aproc/shell/xe_host-cpu-list.err`
    #EXIT_VAL=`echo "cpu count is zero(error)." 2>> ./xe_host-cpu-list.err`
    exit 255
else 
    exit $EXIT_VAL
fi
