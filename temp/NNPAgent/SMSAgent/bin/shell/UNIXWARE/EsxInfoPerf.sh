#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

./shell/LINUX/EsxGtrPerf $1 > ../aproc/shell/EsxInfoPerf.dat_

