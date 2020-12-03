#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

CMDFILE=$1
ID=`echo $CMDFILE | awk -F. '{print $2}' | awk -F/ '{print $2}'`
FILEPATH="../aproc/shell/CmdProcCheck_$ID.dat"

if [ -f $FILEPATH ]; then
    rm -f $FILEPATH
fi

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    ps -Nef | grep $CMDFILE | grep -v grep | grep -v ProcCheck | awk '{print $2}' > $FILEPATH
else
    ps -ef | grep $CMDFILE | grep -v grep | grep -v ProcCheck | awk '{print $2}' > $FILEPATH
fi

while read line
do
    if [ "$line" != "1" ] ; then
        kill -9 $line
    fi
done <$FILEPATH

\rm -f $FILEPATH
exit 0
