#!/bin/sh
LANG=C;export LANG

if [ -z $1 ]; then
    exit 0
fi

l_dca_flag=0
if [ $1 -eq 2 ]; then
    fdisk -l 2> /dev/null | grep -i ^Disk | grep [a-zA-Z]  > ./fdisk_result.txt

    if [ -d ../../DCAAgent ] ; then
        l_dca_flag=1
        \rm ./dca_diskinfo.out 2> /dev/null
    fi
fi

VALUE=`which lsblk 2> /dev/null |  wc -l`
if [ $VALUE -eq 0 ]; then
    touch ./lsblk_result.txt
else
    lsblk | grep ^nvme | grep disk > ./lsblk_result.txt
fi



while read line
do
    value=`echo $line | egrep -i "emcpower|dm-|sddlma|major" | wc -l`
    if [ $value -ne 0 ]; then
        continue
    fi
    value=`echo $line | grep "[a-zA-Z]" | wc -l`
    if [ $value -eq 0 ]; then
        continue
    fi
    #partitions minor version check(minor == 0 or minor % 16 == 0)
    value=`echo $line | awk '{print $2%16}'`
    if [ $value -ne 0 ]; then
        l_diskname=`echo $line | awk '{print $NF}'`
        l_check=`cat ./lsblk_result.txt | grep $l_diskname | wc -l`
        if [ $l_check -ne 1 ] ; then
            continue
        fi
    fi
    DiskSize=`echo $line | awk '{print $3}'`
    if [ $DiskSize -le 900000 ]; then
        continue
    fi
    name=`echo $line | awk '{print $4}'`
    DiskName=/dev/$name

    if [ $1 -eq 1 ]; then
        echo "NKIADSK|"$DiskName
    else
        DiskSize=`expr $DiskSize \/ 1000`
        if [ -f /sys/block/$name/device/vendor ];  then
            DiskVendor=`cat /sys/block/$name/device/vendor | head -1` 
            if [ ${#DiskVendor} -le 2 ] ; then
                DiskVendor="-"
            fi
            value=`echo $DiskVendor | grep [a-zA-Z] | wc -l`
            if [ $value -eq 0 ] ; then
                DiskVendor="-"
            fi
        else
            DiskVendor="-"
        fi
        if [ -f /sys/block/$name/device/type ];  then
            DiskType=`cat /sys/block/$name/device/type | head -1` 
            if [ ${#DiskType} -le 2 ] ; then
                DiskType="-"
            fi
        else
            DiskType="-"
        fi
        value=`grep $DiskName ./fdisk_result.txt | grep GB | wc -l`
        if [ $value -eq 1 ]; then
            TotalSize=`grep $DiskName ./fdisk_result.txt | awk -F'GB' '{print $1}' | awk '{print $(NF)*1000}'`
            #TotalSize=`grep $DiskName ./fdisk_result.txt | awk '{print $(NF-1)/1000/1000}'`
        else
            TotalSize=$DiskSize
        fi
        if [ -z "$TotalSize" ]; then
            TotalSize="-"
        fi
        echo "NKIADSK|"$DiskName"|"$DiskVendor"|"$DiskType"|"$DiskSize"|"$TotalSize

        if [ $l_dca_flag -eq 1 ] ; then
            if [ "$DiskVendor" = "-" ] ; then
                DiskVendor=""
            fi
            if [ "$TotalSize" = "-" ] ; then
                TotalSize=""
            fi
            echo $DiskName"|"$TotalSize"|"$DiskVendor >> ./dca_diskinfo.out
        fi
    fi

done </proc/partitions

if [ $1 -eq 2 ]; then
    \rm ./fdisk_result.txt 2> /dev/null
    \rm ./lsblk_result.txt 2> /dev/null
fi

exit 0
