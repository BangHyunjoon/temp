#!/bin/sh
LANG=C;export LANG

filename=$1

filecount=`ls -Rl $filename | grep ^- | wc -l`
filesize=`du -sk $filename | awk '{print $1}'`
echo $filecount"|"$filesize

