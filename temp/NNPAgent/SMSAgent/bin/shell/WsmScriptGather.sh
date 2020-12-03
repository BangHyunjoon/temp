#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C

DF_RESULT="../aproc/shell/WsmDF_p.out"
PS_AUXWW_RESULT="../aproc/shell/WsmPS_AUXWW.out"
PS_ELFWW_RESULT="../aproc/shell/WsmPS_ELFWW.out"
NETSTAT_RESULT="../aproc/shell/WsmNetstat.out"

INSTANCE="$1"
l_strTmpChain="$2"
CHAIN_LISTS=`echo $l_strTmpChain | sed -e 's/,/ /g'`
l_strTmpDBConn="$3"
DBCONNLISTS=`echo $l_strTmpDBConn | sed -e 's/,/ /g'`

#df -P  > $DF_RESULT
#ps auxww > $PS_AUXWW_RESULT
#ps -eLfww > $PS_ELFWW_RESULT
#netstat -an | grep tcp | grep | ESTABLISHED  > $NETSTAT_RESULT

chain_data()
{
    #echo " ----------------> $CHAIN"
    l_strPSFIND=`cat $PS_AUXWW_RESULT | grep $INSTANCE |grep -v grep | grep $CHAIN | grep java`
    PCPU=`echo $l_strPSFIND | awk '{print $3}'`
    #MEM=`echo $l_strPSFIND | awk '{print $6}'`
    MEM=`echo $l_strPSFIND | awk '{print $4}'`
    TRD=`cat $PS_ELFWW_RESULT | grep $INSTANCE |grep -v grep | grep -c $CHAIN`

    if [[ -z $PCPU ]] ; then PCPU="0" ; fi
    if [[ -z $MEM ]] ; then MEM="0" ; fi
    if [[ -z $TRD ]] ; then TRD="0" ; fi

    echo "CHAIN_S:"$CHAIN,$PCPU,$MEM,$TRD
}

dbconn_data()
{
    DBConCnt=`cat $NETSTAT_RESULT | grep $DB_PORT | grep -c EST`
    if [[ -z $DBConCnt ]] ; then DBConCnt="0" ; fi
    echo "DBCONN_S:"$DB_PORT","$DBConCnt
}



############### main start

##instance
FS_ENGINE=`cat $DF_RESULT | grep $INSTANCE | grep -v LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
FS_LOG=`cat $DF_RESULT | grep $INSTANCE | grep LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
if [[ -z $FS_ENGINE ]] ; then FS_ENGINE="-,0" ; fi
if [[ -z $FS_LOG ]] ; then FS_LOG="-,0" ; fi
echo "FILE_SYSTEMS:"$FS_ENGINE
echo "FILE_SYSTEMS:"$FS_LOG

HTTP_COUNT=`cat $PS_AUXWW_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
if [[ -z $HTTP_COUNT ]] ; then HTTP_COUNT="0" ; fi

echo "HTTP_CNT:"$HTTP_COUNT


##chain
for CHAIN in $CHAIN_LISTS
do
    chain_data
done

##db connection data
for DB_PORT in $DBCONNLISTS
do
    dbconn_data
done


#./a.sh III ch1,ch2,ch3 10.132.11.151:1851,10.132.11.152:1852


