#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

LD_LIBRARY_PATH=/lib:/usr/lib
export LD_LIBRARY_PATH
command=`which kstat 2> /dev/null | grep -v "no " | wc -l`

l_nGatherFlag=1
ifname=`/sbin/ifconfig -a 2> /dev/null | grep "<UP" | egrep -v "LOOPBACK" | nawk -F': ' '{print $1}'`
for name in `echo $ifname`
do
    if [ $command -eq 0 ]; then
        #echo "kstat command not found"
        Duplex="UNKNOWN"
    else
        Duplex="UNKNOWN"
        namechk=`echo $name | grep e1000g | wc -l`
        if [ $namechk -eq 1 ]; then
            kstat -p e1000g | grep link_ > ./ifresult.txt
            ifnum=`echo $name | nawk -F'e1000g' '{print $2}' | awk -F':' '{print $1}'`
            namechk="e1000g:"$ifnum":"
            value=`grep $namechk ./ifresult.txt | grep -i "link_duplex" | awk '{print $2}'` 
        else
            value=`kstat -n $name 2> /dev/null | grep -i "link_duplex" | awk '{print $2}'` 
        fi
        if [ ! -z "$value" ]; then
            l_nGatherFlag=2
            if [ $value -eq 2 ]; then
                Duplex="Full"
            elif [ $value -eq 1 ]; then
                Duplex="Half"
            fi
            echo $name"|"$Duplex
        fi 
    fi  
done

if [ $l_nGatherFlag -eq 1 ] ; then
    l_nFoundFlag=1
    /sbin/dladm show-dev > ./ldadm_result.out
    for name in `echo $ifname`
    do
        l_strTmp=`cat ./ldadm_result.out | grep $name | awk '{print $NF}'`
        l_nCheck=`echo $l_strTmp | grep -i full | wc -l`
        if [ $l_nCheck -eq 1 ] ; then
            Duplex="Full"
            l_nFoundFlag=2
        else
            l_nCheck=`echo $l_strTmp | grep -i half | wc -l`
            if [ $l_nCheck -eq 1 ] ; then
                Duplex="Half"
                l_nFoundFlag=2
            fi
        fi
        if [ $l_nFoundFlag -eq 1 ] ; then
            Duplex="UNKNOWN"
        fi
        echo $name"|"$Duplex
    done
fi

