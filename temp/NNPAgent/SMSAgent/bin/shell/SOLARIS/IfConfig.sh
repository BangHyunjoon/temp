#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

ifconfig $1 | grep ether | cut -d ' ' -f2 > ../aproc/shell/ifconfig.dat


