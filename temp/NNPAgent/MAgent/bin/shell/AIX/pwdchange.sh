#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/pwd_result.dat
FILE_DAT_EXIT=../aproc/shell/pwd_result.exit

echo "" > $FILE_DAT

PWD_USER=""
if [ "$1" ] ; then
    PWD_USER=$1
else
    echo "user name input error!!!" >> $FILE_DAT
    echo 255 > $FILE_DAT_EXIT
    exit 255
fi

PWD_WORD=""
if [ "$2" ] ; then
    PWD_WORD=$2
else
    echo "user passwd input error!!!" >> $FILE_DAT
    echo 255 > $FILE_DAT_EXIT
    exit 255
fi

PWD_CMD_CHK=0
PWD_CMD_CHK=`passwd --help | grep stdin | wc -l`
if [ $PWD_CMD_CHK = 0 ] ; then
    # cpd <passwd> <user> <password> exec
    # cpd_rst.dat : 1 -> success
    TMP_CHK=0
    TMP_CHK=`../../utils/ETC/cpd passwd $PWD_USER $PWD_WORD >> $FILE_DAT 2>&1;cat ./pcd_rst.dat`
    if [ $TMP_CHK = 1 ] ; then
        echo "user<$PWD_USER> passwd change success" >> $FILE_DAT
        echo 0 > $FILE_DAT_EXIT
        exit 0
    else
        echo "user<$PWD_USER> passwd change failed" >> $FILE_DAT
        echo 1 > $FILE_DAT_EXIT
        exit 1
    fi
else
    # echo password | passwd --stdin  <user>
    TMP_CHK=0
    TMP_CHK=`echo $PWD_WORD | passwd --stdin $PWD_USER >> $FILE_DAT 2>&1;echo $?`
    if [ $TMP_CHK = 0 ] ; then
        echo "user<$PWD_USER> passwd change success" >> $FILE_DAT
        echo 0 > $FILE_DAT_EXIT
        exit 0
    else
        echo "user<$PWD_USER> passwd change failed" >> $FILE_DAT
        echo 1 > $FILE_DAT_EXIT
        exit 1
    fi
fi
