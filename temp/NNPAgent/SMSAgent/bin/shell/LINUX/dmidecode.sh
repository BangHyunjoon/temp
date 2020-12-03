#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

SH_CMD=dmidecode
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/dmidecode.dat_err`
    echo " " > ../aproc/shell/dmidecode.dat
    exit 255
fi

DMIDECODE_DAT_CHK=`ls -al ../aproc/shell/dmidecode.dat 2> /dev/null | wc -l`

if [ $DMIDECODE_DAT_CHK = 0 ] ; then

    TMP_DAT=`dmidecode > ../aproc/shell/dmidecode.dat`

fi 
