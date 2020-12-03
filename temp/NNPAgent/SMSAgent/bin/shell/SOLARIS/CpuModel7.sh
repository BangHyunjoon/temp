#!/bin/sh

LD_LIBRARY_PATH=/lib
export LD_LIBRARY_PATH

kstat -c misc -m cpu_info | grep implementation | awk '{print $2}' | tail -1 > ../aproc/shell/CpuModel7.dat 2> /dev/null
