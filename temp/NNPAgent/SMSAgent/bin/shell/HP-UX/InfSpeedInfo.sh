#!/bin/ksh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG=C

value=`lanadmin -s $1 | grep -i speed | awk -F'=' '{print $2}'`
if [ $value -le 1000 ] ; then
    bandwidth=`echo "$value * 1000" | bc`
else
    bandwidth=`echo "$value / 1000" | bc`
fi

echo "NKIA|"$bandwidth
