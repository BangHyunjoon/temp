#
# Copyright 2006 Nkia, Inc.  All rights reserved.
# Polestar auto install script
# Use subject to license terms.
#
#ident  "@(#)AgentInstall.sh  v0.2     06/02/23 "
#add     /usr/bin/csh adding  by jsyoo 06/03/27
#!/bin/sh

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
CUR_PATH=`/bin/pwd`

EXECUR_PATH="/usr/bin"
if [ "$OS" = "$LINUX" ]; then
    EXECUR_PATH="/bin"
fi
if [ "$OS" = "$MAC" ]; then
    EXECUR_PATH="/bin"
fi


if [ "$OS" = "$SOLARIS" ]; then
    LD_LIBRARY_PATH=$CUR_PATH/NNPAgent/LIB
    export LD_LIBRARY_PATH
fi

##########################################################################
### File Add and Config : agentstart.sh , agentstop.sh, /etc/rc.nomni2 ###
##########################################################################

if [ "$1"  != "-uninstall" ]; then
    if [ -f /usr/bin/plog ]; then
        \rm -f /usr/bin/plog 2> /dev/null
    fi
        echo "#!/bin/sh" > "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        if [ "$OS" = "$SOLARIS" ]; then
            echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
            echo "export LD_LIBRARY_PATH" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        fi
        echo "cd "$CUR_PATH"/NNPAgent/utils/ETC; ./plog \$*" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        $EXECUR_PATH/chmod 755 "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh /usr/bin/plog
else
    if [ -f /usr/bin/plog ]; then
        \rm -f /usr/bin/plog 2> /dev/null
    fi
fi


echo "#!/bin/sh" > agentstart.sh
echo "#!/bin/sh" > agentstop.sh

if [ "$OS" = "$SOLARIS" ]; then
    echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
    echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
    echo "export LD_LIBRARY_PATH" >> agentstart.sh
    echo "export LD_LIBRARY_PATH" >> agentstop.sh

    LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
    export LD_LIBRARY_PATH

elif [ "$OS" = "$HP" ]; then
    grep -v SOCKET_.*_SIZE "$CUR_PATH"/NNPAgent/MAgent/conf/MasterAgent.conf > "$CUR_PATH"/NNPAgent/MAgent/conf/MasterAgent.conf_
    grep -v SOCKET_.*_SIZE "$CUR_PATH"/NNPAgent/SMSAgent/conf/SMSAgent.conf > "$CUR_PATH"/NNPAgent/SMSAgent/conf/SMSAgent.conf_
    TMP_CMD=`\rm -f "$CUR_PATH"/NNPAgent/MAgent/conf/MasterAgent.conf`
    TMP_CMD=`\rm -f "$CUR_PATH"/NNPAgent/SMSAgent/conf/SMSAgent.conf`
    TMP_CMD=`mv "$CUR_PATH"/NNPAgent/MAgent/conf/MasterAgent.conf_ "$CUR_PATH"/NNPAgent/MAgent/conf/MasterAgent.conf`
    TMP_CMD=`mv "$CUR_PATH"/NNPAgent/SMSAgent/conf/SMSAgent.conf_ "$CUR_PATH"/NNPAgent/SMSAgent/conf/SMSAgent.conf`

    VS=`uname -r | cut -f 2 -d "."`
    if [ "$HP10" = "$VS" ]; then
        if [ ! -f /usr/lib/libpthread.sl ]; then
            $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/LIB/libpthread.sl /usr/lib/libpthread.sl
        fi

        echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
        echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
        echo "export LD_LIBRARY_PATH" >> agentstart.sh
        echo "export LD_LIBRARY_PATH" >> agentstop.sh

        LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH
    fi

elif [ "$OS" = "$LINUX" ]; then
    if [ -f /usr/bin/gcc ]; then
        echo ""
#        echo "/usr/bin/gcc is exists"
    else
#        echo "/usr/bin/gcc is not exists"
        if [ "$CUR_SHELL" = "/bin/csh" ]; then
            if [ $LD_LIBRARY_PATH ]; then
                echo "setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
                echo "setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
            else
                echo "setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
                echo "setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
            fi
        elif [ "$CUR_SHELL" = "/usr/bin/csh" ]; then
            if [ $LD_LIBRARY_PATH ]; then
                echo "setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
                echo "setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
            else
                echo "setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
                echo "setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
            fi
        else
                echo "LD_LIBRARY_PATH=$""LD_LIBRARY_PATH:"$CUR_PATH"/NNPAgent/LIB" >> agentstart.sh
                echo "LD_LIBRARY_PATH=$""LD_LIBRARY_PATH:"$CUR_PATH"/NNPAgent/LIB" >> agentstop.sh
                echo "export LD_LIBRARY_PATH" >> agentstart.sh
                echo "export LD_LIBRARY_PATH" >> agentstop.sh

        fi
        LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH
    fi
fi
echo "cd $CUR_PATH/NNPAgent/MAgent/bin; ./magentctl -start > /dev/null 2>&1" >> agentstart.sh
echo "cd $CUR_PATH/NNPAgent/MAgent/bin; ./magentctl -stop > /dev/null 2>&1" >> agentstop.sh

$EXECUR_PATH/chmod 755 $CUR_PATH/agentstart.sh $CUR_PATH/agentstop.sh
$EXECUR_PATH/mv $CUR_PATH/agentstart.sh $CUR_PATH/NNPAgent/
$EXECUR_PATH/mv $CUR_PATH/agentstop.sh $CUR_PATH/NNPAgent/

#./NNPAgent/utils/INSTALL/AgentInstall $*
#./NNPAgent/IMSAgent/bin/IMSAgentInstall.sh 2 $CUR_PATH R1.5.718
#./NNPAgent/DB2Agent/bin/DB2AgentInstall.sh 2 $CUR_PATH R1.5.718
#./NNPAgent/BUFAgent/bin/BUFAgentInstall.sh 2 $CUR_PATH R1.5.718
#./NNPAgent/DCAAgent/bin/DCAAgentInstall.sh 2 $CUR_PATH R1.5.718
 
if [ "$1"  = "-cloud" ]; then
    echo "Cloud Agent install..."
    AGENT_TYPE=`grep PROCNAME "$CUR_PATH/NNPAgent/MAgent/conf/MasterAgent.conf" | cut -d'=' -f2 | awk '{print $1}'`
    AUIP=`grep AUTO_UPGRADE_IP "$CUR_PATH/NNPAgent/MAgent/conf/MasterAgent.conf" | cut -d'=' -f2 | awk '{print $1}'`
    if [ "$AGENT_TYPE" = "VAGENT" ]; then
        ./AgentInstall.sh -magent auip=$AUIP makey=MA_ -addrc
        echo "Cloud(VirtualMachine) agent install success"
    elif [ "$AGENT_TYPE" = "HAGENT" ]; then
        ./AgentInstall.sh -magent auip=$AUIP makey=MA_ -addrc
        echo "Cloud(Hypervisor) agent install success"
    else
        echo "Install failed : Unknown AGENT TYPE(VAGENT or HAGENT) -> MasterAgent.conf(PROCNAME=)"
        exit 255
    fi
    exit 0
fi

NODEIP=`$CUR_PATH/NNPAgent/utils/INSTALL/ipinfo.sh IP`
INSTALLDATE=`$CUR_PATH/NNPAgent/utils/INSTALL/ipinfo.sh`
PARAMETER=`echo "-magent auip=10.192.29.26 makey=MA_"$NODEIP"_"$INSTALLDATE" -start -addrc"`
 
#./NNPAgent/utils/INSTALL/AgentInstall $*
./NNPAgent/utils/INSTALL/AgentInstall $PARAMETER
