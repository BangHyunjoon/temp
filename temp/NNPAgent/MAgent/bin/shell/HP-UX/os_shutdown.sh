#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

CUR_PATH=`pwd`
FILE_DAT=../aproc/shell/os_shutdown.dat
EXEC_DATE=`date +%Y\-%m\-%d\ %H:%M:%S`
T_HOSTNAME=`hostname`

if [ "$1" = "SHUTDOWN" ] ; then

    CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command exec" >> $FILE_DAT`
    #CMD=`halt >> $FILE_DAT 2>&1`
    CMD=`cd /;shutdown -hy 0 >> $CUR_PATH/$FILE_DAT 2>&1`
    CMD=`cd $CUR_PATH`
    CMD=`echo "halt - system shutdown now !!!!" >> $FILE_DAT`

else

    if [ "$1" = "REBOOT" ] ; then

        CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command exec" >> $FILE_DAT`
        CMD=`cd /;shutdown -ry 0 >> $CUR_PATH/$FILE_DAT 2>&1`
        CMD=`cd $CUR_PATH`
        CMD=`echo "reboot - system rebooting now !!!!" >> $FILE_DAT`

    else

        CMD=`echo "$EXEC_DATE [$T_HOSTNAME] $1 command - not defined" >> $FILE_DAT`

    fi

fi
exit 0
