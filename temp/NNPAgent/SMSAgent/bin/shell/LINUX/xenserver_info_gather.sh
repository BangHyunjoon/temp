#!/bin/bash

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

EXIT_VAL=`./shell/LINUX/xenserver_host_xe_host-cpu-list.sh > ../aproc/shell/xenserver_host_xe_host-cpu-list.out 2>&1;echo $?`
# xe_info.dat, xenserver_host_cpu_used.dat
# xe_host-cpu-list.err

EXIT_VAL=`./shell/LINUX/xenserver_vm_list.sh > ../aproc/shell/xenserver_vm_list.out 2>&1;echo $?`
# vm-list.dat, vm-list-info.dat
# xe_vm-list.dat, xe_vm-list.err

#echo "[$EXIT_VAL]"
if [ $EXIT_VAL = 0 ] ; then
    EXIT_VAL=`./shell/LINUX/xenserver_xentop.sh > ../aproc/shell/xenserver_xentop.out 2>&1;echo $?`
    # xentop.dat, xentop.err
    # vm-perf.dat
fi

exit $EXIT_VAL
