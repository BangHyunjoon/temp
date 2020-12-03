#!/bin/sh
# errpt logging shell

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

DPATH=../aproc/shell
#DPATH=.

S_DATE=`date +%m%d0000%y`
E_DATE=`date +%m%d2359%y`

#if [ -f $2 ]
#then
#    \rm -f $2
#fi

if [ ! -f $DPATH/errlog_1 ]
then
    errpt -s $S_DATE -e $E_DATE -d $1 > $DPATH/errlog_1
    CHECK_MSG=`cat ../aproc/shell/errlog_1 | grep "Unable to process error log file /var/adm/ras/errlog" | wc -l`
    if [ $CHECK_MSG != 0 ] ; then
        touch $DPATH/errpt.log
        exit 1
    fi
fi


errpt -s $S_DATE -e $E_DATE -d $1 > $DPATH/errlog_2
CHECK_MSG=`cat ../aproc/shell/errlog_2 | grep "Unable to process error log file /var/adm/ras/errlog" | wc -l`
if [ $CHECK_MSG != 0 ] ; then
    touch $DPATH/errpt.log
    exit 1
fi


if ! cmp -s $DPATH/errlog_1 $DPATH/errlog_2
then
    if [ -f $DPATH/errlog_2 ]; then
        diff -w $DPATH/errlog_1 $DPATH/errlog_2 > $DPATH/errlog_3
    fi



    exec 3< $DPATH/errlog_3

    while read IMSI MES<&3
    do
        if [ "$IMSI" = ">" ]
        then
            if [ "$MES" != "IDENTIFIER TIMESTAMP  T C RESOURCE_NAME  DESCRIPTION" ]
            then
                if [ "$MES" != "" ]
                then
                    echo $MES >> $2
                fi
            fi
        fi
    done
    exec 3<&-



#    SIZE_2=`cat $DPATH/errlog_2 | wc -c`
#    SIZE_LOG=`cat $DPATH/errpt.log_ | wc -c`
#    if [ $SIZE_LOG -gt $SIZE_2 ]; then
#        mv $DPATH/errlog_2 $DPATH/errlog_1
#        \rm -f $DPATH/errlog_3
#        \rm -f $DPATH/errpt.log_
#        touch $DPATH/errpt.log_
#        exit 1
#    fi
fi
mv $DPATH/errlog_2 $DPATH/errlog_1
touch $DPATH/errpt.log


