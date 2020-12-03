#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

GLANCE_LOOP_FILE="./shell/WsmGlance_loop.txt"

netstat -an | grep -i tcp > ../aproc/shell/WsmNetstat.out_
bdf  >  ../aproc/shell/WsmDF_bdf.out_
ps -ex > ../aproc/shell/WsmPS_EX.out_
glance -adviser_only -syntax $GLANCE_LOOP_FILE -j 2 -iterations 1 > ../aproc/shell/WsmGlance_proclist.out_

mv ../aproc/shell/WsmNetstat.out_ ../aproc/shell/WsmNetstat.out
mv ../aproc/shell/WsmDF_bdf.out_ ../aproc/shell/WsmDF_bdf.out
mv ../aproc/shell/WsmPS_EX.out_ ../aproc/shell/WsmPS_EX.out
mv ../aproc/shell/WsmGlance_proclist.out_ ../aproc/shell/WsmGlance_proclist.out
