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

INSTALL_RST=FALSE
INSTALL_RSTMSG=UNKNOWN

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

elif [ "$OS" = "$LINUX" ]; then

	if [ -f /usr/bin/gcc ]; then
    echo ""
#		echo "/usr/bin/gcc is exists"
	else
#		echo "/usr/bin/gcc is not exists"
		LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
		export LD_LIBRARY_PATH
	fi

fi


DATE=`date`
echo "[$DATE] Agent auto install start" > ./autoinstall.log

curl http://172.27.0.1/latest/instance-id > ./VMID.dat 2>/dev/null

DATE=`date`
VMID=`cat ./VMID.dat | awk -F-VM '{print $1}'`-VM

#CFG_FILE=`echo "$VMID"_AGENT.cfg`
#CFG_FILE_PATH=`echo ./"$VMID"_AGENT.cfg`
#CFG_OLDFILE_PATH=`echo ./"$VMID"_AGENT_old.cfg`

CFG_FILE=`echo DEF_AGENT.cfg`
CFG_FILE_PATH=`echo ./DEF_AGENT.cfg`
CFG_OLDFILE_PATH=`echo ./DEF_AGENT_old.cfg`

echo "[$DATE] Agent VM ID = [$VMID]" >> ./autoinstall.log

AGENT_KEY=$VMID
AGENT_UPGRADE_IP=127.0.0.1
AGENT_UPGRADE_PORT=21080

SMS=" "
JMX=" "
WSM=" "
JAVA_HOME=" "
WSM_RUN=" "

if [ -f $CFG_FILE_PATH ]; then
    for j in `cat $CFG_FILE_PATH`
    do
        OPARAM_NUM=`echo $j | cut -d ';' -f 1`
        OPARAM=`echo $j | cut -d ';' -f 2`
        OPARAM_NAME=`echo $OPARAM | cut -d= -f 1`
        OPARAM_VALUE=`echo $OPARAM | cut -d= -f 2`

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
else
    echo "[$DATE]not found $CFG_OLDFILE_PATH" >> ./autoinstall.log
fi

DATE=`date`
ARG=`echo $1 | cut -d= -f 1`
if [ "$ARG" = "-SMS" ]; then
    SMS="START"
    echo "Input SMS AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-WSM" ]; then
    WSM="START"
    echo "Input WSM AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-JMX" ]; then
    JMX="START"
    echo "Input JMX AGENT COMMAND = START" >> ./autoinstall.log
fi

ARG=`echo $2 | cut -d= -f 1`
if [ "$ARG" = "-SMS" ]; then
    SMS="START"
    echo "Input SMS AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-WSM" ]; then
    WSM="START"
    echo "Input WSM AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-JMX" ]; then
    JMX="START"
    echo "Input JMX AGENT COMMAND = START" >> ./autoinstall.log
fi

ARG=`echo $3 | cut -d= -f 1`
if [ "$ARG" = "-SMS" ]; then
    SMS="START"
    echo "Input SMS AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-WSM" ]; then
    WSM="START"
    echo "Input WSM AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-JMX" ]; then
    JMX="START"
    echo "Input JMX AGENT COMMAND = START" >> ./autoinstall.log
fi

ARG=`echo $4 | cut -d= -f 1`
if [ "$ARG" = "-SMS" ]; then
    SMS="START"
    echo "Input SMS AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-WSM" ]; then
    WSM="START"
    echo "Input WSM AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-JMX" ]; then
    JMX="START"
    echo "Input JMX AGENT COMMAND = START" >> ./autoinstall.log
fi

ARG=`echo $5 | cut -d= -f 1`
if [ "$ARG" = "-SMS" ]; then
    SMS="START"
    echo "Input SMS AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-WSM" ]; then
    WSM="START"
    echo "Input WSM AGENT COMMAND = START" >> ./autoinstall.log
elif [ "$ARG" = "-JMX" ]; then
    JMX="START"
    echo "Input JMX AGENT COMMAND = START" >> ./autoinstall.log
fi

if [ "$JMX" = "START" ]; then
    if [ -f $JAVA_HOME/bin/java ]; then
        \cp -f ./wasagent.jar ../..
        echo "[$DATE] parent : $JAVA_HOME/bin/java -jar -Dsetup_dir=/home/cams/NNPAgent -Dagent_java=$JAVA_HOME wasagent.jar" >> ./autoinstall.log
        ../ETC/TextUpdate JAVA_HOME=$JAVA_HOME ./wasinstall.sh
        chmod 700 ./wasinstall.sh
        ./wasinstall.sh >> ./autoinstall.log 2>&1
        \rm -f ../../wasagent.jar
        if [ ! -f /home/cams/NNPAgent/WASAgent/bin/wastart.sh ]; then
            echo "[$DATE]JMX Agent install failed." >> ./autoinstall.log
            JMX=" "
        else 
            echo "[$DATE]JMX Agent install success" >> ./autoinstall.log
        fi
    else 
        echo "[$DATE]Not found java.[$JAVA_HOME/bin/java]" >> ./autoinstall.log
    fi
fi
#while [ 1 ]
#do

DATE=`date`
    if [ -f $CFG_FILE_PATH ]; then

        echo "[$DATE]cat-1 $CFG_FILE_PATH" >> ./autoinstall.log
        ls -al >> ./autoinstall.log

        cat $CFG_FILE_PATH | tr -d "\r\t" > aa

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

            ARG=`echo $1 | cut -d= -f 1`
            if [ "$ARG" = "-mip1" ]; then
                MIP=`echo $1 | cut -d= -f 2`
                echo "Input manager ip = $MIP" >> ./autoinstall.log
            elif [ "$ARG" = "-auip" ]; then
                AGENT_UPGRADE_IP=`echo $1 | cut -d= -f 2`
                echo "Input auto upgrade ip = $AGENT_UPGRADE_IP" >> ./autoinstall.log
                ../ETC/ConfUpdate AGENT_UPGRADE_IP=$AGENT_UPGRADE_IP ../../MAgent/conf/MasterAgent.conf >> ./autoinstall.log 2>&1
            fi

            ARG=`echo $2 | cut -d= -f 1`
            if [ "$ARG" = "-mip1" ]; then
                MIP=`echo $2 | cut -d= -f 2`
                echo "Input manager ip = $MIP" >> ./autoinstall.log
            elif [ "$ARG" = "-auip" ]; then
                AGENT_UPGRADE_IP=`echo $2 | cut -d= -f 2`
                echo "Input auto upgrade ip = $AGENT_UPGRADE_IP" >> ./autoinstall.log
            fi

            ARG=`echo $3 | cut -d= -f 1`
            if [ "$ARG" = "-mip1" ]; then
                MIP=`echo $3 | cut -d= -f 2`
                echo "Input manager ip = $MIP" >> ./autoinstall.log
            elif [ "$ARG" = "-auip" ]; then
                AGENT_UPGRADE_IP=`echo $3 | cut -d= -f 2`
                echo "Input auto upgrade ip = $AGENT_UPGRADE_IP" >> ./autoinstall.log
            fi

            ARG=`echo $4 | cut -d= -f 1`
            if [ "$ARG" = "-mip1" ]; then
                MIP=`echo $4 | cut -d= -f 2`
                echo "Input manager ip = $MIP" >> ./autoinstall.log
            elif [ "$ARG" = "-auip" ]; then
                AGENT_UPGRADE_IP=`echo $4 | cut -d= -f 2`
                echo "Input auto upgrade ip = $AGENT_UPGRADE_IP" >> ./autoinstall.log
            fi

            ARG=`echo $5 | cut -d= -f 1`
            if [ "$ARG" = "-mip1" ]; then
                MIP=`echo $5 | cut -d= -f 2`
                echo "Input manager ip = $MIP" >> ./autoinstall.log
            elif [ "$ARG" = "-auip" ]; then
                AGENT_UPGRADE_IP=`echo $5 | cut -d= -f 2`
                echo "Input auto upgrade ip = $AGENT_UPGRADE_IP" >> ./autoinstall.log
            fi

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

            echo "MIP=$MIP, MAIP=$MAIP" >> ./autoinstall.log
            echo "[$DATE]AGENT INSTALL RUN [$AGENT_INSTALL]" >> ./autoinstall.log


            if [ "$AGENT_COMMAND" = "-start" ]; then
                echo "[$DATE]AGENT START" >> ./autoinstall.log
                cd /home/cams/NNPAgent/
                ./agentstart.sh > /dev/null 2>&1
                cd /home/cams/NNPAgent/utils/AUTOINSTALL/
            fi

            echo "[$DATE] Agent auto install end" >> ./autoinstall.log

    else 
        echo "[$DATE]not found $CFG_FILE_PATH" >> ./autoinstall.log

    fi 

exit 0

