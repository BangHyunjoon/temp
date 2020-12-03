#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/symcli/bin
export PATH


FILE_DAT=../aproc/shell/software_path.dat
T_FILE_DAT="$FILE_DAT"_


EXIT_VAL=`./shell/UNIXWARE/software_path > $T_FILE_DAT`

CMD=`\rm -f $FILE_DAT`
CMD=`mv $T_FILE_DAT $FILE_DAT`
exit $EXIT_VAL

