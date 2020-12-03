#!/bin/sh
PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export PATH
LANG=C
export LANG=C

DEVNAME=$1

if [ -f ../aproc/shell/InterfaceIrix.dat ]; then
    `/sbin/rm ../aproc/shell/InterfaceIrix.dat`
fi

MACADDRESS=`netstat -an -I $DEVNAME | grep ":"`
#SPEED=`ifconfig -v $DEVNAME | grep speed | awk '{print $2" " $3}'`

if [ "$MACADDRESS" = "" ]; then
    echo "UNKNOWN" >> ../aproc/shell/InterfaceIrix.dat
    #echo "UNKNOWN" 
else
    echo $MACADDRESS >> ../aproc/shell/InterfaceIrix.dat
    #echo $MACADDRESS 
fi

#if [ "$SPEED" = "" ]; then
#    echo "UNKNOWN"
#else
#    echo $SPEED
#fi
