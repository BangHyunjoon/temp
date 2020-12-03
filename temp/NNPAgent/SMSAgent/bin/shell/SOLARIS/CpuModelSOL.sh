#!/bin/sh

#PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/platform/`arch -k`/sbin
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/platform/`uname -i`/sbin
export PATH

LANG=C
export LANG

LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

#FILE_CNT=`ls -al ../aproc/shell/CpuModelSOL.dat 2> /dev/null | wc -l`

#if [ $FILE_CNT = 0 ] ; then
    prtdiag 2>&1 | grep "US" | awk '{print $6}' > ../aproc/shell/CpuModelSOL.dat
    #prtconf -p | grep UltraSPARC- | awk -F"," '{print $2}' | awk -F"'" '{print $1}'
#fi
