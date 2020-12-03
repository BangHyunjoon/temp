#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#ethtool $1 | grep Speed | cut -d ' ' -f2 > $2
ethtool $1 | grep Mb | awk '{print $2}' | awk -F"Mb" '{print $1}' > $2
