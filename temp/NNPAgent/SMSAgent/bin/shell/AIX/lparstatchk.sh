#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

version=`oslevel | awk -F. 'int($1$2) >= 53 {print "ok"}'`
if [ "$version" = "ok" ]; then
    value=`lparstat | grep smt= | awk '{print $5}'`
    if [ "$value" = "smt=On" ] ; then
        ../../utils/ETC/ConfUpdate AIX53_CPU_GATHER_TYPE=1 ../conf/SMSAgent.conf
    fi
fi
