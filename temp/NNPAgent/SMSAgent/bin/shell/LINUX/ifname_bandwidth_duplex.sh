#!/bin/sh
#Copyright¨ÏNKIA Co., Ltd.
LANG=C;export LANG

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

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

    dupcheck=`grep Duplex ./ifresult.txt | grep -i full| wc -l`
    if [ $dupcheck -eq 1 ] ; then
        duplex_return=1
    else
        dupcheck=`echo $arg_string | grep -i half | wc -l`
        if [ $dupcheck -eq 1 ] ; then
            duplex_return=2
        else
            duplex_return=0
        fi
    fi
    if [ -z $duplex_return ] ; then
        duplex_return=0
    fi


    echo "NKIASC|"$name"|"$bandwidth"|"$duplex_return
done
\rm ./ifresult.txt 2> /dev/null
