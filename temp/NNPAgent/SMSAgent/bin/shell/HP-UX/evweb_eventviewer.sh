#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/opt/sfm/bin/
export PATH

LANG=C
export LANG

DIFF_FILE=../aproc/shell/evweb_diff_tmp.dat
DPATH=../aproc/shell
if [ ! -f $DPATH/evweb_1.dat ] ; then
    rm -f $DPATH/evweb_diff.dat
fi

if [ ! -f $DPATH/evweb_1.dat ] ; then
    #Displays events that were generated in the last 5 days, with severity greater than or equal to Warning.
    #/opt/sfm/bin/evweb eventviewer -L -e ge:4 -a 5:dd | grep -v "======="  > $DPATH/evweb_1.dat
    /opt/sfm/bin/evweb eventviewer -L -a 5:dd | grep -v "=======" | grep -i Critical > $DPATH/evweb_1.dat
    exit 0
fi

/opt/sfm/bin/evweb eventviewer -L -a 5:dd | grep -v "=======" | grep -i Critical > $DPATH/evweb_2.dat
#cat ev_temp > $DPATH/evweb_2.dat

if ! cmp -s $DPATH/evweb_1.dat $DPATH/evweb_2.dat
then
    if [ -f $DPATH/evweb_2.dat ]; then
        diff -w $DPATH/evweb_1.dat $DPATH/evweb_2.dat | grep ^\> > $DPATH/evweb_3.dat
    fi

    while read strBuf
    do
        CHECK=`echo $strBuf | awk '{print $1}`
        if [ "$CHECK" = ">" ] ; then
            echo $strBuf | sed -e 's/>//g' >> $DIFF_FILE
        fi
    done < $DPATH/evweb_3.dat
fi

mv $DPATH/evweb_2.dat $DPATH/evweb_1.dat
rm -f $DPATH/evweb_3.dat

if [ -f $DIFF_FILE ] ; then
    LINE=`cat $DIFF_FILE | awk '{for(a=7;a<=NF;a++)print $a}'`
    echo "NKIA|"$LINE > ../aproc/shell/evweb_diff_result.dat
fi
rm -f $DIFF_FILE
exit 0
