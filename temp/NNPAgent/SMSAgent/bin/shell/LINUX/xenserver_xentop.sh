#!/bin/bash

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

SH_CMD=xentop
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found command($SH_CMD)" > ../aproc/shell/xentop_err`
    #CMD=`echo "not found command($SH_CMD)" > ./xentop_err`
    exit 255
fi


FILE_DAT=../aproc/shell/xentop.dat
#FILE_DAT=./xentop.dat
T_FILE_DAT="$FILE_DAT"_

EXIT_VAL=`xentop -b -i 2 -d1 -f  > $T_FILE_DAT  2> ./xentop.err;echo $?`

CMD=`\rm -f $FILE_DAT`
CMD=`mv $T_FILE_DAT $FILE_DAT`

VM_READ_CNT=0
VN_CHECK=0
#date
while read line_xentop
do
    #echo "[$VM_READ_CNT] read line xentop = $line_xentop"
    if [ $VM_READ_CNT = 2 ] ; then
        CMD=`echo $line_xentop | sed '1,$s/^ *//' | sed '1,$s/ *$//' >> $T_FILE_DAT`
    else
        VM_CHECK=`echo $line_xentop | grep -v '[0-9]' | wc -l`
        if [ $VM_CHECK = 1 ] ; then
            VM_READ_CNT=$(echo "scale=0; $VM_READ_CNT + 1" | bc)
        fi
    fi
done <$FILE_DAT

CMD=`\rm -f $FILE_DAT`
CMD=`mv $T_FILE_DAT $FILE_DAT`


VM_LIST_FILE=../aproc/shell/vm-list-info.dat
#VM_LIST_FILE=./vm-list-info.dat

VM_PERF_FILE=../aproc/shell/vm-perf.dat
#VM_PERF_FILE=./vm-perf.dat
T_VM_PERF_FILE="$VM_PERF_FILE"_

CMD=`\rm -f $T_VM_PERF_FILE`

# shell : xenserver_vm_list.sh --> vm-list-info.dat
#1, a99e4869-475c-4002-8b86-d7d839c9cacb, 20120326T07:36:39Z, 20120326T07:34:10Z, Ubuntu-dev-sms
#2, c0513da0-c4ca-8d5b-1d1e-d729036b6733, 20120406T05:50:13Z, 20120406T05:50:06Z, PXE-CLIENT-TEST
#3, 79eed8aa-cc27-4f45-5a45-54aeba97dcf7, 20120404T05:15:34Z, 20120404T05:15:27Z, PXE-SERVER-W
#4, 063214c0-046f-6005-68cf-79253c59c730, 20120224T02:46:44Z, 20120224T02:50:03Z, rhel61-rhevm3beta
#6, 0c731c99-f3ee-6fb2-ea29-62cc3b3bef5e, 20120326T11:19:22Z, 20120326T11:14:51Z, Win2008R2-CLOUD-TFT
#7, bb8d0cf8-53d3-6e2f-23e2-94f7bb64ca78, 20120328T10:07:52Z, 20120328T10:07:44Z, PXE-SERVER-L
#8, 7b60519a-6019-90d4-b4e8-4f801ceb48fc, 20120329T05:11:22Z, 20120329T05:11:15Z, linux-64bit-dev-wpm
#9, 97ebcda9-1bca-e75a-9859-6efd4dffae68, 20120329T05:00:10Z, 20120329T05:00:02Z, linux-64bit-dev-sms

VM_STR=""
VM_CHECK=0
VM_TOKEN_INDEX=0
VM_TOKEN=""
VM_SUBTOKEN=""
VM_TOKEN_LEN1=0
VM_TOKEN_LEN2=0
VM_NEXTTOKEN=""
VM_ARRAY_CNT=0

VM_INDEX=0
VM_ID=""
VM_STATUS=""
VCPU_CNT=0
VCPU_USED=0.0
ALLOC_MEM=0
MEM_USED=0.0
NWT_CNT=0
NIC_MAC=""
NIC_MACS=""
TX_TRAFFIC=0
RX_TRAFFIC=0
VBD_CNT=0
VBD_OO=0
VBD_RD=0
VBD_WR=0
START_TIME=""
LAST_SHUTDOWN_TIME=""
VM_NAME=""

# "INDEX", "VM_NAME", "VMID", "VM_STATUS", 
# "VCPU_CNT", "VCPU_USED", 
# "ALLOC_MEM", "MEM_USED", 
# "NWT_CNT", "MAC", "TX_TRAFFIC", "RX_TRAFFIC", 
# "VBD_CNT", "VBD_OO", "VBD_RD", "VBD_WR", 
# "START_TIME", "LAST_SHUTDOWN_TIME"

echo "aaaa"
while read line_vmlist
do
    #echo "read line vmlist = $line_vmlist"
    VM_NAME=`echo $line_vmlist | awk -F", " '{print $5}'`
    VM_ID=`echo $line_vmlist | awk -F", " '{print $2}'`
    START_TIME=`echo $line_vmlist | awk -F", " '{print $3}'`
    LAST_SHUTDOWN_TIME=`echo $line_vmlist | awk -F", " '{print $4}'`

    echo "bbbb"
    while read line_xentop
    do
        #VM_CHECK=$(echo "$line_xentop" | grep "^$line_vmlist " | wc -l)
        VM_CHECK=$(echo "$line_xentop" | grep "^$VM_NAME " | wc -l)
        echo "[$VM_CHECK] read line xentop = [$line_xentop] <===> [$VM_NAME]"
        if [ $VM_CHECK = 1 ] ; then
            #echo "[$VM_CHECK]==> VM[$line_vmlist], XENTOP[$line_xentop]"
            #echo "[$VM_CHECK]==> VM[$VM_NAME], XENTOP[$line_xentop]"

            #VM_TOKEN=$line_xentop
            VM_TOKEN_INDEX=0
            #VM_TOKEN_LEN1=$(expr length "$line_vmlist ")
            VM_TOKEN_LEN1=$(expr length "$VM_NAME ")
            VM_TOKEN_LEN2=$(expr length "$line_xentop")
            VM_SUBTOKEN=$(expr substr "$line_xentop" $VM_TOKEN_LEN1 $VM_TOKEN_LEN2)

            VM_ARRAY=( $VM_SUBTOKEN )
            VM_ARRAY_CNT=${#VM_ARRAY[@]}        
            echo "ARRAY COUNT=[$VM_ARRAY_CNT]"
            if [ $VM_ARRAY_CNT = 18 ] ; then
                let "VM_INDEX = $VM_INDEX + 1"

                VM_STATUS=${VM_ARRAY[0]}
                if [ "$VM_STATUS" = "------" ] ; then
                    VM_STATUS="-----r"
                fi
                    
                VCPU_CNT=${VM_ARRAY[7]}
                VCPU_USED=${VM_ARRAY[2]}
                ALLOC_MEM=${VM_ARRAY[3]}
                let "ALLOC_MEM = $ALLOC_MEM / 1024"
                MEM_USED=${VM_ARRAY[4]}
                NWT_CNT=${VM_ARRAY[8]}
                NIC_MACS=""
                for NIC_MAC in `xl network-list "$VM_NAME" | grep ":" | awk -F " " '{print $3}'`
                do
                    if [ "$NIC_MACS" != "" ] ; then
                        NIC_MACS="$NIC_MACS",
                    fi
                    NIC_MACS="$NIC_MACS$NIC_MAC"
                done
                TX_TRAFFIC=${VM_ARRAY[9]}
                RX_TRAFFIC=${VM_ARRAY[10]}
                VBD_CNT=${VM_ARRAY[11]}
                VBD_OO=${VM_ARRAY[12]}
                VBD_RD=${VM_ARRAY[13]}
                VBD_WR=${VM_ARRAY[14]}

                VM_ARRAY_INDX=0
                while [ $VM_ARRAY_INDX -lt $VM_ARRAY_CNT ]
                do
                    echo "ARRAY[$VM_ARRAY_INDX]=[${VM_ARRAY[$VM_ARRAY_INDX]}]"
                    let "VM_ARRAY_INDX = $VM_ARRAY_INDX + 1"
                done

                echo "$VM_INDEX, $VM_ID, $VM_STATUS, $VCPU_CNT, $VCPU_USED, $ALLOC_MEM, $MEM_USED, $NWT_CNT, $NIC_MACS, $TX_TRAFFIC, $RX_TRAFFIC, $VBD_CNT, $VBD_OO, $VBD_RD, $VBD_WR, $START_TIME, $LAST_SHUTDOWN_TIME, $VM_NAME" >> $T_VM_PERF_FILE
                echo "$VM_INDEX, $VM_ID, $VM_STATUS, $VCPU_CNT, $VCPU_USED, $ALLOC_MEM, $MEM_USED, $NWT_CNT, $NIC_MACS, $TX_TRAFFIC, $RX_TRAFFIC, $VBD_CNT, $VBD_OO, $VBD_RD, $VBD_WR, $START_TIME, $LAST_SHUTDOWN_TIME, $VM_NAME"

                break
            fi
        fi
    done <$FILE_DAT
done <$VM_LIST_FILE

CMD=`\rm -f $VM_PERF_FILE 2> /dev/null`
CMD=`mv $T_VM_PERF_FILE $VM_PERF_FILE 2> /dev/null`

#      NAME  STATE   CPU(sec) CPU(%)     MEM(k) MEM(%)  MAXMEM(k) MAXMEM(%) VCPUS NETS NETTX(k) NETRX(k) VBDS   VBD_OO   VBD_RD   VBD_WR  VBD_RSECT  VBD_WSECT SSID
#  Domain-0 -----r     172345   13.2     771328    2.3     771328       2.3     8    0        0        0    0        0        0        0          0          0    0
#linux-64bit-dev-sms --b---      10139    8.4    1048548    3.1    1061888       3.2     2    2        0        0    3        0        0        0          0          0    0
#linux-64bit-dev-wpm --b---      13525    2.7    1048548    3.1    1061888       3.2     2    2        0        0    3        0        0        0          0          0    0
#    nkia01 --b---       1599    0.3    2097124    6.3    2118656       6.3     2    2        0        0    2        0        0        0          0          0    0
#PXE-CLIENT-TEST --b---       3857    5.9    2097120    6.3    2118656       6.3     2    1        0        0    2        0        0        0          0          0    0
#PXE-SERVER-L --b---       1975    0.1    2097120    6.3    2118656       6.3     2    3  1427731  4089386    3     7172   348982   244227   23879014   19682506    0
#PXE-SERVER-W --b---      10101    1.9    2097124    6.3    2118656       6.3     2    3        0        0    2        0        0        0          0          0    0
#Ubuntu-dev --b---       4869    0.5    2097124    6.3    2117632       6.3     1    1        0        0    2        0        0        0          0          0    0
#Win2008R2-CLOUD-TFT --b---       7470    1.1    2097124    6.3    2118656       6.3     2    2        0        0    3        0        0        0          0          0    0

exit $EXIT_VAL
