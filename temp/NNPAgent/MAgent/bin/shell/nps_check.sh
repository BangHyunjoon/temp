#!/bin/sh
#/check.sh /tmp TCP 10.10.10.10 31001 HOST1

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH

LANG=C
export LANG

CONF_FILE=$1"/nps_status.d/nps_status.conf"
NPS_FILE=$1"/nps_status.d/nps_status_sender"
PROTOCOL="PROTOCOL="$2
IP="IP="$3
PORT="PORT="$4
AGENT_ID="AGENT_ID="$5

l_result=-1
if [ -f $CONF_FILE ] ; then
    #while read line
    #    echo $line | grep $PROTOCOL | wc -l
    #do
    #done <$CONF_FILE
    l_check=`grep $PROTOCOL $CONF_FILE | wc -l`
    if [ $l_check -eq 1 ] ; then
        l_check=`grep $IP $CONF_FILE | wc -l`
        if [ $l_check -eq 1 ] ; then
            l_check=`grep $PORT $CONF_FILE | wc -l`
            if [ $l_check -eq 1 ] ; then
                l_check=`grep $AGENT_ID $CONF_FILE | wc -l`
                if [ $l_check -eq 1 ] ; then
                    l_result=0
                fi
            fi
        fi
    fi
fi

if [ $l_result -ne 0 ] ; then
    echo "NKIA_FILECHECK_FAIL"
    exit 0
fi

######################################
DIR1="/var/spool/cron/crontabs"
DIR2="/var/spool/cron"
DIR_LAST=""
CRON_FILE=""
l_dirtype=-1

if [ -d $DIR1 ] ; then
    l_dirtype=1
    DIR_LAST=$DIR1
else
    if [ -d $DIR2 ] ; then
        l_dirtype=2
        DIR_LAST=$DIR2
    fi
fi

if [ $l_dirtype -eq -1 ] ; then
    #echo "no cronttab dir found!"
    echo "NKIA_FILECHECK_FAIL"
    exit 0
fi

l_result=-1
CRON_FILE=$DIR_LAST"/root"
if [ -f $CRON_FILE ] ; then
    l_check=`grep "nps_status.d/nps_status_sender" $CRON_FILE | wc -l`
    if [ $l_check -eq 1 ] ; then
        l_result=1
    else
        l_result=-1
    fi
else
    l_result=-1
fi

if [ $l_result -eq 1 ] ; then
    if [ -f $NPS_FILE ] ; then
        echo "NKIA_FILECHECK_SUCCESS"
    else
        echo "NKIA_FILECHECK_FAIL"
    fi
else
    echo "NKIA_FILECHECK_FAIL"
fi
exit 0

