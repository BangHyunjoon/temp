#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#ps -e -o pid -o ppid -o vsz -o rss -o pmem -o pcpu -o args | grep "AGENT"
for PID in `ps -e -o pid -o ppid -o vsz -o rss -o pmem -o pcpu -o args | grep "SMSAGENT" | grep -v grep | cut -d' ' -f1 | awk '{print $1}'`
do
    echo "PID=$PID"
    kill -9 $PID
done

exit 0

