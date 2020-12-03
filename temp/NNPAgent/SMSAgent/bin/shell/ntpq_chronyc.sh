#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

l_ver=`cat /etc/redhat-release | awk -F'release' '{print $2}' | awk '{print $1}'`

if [ $(echo "$l_ver >= 8.0" | bc) -ne 0 ]  ; then
    exit 0
fi

NTPQ_OUT=../aproc/shell/ntpq_p.out

        l_unit_array=("ns" "us" "ms" "s")
        l_val_array=("1000000" "1000" "0" "0.001")

        #cp ../aproc/shell/ntpq_p.out_sss ../aproc/shell/ntpq_p.out
        chronyc sources > $NTPQ_OUT 2> /dev/null

        l_check=`grep \^"^\*" $NTPQ_OUT | wc -l`
        if [ $l_check -ge 1 ] ; then
            l_t_offset=`grep \^"^\*" $NTPQ_OUT | awk '{print $7}' | awk -F'[' '{print $1}'`
            #+493us -> + 493 us
            l_val1=`expr substr $l_t_offset 1 1`
            l_temp_val=`echo ${l_t_offset:1}`
            l_val2=`echo $l_temp_val | grep -o '[0-9]*'`
            l_val3=`echo $l_temp_val | sed -e 's/[0-9]//g'`

            #echo $l_val1 $l_val2 $l_val3

            l_idx=0
            for l_value in "${l_unit_array[@]}"
            do
                if [ "$l_val3" = "$l_value" ] ; then
                    break
                fi
                l_idx=`expr $l_idx + 1`
            done

            #echo $l_idx
            #echo ${l_val_array[$l_idx]}

            if [ $l_idx -eq 2 ] ; then
                l_offset=`echo $l_val2`
            else
                l_offset=`echo $l_val2 ${l_val_array[$l_idx]} | awk '{printf "%.4f", $1 / $2}' `
            fi

            echo "NKIA|"$l_val1$l_offset
        fi

exit 0
