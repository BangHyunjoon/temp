#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG=C

ps -Nef | egrep $1 | grep -v PidGrep | grep -v egrep
