#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

VG_LV_DISPLAY_V_FILE="../aproc/shell/vg_lvdisplay_v.out"

touch ../aproc/shell/VgDisplay_Gather_result.out_
vgdisplay -v 2> /dev/null > $VG_LV_DISPLAY_V_FILE

l_nCnt=0
while read l_strBuf
do
    l_strVGCheckNAME=`echo $l_strBuf | awk '{print $1$2}'`
    if [ "$l_strVGCheckNAME" = "VGName" ] ; then
        l_strVGName=`echo $l_strBuf | awk '{print $3}'`
        l_nCnt=`expr $l_nCnt + 1`
        continue
    fi

    if [ $l_nCnt -ge 1 ] ; then
        l_strPECheckNAME=`echo $l_strBuf | awk '{print $1$2}'`
        if [ "$l_strPECheckNAME" = "PESize" ] ; then
            l_strPESize=`echo $l_strBuf | awk '{print $4}'`
            l_nCnt=`expr $l_nCnt + 1`
        fi

        l_strTotalCheckPE=`echo $l_strBuf | awk '{print $1$2}'`
        if [ "$l_strTotalCheckPE" = "TotalPE" ] ; then
            l_strTotalPE=`echo $l_strBuf | awk '{print $3}'`
            l_nCnt=`expr $l_nCnt + 1`
        fi
    
        l_strAllocCheckPE=`echo $l_strBuf | awk '{print $1$2}'`
        if [ "$l_strAllocCheckPE" = "AllocPE" ] ; then
            l_strAllocPE=`echo $l_strBuf | awk '{print $3}'`
            l_nCnt=`expr $l_nCnt + 1`
        fi
    fi

    if [ $l_nCnt -eq 4 ] ; then
        l_nTotal=`expr $l_strTotalPE \* $l_strPESize`
        l_nAlloc=`expr $l_strAllocPE \* $l_strPESize`
        l_nFree=`expr $l_nTotal - $l_nAlloc`
        l_nRate=`expr $l_strAllocPE \* 100 \/ $l_strTotalPE`
        echo "VG_INV:"$l_strVGName","$l_nTotal","$l_nAlloc","$l_nFree","$l_nRate >> ../aproc/shell/VgDisplay_Gather_result.out_
        l_nCnt=0
    fi
done < $VG_LV_DISPLAY_V_FILE

mv ../aproc/shell/VgDisplay_Gather_result.out_ ../aproc/shell/VgDisplay_Gather_result.out
