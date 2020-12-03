#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=C;
export LANG

cmdchk=1
l_idx=0
l_cmdrun=1
l_dca_flag=0

command=`which bc 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    cmdchk=0
fi

if [ -d ../../DCAAgent ] ; then
    l_dca_flag=1
    \rm -f ./dca_diskinfo.out 2> /dev/null
fi

diskname=`lspv | awk '{print $1}'`
for name in $diskname
do
    size=`bootinfo -s $name 2> /dev/null`

    if [ $l_cmdrun -eq 1 ] ; then
        starttime=`date +%Y%m%d%H%M%S`
        lscfg -vl $name 2> /dev/null > ./disk_lscfg.dat
        endtime=`date +%Y%m%d%H%M%S`

        if [ $cmdchk -eq 0 ]; then
            elapsetime=`expr $endtime - $starttime`
        else
            elapsetime=`echo "$endtime - $starttime" | bc`
        fi

        if [ $elapsetime -ge 2 ] ; then
            l_cmdrun=0
        fi
    fi

    if [ $l_cmdrun -eq 1 ] ; then
        vendor=`grep Manufacturer ./disk_lscfg.dat | awk -F. '{print $NF}'`
        type=`grep $name ./disk_lscfg.dat | awk '{for(a=3;a<=NF;a++)print $a}'`
        #serial=`grep Serial ./disk_lscfg.dat | awk -F. '{print $NF}'`

        if [ "$size" = "" ]; then
            size="UNKNOWN"
        fi
        if [ "$vendor" = "" ]; then
            value=`grep "Virtual SCSI" ./disk_lscfg.dat | wc -l`
            if [ $value -ne 0 ]; then
                vendor="Virtual SCSI Disk Drive"
            else
                vendor="UNKNOWN"
            fi
        fi
        if [ "$type" = "" ]; then
    	type="UNKNOWN"
        else
            idechk=`echo $type | grep -i "ide" | wc -l`
            if [ $idechk -ne 0 ];  then
                type="ide"
    	    fi    
            virchk=`echo $type | grep -i "Virtual scsi" | wc -l`
            if [ $idechk -eq 0 -a $virchk -ne 0 ];  then
                type="Virtual SCSI"
            fi    
            scsichk=`echo $type | grep -i "scsi" | wc -l`
            if [ $idechk -eq 0 -a $virchk -eq 0 -a $scsichk -ne 0 ];  then
                type="SCSI"
            fi   
        fi
    else
        vendor="UNKNOWN"
    	type="UNKNOWN"
    fi
    serial="UNKNOWN"

    echo $name"|"$size"|"$vendor"|"$type"|"$serial
    if [ $l_dca_flag -eq 1 ] ; then
        if [ "$vendor" = "UNKNOWN" ] ; then
            vendor=""
        fi
        if [ "$size" = "UNKNOWN" ] ; then
            size=""
        fi
        echo $name"|"$size"|"$vendor >> ./dca_diskinfo.out

    fi

    l_idx=`expr $l_idx + 1 `
    if [ $l_idx -ge 100 ] ; then
        l_idx=1
        sleep 1
    fi
done
\rm ./disk_lscfg.dat
