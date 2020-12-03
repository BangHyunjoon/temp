#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

netstat -an | grep -i tcp > ../aproc/shell/WsmNetstat.out_
df -P > ../aproc/shell/WsmDF_p.out_
ps auxww > ../aproc/shell/WsmPS_AUXWW.out_
ps -eLfww > ../aproc/shell/WsmPS_ELFWW.out_

mv ../aproc/shell/WsmPS_AUXWW.out_ ../aproc/shell/WsmPS_AUXWW.out
mv ../aproc/shell/WsmDF_p.out_ ../aproc/shell/WsmDF_p.out
mv ../aproc/shell/WsmNetstat.out_ ../aproc/shell/WsmNetstat.out
mv ../aproc/shell/WsmPS_ELFWW.out_ ../aproc/shell/WsmPS_ELFWW.out

#cp ./shell/WSM/* ../aproc/shell/

