#!/bin/ksh
. ~root/.profile
HOSTNAME=`hostname`
#HOSTNAME=`echo "LIGRTP3"`
#lslpp -l | grep VRTSvcs.rte
LSLPP_ALL="lslpp -l"
HASTATUS_CMD="hastatus -sum"
CLTCMD="cltopinfo"
#LSLPP_ALL="cat ./shell/AIX/sample_dat/soft.dat"
#HASTATUS_CMD="cat ./shell/AIX/sample_dat/hastatus.dat"
#CLTCMD="cat ./shell/AIX/sample_dat/cltopinfo.dat"
VRTSvcs_GRP=`$LSLPP_ALL 2> /dev/null | grep VRTSvcs.rte`
if [ "$VRTSvcs_GRP" = "" ] ; then
    HACMP_Soft_GRP=`$LSLPP_ALL 2> /dev/null | grep cluster.es.server.rte`
    if [ "$HACMP_Soft_GRP" = "" ] ; then
        echo "Not found cluster product." > ../aproc/shell/ClusterInfo.dat
    else
        HACMP_Soft_VER=`echo $HACMP_Soft_GRP | cut -f 2 -d ' '`
        #echo $HACMP_Soft_VER
        CS_VERSION="cluster.es.server.rte($HACMP_Soft_VER)"
        # cltopinfo | grep "^NODE "
        CLTOPINFO=`$CLTCMD 2> /dev/null | grep "^NODE "`
        if [ "$CLTOPINFO" = "" ]; then
            echo "Not found cluster server info." > ../aproc/shell/ClusterInfo.dat
        else
            for i in `$CLTCMD 2> /dev/null | grep "^NODE " | awk '{print $2}'`
            do
                SP_HNAME=`echo $i | cut -f 1 -d ':'`
                #echo ">> host name = $SP_HNAME"
                if [ "$HOSTNAME" = "$SP_HNAME" ] ; then
                    #echo "hostname = <$SP_HNAME>"
                    continue
                else
                    #echo "Cluster Server <$SP_HNAME>"
                    for j in `grep $SP_HNAME /etc/hosts | awk '{print $1 "|" $2}'`
                    do
                        CSHOST_GRP=`echo "$j" | cut -f 2 -d '|'`
                        if [ "$CSHOST_GRP" = "$SP_HNAME" ]; then
                            CSHOST_IP=`echo "$j" | cut -f 1 -d '|'`
                        fi
                    done
                    if [ "$CSHOST_IP" = "" ]; then
                        CSHOST_IP="UNKNOWN"
                    fi
                    echo CS_NAME=HACMP > ../aproc/shell/ClusterInfo.dat
                    echo CS_VERSION=$CS_VERSION >> ../aproc/shell/ClusterInfo.dat
                    echo CSHOST_NAME=$SP_HNAME >> ../aproc/shell/ClusterInfo.dat
                    echo CSHOST_IP=$CSHOST_IP >> ../aproc/shell/ClusterInfo.dat
                    break
                fi
            done
        fi
    fi
else
    VRTSvcs_VER=`echo $VRTSvcs_GRP | cut -f 2 -d ' '`
    #echo $VRTSvcs_VER
    VRTSvxfs_GRP=`$LSLPP_ALL 2> /dev/null | grep VRTSvxfs`
    VRTSvxfs_VER=`echo $VRTSvxfs_GRP | cut -f 2 -d ' '`
    #echo $VRTSvxfs_VER
    VRTSvxvm_GRP=`$LSLPP_ALL 2> /dev/null | grep VRTSvxvm`
    VRTSvxvm_VER=`echo $VRTSvxvm_GRP | cut -f 2 -d ' '`
    #echo $VRTSvxvm_VER
    CS_VERSION="VRTSvcs.rte($VRTSvcs_VER), VRTSvxfs($VRTSvxfs_VER), VRTSvxvm($VRTSvxvm_VER)"
    #hastatus -sum
    HASTATUS_GRP=`$HASTATUS_CMD 2> /dev/null | grep "^A "`
    if [ "$HASTATUS_GRP" = "" ]; then
        echo "Not found cluster server info." > ../aproc/shell/ClusterInfo.dat
    else
        for i in `$HASTATUS_CMD 2> /dev/null | grep "^A " | awk '{print $2}'`
        do
            if [ "$HOSTNAME" = "$i" ] ; then
                #echo "hostname = <$i>"
                continue
            else
                #echo "Cluster Server <$i>"
                for j in `grep $i /etc/hosts | awk '{print $1 "|" $2}'`
                do
                    CSHOST_GRP=`echo "$j" | cut -f 2 -d '|'`
                    if [ "$CSHOST_GRP" = "$i" ]; then
                        CSHOST_IP=`echo "$j" | cut -f 1 -d '|'`
                    fi
                done
                if [ "$CSHOST_IP" = "" ]; then
                    CSHOST_IP="UNKNOWN"
                fi
                echo CS_NAME=VERITAS > ../aproc/shell/ClusterInfo.dat
                echo CS_VERSION=$CS_VERSION >> ../aproc/shell/ClusterInfo.dat
                echo CSHOST_NAME=$i >> ../aproc/shell/ClusterInfo.dat
                echo CSHOST_IP=$CSHOST_IP >> ../aproc/shell/ClusterInfo.dat
                break
            fi
        done
    fi
fi

