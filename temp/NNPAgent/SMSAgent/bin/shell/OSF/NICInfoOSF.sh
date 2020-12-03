#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

#hwmgr -get attribute -category network
hwmgr -get attribute -category network | egrep '^[0-9][0-9]:|model'
