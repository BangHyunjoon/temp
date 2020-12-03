#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

Version=`uname -r  | awk -F. '{print $2"."$3}'`
if [ "$Version" = "11.11" ]; then
    SERIALNO=`getconf MACHINE_SERIAL 2> /dev/null`
    content_len=`echo $SERIALNO | wc -c`
    if [ $content_len -le 2 ] ; then
            SERIALNO=`echo "sc product system;info;wait;il" | cstm | grep -i "system serial" | awk -F: '{print $2}'`
    fi
elif [ "$Version" = "11.00" ]; then
    SERIALNO="UNKNOWN"
else
    result=`which machinfo 2> /dev/null | egrep -v "no" | wc -l`
    if [ $result -eq 0 ] ; then
        SERIALNO=`getconf MACHINE_SERIAL 2> /dev/null`
    else
        #SERIALNO=`machinfo | grep "machine serial" | awk -F= '{print $2}' 2> /dev/null `
        #SERIALNO=`echo "sc product system;info;wait;il" | cstm | grep -i "system serial" | awk -F: '{print $2}'`
        SERIALNO=`machinfo | grep -i "machine serial" | awk '{print $NF}' 2> /dev/null `
    fi
fi
echo $SERIALNO > ../aproc/shell/SystemidHP.dat
