#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

FILENAME=$1"*"

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    ls -al $FILENAME | awk '{print $NF}' | awk -F'_' '{print $4}' 
fi

if [ $OS_TYPE = "HP-UX" ] ; then
    ls -al $FILENAME | awk '{print $NF}' | awk -F'_' '{print $4}'
fi

if [ $OS_TYPE = "Linux" ] ; then
    ls -al $FILENAME | awk '{print $NF}' | awk -F'_' '{print $4}'
fi

if [ $OS_TYPE = "SunOS" ] ; then
    ls -al $FILENAME | awk '{print $NF}' | awk -F'_' '{print $4}'
fi 

