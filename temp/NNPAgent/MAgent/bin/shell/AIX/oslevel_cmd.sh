#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

l_cmd=`oslevel`
echo "NKIA|"$l_cmd

exit 0
