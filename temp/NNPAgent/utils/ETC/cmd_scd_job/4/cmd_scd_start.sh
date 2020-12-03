#!/bin/sh

UNIX95=1
export UNIX95

CMD_SCD_PATH=$1
CMD=""

if [ "$1" ]; then

    START_DATE=`date +%Y%m%d%H%M%S`
    CMD_SCD_PID=`ps -e -o pid -o args | grep -v grep | grep "$CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/" | awk '{print $1}'`

    if [ $CMD_SCD_PID ]; then

        CMD=`echo "[$START_DATE] already start : $CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/($CMD_SCD_PID)" >> $CMD_SCD_PATH/cmd_scd.result`
        
    else

        CMD=`\rm -f  $CMD_SCD_PATH/cmd_scd.status*`
        ../../utils/ETC/ShCmd 60 $CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/
        CMD=`echo "$CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/" > $CMD_SCD_PATH/cmd_scd.result`
    fi
else
    CMD=`echo "usage : $0 <home dir>" >> $CMD_SCD_PATH/cmd_scd.result`
fi

exit 0
