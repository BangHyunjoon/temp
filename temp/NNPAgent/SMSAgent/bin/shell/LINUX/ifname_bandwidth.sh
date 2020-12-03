#!/bin/sh
#Copyright¨ÏNKIA Co., Ltd.

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

if [ -f ./result.txt ] ; then
    unlink ./result.txt 2> /dev/null
fi

for name in `ifconfig -a  | grep -i link | awk '{print $1}' | egrep -v "lo|inet6"`
do
    ifconfig $name 2> /dev/null > ./result.txt
    value=`cat ./result.txt | grep -i "inet addr" | wc -l`
    if [ $value -eq 1 ]; then
        hwaddr=`cat ./result.txt | grep -i Link | awk '{print $5}'`
        bridge="/sys/class/net/$name/bridge"
        bondchk=`echo $name | grep -i bond | awk -F. '{print $1}' | wc -l`
        bond=`echo $name | grep -i bond | awk -F. '{print $1}'`
        if [ -d $bridge ]; then
            for ifname in `ifconfig -a | grep -i $hwaddr | grep -v $name | awk '{print $1}'`
            do
                ret=`ethtool $ifname | grep Mb 2> /dev/null | wc -l`
                if [ $ret -ne 0 ]; then
                    bandwidth=`ethtool $ifname | grep Mb | awk '{print $2}' | awk -F"Mb" '{print ($1*1000)}'`
                    break
                fi
            done
            #echo "bridgeif="$name $bandwidth
            echo $name $bandwidth
        elif [ $bondchk -eq 1 ]; then
            ret=`cat /proc/net/bonding/$bond | grep -i "Currently Active Slave" | awk '{print $4}'`
            bandwidth=`ethtool $ret | grep Mb | awk '{print $2}' | awk -F"Mb" '{print ($1*1000)}'`
            #echo "bond="$name $bandwidth
            echo $name $bandwidth
        else
            bandwidth=`ethtool $name | grep Mb | awk '{print $2}' | awk -F"Mb" '{print ($1*1000)}'`
            #echo "Ethernet="$name $bandwidth
            echo $name $bandwidth
        fi
    fi
done
unlink ./result.txt 2> /dev/null
