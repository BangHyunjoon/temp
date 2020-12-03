#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

CONF_FILE=$1
FILE_INDEX=$2
HTTPD_PORT_TMP_FILE=../aproc/shell/httpd_port_tmp_result_$FILE_INDEX.dat
HTTPD_PORT_FILE=../aproc/shell/httpd_port_result_$FILE_INDEX.dat

cat $CONF_FILE | egrep "^Port|^Listen" > $HTTPD_PORT_TMP_FILE

l_nCheck=`cat $HTTPD_PORT_TMP_FILE | wc -c`
if [ $l_nCheck -eq 0 ] ; then
    cat $CONF_FILE | grep PORT | sed -e 's/ //g' | grep ^PORT= | sed -e 's/=/ /g' | sed -e 's/\"//g' | sed -e 's/,//g'  > $HTTPD_PORT_TMP_FILE
fi

l_strLastPort=""
l_nFirstFlag=0

while read l_strReadBuf
do
    l_strTmpPort=`echo $l_strReadBuf | awk '{print $2}'`
    l_nCheck=`echo $l_strTmpPort | grep ":" | wc -l`
    if [ $l_nCheck -eq 1 ] ; then
        l_strPort=`echo $l_strTmpPort | awk -F':' '{print $2}'`
    else
        l_strPort=`echo $l_strTmpPort`
    fi

    if [ $l_nFirstFlag -eq 0 ] ; then
        l_strLastPort=$l_strPort
        l_nFirstFlag=1
    else
        l_strTmpPort=`echo $l_strLastPort | sed -e 's/,/ /g'`
        for l_strTok  in `echo $l_strTmpPort`
        do
            if [ $l_strTok -eq $l_strPort ] ; then
                break
            fi

            if [ $l_strTok -ne $l_strPort ] ; then

                l_strLastPort=$l_strLastPort","$l_strPort
                break
            fi
        done
    fi
done <$HTTPD_PORT_TMP_FILE

echo $l_strLastPort > $HTTPD_PORT_FILE
