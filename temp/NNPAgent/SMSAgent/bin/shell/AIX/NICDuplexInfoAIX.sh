#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH

LANG=en
export LANG

###########################################
# Info : get NIC Duplex Type(Full or Half)
# usage : ./NICDuplexInfoAIX.sh -d interface_name
# ex) ./NICDuplexInfoAIX.sh -d en0

entstat -d $1 > $2 2<&1
cat $2 | grep Duplex | cut -d ' ' -f6 > $3 
