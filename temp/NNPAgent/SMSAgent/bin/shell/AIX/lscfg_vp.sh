#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/lscfg_vp.dat
CMD=`echo "" > $FILE_DAT`

LSCFG_CMD=lscfg
COMMAND=`which $LSCFG_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found processor info command($LSCFG_CMD [-vp])" > ../aproc/shell/lscfg_vp.dat_err`
    exit 255
fi

LSCFG_CMD_EXE=`$LSCFG_CMD -vp > $FILE_DAT`

exit 0
