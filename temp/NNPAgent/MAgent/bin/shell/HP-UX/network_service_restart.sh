#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

EXIT_CODE=0

echo "net service stop..."
/sbin/init.d/net stop

echo "Deletes all route table entries..."
route -f

echo "net service start..."
/sbin/init.d/net start

exit $EXIT_CODE
