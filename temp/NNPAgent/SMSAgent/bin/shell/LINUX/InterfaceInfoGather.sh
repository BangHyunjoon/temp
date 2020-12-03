#!/bin/sh
#Copyright¨ÏNKIA Co., Ltd.
LANG=C;export LANG

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LIN_TYPE=0 
UBUNTUCHK=0
if [ -f /etc/lsb-release ] ; then
    UBUNTUCHK=`grep -i ubuntu /etc/lsb-release | wc -l`
fi
if [ $UBUNTUCHK -ge 1 ] ; then
    LIN_TYPE=1
fi

if [ -f /etc/sysconfig/network/ifcfg-lo ]; then
    searchdir="/etc/sysconfig/network/ifcfg-*"
elif [ -f /etc/sysconfig/network-scripts/ifcfg-lo ]; then
    searchdir="/etc/sysconfig/network-scripts/ifcfg-*"
fi

if [ ! -z "$searchdir" ]; then 
    ifname=`ls -al $searchdir | awk -F"/" '{print $NF}' | awk -F"ifcfg-" '{print $NF}' 2> /dev/null | grep -v "lo"`
else
    ifname=`netstat -in | egrep -iv "Kernel|Iface|lo0|lo" | grep [a-zA-Z] | awk '{print $1}'`
fi

for name in `echo $ifname`
do
    ##bandwidth
    ethtool $name 2> /dev/null > ./ifresult.txt
    value=`grep -i "Speed:" ./ifresult.txt | awk '{print $2}' | awk -F"Mb" '{print $1}' `
    if [ ! -z "$value" ]; then
        chk=`echo $value | grep -i "Unknown" | wc -l`
        if [ $chk -eq 0 ]; then
            #bandwidth=`expr $value \* 1000`
            #bandwidth=`echo "$value * 1000" | bc`
            bandwidth=$value"000"
        else
            bandwidth=0
        fi
    else
        bandwidth=0
    fi

    if [ $bandwidth -eq 0 ] ; then
        if [ -f /sys/class/net/$name/speed ] ; then
            bandwidth_temp=`cat /sys/class/net/$name/speed`
            if [ $bandwidth_temp -le -1 ] ; then
                bandwidth=0
            else
                bandwidth=$bandwidth_temp"000"
            fi
        fi
    fi

    ##duplex
    dupcheck=`grep "Duplex" ./ifresult.txt | wc -l`
    if [ $dupcheck -eq 1 ] ; then
        str_duplex=`grep Duplex ./ifresult.txt | awk '{print $2}'`
    else
        str_duplex="UNKNOWN"
    fi

    echo $name"|"$bandwidth"|"$str_duplex
    #echo $name"|"$bandwidth
done
#\rm ./ifresult.txt 2> /dev/null
