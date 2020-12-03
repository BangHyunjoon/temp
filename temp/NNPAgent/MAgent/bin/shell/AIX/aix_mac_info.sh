#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#NETSTAT_NI_FILE=../aproc/shell/netstat_ni.dat
NETSTAT_NI_FILE=./netstat_ni.dat
TMP_CMD=`netstat -ni > $NETSTAT_NI_FILE`

MAC_INFO=""
MAC_INFO_SAVE=""
MAC_INFO_TEMP=""
NIC_INFO=""
NIC_INFO_SAVE=""
IP_INFO=""
UPDOWN_INFO=""
UPDOWN_CHECK=0
MAC_CHECK=0

while read line
do
    #echo ">> $line <<"
    MAC_INFO=`echo $line | grep "link" | cut -d' ' -f4 | awk '{print $1}' | grep '\.'`

    #echo "MAC:$MAC_INFO_SAVE, NIC:$NIC_INFO_SAVE, IP:$IP_INFO"

    if [ "$MAC_INFO" = "" ] ; then
        MAC_INFO=""
        if [ "$MAC_INFO_SAVE" = "" ] ; then
            MAC_INFO_SAVE=""
        else
            if [ "$NIC_INFO_SAVE" = "" ] ; then
                NIC_INFO_SAVE=""
            else
                IP_INFO=`echo $line | grep "$NIC_INFO" | cut -d' ' -f4 | awk '{print $1}'`
                #echo "==>MAC:$MAC_INFO_SAVE, NIC:$NIC_INFO_SAVE, IP:$IP_INFO"
                MAC_INFO_SAVE=`echo "$MAC_INFO_SAVE" | tr -s "[:lower:]" "[:upper:]" | tr -s "." ":" | awk '{print $1}'`
                MAC_INFO_TEMP=""
                for MAC_CH1 in `echo "$MAC_INFO_SAVE" | awk -F':' '{for(a=1;a<=6;a++)print $a}'`
                do
                    #echo "MAC_CH1=$MAC_CH1"
                    if [ "$MAC_INFO_TEMP" = "" ] ; then
                        MAC_CHECK=`echo "$MAC_CH1" | wc -c | awk '{print $1}'`
                        if [ "$MAC_CHECK" = "2" ] ; then
                            MAC_INFO_TEMP="0$MAC_CH1"
                        else
                            MAC_INFO_TEMP="$MAC_CH1"
                        fi
                    else
                        MAC_CHECK=`echo "$MAC_CH1" | wc -c | awk '{print $1}'`
                        if [ "$MAC_CHECK" = "2" ] ; then
                            MAC_INFO_TEMP="$MAC_INFO_TEMP:0$MAC_CH1"
                        else
                            MAC_INFO_TEMP="$MAC_INFO_TEMP:$MAC_CH1"
                        fi
                    fi
                done
                MAC_INFO_SAVE=$MAC_INFO_TEMP

                echo "[$NIC_INFO_SAVE, $IP_INFO, $UPDOWN_INFO]=$MAC_INFO_SAVE"
                MAC_INFO=""
                MAC_INFO_SAVE=""
                NIC_INFO=""
                NIC_INFO_SAVE=""
                IP_INFO=""
            fi
        fi
    else
        MAC_INFO_SAVE=$MAC_INFO
        #NIC_INFO=`echo $line | grep "link" | cut -d' ' -f1 | awk '{print $1}' | tr -s "*" " " | awk '{print $1}'`
        NIC_INFO=`echo $line | grep "link" | cut -d' ' -f1 | awk '{print $1}' | awk '{print $1}'`
        if [ "$NIC_INFO" = "" ] ; then
            NIC_INFO=""
        else
            NIC_INFO_SAVE=`echo $NIC_INFO | tr -s "*" " " | awk '{print $1}'`
            UPDOWN_CHECK=`echo $NIC_INFO | grep "*" | wc -l | awk '{print $1}'`
            if [ "$UPDOWN_CHECK" = "0" ] ; then
                UPDOWN_INFO="UP"
            else
                UPDOWN_INFO="DOWN"
            fi
        fi
    fi

done < $NETSTAT_NI_FILE
