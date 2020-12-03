#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG


lsattr -Elsys0 | grep systemid > ../aproc/shell/SystemId.dat

