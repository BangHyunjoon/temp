#!/bin/ksh

if [ "$1" = "" ] ; then
    echo " Usage : $0 <backup home path>"
    echo "         ex) #$0 /backup/ncia"
    exit 255
fi
BACKUP_PATH=$1
#BACKUP_PATH=/home/djlee/job/backup/ibm
BACKUP_LIST_FILE=backup_path.dat
TMP_CMD=`ls -al $BACKUP_PATH/????????/*/????-??-??,??:?? > $BACKUP_LIST_FILE`

echo "BACKUP PATH|BACKUP FNAME|BACKUP VM UUID|BACKUP SIZE|BACKUP TIME|BACKUP VM NAME"
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
    BACKUP_TIME=""
    BACKUP_yyyy=""
    BACKUP_mm=""
    BACKUP_dd=""
    BACKUP_HH=""
    BACKUP_MM=""
    for FF in `echo $BACKUP_FNAME | awk -F',' '{for(a=1;a<=NF;a++)print $a}'`
    do
        if [ "$BACKUP_dd" = "" ] ; then
            for FFyy in `echo $FF | awk -F'-' '{for(b=1;b<=NF;b++)print $b}'`
            do
                if [ "$BACKUP_yyyy" = "" ] ; then
                    BACKUP_yyyy="$FFyy"
                else
                    if [ "$BACKUP_mm" = "" ] ; then
                        BACKUP_mm="$FFyy"
                    else
                        if [ "$BACKUP_dd" = "" ] ; then
                            BACKUP_dd="$FFyy"
                        fi
                    fi
                fi
            done
        else
            for FFyy in `echo $FF | awk -F':' '{for(b=1;b<=NF;b++)print $b}'`
            do
                if [ "$BACKUP_HH" = "" ] ; then
                    BACKUP_HH="$FFyy"
                else
                    if [ "$BACKUP_MM" = "" ] ; then
                        BACKUP_MM="$FFyy"
                    fi
                fi
            done
        fi
    done
    BACKUP_TIME="$BACKUP_yyyy$BACKUP_mm$BACKUP_dd$BACKUP_HH$BACKUP_MM"00
    #echo "BACKUP_PATH:$BACKUP_PATH/$BACKUP_DATE/$BACKUP_VM_UUID, BACKUP_FNAME:$BACKUP_FNAME, BACKUP_VM_UUID:$BACKUP_VM_UUID, SIZE:$BACKUP_SIZE, BACKUP_TIME:$BACKUP_TIME"

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
                        BACKUP_TIME="$BACKUP_DATE"000000
                    fi
                    if [ "$BACKUP_TIME" = "00" ] ; then
                        BACKUP_TIME="$BACKUP_DATE"000000
                    fi

                    BACKUP_VMNAME="-"
                    TMP_CNT=0
                    for FF in `ls $BACKUP_PATH/$BACKUP_DATE/$BACKUP_VM_UUID/*.vm | awk -F'/' '{for(a=1;a<=NF;a++)print $a}'`
                    do
                        if [ "$TMP_CNT" = "3" ] ; then
                            BACKUP_VMNAME=`echo $FF | cut -d'.' -f1 | awk '{print $1}'`
                        fi

                        let "TMP_CNT = $TMP_CNT + 1"
                    done

                    echo "$BACKUP_PATH/$BACKUP_DATE/$BACKUP_VM_UUID|$BACKUP_FNAME|$BACKUP_VM_UUID|$BACKUP_SIZE|$BACKUP_TIME|$BACKUP_VMNAME"
                fi
            fi
        fi
    fi
done <$BACKUP_LIST_FILE

exit 0
