#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

./shell/SOLARIS/GMT_GTR_BIN > ../aproc/shell/GMT_GTR.dat
