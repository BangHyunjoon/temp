#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH

LANG=C
export LANG

###########################################
# Info : get NIC Duplex Type(Full or Half)
# usage : ./NICDuplexInfoHpux.sh -x ppa_number datafile
# ex) ./NICDuplexInfoHpux.sh -x 0 Duplex.dat

lanadmin -x $1 > $2 2<&1
cat $2 | grep Duplex | cut -d '=' -f2 > $3
