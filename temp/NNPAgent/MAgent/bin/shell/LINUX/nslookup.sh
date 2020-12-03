#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/nslookup.dat
IP_DAT=../aproc/shell/nslookup_ip.dat
CMD=`echo "" > $FILE_DAT`
CMD=`echo "" > $IP_DAT`

NSLOOKUP_CMD=nslookup
COMMAND=`which $NSLOOKUP_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found nslookup info command($NSLOOKUP_CMD)" > ../aproc/shell/nslookup.dat_err`
    exit 255
fi

if [ $1 ] ; then

    NSLOOKUP_CMD_EXE=`$NSLOOKUP_CMD $1 > $FILE_DAT`
    LINE_CNT=0
    DNS_CHECK=0
    DNS_NAME_FLAG=0
    DNS_NAME2_FLAG=0
    DNS_IP=" "
    while read line
    do
        LINE_CNT=`expr $LINE_CNT + 1`

        #echo "READ LINE=[$line]"

        ## case 1)
        #READ LINE=[Server:              168.126.63.1]
        #READ LINE=[Address:     168.126.63.1#53]
        #READ LINE=[]
        #READ LINE=[Non-authoritative answer:]
        #READ LINE=[Name:        nis.nkia.net]
        #READ LINE=[Address: 211.115.112.26]
        #READ LINE=[]

        ## case 2)
        #READ LINE=[;; connection timed out; no servers could be reached]
        #READ LINE=[]

        ## case 3)
        #READ LINE=[Server:              168.126.63.1]
        #READ LINE=[Address:     168.126.63.1#53]
        #READ LINE=[]
        #READ LINE=[** server can't find nis.nkia.co.kr: NXDOMAIN]
        #READ LINE=[]

        ## case 4)
        #READ LINE=[Server:              168.126.63.1]
        #READ LINE=[Address:     168.126.63.1#53]
        #READ LINE=[]
        #READ LINE=[Non-authoritative answer:]
        #READ LINE=[www.naver.com        canonical name = www.g.naver.com.]
        #READ LINE=[Name:        www.g.naver.com]
        #READ LINE=[Address: 222.122.195.5]
        #READ LINE=[Name:        www.g.naver.com]
        #READ LINE=[Address: 202.131.29.70]
        #READ LINE=[]

        DNS_CHECK=`echo $line | grep $1 | wc -l`
        if [ $DNS_CHECK = 0 ] ; then
            DNS_CHECK=0
        else
            DNS_NAME_FLAG=1
        fi

        if [ $DNS_NAME_FLAG = 1 ] ; then
            DNS_CHECK=`echo $line | grep "Name:" | wc -l`
            if [ $DNS_CHECK = 0 ] ; then
                DNS_CHECK=0
            else
                DNS_NAME2_FLAG=1
            fi

            if [ $DNS_NAME2_FLAG = 1 ] ; then
                DNS_CHECK=`echo $line | grep "Address:" | wc -l`
                if [ $DNS_CHECK = 0 ] ; then
                    DNS_CHECK=0
                else
                    DNS_IP=`echo $line | cut -d':' -d' ' -f2`
                    #echo "[$1]=[$DNS_IP]"
                    CMD=`echo $DNS_IP > $IP_DAT`
                    break
                fi
            fi
        fi

    done <$FILE_DAT
else 
    NSLOOKUP_CMD_EXE=`echo "domain name input error" >> $FILE_DAT`
fi

exit 0
