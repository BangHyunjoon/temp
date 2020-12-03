#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=en
export LANG

#result=`entstat -d $1 | grep "Media Speed Running" | head -1`
#echo $result  | awk '{if($5=="Mbps")print $4;else print $4*1000}' > $2

#entstat -d $1 | grep "Media Speed Running" | cut -d ' ' -f4 > $2

for name in `ifconfig -a | grep flags | cut -d ':' -f1 | grep -v lo0`
do
    entstat -d $name 2> /dev/null > ./ifresult.txt
    ##bandwidth
    value=`grep -i "Media Speed Running" ./ifresult.txt | head -1`
    if [ ! -z "$value" ]; then
        bandwidth=`echo $value | awk '{if($5=="Mbps")print $4*1000;else print $4*1000*1000}'`
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

    value=`grep -i "Media Speed Running" ./ifresult.txt | head -1`
    if [ ! -z "$value" ]; then
        l_check=`grep -i "Media Speed Running" ./ifresult.txt | head -1 | grep -i Full | wc -l`
        if [ $l_check -eq 1 ]; then
            duplex_result=1
        else
            duplex_result=2
        fi
    else
        #Physical Port Speed: 10Gbps Full Duplex
        value=`grep -i "Physical Port Speed" ./ifresult.txt | head -1`
        if [ ! -z "$value" ]; then
            l_check=`grep -i "Physical Port Speed" ./ifresult.txt | head -1 | grep -i Full | wc -l`
            if [ $l_check -eq 1 ]; then
                duplex_result=1
            else
                duplex_result=2
            fi
        fi
    fi

    echo "NKIASC|"$name"|"$bandwidth"|"$duplex_result
done
