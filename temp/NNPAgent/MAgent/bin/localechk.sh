#!/bin/sh

FILE_CNT=`ls -al ./locale.txt 2> /dev/null | wc -l`

if [ $FILE_CNT = 1 ] ; then
    \rm locale.txt
fi
locale | grep LANG > locale.txt

euckr=`cat ./locale.txt | grep -iv "utf8|utf-8" | egrep -i "euckr|euc-kr|ko_kr|korean|ko" | wc -l`
utf=`cat ./locale.txt | egrep -i "utf8|utf-8" | wc -l`

if [ $euckr -eq 0 -a $utf -eq 0 ]; then
    echo "etc="0 > locale.txt
elif [ $euckr -eq 1 -a $utf -eq 0 ]; then
    echo "euckr=1" > locale.txt
elif [ $euckr -eq 0 -a $utf -eq 1 ]; then
    echo "utf=2" > locale.txt
elif [ $euckr -eq 1 -a $utf -eq 1 ]; then
    echo "utf=2" > locale.txt
fi


