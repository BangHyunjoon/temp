#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

hwmgr -get attribute -category disk  | grep 'sub_category = cdrom' | wc -l