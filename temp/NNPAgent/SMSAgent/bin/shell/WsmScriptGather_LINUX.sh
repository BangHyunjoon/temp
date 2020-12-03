#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C

DF_RESULT="../aproc/shell/WsmDF_p.out"
PS_AUXWW_RESULT="../aproc/shell/WsmPS_AUXWW.out"
PS_ELFWW_RESULT="../aproc/shell/WsmPS_ELFWW.out"
PS_EMWWW_RESULT="../aproc/shell/WsmPS_emwww.out"
NETSTAT_RESULT="../aproc/shell/WsmNetstat.out"

INSTANCE="$1"
CHAIN_ISLAND_LISTS="$2"
MEM_RATE="0"
CONN_IDS="-"
NODE_NAME=`uname -n`
NODE_NAME1=`echo $NODE_NAME | tr '[A-Z]' '[a-z]'`
NODE_NAME2=`echo $NODE_NAME | tr '[a-z]' '[A-Z]'`



chain_island_data()
{
    #echo " -> $CHAIN_ISLAND"
    CHAIN_NAME=`echo $CHAIN_ISLAND | awk -F'[' '{print $1}'`
    ISLAND_COUNT_STR=`echo $CHAIN_ISLAND | awk -F'[' '{print $2}' | awk -F']' '{print $1}'`
    ISLAND_NAME=`echo $ISLAND_COUNT_STR | awk -F'+' '{print $1}' ` 
    ISLAND_CNT=`echo $ISLAND_COUNT_STR | awk -F'+' '{print $2}' `

    PCPU=0.0
    MEM=0
    TRD=0

    if [ "$ISLAND_NAME" = "__NULL__" ] ; then
        l_strPSFIND=`cat $PS_AUXWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep java `
        if [[ -z $l_strPSFIND ]] ; then
            sleep 1
            l_strPSFIND=`cat $PS_AUXWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep java`
        fi

        PCPU=`echo $l_strPSFIND | awk '{print $3}'`
        MEM=`echo $l_strPSFIND | awk '{print $6}'`
        if [[ -n $MEM ]] ; then
            if [ $MEM -ge 1024 ] ; then
                MEM=`expr $MEM \/ 1024`
            else
                MEM="0"
            fi
        fi
        TRD=`cat $PS_ELFWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | wc -l`
        if [[ -z $TRD ]] ; then
            sleep 1
            TRD=`cat $PS_ELFWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | wc -l`
        fi
        if [ $TRD -eq 0 ] ; then
            TRD=`cat $PS_EMWWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | wc -l`
            if [[ -z $TRD ]] ; then
                sleep 1
                TRD=`cat $PS_EMWWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | wc -l`

            fi
        fi



        #if [[ -z $CHAIN_NAME ]] ; then CHAIN_NAME="-" ; fi
        if [[ -z $PCPU ]] ; then PCPU="0.0" ; fi
        if [[ -z $MEM ]] ; then MEM="0" ; fi
        if [[ -z $TRD ]] ; then TRD="0" ; fi

        echo "CHAIN_S:"$CHAIN_NAME,"-","-",$PCPU,$MEM,$MEM_RATE,$TRD
    else
        if [ $ISLAND_CNT -ge 1 ] ; then
            l_nArrayIndex=1
            while [ $l_nArrayIndex -le $ISLAND_CNT ]
            do
                PCPU=0.0
                MEM=0
                TRD=0

                FULL_ISLAND_NAME=$CHAIN_NAME"."$ISLAND_NAME"."$l_nArrayIndex
                #echo "FULL_ISLAND_NAME="$FULL_ISLAND_NAME

                l_nArrayIndex=`expr $l_nArrayIndex + 1` 
                l_strPSFIND=`cat $PS_AUXWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME |  grep java`
                if [[ -z $l_strPSFIND ]] ; then
                    sleep 1
                    l_strPSFIND=`cat $PS_AUXWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME |  grep java`
                fi
                PCPU=`echo $l_strPSFIND | awk '{print $3}'`
                MEM=`echo $l_strPSFIND | awk '{print $6}'`
                if [[ -n $MEM ]] ; then
                    if [ $MEM -ge 1024 ] ; then
                        MEM=`expr $MEM \/ 1024`
                    else
                        MEM="0"
                    fi
                fi

                TRD=`cat $PS_ELFWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME |  wc -l`
                if [[ -z $TRD ]] ; then
                    sleep 1
                    TRD=`cat $PS_ELFWW_RESULT |  egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME |  wc -l`
                fi
                if [ $TRD -eq 0 ] ; then
                    TRD=`cat $PS_EMWWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME | wc -l`
                    if [[ -z $TRD ]] ; then
                        sleep 1
                        TRD=`cat $PS_EMWWW_RESULT | egrep -e weblogic.Name -e Doracle.home -e jeus -e ":"$CHAIN_NAME | grep $INSTANCE | grep $CHAIN_NAME | grep grep $FULL_ISLAND_NAME | wc -l`

                    fi
                fi

                conn_found_flag=0
                conn_flag=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Dsm.conids=" | wc -l` 
                CONN_IDS="-"
                if [ $conn_flag -eq 1 ] ; then
                    CONN_IDS=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Dsm.conids=" | awk -F'Dsm.conids=' '{print $2}' | awk '{print $1}'`
                    conn_found_flag=1
                else
                    conn_flag=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Dsm.property=" | wc -l`
                    CONN_IDS="-"
                    CONN_FILE="-"
                    if [ $conn_flag -eq 1 ] ; then
                        CONN_FILE=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Dsm.property=" | awk -F'Dsm.property=' '{print $2}' | awk '{print $1}'`
                        CONN_IDS=`cat $CONN_FILE | grep "container.id=" | awk -F'container.id=' '{print $2}' | awk '{print $1}'`
                        conn_found_flag=1
                    else
                        conn_flag=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Djennifer.config=" | wc -l`
                        CONN_IDS="-"
                        CONN_FILE="-"
                        if [ $conn_flag -eq 1 ] ; then
                            CONN_FILE=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep "Djennifer.config=" | awk -F'Djennifer.config=' '{print $2}' | awk '{print $1}'`
                            CONN_IDS=`cat $CONN_FILE | grep "agent_name" | awk -F'=' '{print $2}' | awk '{print $1}'`
                            conn_found_flag=1
                        fi
                    fi
                fi
                if [ $conn_found_flag -eq 0 ] ; then #20150420 add
                    l_strTmpName1="Dsm.conids."$NODE_NAME1"="
                    conn_flag=`echo $l_strPSFIND | grep $INSTANCE | grep $CHAIN_NAME | grep $l_strTmpName1 | wc -l` 
                    CONN_IDS="-"
                    if [ $conn_flag -eq 1 ] ; then
                        CONN_IDS=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep $l_strTmpName1 |awk -F''$l_strTmpName1'' '{print $2}' | awk '{print $1}'`
                        conn_found_flag=1
                    fi
                fi
                if [ $conn_found_flag -eq 0 ] ; then #20150420 add
                    l_strTmpName2="Dsm.conids."$NODE_NAME2"="
                    conn_flag=`echo $l_strPSFIND | grep $INSTANCE | grep $CHAIN_NAME | grep $l_strTmpName2 | wc -l` 
                    CONN_IDS="-"
                    if [ $conn_flag -eq 1 ] ; then
                        CONN_IDS=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep $l_strTmpName2 |awk -F''$l_strTmpName2'' '{print $2}' | awk '{print $1}'`
                        conn_found_flag=1
                    fi
                fi

                CONN_IDS=`echo $CONN_IDS | sed -e 's/ /:/g'`
                echo "CHAIN_S:"$CHAIN_NAME,$FULL_ISLAND_NAME,$CONN_IDS,$PCPU,$MEM,$MEM_RATE,$TRD
                   
            done
        else
            echo "CHAIN_S:-,-,-,0.0,0,0,0"
        fi
    fi
}

dbconn_data()
{
    DBConCnt=`cat $NETSTAT_RESULT | grep $DB_PORT | grep -c EST`
    if [[ -z $DBConCnt ]] ; then DBConCnt="0" ; fi
    echo "DBCONN_S:"$DB_PORT","$DBConCnt
}



############### main start

##instance
FS_ENGINE=`cat $DF_RESULT | grep $INSTANCE | grep -v LOG | awk '{print $6","$5}' | sed -e 's/%//g'`
FS_LOG=`cat $DF_RESULT | grep $INSTANCE | grep LOG | awk '{print $6","$5}' | sed -e 's/%//g'`
if [[ -z $FS_ENGINE ]] ; then 
    sleep 1
    FS_ENGINE=`cat $DF_RESULT | grep $INSTANCE | grep -v LOG | awk '{print $6","$5}' | sed -e 's/%//g'`
fi
if [[ -z $FS_LOG ]] ; then 
    sleep 1
    FS_LOG=`cat $DF_RESULT | grep $INSTANCE | grep LOG | awk '{print $6","$5}' | sed -e 's/%//g'`
fi
if [[ -z $FS_ENGINE ]] ; then FS_ENGINE="-,0" ; fi
if [[ -z $FS_LOG ]] ; then FS_LOG="-,0" ; fi
echo "FILE_SYSTEMS:"$FS_ENGINE
echo "FILE_SYSTEMS:"$FS_LOG

HTTP_COUNT=`cat $PS_ELFWW_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
if [[ -z $HTTP_COUNT ]] ; then
    sleep 1
    HTTP_COUNT=`cat $PS_ELFWW_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
fi
if [ $HTTP_COUNT -eq 0 ] ; then
    HTTP_COUNT=`cat $PS_EMWWW_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
    if [[ -z $HTTP_COUNT ]] ; then
        sleep 1
        HTTP_COUNT=`cat $PS_EMWWW_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
    fi
fi

if [ $HTTP_COUNT -eq 0 ] ; then
    l_nWebtobFlag=`cat $PS_AUXWW_RESULT | grep jeus | grep java | grep $INSTANCE | wc -l`
    if [ $l_nWebtobFlag -ge 1 ] ; then
        l_strWebtobUser=`cat $PS_AUXWW_RESULT | grep jeus | grep java | grep $INSTANCE | head -1 | awk '{print $1}'`
        HTTP_COUNT=`cat $PS_AUXWW_RESULT | grep $l_strWebtobUser | grep -v $l_strWebtobUser[0123456789abcdefghijklmnopqrstuvwxyz] | grep hth | wc -l`
    else
        HTTP_COUNT="0"
    fi
fi
if [[ -z $HTTP_COUNT ]] ; then HTTP_COUNT="0" ; fi
echo "HTTP_CNT:"$HTTP_COUNT


##chain
CHAIN_ISLAND_LISTS=`echo $CHAIN_ISLAND_LISTS | sed -e 's/,/ /g'`
for CHAIN_ISLAND in $CHAIN_ISLAND_LISTS
do
    chain_island_data
done

##db connection data
#for DB_PORT in $DBCONNLISTS
#do
#    dbconn_data
#done


#./a.sh III ch1,ch2,ch3 10.132.11.151:1851,10.132.11.152:1852
# ./shell/WsmScriptGather_LINUX.sh local S1A020[default_island+4],P20[default_island+4]
# ./shell/WsmScriptGather_LINUX.sh local S1A020[default_island+4],P20[default_island+4],P20[__NULL__+0]


