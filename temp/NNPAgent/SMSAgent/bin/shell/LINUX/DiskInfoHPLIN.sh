#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

hpacucli ctrl all show config | grep "physicaldrive" | awk '{print $1 $2 "|" $8}' | sed -e 's/:/-/g'
#cat ./shell/LINUX/disk | grep "physicaldrive" | awk '{print $1 $2 "|" $8}' | sed -e 's/:/-/g'

