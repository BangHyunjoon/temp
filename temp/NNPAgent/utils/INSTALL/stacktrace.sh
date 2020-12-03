#!/bin/sh

exit 0
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

PID=$1
OS=`uname -s`

if [ "$OS" = "AIX" ]; then
    command=`which procstack  2> /dev/null | grep -v "no " | wc -l`
    if [ $command -gt 0 ]; then
        ../../utils/ETC/ShCmd 5 procstack $PID
    else
        echo "procstack: command not found"
    fi
elif [ "$OS" = "HP-UX" ]; then
    command=`which pstack 2> /dev/null | grep -v "no " | wc -l`
    if [ $command -gt 0 ]; then
        ../../utils/ETC/ShCmd 5 pstack $PID
    else
        echo "pstack: command not found"
    fi
else
    command=`which pstack 2> /dev/null | grep -v "no " | wc -l`
    if [ $command -gt 0 ]; then
        ../../utils/ETC/ShCmd 5 pstack $PID
    else
        echo "pstack: command not found"
    fi
fi
