#!/bin/sh

#./shell/nps_del.sh /tmp/nps_status.d

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH

LANG=C
export LANG

l_Old2check=`echo $1 | grep nps_status.d | wc -l`
if [ $l_Old2check -eq 1 ] ; then
    mv $1 ../aproc/temp/
fi

l_DATE=`date +%Y%m%d%H%M%S`
l_CronBack="cron_"$l_DATE

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
    echo "no cronttab dir found!"
    exit 0
fi
CRON_FILE=$DIR_LAST"/root"

\cp -f $CRON_FILE ../aproc/$l_CronBack

l_vimode=-1
if [ -f $CRON_FILE ] ; then
    l_check=`grep "nps_status.d/nps_status_sender" $CRON_FILE | wc -l`
    if [ $l_check -eq 0 ] ; then
        echo "NKIA_CRONEDIT_SUCCESS"
        exit 0 
    else
        echo "exist"
        cat $CRON_FILE | sed '/nps_status.d/d' > ./tmp_cron_root
        cp ./tmp_cron_root $CRON_FILE
        l_vimode=0
    fi
else
    echo "NKIA_CRONEDIT_SUCCESS"
    exit 0 
fi

if [ $l_vimode -eq 0 ] ; then
    EDITOR=vi
    export EDITOR
    #echo :wq | crontab -e
    crontab $CRON_FILE

    l_check=`cat $CRON_FILE | grep nps_status.d | wc -l`
    if [ $l_check -eq 0 ] ; then
        echo "NKIA_CRONEDIT_SUCCESS"
    else
        echo "NKIA_CRONEDIT_FAIL"
    fi
else
    echo "NKIA_CRONEDIT_FAIL"
fi
exit 0

