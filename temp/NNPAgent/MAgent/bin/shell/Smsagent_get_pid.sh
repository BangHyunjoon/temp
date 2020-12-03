#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

FILENAME=$1"*"
ls -al $FILENAME | awk '{print $NF}' | awk -F'_' '{print $NF}'