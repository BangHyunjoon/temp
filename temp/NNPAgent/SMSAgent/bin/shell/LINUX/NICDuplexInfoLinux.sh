#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH

LANG=C
export LANG

###########################################
# Info : get NIC Duplex Type(Full or Half)
# usage : ./NICDuplexInfoLinux.sh interface_name
# ex) ./NICDuplexInfoLinux.sh eth0

ethtool $1 > $2 2<&1
cat $2 | grep Duplex | cut -d ':' -f2 > $3 
