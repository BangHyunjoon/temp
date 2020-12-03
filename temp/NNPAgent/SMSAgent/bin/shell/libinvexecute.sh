#!/bin/sh
LANG=C; export LANG

#cpu, disk, interface
invtype=$1
#name inv gather, all inv gather, name chanage check
gathertype=$2
filename=$3

./libinvinfo $invtype $gathertype > $filename"_"
mv $filename"_" $filename