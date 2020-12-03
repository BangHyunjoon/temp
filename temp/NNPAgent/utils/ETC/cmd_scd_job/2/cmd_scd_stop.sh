#!/bin/sh

UNIX95=1
export UNIX95

CMD_SCD_PATH=$1
CMD=""

if [ "$1" ]; then

    START_DATE=`date +%Y%m%d%H%M%S`
    CMD_SCD_PID=`ps -e -o pid -o args | grep -v grep | grep "$CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/" | awk '{print $1}'`
    #ps -e -o pid -o args | grep -v grep | grep "$CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/"

    if [ $CMD_SCD_PID ]; then

        CMD=`\rm -f  $CMD_SCD_PATH/cmd_scd.status.$CMD_SCD_PID`
        CMD=`echo "rm -f $CMD_SCD_PATH/cmd_scd.status.$CMD_SCD_PID" >> $CMD_SCD_PATH/cmd_scd.result`

        TRY_CNT=0
        while [ $CMD_SCD_PID ]
        do
            TRY_CNT=`expr $TRY_CNT + 1`
            if [ $TRY_CNT = '60' ] ; then
                CMD=`kill -9 $CMD_SCD_PID`
                CMD=`echo "kill $CMD_SCD_PID" >> $CMD_SCD_PATH/cmd_scd.result`
                break;
            fi

            CMD=`echo "[$TRY_CNT] $CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/ : stopping[$CMD_SCD_PID]...." >> $CMD_SCD_PATH/cmd_scd.result`

            sleep 1

            CMD_SCD_PID=`ps -e -o pid -o args | grep -v grep | grep "$CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/" | awk '{print $1}'`
        done
    else
        CMD=`echo "already stop : $CMD_SCD_PATH/cmd_scd $CMD_SCD_PATH/" >> $CMD_SCD_PATH/cmd_scd.result`
    fi
else
    CMD=`echo "usage : $0 <home dir>" >> $CMD_SCD_PATH/cmd_scd.result`
fi

exit 0
