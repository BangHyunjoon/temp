#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_PATH=$1
FILE_SH_EXEC=$1.sh

cat $FILE_PATH > $FILE_SH_EXEC
chmod 700 $FILE_SH_EXEC

$FILE_SH_EXEC

#echo "$FILE_SH_EXEC"

\rm -f $FILE_SH_EXEC

exit 0
