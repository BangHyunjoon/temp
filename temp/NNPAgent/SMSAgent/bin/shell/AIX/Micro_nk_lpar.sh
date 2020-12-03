#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

./shell/AIX/nk_Perfstat $1 > ../aproc/shell/Micro_lpar.dat 2>&1
