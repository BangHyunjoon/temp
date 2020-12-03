#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/mpsched_s.dat
CMD=`echo "" > $FILE_DAT`

MPSCHED_CMD=mpsched
COMMAND=`which $MPSCHED_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found processor info command($MPSCHED_CMD [-s])" > ../aproc/shell/mpsched_s.dat_err`
    exit 255
fi

MPSCHED_CMD_EXE=`$MPSCHED_CMD -s > $FILE_DAT`

exit 0
