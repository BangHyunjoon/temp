#!/bin/sh

PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export PATH

LANG=C
export LANG

./shell/IRIX/Chk_connect $1 $2 > ../aproc/shell/Chk_connect.dat


