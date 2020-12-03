#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

./shell/HP-UX/Chk_connect $1 $2 > ../aproc/shell/Chk_connect.dat


