#!/bin/ksh

if [ "$1" = "" ] ; then
    echo " Usage : $0 <backup home path>"
    echo "         ex) #$0 /backup/ncia"
    exit 255
fi

BACKUP_PATH=$1
#BACKUP_PATH=/home/djlee/job/backup/ibm
BACKUP_LIST_FILE=backup_path.dat
BACKUP_LSNIM_FILE=backup_lsnim.dat
TMP_CMD=`ls -al $BACKUP_PATH/????????/*/*.mksysb > $BACKUP_LIST_FILE`
TMP_CMD=`ls -al $BACKUP_PATH/????????/*/*.spot >> $BACKUP_LIST_FILE`
TMP_CMD=`lsnim -t mksysb > $BACKUP_LSNIM_FILE`
TMP_CMD=`lsnim -t spot >> $BACKUP_LSNIM_FILE`

echo "BACKUP PATH|BACKUP FNAME|BACKUP VM UUID|BACKUP SIZE|BACKUP TIME|BACKUP LSNIM-NAME|BACKUP VM NAME"
while read line
do
    #echo "LS : $line"
    VM_BACKUP_PATH=`echo $line | awk -F' ' '{print $9}'`
    BACKUP_SIZE=`echo $line | awk -F' ' '{print $5}'`
    #echo "VM_BACKUP_PATH=$VM_BACKUP_PATH" | awk -F'/' '{print $*}'
    TMP_FF=""
    BACKUP_DATE=""
    BACKUP_VM_UUID=""
    BACKUP_FNAME=""
    for FF in `echo $VM_BACKUP_PATH | awk -F'/' '{for(a=1;a<=NF;a++)print $a}'`
    do
        if [ "$TMP_FF" = "$BACKUP_PATH" ] ; then
            if [ "$BACKUP_DATE" = "" ] ; then
                BACKUP_DATE="$FF"
            else
                if [ "$BACKUP_VM_UUID" = "" ] ; then
                    BACKUP_VM_UUID="$FF"
                else
                    if [ "$BACKUP_FNAME" = "" ] ; then
                        BACKUP_FNAME="$FF"
                    fi
                fi
            fi
            #echo "TMP_FF = $TMP_FF"
        else
            TMP_FF="$TMP_FF/$FF"
        fi
    done

    TMP_FF=""
    TMP_CNT=0
    BACKUP_VMNAME="-"
    BACKUP_TIME="-"
    for FF in `echo $BACKUP_FNAME | awk -F'.' '{for(a=1;a<=NF;a++)print $a}'`
    do
        if [ "$TMP_CNT" = "0" ] ; then
            BACKUP_VMNAME=`echo $FF | awk -F'.' '{print $1}'`
        fi

        if [ "$TMP_CNT" = "1" ] ; then
            BACKUP_TIME=`echo $FF | awk -F'.' '{print $1}'`
        fi

        let "TMP_CNT = $TMP_CNT + 1"
    done

    if [ ! "$TMP_CNT" = "3" ] ; then
        BACKUP_TIME="$BACKUP_DATE"000000
        BACKUP_VMNAME="-"
    fi

    BACKUP_NAME="-"

    if [ ! "$BACKUP_VMNAME" = "-" ] ; then
        TMP_CHK=0
        TMP_CHK=`echo $BACKUP_FNAME | grep mksysb | wc -l`
        if [ "$TMP_CHK" = "0" ] ; then
            TMP_FF=`grep "$BACKUP_VMNAME$BACKUP_DATE" $BACKUP_LSNIM_FILE | grep spot | awk -F' ' '{print $1}'`
        else
            TMP_FF=`grep "$BACKUP_VMNAME$BACKUP_DATE" $BACKUP_LSNIM_FILE | grep mksysb | awk -F' ' '{print $1}'`
        fi

        if [ "$TMP_FF" = "" ] ; then
            BACKUP_NAME="-"
        else
            BACKUP_NAME="$TMP_FF"
        fi
    fi
    #echo "BACKUP_PATH:$BACKUP_PATH/$BACKUP_DATE/$BACKUP_VM_UUID, BACKUP_FNAME:$BACKUP_FNAME, BACKUP_VM_UUID:$BACKUP_VM_UUID, SIZE:$BACKUP_SIZE, BACKUP_TIME:$BACKUP_TIME, BACKUP_NAME:$BACKUP_NAME"

    if [ "$BACKUP_DATE" = "" ] ; then
        TMP_CHK=0
    else
        if [ "$BACKUP_VM_UUID" = "" ] ; then
            TMP_CHK=0
        else
            if [ "$BACKUP_FNAME" = "" ] ; then
                TMP_CHK=0
            else
                if [ "$BACKUP_SIZE" = "" ] ; then
                    TMP_CHK=0
                else
                    if [ "$BACKUP_TIME" = "" ] ; then
                        TMP_CHK=0
                    else
                        echo "$BACKUP_PATH/$BACKUP_DATE/$BACKUP_VM_UUID|$BACKUP_FNAME|$BACKUP_VM_UUID|$BACKUP_SIZE|$BACKUP_TIME|$BACKUP_NAME|$BACKUP_VMNAME"
                    fi
                fi
            fi
        fi
    fi
done <$BACKUP_LIST_FILE

exit 0
