#!/bin/ksh

if [ "$1" = "" ] ; then
    echo " Usage : $0 <backup home path> <yyyymmdd> <vm-uuid> [<vm-name>]"
    echo "         ex) #$0 /backup/ncia 20121008 304C-CX86-AEBD-FFFF-455F vm001"
    exit 255
fi

if [ "$2" = "" ] ; then
    echo " Usage : $0 <backup home path> <yyyymmdd> <vm-uuid> [<vm-name>]"
    echo "         ex) #$0 /backup/ncia 20121008 304C-CX86-AEBD-FFFF-455F vm001"
    exit 255
fi

if [ "$3" = "" ] ; then
    echo " Usage : $0 <backup home path> <yyyymmdd> <vm-uuid> [<vm-name>]"
    echo "         ex) #$0 /backup/ncia 20121008 304C-CX86-AEBD-FFFF-455F vm001"
    exit 255
fi

BACKUP_PATH="$1/$2/$3"
TMP_CMD=`mkdir -p $BACKUP_PATH`
TMP_CMD=`chown bin:bin $BACKUP_PATH`
TMP_CHK=`ls -al $BACKUP_PATH | wc -l`

if [ "$TMP_CHK" = "0" ] ; then
   echo "backup path[$BACKUP_PATH] creat failed."
   exit 255
else
   echo "backup path[$BACKUP_PATH] creat success."
   if [ ! "$4" = "" ] ; then
       TMP_CMD=`touch $BACKUP_PATH/$4.vm`
   fi
   exit 0
fi
