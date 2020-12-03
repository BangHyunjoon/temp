#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=en
export LANG

#result=`entstat -d $1 | grep "Media Speed Running" | head -1`
#echo $result  | awk '{if($5=="Mbps")print $4;else print $4*1000}' > $2

entstat -d $1 > ./entstat_aix.txt

    value=`grep -i "Media Speed Running" ./entstat_aix.txt | head -1`
    if [ ! -z "$value" ]; then
        bandwidth=`echo $value | awk '{if($5=="Mbps")print $4;else print $4*1000}'`
    else
        #Physical Port Speed: 10Gbps Full Duplex
        value=`grep -i "Physical Port Speed" ./entstat_aix.txt | head -1`
        if [ ! -z "$value" ]; then
            t_band=`echo $value | awk '{print $4}' `
            l_check=`echo $t_band  | grep Gbps | wc -l`
            if [ $l_check -eq 1 ] ; then
                bandwidth=`echo $t_band | awk -F'G' '{print $1 *1000}'`
            else
                t_band=`echo $value | awk '{print $4}' `
                l_check=`echo $t_band  | grep Mbps | wc -l`
                if [ $l_check -eq 1 ] ; then
                    bandwidth=`echo $t_band | awk -F'M' '{print $1 }'`
                else
                    bandwidth=0
                fi
            fi
        else
            bandwidth=0
        fi
    fi

echo $bandwidth




