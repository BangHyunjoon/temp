#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

hpasmcli -s "show server" | grep Core | cut -d ':' -f2 | awk '{x+=$1} END {print x}'
#cat ./shell/LINUX/server | grep Core | cut -d ':' -f2 | awk '{x+=$1} END {print x}'

