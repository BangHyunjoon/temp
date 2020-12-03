#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

LANSCAN_FILE="../aproc/shell/ioscan_script.out"
LANADMIN_FILE="../aproc/shell/lanadmin_script.out"
RESULT_FILE="../aproc/shell/Nic_name_bandwidth.out"

\rm -f $LANSCAN_FILE
\rm -f $LANADMIN_FILE
\rm -f $RESULT_FILE
\rm -f $RESULT_FILE"_"

touch $RESULT_FILE"_"

lanscan | grep -v Hardware | grep -v NamePPA > $LANSCAN_FILE

echo #name,bandwidth,duplex(2:full,1:half)

while read line
do
    l_nPPA=`echo $line | awk '{print $3}'`
    l_strNAME=`echo $line | awk '{print $5}'`

    #bandwidth
    l_nSpeed=`lanadmin -s $l_nPPA | awk '{print $NF}' `
    if [[ -z $l_nSpeed ]] ; then
        l_nSpeed=1000000000
    fi
    #l_nSpeed=`expr $l_nSpeed / 1000`
    l_nSpeed=`echo "$l_nSpeed / 1000" | bc`

    #Duplex
    lanadmin -x $l_nPPA > $LANADMIN_FILE
    l_nCheck=`cat $LANADMIN_FILE | grep -i full | wc -l`
    if [ $l_nCheck -eq 1 ] ; then
        l_nDuplex=2
    else
        l_nCheck=`cat $LANADMIN_FILE | grep -i half | wc -l`
        if [ $l_nCheck -eq 1 ] ; then
            l_nDuplex=1
        else
            l_nDuplex=2
        fi
    fi 
    #echo "NKIA|"$l_strNAME"|"$l_nSpeed"|"$l_nDuplex
    echo "NKIA|"$l_strNAME"|"$l_nSpeed"|"$l_nDuplex >> $RESULT_FILE"_"

done <$LANSCAN_FILE

mv $RESULT_FILE"_" $RESULT_FILE
