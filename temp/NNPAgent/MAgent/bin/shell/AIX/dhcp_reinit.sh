#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

ALT_DSK_CHK=0
CHK_CNT=0

LOG_FILE="/tmp/dhcp_reinit_check.log"
CMD=`rm -f $LOG_FILE`
CMD=`date > $LOG_FILE`
DHCP_CHK=`netstat -ni | grep en | grep -v "link" | grep -v "0.0.0.0" | wc -l | awk '{print $1}'`
EN_NUM=0
EN_NAME="en$EN_NUM"
EN_CHECK=0
while [ "$DHCP_CHK" = "0" ]
do
    let "CHK_CNT = $CHK_CNT + 1"
    CMD=`echo "check...[$CHK_CNT] ==> $DHCP_CHK" >> $LOG_FILE`

    CMD=`ifconfig en0 down`
    CMD=`ifconfig en1 down`
    CMD=`ifconfig en2 down`
    CMD=`rmdev -dl en0`
    CMD=`rmdev -dl en1`
    CMD=`rmdev -dl en2`
    CMD=`cfgmgr`

    EN_NAME="en$EN_NUM"
    EN_CHECK=`ifconfig -a | grep "$EN_NAME:" | wc -l | awk '{print $1}'`
    if [ "$EN_CHECK" = "1" ] ; then
        CMD=`/NCIA/POLESTAR/NNPAgent/MAgent/bin/shell/AIX/set_dhcp.sh >> $LOG_FILE`
    fi

    if [ "$EN_NUM" = "0" ] ; then
        EN_NUM=1
    else
        if [ "$EN_NUM" = "1" ] ; then
            EN_NUM=2
        else
            if [ "$EN_NUM" = "2" ] ; then
                EN_NUM=0
            fi
        fi
    fi

    CMD=`sleep 60`
    DHCP_CHK=`netstat -ni | grep en | grep -v "link" | grep -v "0.0.0.0" | wc -l | awk '{print $1}'`
done


CMD=`echo "check...[$CHK_CNT] ==> $DHCP_CHK" >> $LOG_FILE`
CMD=`echo "dhcp reinit end." >> $LOG_FILE`

CMD=`cat /etc/rc | grep -v rc.dhcp > /etc/rc_`
CMD=`rm -f /etc/rc`
CMD=`mv /etc/rc_ /etc/rc`
CMD=`chmod +x /etc/rc`


exit 0
