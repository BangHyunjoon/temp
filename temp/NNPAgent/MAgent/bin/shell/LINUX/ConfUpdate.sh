#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/confupdate.dat

NSLOOKUP_CMD=`../../utils/ETC/ConfUpdate $* > $FILE_DAT`

exit 0
