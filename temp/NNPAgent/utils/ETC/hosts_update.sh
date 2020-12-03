#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hosts_update.dat

IP_ADDR="$1"
IP_ALIAS="$2"

TMP_CMD=`date > $FILE_DAT`
TMP_CMD=`echo "================ OLD /etc/hosts =======================" >> $FILE_DAT`
TMP_CMD=`cat /etc/hosts >> $FILE_DAT`
TMP_CMD=`echo "=================++++++++++++++++======================" >> $FILE_DAT`

TMP_CMD=`grep -v "$IP_ADDR" /etc/hosts > /etc/hosts_`
TMP_CMD=`grep "$IP_ADDR" /etc/hosts | wc -l >> $FILE_DAT`

TMP_CMD=`grep -v "$IP_ALIAS" /etc/hosts_ > /etc/hosts`
TMP_CMD=`grep "$IP_ALIAS" /etc/hosts_ | wc -l >> $FILE_DAT`

TMP_CMD=`echo "$IP_ADDR		$IP_ALIAS" >> /etc/hosts`
TMP_CMD=`echo "ADD [$IP_ADDR            $IP_ALIAS]" >> $FILE_DAT`

TMP_CMD=`rm -f /etc/hosts_`

TMP_CMD=`echo "================ NEW /etc/hosts =======================" >> $FILE_DAT`
TMP_CMD=`cat /etc/hosts >> $FILE_DAT`
TMP_CMD=`echo "=================++++++++++++++++======================" >> $FILE_DAT`

exit 0
