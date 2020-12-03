#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

LSCFG_FNAME=lscfg_hdisk.out
LSMAP_FNAME=lsmap_all.out

TMP_CMD=`ioscli lsmap -all -fmt : | awk -F'|' '{print "echo " $1}' | ioscli oem_setup_env > $LSMAP_FNAME`
HDISK_NAME=""
NODE_NAME=""
SERIAL_NUM=""
PVID=""
VG_NAME=""
LPAR_ID=""
PRNT_STR=""

if [ -f ls_disk.out ] ; then
  while read line
  do
    #echo "###LINE : [$line]"
    HDISK_NAME=`echo "$line" | awk -F',' '{print $1}'`
    PRNT_STR=`echo "$line" | awk -F',' '{print $1","$2","$3","$4","$5","$6","$7}'`

    LPAR_LIST=""
    LPAR_ID=`grep ":$HDISK_NAME:" $LSMAP_FNAME | awk -F':' '{print $3}'`
    if [ "$LPAR_ID" = "" ] ; then
        LPAR_LIST="0x00000000"
    else
        for partition_id in `echo $LPAR_ID`
        do
            if [ ! "$partition_id" = "0x00000000" ] ; then
                if [ "$LPAR_LIST" = "" ] ; then
                    LPAR_LIST=`echo "$partition_id"`
                else
                    LPAR_LIST=`echo "$LPAR_LIST,$partition_id"`
                fi
            fi
        done
    fi

    if [ "$LPAR_LIST" = "" ] ; then
        LPAR_LIST="0x00000000"
    fi

    echo "$PRNT_STR,$LPAR_LIST"
    TMP_CMD=`echo "echo \"$PRNT_STR,$LPAR_LIST\"" | ioscli oem_setup_env >> ls_disk.out_`
  done <ls_disk.out
  TMP_CMD=`echo "rm -f ./ls_disk.out" | ioscli oem_setup_env`
  TMP_CMD=`echo "mv ./ls_disk.out_ ./ls_disk.out" | ioscli oem_setup_env`
  TMP_CMD=`echo "chmod 777 ./ls_disk.out" | ioscli oem_setup_env`
else
  TMP_CMD=`echo "lscfg | grep hdisk | grep '\-W'" | ioscli oem_setup_env > $LSCFG_FNAME`
  while read line
  do
    #echo "###LINE : [$line]"
    HDISK_NAME=`echo "$line" | awk -F' ' '{print $2}'`
    NODE_NAME=`echo "$line" | awk -F' ' '{print $3}' | awk -F'-' '{print $5}'`
    LUN_ID=`echo "$line" | awk -F' ' '{print $3}' | awk -F'-' '{print $6}'`

    HDISK_SIZE=`echo "bootinfo -s $HDISK_NAME" | ioscli oem_setup_env`
    SERIAL_NUM=`echo "lscfg -vpl $HDISK_NAME | grep Serial | cut -d'.' -f16" | ioscli oem_setup_env`
    if [ "$SERIAL_NUM" = "" ] ; then
        SERIAL_NUM=`ioscli lsdev -dev $HDISK_NAME -attr | grep unique_id | awk -F' ' '{print $2}'`
    fi

    LPAR_LIST=""
    LPAR_ID=`grep ":$HDISK_NAME:" $LSMAP_FNAME | awk -F':' '{print $3}'`
    if [ "$LPAR_ID" = "" ] ; then
        LPAR_LIST="0x00000000"
    else
        for partition_id in `echo $LPAR_ID`
        do
            if [ ! "$partition_id" = "0x00000000" ] ; then
                if [ "$LPAR_LIST" = "" ] ; then
                    LPAR_LIST=`echo "$partition_id"`
                else
                    LPAR_LIST=`echo "$LPAR_LIST,$partition_id"`
                fi
            fi
        done
    fi

    if [ "$LPAR_LIST" = "" ] ; then
        LPAR_LIST="0x00000000"
    fi

    PVID=`lspv | grep "$HDISK_NAME " | awk '{print $2}'`
    VG_NAME=`lspv | grep "$HDISK_NAME " | awk '{print $3}'`

    echo "$HDISK_NAME,$NODE_NAME,$LUN_ID,$SERIAL_NUM,$HDISK_SIZE,$PVID,$VG_NAME,$LPAR_LIST"
    TMP_CMD=`echo "echo \"$HDISK_NAME,$NODE_NAME,$LUN_ID,$SERIAL_NUM,$HDISK_SIZE,$PVID,$VG_NAME,$LPAR_LIST\"" | ioscli oem_setup_env >> ls_disk.out`
  done <$LSCFG_FNAME

  TMP_CMD=`echo "chmod 777 ./ls_disk.out" | ioscli oem_setup_env`
fi

exit 0
