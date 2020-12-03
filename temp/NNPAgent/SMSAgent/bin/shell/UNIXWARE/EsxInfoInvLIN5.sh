#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

cat $1 | grep -w ethernet0.generatedAddress > ../aproc/shell/EsxInfoInv5.dat

