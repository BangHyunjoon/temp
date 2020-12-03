#!/bin/sh
pATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG=C

cat /proc/iomem | grep 'System RAM' | wc -l
