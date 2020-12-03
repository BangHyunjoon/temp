#!/bin/sh

PATH=$PATH:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

CURRENTPATH=`pwd`
IPFILE=$CURRENTPATH/nodeipinfo.txt

`rm $CURRENTPATH/nodeipinfo.txt $CURRENTPATH/tmp.txt $CURRENTPATH/a.out 2> /dev/null`

OS=`uname -s`
HOST=`hostname`
PARAMETER=$1

if [ "$OS" = "SunOS" ]; then
    `netstat -in > $IPFILE`
fi
if [ "$OS" = "HP-UX" ]; then
    `netstat -in > $IPFILE`
fi
if [ "$OS" = "AIX" ]; then
    `netstat -in > $IPFILE`
fi
if [ "$OS" = "Linux" ]; then
    TMPFILE=$CURRENTPATH/tmp.txt
    `ifconfig -a | grep "inet addr:" > $TMPFILE`
    if [ -s $TMPFILE ]
    then
        while read LINEREAD
        do
            TMP=`echo $LINEREAD | cut -f 2 -d ":"`
            DATA=`echo $TMP | cut -f 1 -d " "`
            if [ "$DATA" = "127.0.0.1" ]; then
                continue
            fi
            echo "ip ip ip" $DATA >> $IPFILE
        done < $TMPFILE
    fi
    /bin/rm $TMPFILE
fi

get_node_ipinfo()
{
    if [ -s $IPFILE ]
    then
        while read LINEREAD
        do
            echo $LINEREAD > $CURRENTPATH/a.out
            IP=`awk '{print $1}' $CURRENTPATH/a.out`
            if [ "$IP" = "lo0" ]; then 
                continue
            fi
            IP=`awk '{print $3}' $CURRENTPATH/a.out`
            if [ "$IP" = "<Link>" ]; then 
                continue
            fi
            if [ "$IP" = "DLI" ]; then 
                continue
            fi
            if [ "$OS" = "AIX" ]; then
		CHK=`echo $IP | cut -f 1 -d "#"`
		if [ "$CHK" = "link" ]; then 
	           continue
		fi
            fi

            IP=`awk '{print $4}' $CURRENTPATH/a.out`
            CHK=`echo $IP | awk -F. '{if(NF == 4)print "normal"}'`
            if [ "$CHK" = "normal" ]; then
                echo $IP
                exit 0
            fi
        done < $IPFILE
    fi
}
INSTALLDATE=`date +%Y%m%d%H%M%S`
NODEIP=`get_node_ipinfo`
`rm $CURRENTPATH/nodeipinfo.txt $CURRENTPATH/tmp.txt $CURRENTPATH/a.out 2> /dev/null`
if [ "$PARAMETER" = "IP" ]; then
    echo $NODEIP
else
    echo $INSTALLDATE
fi
