#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
LANG=C
export LANG=C

system_profiler SPHardwareDataType | grep "Processor Name" > ../aproc/shell/CpuInfoMac.dat
echo "speed:"`sysctl -n hw.cpufrequency` >> ../aproc/shell/CpuInfoMac.dat
echo "count:"`sysctl -n hw.ncpu` >> ../aproc/shell/CpuInfoMac.dat
