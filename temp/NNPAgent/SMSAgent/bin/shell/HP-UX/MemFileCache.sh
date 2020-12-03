#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/MemFileCache.dat
CMD=`echo " " > $FILE_DAT`

K_TUNE_CMD=kctune
COMMAND=`which kctune 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    COMMAND=`which kmtune 2> /dev/null | grep -v "no "`

    if [[ -z $COMMAND ]] ; then
        CMD=`echo "not found kernel param view command(kmtune or kctune)" > ../aproc/shell/MemFileCache.dat_err`
        K_TUNE_CMD=NO
    else
        K_TUNE_CMD=kmtune
    fi
fi

if [ "$K_TUNE_CMD" = "NO" ];then
    exit
fi

#echo "K_TUNE_CMD=$K_TUNE_CMD"

CMD_CNT=`$K_TUNE_CMD | grep dbc_ | wc -l`
if [ "$CMD_CNT" = 0 ];then
    
    CMD_CNT=`$K_TUNE_CMD | grep filecache_ | wc -l`
    #CMD_CNT=`cat ./$K_TUNE_CMD.dat | grep filecache_ | wc -l`

    if [ "$CMD_CNT" = 0 ];then
        CMD=`echo "not found cache kernel param(dbc_max/min_pct or filecache_max/min)" > ../aproc/shell/MemFileCache.dat_err`
    else
        CACHE_INFO=`$K_TUNE_CMD | grep filecache_ > $FILE_DAT`
        #echo $CACHE_INFO > $FILE_DAT
    fi
else
    CACHE_INFO=`$K_TUNE_CMD | grep dbc_ > $FILE_DAT`
    #echo $CACHE_INFO
fi
