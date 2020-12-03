#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/ps_vdsm.dat
VDSM_CNT=../aproc/shell/ps_vdsm_cnt.dat
CMD=`echo "" > $FILE_DAT`
CMD=`echo "" > $VDSM_CNT`

PM_CHK_CMD=`ps -ef | grep "/vdsm " | grep -v grep > $FILE_DAT 2>&1`
PM_CHK_CMD=`ps -ef | grep "/vdsm " | grep -v grep | wc -l >  $VDSM_CNT`

exit 0
