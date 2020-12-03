#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/symcli/bin
export PATH


FILE_DAT=../aproc/shell/omninet.txt
RETURN_DAT=../aproc/shell/omninet_return.dat
T_FILE_DAT="$FILE_DAT"_

\rm -f $RETURN_DAT 2> /dev/null
CMD=`\rm -f $FILE_DAT`
EXIT_VAL=`./shell/LINUX/omninet -an | egrep -i "^tcp|^udp" > $T_FILE_DAT;echo $? > $RETURN_DAT`

CMD=`mv $T_FILE_DAT $FILE_DAT`
exit $EXIT_VAL
