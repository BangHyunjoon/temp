#! /bin/ksh

LANG=C
export LANG

mkres()
{
    MKSYSB_FLAGS=
    COMMENTS=
    MK_IMAGE=
    SERVER=
    EXCLUDE_FILES=
    SOURCE=
    LOCATION=

    while getopts N:t:s:l:c:R:f:mS:e:b:K:Q:PFaZApJ option
    do
        case $option in
            N) NAME=$OPTARG;;
            t) TYPE=$OPTARG;;
            s) SERVER=-aserver=$OPTARG ;;
            l) LOCATION=-alocation=$OPTARG ;;
            c) COMMENTS="$OPTARG" ;;
            m) MK_IMAGE=-amk_image=yes ;;
            S) SOURCE=-asource=$OPTARG
               CLIENT=$OPTARG ;;
            f) MKSYSB_FLAGS=${MKSYSB_FLAGS}$OPTARG ;;
            b) MKSYSB_FLAGS=${MKSYSB_FLAGS}b$OPTARG ;;
            J) MKSYSB_FLAGS=${MKSYSB_FLAGS}P ;;
            e) EXCLUDE_FILES=-aexclude_files=$OPTARG ;;
            P) SIZE_PREVIEW=-asize_preview=yes ;;
            F) FORCE=-F ;;
            K) NFS_SEC=$OPTARG;;
            Q) NFS_VERS=$OPTARG;;
            R) REP_SRC=$OPTARG;;
            a) sysbr_level=`nim -o lslpp -a lslpp_flags="-lcOu" $CLIENT 2>/dev/null | grep bos.sysmgt.sysbr | cut -d: -f3`
               version=`echo ${sysbr_level} | cut -d. -f1`
               release=`echo ${sysbr_level} | cut -d. -f2`

               if [[ ${version} -gt 5 ]] || [[ ${version} -eq 5 ]] && [[ ${release} -gt 2 ]]; then
                    MKSYSB_FLAGS=${MKSYSB_FLAGS}a
               fi ;;
            Z) sysbr_level=`nim -o lslpp -a lslpp_flags="-lcOu" $CLIENT 2>/dev/null | grep bos.sysmgt.sysbr | cut -d: -f3`
               version=`echo ${sysbr_level} | cut -d. -f1`
               release=`echo ${sysbr_level} | cut -d. -f2`

               if [[ ${version} -gt 5 ]] || [[ ${version} -eq 5 ]] && [[ ${release} -gt 3 ]]; then
                    MKSYSB_FLAGS=${MKSYSB_FLAGS}Z
               fi ;;
            A) MKSYSB_FLAGS=${MKSYSB_FLAGS}A;;
            p) MKSYSB_FLAGS=${MKSYSB_FLAGS}p;;
        esac
    done

    # Make sure that both $REP_SRC and $SOURCE are not specified together
    if [[ -n ${REP_SRC} ]] && [[ -n ${SOURCE} ]]
    then
       # include the error definitions
       . /usr/lpp/bos.sysmgt/nim/methods/cmdnim_errors.shh

       # display an error message
       dspmsg -s ${ERR_SET} cmdnim.cat ${ERR_M_EXCLUS_REP_SRC} "0042-313 The \"Source for Replication\" option and the
        \"NIM CLIENT to backup\" option may not
        be specified together.
"
       return -1
    elif [[ -n ${REP_SRC} ]] && [[ -n ${MK_IMAGE} ]]
    then

       # include the error definitions
       . /usr/lpp/bos.sysmgt/nim/methods/cmdnim_errors.shh

       # display an error message
       dspmsg -s ${ERR_SET} cmdnim.cat ${ERR_M_EXCLUS_MKIMAGE_SRC} "0042-314 The \"Source for Replication\" option and the
        \"CREATE system backup image\" option may not
        be specified together.
"
       return -1
    fi



    nim -o define -t ${TYPE} ${FORCE} ${SERVER} ${LOCATION} ${SOURCE} ${MK_IMAGE} ${MKSYSB_FLAGS:+-amksysb_flags=$MKSYSB_FLAGS} ${NFS_SEC:+-a nfs_sec=$NFS_SEC} ${NFS_VERS:+-a nfs_vers=$NFS_VERS} ${EXCLUDE_FILES} ${SIZE_PREVIEW} ${REP_SRC:+-a source=$REP_SRC} ${COMMENTS:+-acomments="${COMMENTS}"} ${NAME}
    exit $?
}


rmres()
{
    while getopts N:r option
    do
        case $option in
            N) NAME=$OPTARG ;;
            r) RM_IMAGE=-arm_image=yes ;;
        esac
    done

    nim -o remove $RM_IMAGE $NAME
}

#rmres -N'db1_AIX61_TL07-20120904'

#mkres -N 'was1_AIX61_TL07-20120903' -t 'standalone' -s 'master' -l '/export/mksysb/was1_aix61-20120903' '-m' -S'WAS-1'  '-A'
#mkres -N 'was1_AIX61_TL07-20120903' -t 'mksysb' -s 'master' -l '/export/mksysb/was1_aix61-20120903' '-m' -S'WAS-1'  '-A'
#mkres -N 'db1_AIX61_TL07-201208234' -t 'mksysb' -s 'master' -l '/export/mksysb/db1_aix61-201209032' '-m' -S'was1'  '-A'
#mkres -N 'db1_AIX61_TL07-20120904' -t 'mksysb' -s 'master' -l '/export/mksysb/db1_aix61-20120904' '-m' -S'db1'  '-A'
#mkres -N '$1' -t 'mksysb' -s 'master' -l '/export/mksysb/$2' '-m' -S'$3'  '-A'

if [ "$1" = "" ] ; then
    echo "Usage : $0 <lpar id> <lpar name> <lpar nas-ip> <backup home-path> <vm uuid>"
    exit 255
fi
if [ "$2" = "" ] ; then
    echo "Usage : $0 <lpar id> <lpar name> <lpar nas-ip> <backup home-path> <vm uuid>"
    exit 255
fi
if [ "$3" = "" ] ; then
    echo "Usage : $0 <lpar id> <lpar name> <lpar nas-ip> <backup home-path> <vm uuid>"
    exit 255
fi
if [ "$4" = "" ] ; then
    echo "Usage : $0 <lpar id> <lpar name> <lpar nas-ip> <backup home-path>"
    exit 255
fi

BACKUP_LPAR_ID=$1
BACKUP_LPAR=$2
BACKUP_LPAR_IP=$3
BACKUP_HOME_PATH=$4
BACKUP_LPAR_UUID=$5

TMP_CMD=`grep -v $BACKUP_LPAR /etc/hosts > /etc/hosts_b`
TMP_CMD=`echo "$BACKUP_LPAR_IP  $BACKUP_LPAR" >> /etc/hosts_b`
TMP_CMD=`mv  -f /etc/hosts_b  /etc/hosts`

BACKUP_DATE=`date +%Y%m%d`
BACKUP_TIME=`date +%Y%m%d%H%M%S`
BACKUP_PATH="$BACKUP_HOME_PATH/$BACKUP_DATE/$BACKUP_LPAR_UUID"
#BACKUP_PATH=/export/mksysb
BACKUP_FILE=$BACKUP_LPAR.$BACKUP_TIME.mksysb
BACKUP_LOG_PATH=/export/ncia/logs
CMD=`\rm -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.10 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.9  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.10 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.8  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.9 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.7  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.8 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.6  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.7 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.5  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.6 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.4  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.5 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.3  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.4 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.2  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.3 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.1  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.2 >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`
CMD=`mv -f $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log  $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log.1`

CMD=`mkdir -p $BACKUP_PATH >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`

CMD=`date >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log`

CMD=`echo "rmres -N $BACKUP_LPAR$BACKUP_DATE" >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log`
rmres -N $BACKUP_LPAR$BACKUP_DATE >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1
\rm -f $BACKUP_PATH/$BACKUP_FILE

CMD=`echo "mkres -N $BACKUP_LPAR$BACKUP_DATE -t 'mksysb' -s 'master' -l $BACKUP_PATH/$BACKUP_FILE '-m' -S $BACKUP_LPAR  '-A'" >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log`

#CMD=`mkres -N $BACKUP_LPAR$BACKUP_DATE -t 'mksysb' -s 'master' -l $BACKUP_PATH/$BACKUP_FILE '-m' -S $BACKUP_LPAR  '-A' >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1`

mkres -N $BACKUP_LPAR$BACKUP_DATE -t 'mksysb' -s 'master' -l $BACKUP_PATH/$BACKUP_FILE '-m' -S $BACKUP_LPAR  '-A' >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1
EXIT_CODE=$?

CMD=`echo "mkres exit code = $EXIT_CODE" >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log`

#CMD=`echo "rmres -N $BACKUP_LPAR$BACKUP_DATE" >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log`
#rmres -N $BACKUP_LPAR$BACKUP_DATE >> $BACKUP_LOG_PATH/nim_backup_$BACKUP_LPAR.log 2>&1

exit $EXIT_CODE
