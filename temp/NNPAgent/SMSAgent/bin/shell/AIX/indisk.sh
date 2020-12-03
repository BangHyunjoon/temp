#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

lsdev -C | grep hdisk | grep ,0 | awk '{print $1}' > ../aproc/shell/indisk.dat

