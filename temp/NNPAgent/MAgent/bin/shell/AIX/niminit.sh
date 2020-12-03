#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/niminit.dat
CMD=`echo "" > $FILE_DAT`

CMD=`echo "################### dlpar init ###################" >> $FILE_DAT`
CMD=`stopsrc -g rsct_rm >> $FILE_DAT 2>&1`
CMD=`stopsrc -g rsct >> $FILE_DAT 2>&1`
CMD=`chdev -l cluster0 -a node_uuid="00000000-0000-0000-0000-000000000000" >> $FILE_DAT 2>&1`
CMD=`/usr/sbin/rsct/bin/mknodeid -f  >> $FILE_DAT 2>&1`
CMD=`lsattr -El cluster0  >> $FILE_DAT 2>&1`
CMD=`/usr/sbin/rsct/bin/lsnodeid  >> $FILE_DAT 2>&1`
CMD=`/usr/sbin/rsct/install/bin/recfgct  >> $FILE_DAT 2>&1`
CMD=`echo "##################################################" >> $FILE_DAT`

CMD=`echo "################### nim init #####################" >> $FILE_DAT`
NIMINIT_CMD=niminit
NIM_PORT=1058
NIM_IP=""
BACKUPNET_IP=""
BACKUPNET_EN=""
COMMAND=`which $NIMINIT_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found niminit info command($NIMINIT_CMD)" > ../aproc/shell/niminit.dat_err`
    exit 255
fi

if [ $1 ] ; then

    if [ "$NIM_IP" = "" ] ; then
        NIM_IP=`grep nim /etc/hosts | grep -v "^#" | cut -d'    ' -f1 | awk '{print $1}'`
    fi

    if [ "$NIM_IP" = "" ] ; then
        CMD_EXE=`echo "nim server ip not found." >> $FILE_DAT`
    else
        CMD_EXE=`echo "nim server ip : [$NIM_IP]" >> $FILE_DAT`
        BACKUPNET_IP=`../../utils/ETC/localip $NIM_IP $NIM_PORT | awk '{print $1}'`
        if [ "$BACKUPNET_IP" = "" ] ; then
            CMD_EXE=`echo "backup network ip not found." >> $FILE_DAT`
        else
            CMD_EXE=`echo "backup network ip : [$BACKUPNET_IP]" >> $FILE_DAT`
            BACKUPNET_EN=`../../utils/ETC/network_mac | grep "$BACKUPNET_IP" | cut -d',' -f1 | cut -d'[' -f2 | awk '{print $1}'`
            if [ "$BACKUPNET_EN" = "" ] ; then
                CMD_EXE=`echo "backup network interface not found." >> $FILE_DAT`
            else
                CMD_EXE=`echo "backup network interface : [$BACKUPNET_EN]" >> $FILE_DAT`

                CMD_EXE=`echo "niminit start..." >> $FILE_DAT`
                CMD_EXE=`\rm -f /etc/niminfo`
                CMD_EXE=`echo "$NIMINIT_CMD -a name=$1 -a master=nim -a platform=chrp -a pif_name=$BACKUPNET_EN -a netboot_kernel=64 -a cable_type1=tp -a connect=shell" >> $FILE_DAT`
                NIMINIT_CMD_EXE=`$NIMINIT_CMD -a name=$1 -a master=nim -a platform=chrp -a pif_name=$BACKUPNET_EN -a netboot_kernel=64 -a cable_type1=tp -a connect=shell >> $FILE_DAT 2>&1`
                CMD_EXE=`echo "niminit end." >> $FILE_DAT`
            fi
        fi
    fi
else
    NIMINIT_CMD_EXE=`echo "niminit commnad vm-name input error" >> $FILE_DAT`
fi

exit 0
