#!/bin/sh
LANG=C;export LANG=C

for name in `ifconfig -a | grep flags | cut -d ':' -f1 | grep -v lo0`
do
    l_check=`echo $name | grep ":" | wc -l`
    if [ $l_check -eq 1 ] ; then
        continue
    fi
    entstat -d $name 2> /dev/null > ./ifresult.txt
    value=`grep -i "Media Speed Running" ./ifresult.txt | head -1`
    if [ ! -z "$value" ]; then
        bandwidth=`echo $value | awk '{if($5=="Mbps")print $4*1000;else print $4*1000*1000}'`
        l_Dupcheck=`echo $value | grep -i Full | wc -l`
        if [ $l_Dupcheck -eq 1 ]; then
            duplex_result="Full"
        else
            duplex_result="Half"
        fi
    else
        #Physical Port Speed: 10Gbps Full Duplex
        value=`grep -i "Physical Port Speed" ./ifresult.txt | head -1`
        if [ ! -z "$value" ]; then
            l_1check=`echo $value | grep " Gbps" | wc -l`
            if [ $l_1check -eq 1 ] ; then
                t_band=`echo $value | awk '{print $4}' `
                bandwidth=`echo $t_band | awk '{print $1 *1000*1000}'`
            else
                t_band=`echo $value | awk '{print $4}' `
                l_check=`echo $t_band  | grep Gbps | wc -l`
                if [ $l_check -eq 1 ] ; then
                    bandwidth=`echo $t_band | awk -F'G' '{print $1 *1000*1000}'`
                else
                    t_band=`echo $value | awk '{print $4}' `
                    l_check=`echo $t_band  | grep Mbps | wc -l`
                    if [ $l_check -eq 1 ] ; then
                        bandwidth=`echo $t_band | awk -F'M' '{print $1*1000}'`
                    else
                        bandwidth=0
                    fi
                fi
            fi
        else
            bandwidth=0
        fi
    fi

    value=`grep -i "Hardware Address:" ./ifresult.txt | head -1`
    if [ ! -z "$value" ]; then
        macaddr=`echo $value | awk '{print $3}`
    else
        macaddr=UNKNOWN
    fi    
    value=`grep -i "Device Type:" ./ifresult.txt | head -1`
    if [ ! -z "$value" ]; then
        type=`echo $value | awk -F": " '{print $2}'`
    else
        type=Ethernet
    fi     
    echo $name"|"$bandwidth"|"$macaddr"|"$type"|"$duplex_result
done

