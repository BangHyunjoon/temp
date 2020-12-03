#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname_bakup.dat
RECVRY_SHELL=../bin/shell/SOLARIS/recovery/hostname_recovery.sh
RECVRY_HOSTNAME_FILE1=../bin/shell/SOLARIS/recovery/hostname_old.dat
RECVRY_HOSTNAME_FILE2=../bin/shell/SOLARIS/recovery/hostname_set_file_old.dat
CMD=`echo "" > $FILE_DAT`
COMMAND=`mkdir ../bin/shell/SOLARIS/recovery >> $FILE_DAT 2>&1 `
RECVRY_HOSTNAME=$1
if [ $1 ] ; then

    COMMAND=`echo "hostname recovery shell creating[$1]..." >> $FILE_DAT` 

    COMMAND=`echo \#\!/bin/sh > $RECVRY_SHELL`
    COMMAND=`echo "PATH=\\\$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin" >> $RECVRY_SHELL`
    COMMAND=`echo "export PATH" >> $RECVRY_SHELL`
    COMMAND=`echo "LANG=C" >> $RECVRY_SHELL`
    COMMAND=`echo "export LANG" >> $RECVRY_SHELL`
    COMMAND=`echo "FILE_DAT=../aproc/shell/hostname_recovery.dat" >> $RECVRY_SHELL`
    COMMAND=`echo "CMD=\\\`echo \"\" > \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "RECVRY_HOSTNAME=$1" >> $RECVRY_SHELL`
    COMMAND=`echo "if [ \\\$RECVRY_HOSTNAME ] ; then" >> $RECVRY_SHELL`
    COMMAND=`echo "    CMD=\\\`./shell/SOLARIS/hostname_update.sh \"$1\" >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "else" >> $RECVRY_SHELL`
    COMMAND=`echo "    CMD=\\\`echo \"hostname recovery info not found.\" >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "    exit 255" >> $RECVRY_SHELL`
    COMMAND=`echo "fi" >> $RECVRY_SHELL`
    COMMAND=`echo "CMD=\\\`echo \"hostname recovery success.\" >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "exit 0" >> $RECVRY_SHELL`
    COMMAND=`chmod +x $RECVRY_SHELL`
 
    COMMAND=`hostname > $RECVRY_HOSTNAME_FILE1`
    COMMAND=`svccfg -s system/identity:node listprop config | grep config/nodename > $RECVRY_HOSTNAME_FILE2`

    COMMAND=`echo "hostname recovery shell created[$1]..." >> $FILE_DAT` 
else 
    COMMAND=`echo "hostname argument intput error." >> $FILE_DAT`
    exit 255
fi

exit 0
