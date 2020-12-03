#!/bin/sh

dca_check=`cat ../conf/MasterAgent.conf | grep dcaagentctl | grep DCAAgent | wc -l`
echo "dca_check="$dca_check
if [ $dca_check -ge 2 ] ; then
    exit 0
fi

mkdir -p ../../DCAAgent/aproc
mkdir -p ../../DCAAgent/aproc/inv
mkdir -p ../../DCAAgent/aproc/resp
mkdir -p ../../DCAAgent/aproc/shell
mkdir -p ../../DCAAgent/log
mkdir -p ../../DCAAgent/conf
touch ../../DCAAgent/conf/DCAAgent.conf

CUR_PATH=`pwd`
cd ../..
NNP_PATH=`pwd`
cd ..
DCA_PATH=`pwd`
cd $CUR_PATH

../../DCAAgent/bin/DCAAgentInstall.sh 2 $DCA_PATH 7.x

exit 0
