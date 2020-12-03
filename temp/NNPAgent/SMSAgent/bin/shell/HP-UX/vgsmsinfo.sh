#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/symcli/bin
export PATH

./shell/HP-UX/vgsmsinfo > ../aproc/shell/vgsmsinfo_result.out &

