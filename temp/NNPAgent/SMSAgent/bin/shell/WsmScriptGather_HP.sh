#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C

INSTANCE="$1"
CHAIN_ISLAND_LISTS="$2"
FILE_INDEX="$3"

DF_RESULT="../aproc/shell/WsmDF_bdf.out"
PS_EX_RESULT="../aproc/shell/WsmPS_EX.out"
GLANCE_LOOP_FILE="./shell/WsmGlance_loop.txt"
GLANCE_PROC_LIST="../aproc/shell/WsmGlance_proclist.out"
GLANCE_FIND_PID="../aproc/shell/WsmGlance_find_pid_$FILE_INDEX.out"

MEM_RATE="0"
CONN_IDS="-"

chain_island_data()
{
    #echo " -> $CHAIN_ISLAND"
    CHAIN_NAME=`echo $CHAIN_ISLAND | awk -F'[' '{print $1}'`
    ISLAND_COUNT_STR=`echo $CHAIN_ISLAND | awk -F'[' '{print $2}' | awk -F']' '{print $1}'`
    ISLAND_NAME=`echo $ISLAND_COUNT_STR | awk -F'+' '{print $1}' `
    ISLAND_CNT=`echo $ISLAND_COUNT_STR | awk -F'+' '{print $2}' `

    if [ "$ISLAND_NAME" = "__NULL__" ] ; then
        l_strPSFIND_PID=`cat $PS_EX_RESULT | grep $INSTANCE | grep $CHAIN_NAME | grep java | awk '{print $1}'`
        if [[ -z $l_strPSFIND_PID ]] ; then
            sleep 1
            l_strPSFIND_PID=`cat $PS_EX_RESULT | grep $INSTANCE | grep $CHAIN_NAME | grep java | awk '{print $1}'`
        fi

        if [[ -z $l_strPSFIND_PID ]] ; then
            PCPU="0.0"
            MEM="0"
            TRD="0"
        else
            cat $GLANCE_PROC_LIST | grep $l_strPSFIND_PID > $GLANCE_FIND_PID
            l_nFoundFlag=0
            l_nFirstFlag=0
            while read l_strReadBuf
            do 
                l_strPid=`echo $l_strReadBuf | awk '{print $1}'`
                if [ "$l_strPid" = "$l_strPSFIND_PID" ] ; then
                    if [ $l_nFirstFlag -eq 0 ] ; then
                        l_nFirstFlag=1
                        continue 
                    fi
                    l_nFoundFlag=1
                    break
                fi
            done <$GLANCE_FIND_PID
            if [ $l_nFoundFlag -eq 0 ] ; then
                cat $GLANCE_PROC_LIST | grep $l_strPSFIND_PID > $GLANCE_FIND_PID
                l_nFoundFlag=0
                l_nFirstFlag=0
                while read l_strReadBuf
                do 
                    l_strPid=`echo $l_strReadBuf | awk '{print $1}'`
                    if [ "$l_strPid" = "$l_strPSFIND_PID" ] ; then
                        if [ $l_nFirstFlag -eq 0 ] ; then
                            l_nFirstFlag=1
                            continue 
                        fi
                        l_nFoundFlag=1
                        break
                    fi
                done <$GLANCE_FIND_PID
            fi
 
            if [ $l_nFoundFlag -eq 1 ] ; then
                PCPU=`echo $l_strReadBuf | awk '{print $2}'`
                MEM=`echo $l_strReadBuf | awk '{print $3}'`
                mem_flag=`echo $MEM | awk '{print substr($1,length($1)-1)}'`

                if [ "$mem_flag" = "mb" ] ; then
                    MEM=`echo $MEM | awk '{print substr($1,1,length($1)-2)}'`
                else
                    MEM=`echo $MEM | awk '{print substr($1,1,length($1)-2)}'`
                    MEM=`expr $MEM \/ 1024`
                fi
                MEM=`printf "%.0f\n" $MEM`
                TRD=`echo $l_strReadBuf | awk '{print $4}'`
            else
                PCPU="0.0"
                MEM="0"
                TRD="0"
            fi

            if [[ -z $PCPU ]] ; then PCPU="0.0" ; fi
            if [[ -z $MEM ]] ; then MEM="0" ; fi
            if [[ -z $TRD ]] ; then TRD="0" ; fi
        fi
        echo "CHAIN_S:"$CHAIN_NAME,"-","-",$PCPU,$MEM,$MEM_RATE,$TRD
    else
        if [ $ISLAND_CNT -ge 1 ] ; then
            l_nArrayIndex=1
            while [ $l_nArrayIndex -le $ISLAND_CNT ]
            do
                FULL_ISLAND_NAME=$CHAIN_NAME"."$ISLAND_NAME"."$l_nArrayIndex
                l_nArrayIndex=`expr $l_nArrayIndex + 1`

                l_strPSFIND_PID=`cat $PS_EX_RESULT | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME | grep java | awk '{print $1}'`
                if [[ -z $l_strPSFIND_PID ]] ; then
                    sleep 1
                    l_strPSFIND_PID=`cat $PS_EX_RESULT | grep $INSTANCE | grep $CHAIN_NAME | grep $FULL_ISLAND_NAME | grep java | awk '{print $1}'`
                fi

                if [[ -z $l_strPSFIND_PID ]] ; then
                    PCPU="0.0"
                    MEM="0"
                    TRD="0"
                else
                    cat $GLANCE_PROC_LIST | grep $l_strPSFIND_PID > $GLANCE_FIND_PID
                    l_nFoundFlag=0
                    l_nFirstFlag=0
                    while read l_strReadBuf
                    do
                        l_strPid=`echo $l_strReadBuf | awk '{print $1}'`
                        if [ "$l_strPid" = "$l_strPSFIND_PID" ] ; then
                            if [ $l_nFirstFlag -eq 0 ] ; then
                                l_nFirstFlag=1
                                continue
                            fi
                            l_nFoundFlag=1
                            break
                        fi
                    done <$GLANCE_FIND_PID
                    if [ $l_nFoundFlag -eq 0 ] ; then
                        cat $GLANCE_PROC_LIST | grep $l_strPSFIND_PID > $GLANCE_FIND_PID
                        l_nFoundFlag=0
                        l_nFirstFlag=0
                        while read l_strReadBuf
                        do
                            l_strPid=`echo $l_strReadBuf | awk '{print $1}'`
                            if [ "$l_strPid" = "$l_strPSFIND_PID" ] ; then
                                if [ $l_nFirstFlag -eq 0 ] ; then
                                    l_nFirstFlag=1
                                    continue
                                fi
                                l_nFoundFlag=1
                                break
                            fi
                        done <$GLANCE_FIND_PID
                    fi
         
                    if [ $l_nFoundFlag -eq 1 ] ; then
                        PCPU=`echo $l_strReadBuf | awk '{print $2}'`
                        MEM=`echo $l_strReadBuf | awk '{print $3}'`
                        mem_flag=`echo $MEM | awk '{print substr($1,length($1)-1)}'`
                        if [ "$mem_flag" = "mb" ] ; then
                            MEM=`echo $MEM | awk '{print substr($1,1,length($1)-2)}'`
                        else
                            MEM=`echo $MEM | awk '{print substr($1,1,length($1)-2)}'`
                            MEM=`expr $MEM \/ 1024`
                        fi
                        MEM=`printf "%.0f\n" $MEM`
                        TRD=`echo $l_strReadBuf | awk '{print $4}'`

                        conn_flag=`echo $l_strPSFIND |  grep $INSTANCE | grep $CHAIN_NAME | grep Dsm.conids | wc -l`
                        CONN_IDS="-"
                        if [ $conn_flag -eq 1 ] ; then
                             CONN_IDS=`echo $l_strReadBuf | grep Dsm.conids | awk -F'Dsm.conids=' '{print $2}' | awk '{print $1}'`
                        fi
                    else
                        PCPU="0.0"
                        MEM="0"
                        TRD="0"
                    fi
                fi

                if [[ -z $PCPU ]] ; then PCPU="0.0" ; fi
                if [[ -z $MEM ]] ; then MEM="0" ; fi
                if [[ -z $TRD ]] ; then TRD="0" ; fi
                echo "CHAIN_S:"$CHAIN_NAME,$FULL_ISLAND_NAME,$CONN_IDS,$PCPU,$MEM,$MEM_RATE,$TRD
            done
        else
            echo "CHAIN_S:-,-,0.0,0,0,0"
        fi




    fi

}

############### main start
##instance
FS_ENGINE=`cat $DF_RESULT | grep $INSTANCE | grep -v LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
FS_LOG=`cat $DF_RESULT | grep $INSTANCE | grep LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
if [[ -z $FS_ENGINE ]] ; then
    sleep 1
    FS_ENGINE=`cat $DF_RESULT | grep $INSTANCE | grep -v LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
fi
if [[ -z $FS_LOG ]] ; then
    sleep 1
    FS_LOG=`cat $DF_RESULT | grep $INSTANCE | grep LOG | awk '{print $1","$5}' | sed -e 's/%//g'`
fi
echo "FILE_SYSTEMS:"$FS_ENGINE
echo "FILE_SYSTEMS:"$FS_LOG


HTTP_COUNT=`cat $PS_EX_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
if [[ -z $HTTP_COUNT ]] ; then 
    sleep 1
    HTTP_COUNT=`cat $PS_EX_RESULT | grep httpd | grep -v grep | grep -c $INSTANCE`
fi
echo "HTTP_CNT:"$HTTP_COUNT

##chain
CHAIN_ISLAND_LISTS=`echo $CHAIN_ISLAND_LISTS | sed -e 's/,/ /g'`
for CHAIN_ISLAND in $CHAIN_ISLAND_LISTS
do
    chain_island_data
done

exit 0

##db connection data
for DB_PORT in $DBCONNLISTS
do
    dbconn_data
done


#./a.sh III ch1,ch2,ch3 10.132.11.151:1851,10.132.11.152:1852

