#
# Copyright 2006 Nkia, Inc.  All rights reserved.
# Polestar auto install script
# Use subject to license terms.
#
#ident  "@(#)AgentInstall.sh  v0.2     06/02/23 "
#add     /usr/bin/csh adding  by jsyoo 06/03/27
#!/bin/sh

#VAGENT_TYPE="1"
#if [ "$1" = "-type=1" ] ; then
#    VAGENT_TYPE="1"
#else
#    if [ "$1" = "-type=2" ] ; then
#        VAGENT_TYPE="2"
#    else
#        echo "usage : $0 -type=< 1 | 2 >"
#        echo "      : type 1 - template vm agent install(auto update->ip, hostname setting)"
#        echo "      : type 2 - vm agent install(auto update->ip, hostname not setting)"
#        exit 255
#    fi
#fi

\cp -f ./AgentInstall.sh ./AgentInstall.sh_

grep -v "./NNPAgent/utils/INSTALL/AgentInstall " ./AgentInstall.sh_ | grep -v "./NNPAgent/DCAAgent/bin/DCAAgentInstall.sh 2 " > ./AgentInstall.sh

echo "./NNPAgent/DCAAgent/bin/DCAAgentInstall.sh 2 \$CUR_PATH R1.5.u635" >> ./AgentInstall.sh

grep "./NNPAgent/utils/INSTALL/AgentInstall " ./AgentInstall.sh_ >> ./AgentInstall.sh

\rm -f ./AgentInstall.sh_

./AgentInstall.sh -magent auip=127.0.0.1 makey=MA_ -addrc

echo "VAgent(VAGENT) setting..."
\cp ./NNPAgent/utils/INSTALL/patch.sh_vagent ./NNPAgent/utils/INSTALL/patch.sh
./NNPAgent/utils/ETC/ConfUpdate PROCNAME=VAGENT ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null

#echo "Agent auto upgrade server set(DNS) : ntops.sms.pe.kr"
#./NNPAgent/utils/ETC/ConfUpdate AUTO_UPGRADE_DNS=ntops.sms.pe.kr ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null
#./NNPAgent/utils/ETC/ConfUpdate DNS_SERVER_IP=10.180.213.179 ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null

#./NNPAgent/utils/ETC/ConfUpdate AUTO_UPGRADE_IP=10.180.213.174 ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null
./NNPAgent/utils/ETC/ConfUpdate AUTO_UPGRADE_IP=127.0.0.1 ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null

echo "Agent auto upgrade interval : 3600 sec(=1 hour)"
./NNPAgent/utils/ETC/ConfUpdate AUTO_UPDATE_TIME=60 ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null

echo "Agent type(1-templet, 2-vm) : $1"
./NNPAgent/utils/ETC/ConfUpdate VAGENT_TYPE=2 ./NNPAgent/MAgent/conf/MasterAgent.conf > /dev/null

#cd ./NNPAgent
#./agentstart.sh
