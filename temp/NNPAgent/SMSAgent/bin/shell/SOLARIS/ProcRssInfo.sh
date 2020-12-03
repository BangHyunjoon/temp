#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE1=../aproc/shell/ProcRssInfo.dat
rm ../aproc/shell/ProcRssInfo.dat 2> /dev/null
ps -e -o pid,rss | awk -F' ' '{print $1,$2}' > $FILE1

exit 

PID=$1
FILE=../aproc/shell/ProcRssInfo.tmp
FILE1=../aproc/shell/ProcRssInfo.dat

rm ../aproc/shell/ProcRssInfo.dat 2> /dev/null
rm ../aproc/shell/ProcRssInfo.tmp 2> /dev/null

ps -e -o pid,rss | grep $PID | awk -F' ' '{print $1,$2}' > $FILE

while read line
do
    RPID=`echo $line | awk -F' ' '{print $1}'`
    RSS=`echo $line | awk -F' ' '{print $2}'`
    if [ "$PID" = "$RPID" ]; then
        echo $RPID","$RSS > $FILE1
    fi
done <$FILE

