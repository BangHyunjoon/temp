#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

#ps -e -o pid -o ppid  -o user -o pcpu -o pmem -o vsz -o args
ps -e -o pid -o ppid -o ruser -o pcpu -o pmem -o vsz -o comm -o args
