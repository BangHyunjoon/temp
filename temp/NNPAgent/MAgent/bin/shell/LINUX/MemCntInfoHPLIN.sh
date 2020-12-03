#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

hpasmcli -s "show dimm" | grep "Cartridge" | wc -l 
#cat ./shell/LINUX/memory | grep "Cartridge" | wc -l 

