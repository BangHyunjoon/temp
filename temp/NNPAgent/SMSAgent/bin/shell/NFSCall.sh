#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

nfsserver_check=`ps -ef | grep nfsd | grep -v grep | wc -l`
command=`which nfsstat 2> /dev/null | grep -v "no " | wc -l`

nfscalls=0
if [ $command -eq 0 ]; then
    echo $nfscalls
    exit 0
fi

if [ $nfsserver_check -ne 0 ]; then
    ../../utils/ETC/ShCmd 5 nfsstat -s 2> /dev/null > ./nfscall.txt
    badauthcheck=0
    servernfscheck=0
    if [ -s nfscall.txt ]; then
        while read line
        do
            if [ $badauthcheck -eq 0 ]; then
                badauthcheck=`echo $line | grep badauth | grep -v grep | wc -l`
            else
                nfscalls=`echo $line | awk '{print $1 + $2}'`
                echo $nfscalls
                break
            fi
            if [ $servernfscheck -eq 0 ]; then
                servernfscheck=`echo $line | grep "Server nfs:" | grep -v grep | wc -l`
            else
                read line
                nfscalls=`echo $line | awk '{print $1 + $2}'`
                echo $nfscalls
                break
            fi            
        done <./nfscall.txt
        if [ $badauthcheck -eq 0 -a $servernfscheck -eq 0 ]; then
            echo $nfscalls
        fi
    else
        echo $nfscalls
    fi
else
    ../../utils/ETC/ShCmd 5 nfsstat -c 2> /dev/null > ./nfscall.txt
    clgetscheck=0
    authrefrsh=0
    if [ -s nfscall.txt ]; then
        while read line
        do
            if [ $clgetscheck -eq 0 ]; then
                clgetscheck=`echo $line | grep clgets | grep -v grep | wc -l`
            else
                nfscalls=`echo $line | awk '{print $1 + $2}'`
                echo $nfscalls
                break
            fi
            if [ $authrefrsh -eq 0 ]; then
                authrefrshcheck=`echo $line | grep authrefrsh | grep -v grep | wc -l`
            else
                nfscalls=`echo $line | awk '{print $1}'`
                echo $nfscalls
                break
            fi       
        done <./nfscall.txt
        if [ $clgetscheck -eq 0 -a $authrefrsh -eq 0 ]; then
            echo $nfscalls
        fi        
    else
        echo $nfscalls
    fi
fi

unlink ./nfscall.txt 2> /dev/null
