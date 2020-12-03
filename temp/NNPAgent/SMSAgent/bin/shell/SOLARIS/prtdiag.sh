#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

PLATFORM='uname -m'

#/usr/platform/"$PLATFORM"/sbin/prtdiag
/usr/platform/sun4u/sbin/prtdiag
