#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

hwmgr -get attribute -category tape | grep 'category = tape' | wc -l
