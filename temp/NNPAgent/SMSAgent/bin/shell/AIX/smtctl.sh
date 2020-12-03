#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/smtctl.dat
CMD=`echo "" > $FILE_DAT`

SMTCTL_CMD=smtctl
COMMAND=`which $SMTCTL_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found smt info command($SMTCTL_CMD)" > ../aproc/shell/smtctl.dat_err`
    exit 255
fi

SMTCTL_CMD_EXE=`$SMTCTL_CMD > $FILE_DAT`

exit 0
