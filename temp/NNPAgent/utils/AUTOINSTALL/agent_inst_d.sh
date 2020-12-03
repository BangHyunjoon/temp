#!/bin/sh

cd /home/cams/NNPAgent/utils/AUTOINSTALL

LANG=C
export LANG


LINUX=Linux
SOLARIS=SunOS
HP=HP-UX
HP10=10
OSF=OSF1
AIX=AIX
UNIXWARE=Uinxware
MAC=Darwin
IRIX=IRIX64

OS=`uname -s`
CUR_SHELL=`echo $SHELL`
CUR_PATH=`cd ../../..;/bin/pwd`

INSTALL_RST=SUCCESS
INSTALL_RSTMSG=-

if [ "$OS" = "$SOLARIS" ]; then

    LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
    export LD_LIBRARY_PATH

elif [ "$OS" = "$HP" ]; then

    VS=`uname -r | cut -f 2 -d "."`
    if [ "$HP10" = "$VS" ]; then
        if [ ! -f /usr/lib/libpthread.sl ]; then
            $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/LIB/libpthread.sl /usr/lib/libpthread.sl
        fi

        LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH
    fi

elif [ "$OS" = "$HP" ]; then

    if [ -f /usr/bin/gcc ]; then
        echo ""
        #echo "/usr/bin/gcc is exists"
    else
        #echo "/usr/bin/gcc is not exists"
        LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH
    fi
fi

\rm -f ./reason.log
DATE=`date`
echo "[$DATE] Agent auto install start" > ./autoinstall.log

WSM="START"
JMX=" "
JAVA_HOME=" "
WSM_RUN=" "
AGENT_UPGRADE_IP=183.110.187.12
AGENT_UPGRADE_PORT=8080
CFG_VERSION=TEST
SLEEP_SEC=60
CONF_UPDATE_FLAG=TRUE
WEBSERVER_IP=220.123.31.4
AGENT_WEBSERVER_IP=$WEBSERVER_IP
AGENT_WEBSERVER_PORT=8080
echo "AGENT_WEBSERVER_IP=$WEBSERVER_IP" >> ./autoinstall.log
echo "../ETC/TextUpdate WEBSERVER_IP=$WEBSERVER_IP ./agent_inst_d.sh" > ./wip.sh
chmod 700 ./wip.sh

while [ 1 ]
do
    curl http://172.27.0.1/latest/instance-id > ./VMID.dat 2>/dev/null

    VMID_CHK=`wc -c ./VMID.dat | cut -f 1 -d " "`
    if [ "$VMID_CHK"  = "0" ]; then
        DATE=`date`
        echo "[$DATE] <VMID> download failed" >> ./autoinstall.log
    else
        break
    fi
    sleep 60
done

VMID=`cat ./VMID.dat | awk -F-VM '{print $1}'`-VM

CFG_FILE=`echo "$VMID"_AGENT.cfg`
CFG_FILE_PATH=`echo ./"$VMID"_AGENT.cfg`
CFG_OLDFILE_PATH=`echo ./"$VMID"_AGENT_old.cfg`

echo "[$DATE] Agent VM ID = [$VMID]" >> ./autoinstall.log
echo "[$DATE]cat $CFG_OLDFILE_PATH" >> ./autoinstall.log

AGENT_KEY=$VMID

if [ -f $CFG_OLDFILE_PATH ]; then
    for j in `cat $CFG_OLDFILE_PATH`
    do
        OPARAM_NUM=`echo $j | cut -d ';' -f 1`
        OPARAM=`echo $j | cut -d ';' -f 2`
        OPARAM_NAME=`echo $OPARAM | cut -d= -f 1`
        OPARAM_VALUE=`echo $OPARAM | cut -d= -f 2`

        if [ "$OPARAM_NAME" = "CFG_VERSION" ]; then
            CFG_VERSION=$OPARAM_VALUE
        elif [ "$OPARAM_NAME" = "DEMON_CHECK_PERIOD" ]; then
            SLEEP_SEC=$OPARAM_VALUE
        elif [ "$OPARAM_NAME" = "AGENT_WEBSERVER_IP" ]; then
            AGENT_WEBSERVER_IP=$OPARAM_VALUE
        elif [ "$OPARAM_NAME" = "AGENT_WEBSERVER_PORT" ]; then
            AGENT_WEBSERVER_PORT=$OPARAM_VALUE
        fi
    done
else 
    echo "[$DATE]not found $CFG_OLDFILE_PATH" >> ./autoinstall.log
fi

while [ 1 ]
do

    INSTALL_RST=SUCCESS
    INSTALL_RSTMSG=-

    DATE=`date`
    CFG_VER_CHECK=0

    # download cfg file
    DATE=`date`
    DOWN_CFG_CMD=`echo "./AutoInstall $AGENT_WEBSERVER_IP $AGENT_WEBSERVER_PORT $CFG_FILE"`
    echo "[$DATE] 1 $DOWN_CFG_CMD" >> ./autoinstall.log
    $DOWN_CFG_CMD
    sleep 10
    DATE=`date`

    if [ -f $CFG_FILE_PATH ]; then

        DOWN_CHK=`wc -c $CFG_FILE_PATH | cut -f 1 -d " "`
        if [ "$DOWN_CHK"  = "0" ]; then
            echo "[$DATE] cfg file[$CFG_FILE] download failed(size zero)" >> ./autoinstall.log
            echo "cfg file[$CFG_FILE] download failed(size zero)" > ./reason.log
            INSTALL_RST=FAILED
            INSTALL_RSTMSG=`cat ./reason.log`
            ../ETC/ShCmd 10 "./ResultSend $AGENT_WEBSERVER_IP $AGENT_WEBSERVER_PORT  $VMID $INSTALL_RST \"$INSTALL_RSTMSG\"" >> ./autoinstall.log  2>&1
            sleep 10
            continue
        fi

        DOWN_CHK=`grep CFG_VERSION= $CFG_FILE_PATH | wc -l`
        if [ "$DOWN_CHK"  = "0" ]; then
            echo "[$DATE] cfg file[$CFG_FILE] error(not foud CFG_VERSION)" >> ./autoinstall.log

            echo "cfg file[$CFG_FILE] error(not foud CFG_VERSION)" > ./reason.log
            INSTALL_RST=FAILED
            INSTALL_RSTMSG=`cat ./reason.log`
            ../ETC/ShCmd 10 "./ResultSend $AGENT_WEBSERVER_IP $AGENT_WEBSERVER_PORT  $VMID $INSTALL_RST \"$INSTALL_RSTMSG\"" >> ./autoinstall.log  2>&1
            sleep 10
            continue
        fi

        echo "[$DATE]cat-1 $CFG_FILE_PATH" >> ./autoinstall.log
        ls -al >> ./autoinstall.log

        cat $CFG_FILE_PATH | tr -d "\r\t" > aa
        \mv -f aa $CFG_FILE_PATH 

        # cfg file version check
        for j in `cat $CFG_FILE_PATH`
        do
            PARAM_NUM=`echo $j | cut -d ';' -f 1`
            PARAM=`echo $j | cut -d ';' -f 2`
            PARAM_NAME=`echo $PARAM | cut -d= -f 1`
            PARAM_VALUE=`echo $PARAM | cut -d= -f 2`

            if [ "$PARAM_NAME" = "CFG_VERSION" ]; then
                echo "[$DATE]CFG_VERSION=[$CFG_VERSION], PARAM_VALUE=[$PARAM_VALUE]" >> ./autoinstall.log
                if [ "$CFG_VERSION" = "$PARAM_VALUE" ]; then
                    CFG_VER_CHECK=0
                else
                    CFG_VER_CHECK=1
                    CFG_VERSION=$PARAM_VALUE
                fi
            fi

            if [ "$OPARAM_NAME" = "JMX_AGENT_COMMAND" ]; then
                if [ "$OPARAM_VALUE" = "-start" ]; then
                    JMX="START"
                fi
            elif [ "$OPARAM_NAME" = "JAVA_HOME" ]; then
                JAVA_HOME=$OPARAM_VALUE
            elif [ "$OPARAM_NAME" = "WEBSERVER_MONITOR_RUN" ]; then
                WSM_RUN=$OPARAM_VALUE
            fi
        done

        if [ "$JMX" = "START" ]; then
            if [ -f $JAVA_HOME/bin/java ]; then
                \cp -f ./wasagent.jar ../..
                echo "[$DATE] parent : $JAVA_HOME/bin/java -jar -Dsetup_dir=/home/cams/NNPAgent -Dagent_java=$JAVA_HOME wasagent.jar" >> ./autoinstall.log
                ../ETC/TextUpdate JAVA_HOME=$JAVA_HOME ./wasinstall.sh
                chmod 700 ./wasinstall.sh
                ./wasinstall.sh >> ./autoinstall.log 2>&1
                \rm -f ../../wasagent.jar
                if [ ! -f /home/cams/NNPAgent/WASAgent/bin/wastart.sh ]; then
                    echo "JMX Agent install failed." >> ./autoinstall.log
                    echo "JMX Agent install failed." > ./reason.log
                    INSTALL_RST=FAILED
JMX=" "
                else 
                    echo "[$DATE]JMX Agent install success" >> ./autoinstall.log
                fi
            else 
                echo "[$DATE]Not found java.[$JAVA_HOME/bin/java]" >> ./autoinstall.log
                echo "Not found java.[$JAVA_HOME/bin/java]" > ./reason.log
                INSTALL_RST=FAILED
            fi
        fi

        echo "[$DATE]cfg version check = $CFG_VER_CHECK" >> ./autoinstall.log
        if [ "$CFG_VER_CHECK" = "1" ]; then

            MIP=" "
            MAIP=" "
            MKEY=" "
            MPORT=" "
            MCONNECT_TYPE=" "
            MEVENT_FLAG=" "
            MID=" "
            AGENT_COMMAND=" "

            cd /home/cams/NNPAgent/
            ./agentstop.sh
            cd /home/cams/NNPAgent/utils/AUTOINSTALL
            
            echo "[$DATE]cat-2 $CFG_FILE_PATH" >> ./autoinstall.log
            ls -al >> ./autoinstall.log

            for k in `cat $CFG_FILE_PATH`
            do
                echo "[$DATE]READ [$k]" >> ./autoinstall.log
                PARAM_NUM=`echo $k | cut -d ';' -f 1`
                PARAM=`echo $k | cut -d ';' -f 2`
                PARAM_NAME=`echo $PARAM | cut -d= -f 1`
                PARAM_VALUE=`echo $PARAM | cut -d= -f 2`
                echo "[$DATE]PARAM=[$PARAM]" >> ./autoinstall.log
                echo "[$DATE]PARAM_NUM=[$PARAM_NUM]" >> ./autoinstall.log
                echo "[$DATE]PARAM_NAME=[$PARAM_NAME]" >> ./autoinstall.log
                echo "[$DATE]PARAM_VALUE=[$PARAM_VALUE]" >> ./autoinstall.log
                if [ "$PARAM_NUM" = "1" ]; then

                    if [ "$PARAM_NAME" = "MANAGER1_IP" ]; then
                        MIP=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_AGENT_IP" ]; then
                        MAIP=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_KEY" ]; then
                        MKEY=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_PORT" ]; then
                        MPORT=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_CONNECT_TYPE" ]; then
                        MCONNECT_TYPE=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_EVENT_FLAG" ]; then
                        MEVENT_FLAG=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "MANAGER1_ID" ]; then
                        MID=$PARAM_VALUE
                    fi

                elif [ "$PARAM_NUM" = "2" ]; then

                    CONF_UPDATE_FLAG=TRUE

                    if [ "$PARAM_NAME" = "MASTER_AGENT_KEY" ]; then
                        AGENT_KEY=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "AUTO_UPGRADE_IP" ]; then
                        AGENT_UPGRADE_IP=$PARAM_VALUE
                    elif [ "$PARAM_NAME" = "SMS_AGENT_COMMAND" ]; then
                        if [ "$PARAM_VALUE" = "-start" ]; then
                            echo "[$DATE]SMS Agent info param[MODULE1_AGENT_AUTO_RUN=TRUE] setting" >> ./autoinstall.log
                            ../ETC/ConfUpdate MODULE1_AGENT_AUTO_RUN=TRUE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                        else
                            echo "[$DATE]SMS Agent info param[MODULE1_AGENT_AUTO_RUN=FALSE] setting" >> ./autoinstall.log
                            ../ETC/ConfUpdate MODULE1_AGENT_AUTO_RUN=FALSE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                        fi
                        
                        if [ "$SMS" = "START" ]; then
                            echo "[$DATE]SMS Agent info param[MODULE1_AGENT_AUTO_RUN=TRUE] setting(Input arg=SMS)" >> ./autoinstall.log
                            ../ETC/ConfUpdate MODULE1_AGENT_AUTO_RUN=TRUE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                        fi  
                        CONF_UPDATE_FLAG=FALSE
                    elif [ "$PARAM_NAME" = "WSM_AGENT_COMMAND" ]; then
                        if [ "$PARAM_VALUE" = "-stop" ]; then
                            echo "[$DATE]SMS Agent info param[WEBSERVER_MONITOR_RUN=0] setting" >> ./autoinstall.log
                            ../ETC/ConfUpdate WEBSERVER_MONITOR_RUN=0 ../../SMSAgent/conf/SMSAgent.conf >> ./autoinstall.log 2>&1
                            if [ "$WSM" = " " ]; then
                                WSM="STOP"
                            fi
                        else
                            WSM="START"
                            if [ ! "$WSM_RUN" = " " ]; then
                                ../ETC/ConfUpdate WEBSERVER_MONITOR_RUN=$WSM_RUN ../../SMSAgent/conf/SMSAgent.conf >> ./autoinstall.log 2>&1
                            fi
                        fi
                        CONF_UPDATE_FLAG=FALSE
                    elif [ "$PARAM_NAME" = "JMX_AGENT_COMMAND" ]; then
                        JMX_PARAM_CK=`grep ^MODULE2_ ../../MAgent/conf/MasterAgent.conf | wc -l`
                        if [ $JMX_PARAM_CK = 7 ]; then
                            if [ "$PARAM_VALUE" = "-start" ]; then
                                echo "[$DATE]JMX Agent info param[MODULE2_AGENT_AUTO_RUN=TRUE] setting" >> ./autoinstall.log
                                ../ETC/ConfUpdate MODULE2_AGENT_AUTO_RUN=TRUE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                            else
                                echo "[$DATE]JMX Agent info param[MODULE2_AGENT_AUTO_RUN=FALSE] setting" >> ./autoinstall.log
                                ../ETC/ConfUpdate MODULE2_AGENT_AUTO_RUN=FALSE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                            fi
                            if [ "$JMX" = "START" ]; then
                                echo "[$DATE]JMX Agent info param[MODULE2_AGENT_AUTO_RUN=TRUE] setting(Input arg=JMX)" >> ./autoinstall.log
                                ../ETC/ConfUpdate MODULE2_AGENT_AUTO_RUN=TRUE ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                            fi  
                        fi
                        CONF_UPDATE_FLAG=FALSE
                    fi

                    if [ "$CONF_UPDATE_FLAG" = "TRUE" ]; then
                        echo "[$DATE]SMS Agent info param[$PARAM] setting" >> ./autoinstall.log
                        ../ETC/ConfUpdate $PARAM ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
                    fi

                elif [ "$PARAM_NUM" = "3" ]; then

                    echo "[$DATE]WSM Agent info param[$PARAM] setting" >> ./autoinstall.log
                    ../ETC/ConfUpdate $PARAM ../../SMSAgent/conf/SMSAgent.conf >> ./autoinstall.log 2>&1

                    if [ "$PARAM_NAME" = "WEBSERVER_MONITOR_RUN" ]; then
                        if [ "$WSM" = "STOP" ]; then
                            ../ETC/ConfUpdate WEBSERVER_MONITOR_RUN=0 ../../SMSAgent/conf/SMSAgent.conf >> ./autoinstall.log 2>&1
                        else
                            ../ETC/ConfUpdate WEBSERVER_MONITOR_RUN=$PARAM_VALUE ../../SMSAgent/conf/SMSAgent.conf >> ./autoinstall.log 2>&1
                        fi
                        WSM_RUN=$PARAM_VALUE
                    fi
                elif [ "$PARAM_NUM" = "4" ]; then

                    CONF_UPDATE_FLAG=TRUE

                    if [ "$JMX" = "START" ]; then
                        if [ "$PARAM_NAME" = "JAVA_HOME" ]; then
                            echo "[$DATE]JMX Agent info param[$PARAM] setting" >> ./autoinstall.log
                            ../ETC/TextUpdate $PARAM ../../WASAgent/bin/setenv.sh >> ./autoinstall.log 2>&1
                            CONF_UPDATE_FLAG=FALSE
                        fi

                        if [ "$CONF_UPDATE_FLAG" = "TRUE" ]; then
                            echo "[$DATE]JMX Agent info param[$PARAM] setting" >> ./autoinstall.log
                            ../ETC/TextUpdate $PARAM ../../WASAgent/conf/jmx.properties >> ./autoinstall.log 2>&1
                        fi
                    fi

                elif [ "$PARAM_NUM" = "5" ]; then

                    echo "[$DATE]ETC Agent info param[$PARAM] setting" >> ./autoinstall.log
                    if [ "$PARAM_NAME" = "AGENT_COMMAND" ]; then
                        if [ "$PARAM_VALUE" = "-start" ]; then
                            AGENT_COMMAND=$PARAM_VALUE 
                        fi
                    fi
                fi
            done

            if [ "$MIP" = " " ]; then
                AGENT_INSTALL=`echo "./AgentInstall.sh -magent auip=$AGENT_UPGRADE_IP makey=$AGENT_KEY -addrc"`
            elif [ "$MAIP" = " " ]; then
                AGENT_INSTALL=`echo "./AgentInstall.sh -magent auip=$AGENT_UPGRADE_IP makey=$AGENT_KEY -minfo mip1=$MIP -addrc"`
            else
                AGENT_INSTALL=`echo "./AgentInstall.sh -magent auip=$AGENT_UPGRADE_IP makey=$AGENT_KEY -minfo mip1=$MIP maip1=$MAIP -addrc"`
            fi

            cd /home/cams
            $AGENT_INSTALL > /dev/null 2>&1
            cd /home/cams/NNPAgent/utils/AUTOINSTALL

            DATE=`date`

            if [ ! "$MKEY" = " " ]; then
                ../ETC/ConfUpdate MANAGER1_KEY=$MKEY ../../MAgent/conf/ManagerInfo.conf >> ./autoinstall.log 2>&1
                echo "MANAGER1_KEY=$MKEY" >> ./autoinstall.log
            fi 
            if [ ! "$MPORT" = " " ]; then
                ../ETC/ConfUpdate MANAGER1_PORT=$MPORT ../../MAgent/conf/ManagerInfo.conf >> ./autoinstall.log 2>&1
                echo "MANAGER1_PORT=$MPORT" >> ./autoinstall.log
            fi 
            if [ ! "$MCONNECT_TYPE" = " " ]; then
                ../ETC/ConfUpdate MANAGER1_CONNECT_TYPE=$MCONNECT_TYPE ../../MAgent/conf/ManagerInfo.conf >> ./autoinstall.log 2>&1
                echo "MANAGER1_CONNECT_TYPE=$MCONNECT_TYPE" >> ./autoinstall.log
            fi 
            if [ ! "$MEVENT_FLAG" = " " ]; then
                ../ETC/ConfUpdate MANAGER1_EVENT_FLAG=$MEVENT_FLAG ../../MAgent/conf/ManagerInfo.conf >> ./autoinstall.log 2>&1
                echo "MANAGER1_EVENT_FLAG=$MEVENT_FLAG" >> ./autoinstall.log
            fi 
            if [ ! "$MID" = " " ]; then
                ../ETC/ConfUpdate MANAGER1_ID=$MID ../../MAgent/conf/ManagerInfo.conf >> ./autoinstall.log 2>&1
            fi 

            DATE=`date`
            echo "MIP=$MIP, MAIP=$MAIP" >> ./autoinstall.log
            echo "[$DATE]AGENT INSTALL RUN [$AGENT_INSTALL]" >> ./autoinstall.log

            if [ "$AGENT_COMMAND" = "-start" ]; then
                echo "[$DATE]AGENT START" >> ./autoinstall.log
                cd /home/cams/NNPAgent/
                ./agentstart.sh > /dev/null 2>&1
                cd /home/cams/NNPAgent/utils/AUTOINSTALL/

                sleep 10
                DATE=`date`
                AGENT_CHK=`ps -ef | grep MAGENT | grep -v grep | wc -l` 
                if  [ "$AGENT_CHK" = "0" ]; then
                    echo "Agent start failed" > ./reason.log
                    INSTALL_RST=FAILED
                else
                    echo "Agent start success" >> ./autoinstall.log
                fi
            fi

            echo "[$DATE] Agent auto install end" >> ./autoinstall.log

            \cp -f $CFG_FILE_PATH $CFG_OLDFILE_PATH

            if [ "$INSTALL_RST" = "FAILED" ]; then
                INSTALL_RSTMSG=`cat ./reason.log`
            fi
    
            ../ETC/ShCmd 10 "./ResultSend $AGENT_WEBSERVER_IP $AGENT_WEBSERVER_PORT  $VMID $INSTALL_RST \"$INSTALL_RSTMSG\"" >> ./autoinstall.log  2>&1
        fi 
    else 
        echo "[$DATE]cfg file[$CFG_FILE] download failed" >> ./autoinstall.log
        echo "cfg file[$CFG_FILE] download failed" > ./reason.log
        INSTALL_RST=FAILED

        if [ "$INSTALL_RST" = "FAILED" ]; then
            INSTALL_RSTMSG=`cat ./reason.log`
        fi
    
        ../ETC/ShCmd 10 "./ResultSend $AGENT_WEBSERVER_IP $AGENT_WEBSERVER_PORT  $VMID $INSTALL_RST \"$INSTALL_RSTMSG\"" >> ./autoinstall.log  2>&1
    fi 

    #\mv -f $CFG_FILE_PATH $CFG_OLDFILE_PATH
    sleep $SLEEP_SEC
done

exit 0

