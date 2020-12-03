#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

#buf_cache=`echo bufpages/D | adb /stand/vmunix /dev/kmem | grep bufpages: | tail -1 | awk '{print $2}'`
buf_cache=`echo bufpages/d | adb /stand/vmunix /dev/kmem | tail -1 | awk '{print $1}'`
echo "NKIA|"$buf_cache

exit 0

