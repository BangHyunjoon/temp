#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

vmware-vim-cmd hostsvc/hostconfig | grep path | grep "vmfs/volumes" > ../aproc/shell/EsxInfoInv4.dat

