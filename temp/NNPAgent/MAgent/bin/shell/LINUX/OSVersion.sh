#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

if [ -f /etc/redhat-release ] ; then
    Version=`cat /etc/redhat-release | grep -v ^#`
elif [ -f /etc/system-release ] ; then
    Version=`cat /etc/system-release | grep -v ^#`
else
    if [ -f /etc/SuSE-release ] ; then
        Version=`grep -i suse /etc/SuSE-release | grep -v ^#`
    else
        if [ -f /etc/lsb-release ] ; then
            Version=`grep DESCRIPTION /etc/lsb-release | awk -F\" '{print $2}'`
        else
            Version=`uname -r | awk -F. '{print $1"."$2"."$3}'`
        fi
    fi
fi


echo "NKIA|"$Version"|"
