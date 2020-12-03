#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

if [ -f /usr/bin/esxtop ] ; then
    esxtop -v > ../aproc/shell/VMWare_check.dat
fi


