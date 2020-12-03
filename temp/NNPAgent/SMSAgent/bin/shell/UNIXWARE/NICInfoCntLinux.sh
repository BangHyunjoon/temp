#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

cat /etc/sysconfig/hwconf | grep "class: NETWORK" | wc -l
