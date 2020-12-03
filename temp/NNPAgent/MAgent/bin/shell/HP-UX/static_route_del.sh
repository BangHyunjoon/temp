#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/static_route_del.dat
S_ROUTE_EXIT=../aproc/shell/static_route_del.exit

CMD=`echo "" > $FILE_DAT`
CMD=`echo "" > $S_ROUTE_EXIT`

ROUTE_CMD=route
COMMAND=`which $ROUTE_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found route info command($ROUTE_CMD)" > ../aproc/shell/static_route_del.dat_err`
    exit 255
fi

#echo "$0 <IP> <NetMask> <GateWay> <MAC_ADDR>"
# route delete -net 10.10.10.0 netmask 255.255.255.0 gw 192.168.0.1
# /etc/rc.net adding..

S_ROUTE_IP="$1"
S_ROUTE_NM="$2"
S_ROUTE_GW="$3"
S_ROUTE_MAC="$4"

CMD=`date > $FILE_DAT`
CMD=`echo "S_ROUTE_IP=$1" >> $FILE_DAT`
CMD=`echo "S_ROUTE_NM=$2" >> $FILE_DAT`
CMD=`echo "S_ROUTE_GW=$3" >> $FILE_DAT`
CMD=`echo "S_ROUTE_MAC=$4" >> $FILE_DAT`

#NIC_NAME=""
#if [ "$S_ROUTE_MAC" ] ; then
#    NIC_NAME=`../../utils/ETC/network_mac | grep $S_ROUTE_MAC |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
#    if [ $NIC_NAME ] ; then
#        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
#    else
#        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
#        exit 255
#    fi
#    #echo "NIC_NAME=[$NIC_NAME]"
#else
#    echo "Not found interface mac addr : $S_ROUTE_MAC" >> $FILE_DAT
#    exit 255
#fi

ROUTE_INDX=0
ROUTE_DELINDX=0
TMP_CMD=1
if [ "$S_ROUTE_IP" ] ; then
    if [ "$S_ROUTE_NM" ] ; then
        if [ "$S_ROUTE_GW" ] ; then
#           if [ "$S_ROUTE_MAC" ] ; then
                S_ROUTE_DEL="route delete net $S_ROUTE_IP netmask $S_ROUTE_NM $S_ROUTE_GW"

                CMD=`echo "Static Route DELETE command : $S_ROUTE_DEL" >> $FILE_DAT`
                TMP_CMD=`$S_ROUTE_DEL 2>&1 >> $FILE_DAT;echo $?`
                CMD=`echo "Static Route DELETE result : $TMP_CMD" >> $FILE_DAT`

                ROUTE_INDX=0
                while [ $ROUTE_INDX -lt 20 ]
                do
                    TMP_CMD=`grep "ROUTE_DESTINATION\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "=\"net $S_ROUTE_IP\"" | wc -l | awk '{print $1}'`
                    if [ "$TMP_CMD" = "0" ] ; then
                        break
                    else
                        ROUTE_DELINDX=`grep "ROUTE_DESTINATION\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "=\"net $S_ROUTE_IP\"" | cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2 | cut -d']' -f1 | awk '{print $1}'`

                        TMP_CMD=`grep "ROUTE_MASK\[$ROUTE_DELINDX\]=\"$S_ROUTE_NM\"" /etc/rc.config.d/netconf | grep -v "^#" |  wc -l | awk '{print $1}'`
                        if [ "$TMP_CMD" = "0" ] ; then
                            break
                        else
                            TMP_CMD=`grep "ROUTE_GATEWAY\[$ROUTE_DELINDX\]=\"$S_ROUTE_GW\"" /etc/rc.config.d/netconf | grep -v "^#" |  wc -l | awk '{print $1}'`
                            if [ "$TMP_CMD" = "0" ] ; then
                                break
                            else
                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_DESTINATION\[$ROUTE_DELINDX\]=\"net $S_ROUTE_IP\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_DESTINATION[$ROUTE_DELINDX]=\"net $S_ROUTE_IP\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_MASK\[$ROUTE_DELINDX\]=\"$S_ROUTE_NM\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_MASK[$ROUTE_DELINDX]=\"$S_ROUTE_NM\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_GATEWAY\[$ROUTE_DELINDX\]=\"$S_ROUTE_GW\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_GATEWAY[$ROUTE_DELINDX]=\"$S_ROUTE_GW\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_COUNT\[$ROUTE_DELINDX\]=\"1\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_COUNT[$ROUTE_DELINDX]=\"1\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_ARGS\[$ROUTE_DELINDX\]=\"\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_ARGS[$ROUTE_DELINDX]=\"\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_SOURCE\[$ROUTE_DELINDX\]=\"\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_SOURCE[$ROUTE_DELINDX]=\"\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                                TMP_CMD=`cat /etc/rc.config.d/netconf | grep -v "^ROUTE_SKIP\[$ROUTE_DELINDX\]=\"\"" > /etc/rc.config.d/netconf_;echo $?`
                                CMD=`echo "Static Route DELETE command deleted(ROUTE_SKIP[$ROUTE_DELINDX]=\"\", /etc/rc.config.d/netconf result : $TMP_CMD" >> $FILE_DAT`
                                if [ "$TMP_CMD" = "0" ] ; then
                                    TMP_CMD=`\rm -f /etc/rc.config.d/netconf;echo $?`
                                    CMD=`echo "/etc/rc.config.d/netconf remove : $TMP_CMD" >> $FILE_DAT`
                                    if [ "$TMP_CMD" = "0" ] ; then
                                        TMP_CMD=`mv /etc/rc.config.d/netconf_ /etc/rc.config.d/netconf;echo $?`
                                        CMD=`echo "/etc/rc.config.d/netconf rename : $TMP_CMD" >> $FILE_DAT`
                                    fi
                                fi

                            fi
                        fi
                    fi
                    let "ROUTE_INDX = $ROUTE_INDX + 1"
                done
#           else 
#               CMD=`echo "ERROR : Static Route MAC info not found." >> $FILE_DAT`
#           fi
        else 
            CMD=`echo "ERROR : Static Route GateWay info not found." >> $FILE_DAT`
        fi
    else 
        CMD=`echo "ERROR : Static Route NetMask info not found." >> $FILE_DAT`
    fi
else 
    CMD=`echo "ERROR : Static Route Destination IP info not found." >> $FILE_DAT`
fi

CMD=`echo "$TMP_CMD" > $S_ROUTE_EXIT`

if [ "$TMP_CMD" = "0" ] ; then
    exit 0
else
    exit 255
fi

