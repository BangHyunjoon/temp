#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

cat $1 | grep \^CustomLog | tail -1 | awk '{print $2}' | tr -d '\n' > ./access_log_path.dat

