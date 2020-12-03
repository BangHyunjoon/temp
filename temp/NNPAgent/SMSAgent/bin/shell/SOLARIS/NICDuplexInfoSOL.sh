#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH

LANG=C
export LANG

###########################################
# Info : get NIC Duplex Type(Full or Half)
# usage : ./NICDuplexInfoSOL.sh /dev/ifname
# ex) ./NICDuplexInfoSOL.sh /dev/hme link_mode


ndd /dev/$1 link_mode > $2 2>&1

