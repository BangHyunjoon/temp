#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/machinfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    TMP_DAT=`machinfo > ../aproc/shell/machinfo.dat`
fi

    result=`cat ../aproc/shell/machinfo.dat | grep "processor model" | awk '{for(a=4;a<=NF;a++) print $a}'`

    if [[ -z $result ]] ; then
        grp_cnt=0
        result=
        for i in `cat ../aproc/shell/machinfo.dat | grep "Intel(R) "`
        do
            #echo "i=[$i]"
            tmp_chk=`echo $i | grep "(" | wc -l`
            if [ $tmp_chk = 0 ] ; then
                result=`echo "$result $i`
            else
                tmp_chk=`echo $i | grep ")" | wc -l`
                if [ $tmp_chk = 0 ] ; then
                    break;
                else
                    result=`echo "$result $i`
                fi
            fi
        done
        #result=`machinfo | grep "Intel(R) " | grep " Itanium" | awk -F'(' '{print $1" ("$2}'`
        #echo $result
    fi
    if [[ -z $result ]] ; then
        echo "N/S" > ../aproc/shell/CpuModel_ia64.dat
    else
        echo $result > ../aproc/shell/CpuModel_ia64.dat
    fi
