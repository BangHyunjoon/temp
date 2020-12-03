#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

vmware-vim-cmd vmsvc/getallvms | awk '{print $1,$2'} | grep -v Vmid > ../aproc/shell/VMEntry.dat

