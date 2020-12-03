#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/confupdate.dat
EXEC_DATE=`date +%Y%m%d%H%M%S`
TMP="../../utils/ETC/ConfUpdate $*"
EXEC_CMD=`echo [$EXEC_DATE]$TMP  >> $FILE_DAT`

NSLOOKUP_CMD=`../../utils/ETC/ConfUpdate $* >> $FILE_DAT 2>&1`

exit 0
