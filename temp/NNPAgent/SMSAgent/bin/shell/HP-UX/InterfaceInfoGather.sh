#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/opt/VRTS/bin
export PATH

LANG=C
export LANG

LANSCAN_FILE="../aproc/shell/inv_lanscan.out"
IFCONFIG_FILE="../aproc/shell/inv_ifconfig.out"

bccmdchk=1
command=`which bc 2> /dev/null | grep -v "no" | wc -l`
if [ $command -eq 0 ]; then
    bccmdchk=0
fi

RELEASE1=`uname -r | awk -F'.' '{print $2}'`
RELEASE2=`uname -r | awk -F'.' '{print $3}'`
if [ $RELEASE1 -ge 12 -o $RELEASE2 -ge 23 ] ; then
    NETSTAT_CMD="netstat -inw"
else
    NETSTAT_CMD="netstat -in"
fi

changenetmask() {
    subnetmask=""
    oldnetmask=$1
    if [ "$oldnetmask" = "ffff0000" ]; then
        subnetmask="255.255.0.0"
    elif [ "$oldnetmask" = "ffffff00" ]; then
        subnetmask="255.255.255.0"
    elif [ "$oldnetmask" = "ffffffff" ]; then
        subnetmask="255.255.255.255"
    elif [ "$oldnetmask" = "ff000000" ]; then
        subnetmask="255.0.0.0"    
    elif [ "$oldnetmask" = "fffffe00" ]; then
        subnetmask="255.255.254.0" 
    elif [ "$oldnetmask" = "ffffff80" ]; then
        subnetmask="255.255.255.80" 
    else
        subnetmask=0  
    fi
    return $subnetmask
}

    lanscan 2> /dev/null | grep [0-9] > $LANSCAN_FILE
    #for name in `grep ^INTERFACE_NAME /etc/rc.config.d/netconf | awk -F= '{print $2}'`
    for name in `eval $NETSTAT_CMD | egrep -iv "Address|lo0|Warning" | awk '{print $1}'`
    do
        l_check=`echo $name | grep ":" | wc -l`
        if [ $l_check -eq 1 ] ; then
            continue
        fi
        card=`grep -i "$name snap" $LANSCAN_FILE | awk '{print $3}'`
        result=`ifconfig $name 2> /dev/null | egrep -v "inet6" > $IFCONFIG_FILE`
        value=`grep "<UP" $IFCONFIG_FILE | wc -l`
        if [ $value -ne 0 ]; then
            managed="1"
        else
            managed="0"
        fi
        value=`lanadmin -m $card 2> /dev/null | awk '{print $NF}'`
        if [ ! -z "$value" ]; then
            mtu=$value
        else
            mtu="-"
        fi   
        value=`lanadmin -a $card 2> /dev/null | awk '{print $NF}'`
        if [ ! -z "$value" ]; then
            mac1=`expr substr $value 3 2`
            mac2=`expr substr $value 5 2`
            mac3=`expr substr $value 7 2`
            mac4=`expr substr $value 9 2`
            mac5=`expr substr $value 11 2`
            mac6=`expr substr $value 13 2`    
            macaddr=$mac1":"$mac2":"$mac3":"$mac4":"$mac5":"$mac6
        else
            macaddr="-"
        fi 
        value=`grep -i "inet" $IFCONFIG_FILE | awk '{print $2}'`
        if [ ! -z "$value" ]; then
            ip=$value
            ip=`echo $ip | sed -e 's/ /,/g'`          
        else
            ip="-"
            continue
        fi 
        value=`grep -i "inet" $IFCONFIG_FILE | awk '{print $4}'`
        if [ ! -z "$value" ]; then
            changenetmask "$value"
            netmask=$subnetmask
            #netmask=$value
            if [ "$netmask" = "0" ]; then
                netmask="-"
            fi
        else
            netmask="-"
        fi
        value=`lanadmin -s $card 2> /dev/null | awk '{print $NF}'`
        if [ ! -z "$value" ]; then
            if [ $value -eq 0 ]; then
                bandwidth=$value
            else
                if [ $bccmdchk -eq 0 ]; then
                    bandwidth=`expr $value / 1000`
                else
                    bandwidth=`echo "$value / 1000" | bc`
                fi
            fi
        else
            bandwidth="-"
        fi    
        Duplex="-"
        value=`lanadmin -x $card 2> /dev/null`
        if [ ! -z "$value" ]; then
            fdchk=`echo $value | grep -i Full | wc -l`
            if [ $fdchk -ne 0 ]; then
                Duplex="Full"
            fi
            hdchk=`echo $value | grep -i Half | wc -l`
            if [ $hdchk -ne 0 ]; then
                Duplex="Half"
            fi
        fi  
        #echo $name"|"$bandwidth"|"$ip"|"$macaddr"|"$managed"|"$mtu"|"$netmask"|"$Duplex
        #echo $name"|"$managed"|"$macaddr"|"$ip"|"$netmask"|""N/S""|"$bandwidth"|"$mtu"|""N/S"
        echo $name"|"$managed"|"$macaddr"|"$ip"|"$netmask"|""N/S""|"$bandwidth"|"$mtu"|""N/S""|"$Duplex
    done



