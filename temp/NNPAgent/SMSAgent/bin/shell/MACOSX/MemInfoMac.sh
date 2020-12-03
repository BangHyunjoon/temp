#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
LANG=C
export LANG=C

system_profiler SPMemoryDataType | grep "Size" | awk '{print $2" " $3}' > ../aproc/shell/MemInfoMac.dat
