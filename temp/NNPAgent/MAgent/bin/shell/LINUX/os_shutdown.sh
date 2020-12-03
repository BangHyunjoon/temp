#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/os_shutdown.dat
EXEC_DATE=`date +%Y\-%m\-%d\ %H:%M:%S`
T_HOSTNAME=`hostname`


WAIT_TIME=0
if [ "$2" != "" ] ; then
    WAIT_TIME=$2
fi

CMD=`echo "$EXEC_DATE [$T_HOSTNAME] wait count($WAIT_TIME sec)..." >> $FILE_DAT`
WAIT_CNT=0
while [ $WAIT_CNT -lt $WAIT_TIME ]
do
    let "WAIT_CNT = $WAIT_CNT + 1"
    sleep 1
done

if [ "$1" = "SHUTDOWN" ] ; then

    CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command exec" >> $FILE_DAT`
    CMD=`init 0;shutdown -H 0;shutdown -H >> $FILE_DAT 2>&1`
    CMD=`echo "halt - system shutdown now !!!!" >> $FILE_DAT`

else

    if [ "$1" = "REBOOT" ] ; then

        CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command exec" >> $FILE_DAT`
        CMD=`reboot >> $FILE_DAT 2>&1`
        CMD=`echo "reboot - system rebooting now !!!!" >> $FILE_DAT`

    else

        CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command - not defined" >> $FILE_DAT`

    fi

fi
exit 0
