#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

CPUTYPE=`uname -a | grep ia64`
if [[ -n $CPUTYPE ]] ; then
    exit
fi

cpu_model=$(grep -i $(model | tr "/" " " | awk '{print $NF}') /usr/sam/lib/mo/sched.models | awk '{print $NF}')

if [ -z $cpu_model ] ; then
    echo "N/S" > ../aproc/shell/CpuModel.dat
else
    echo $cpu_model > ../aproc/shell/CpuModel.dat
fi

exit 0

COMMAND=`which cstm 2> /dev/null | grep -v "no "`
if [[ -z $COMMAND ]] ; then
    exit
fi

FILE_CNT=`ls -al ../aproc/shell/CpuModel.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    CPUMODEL=`echo "selclass qualifier cpu;info;wait;il;view;done" | cstm | grep "CPU Module" | grep PA | awk '{print $1$2}'` 
    result=`echo $CPUMODEL | awk '{print $1}'`

    #if [[ -n $result ]] ; then
    #    echo $result > ../aproc/shell/CpuModel.dat
    #fi

    if [[ -z $result ]] ; then
        echo "N/S" > ../aproc/shell/CpuModel.dat
    else
        echo $result > ../aproc/shell/CpuModel.dat
    fi
fi
