#!/bin/sh
# errpt check shell

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

DPATH=../aproc/shell
if [ $2 ]
then
    PORT=$2
else
    PORT=21004
fi

case "$1" in
H)
#current file check
SIZE_01=0
errpt -s $3 -d H > $DPATH/errlog_H.2
SIZE_O2=`cat $DPATH/errlog_H.2 | wc -c`
if [ $SIZE_O2 -gt $SIZE_01 ]; then
    DATE=`date`
    MSG=`cat $DPATH/errlog_H.2|grep -v "IDENTIFIER TIMESTAMP"`
    plog -port $PORT ERRPTMSG 4 "$MSG"
    #plog -port $PORT ERRPTMSG 4 "[ERRPT] HARDWARE Fault!! [check : '#errpt -d H']"
    echo "HARDWARE Fault!! [$DATE,SIZE_02[$SIZE_O2]] " >> $DPATH/errpt_p.log
    # data backup
    mv $DPATH/errlog_H.2 $DPATH/errlog_H.1
fi
esac

case "$1" in
O)
#current file check
SIZE_01=0
errpt -s $3 -d O > $DPATH/errlog_O.2
SIZE_O2=`cat $DPATH/errlog_O.2 | wc -c`
if [ $SIZE_O2 -gt $SIZE_01 ]; then
    DATE=`date`
    MSG=`cat $DPATH/errlog_O.2|grep -v "IDENTIFIER TIMESTAMP"`
    plog -port $PORT ERRPTMSG 3 "$MSG"
    #plog -port $PORT ERRPTMSG 3 "[ERRPT] OPERATION Fault!! [check : '#errpt -d O']"
    echo "OPERATION Fault!! [$DATE,SIZE_02[$SIZE_O2]] " >> $DPATH/errpt_p.log
    # data backup
    mv $DPATH/errlog_O.2 $DPATH/errlog_O.1
fi
esac

case "$1" in
S)
#current file check
SIZE_01=0
errpt -s $3 -d S > $DPATH/errlog_S.2
SIZE_O2=`cat $DPATH/errlog_S.2 | wc -c`
if [ $SIZE_O2 -gt $SIZE_01 ]; then
    DATE=`date`
    MSG=`cat $DPATH/errlog_S.2|grep -v "IDENTIFIER TIMESTAMP"`
    plog -port $PORT ERRPTMSG 3 "$MSG"
    #plog -port $PORT ERRPTMSG 3 "[ERRPT] SOFTWARE Fault!! [check : '#errpt -d S']"
    echo "SOFTWARE Fault!! [$DATE,SIZE_02[$SIZE_O2]] " >> $DPATH/errpt_p.log
    # data backup
    mv $DPATH/errlog_S.2 $DPATH/errlog_S.1
fi
esac

case "$1" in
U)
#current file check
SIZE_01=0
errpt -s $3 -d U > $DPATH/errlog_U.2
SIZE_O2=`cat $DPATH/errlog_U.2 | wc -c`
if [ $SIZE_O2 -gt $SIZE_01 ]; then
    DATE=`date`
    plog -port $PORT ERRPTMSG 3 "[ERRPT] UNKNOWN Fault!! [check : '#errpt -d U']"
    echo "UNKNOWN Fault!! [$DATE,SIZE_02[$SIZE_O2]] " >> $DPATH/errpt_p.log
    # data backup
    mv $DPATH/errlog_U.2 $DPATH/errlog_U.1
fi
esac
