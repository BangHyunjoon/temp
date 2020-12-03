#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

lanscan 2> /dev/null | grep [0-9] > ./lanscan.txt
#for name in `grep ^INTERFACE_NAME /etc/rc.config.d/netconf | awk -F= '{print $2}'`
for name in `netstat -in | egrep -iv "Address|lo0|Warning" | awk '{print $1}'`
do
    name=`echo $name | sed -e 's/\"//g'`
    card=`grep -i "$name snap" ./lanscan.txt | awk '{print $3}'`

    ##bandwidth
    value=`lanadmin -s $card 2> /dev/null | awk '{print $NF}'`
    if [ ! -z "$value" ]; then
        if [ $value -eq 0 ]; then
            bandwidth=$value
        else
            #bandwidth=`expr $value / 1000`
            bandwidth=`echo "$value / 1000" | bc`
        fi
    else
        bandwidth=0
    fi 
  
    ##duplex
    value=`lanadmin -x $card 2> /dev/null`
    #value="Current Config                   = 100 Half-Duplex AUTONEG"
    if [ ! -z "$value" ]; then
        l_check=`echo $value | grep -i full | wc -l`
        if [ $l_check -eq 1 ]; then
            duplex_result=1
        else
            duplex_result=2
        fi
    else
        duplex_result=0
    fi 

    echo "NKIASC|"$name"|"$bandwidth"|"$duplex_result
done

\rm -f ./lanscan.txt
