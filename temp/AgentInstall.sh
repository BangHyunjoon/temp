#
# Copyright 2006 Nkia, Inc.  All rights reserved.
# Polestar auto install script
# Use subject to license terms.
#
#ident  "@(#)AgentInstall.sh  v0.2     16/07/23 "
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

TYPE=""
MANAGER_INFO=""
AGENT_INFO=""
AGENT_KEY=""
UNINSTALL_FLAG=0
AGENT_PORT="31003"
UDP_PORT="31004"

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


fPrintUsage ()
{
    echo "usage : ./AgentInstall.sh [-t] [-m] [-a] [-i] [-p]"
    echo "        -t : type                1: agent -> manager"
    echo "                                 2: manager -> agent"
    echo "        -m : MANAGER_IP:PORT     manager ip:manager port"
    echo "                                 port is optional information, default:31002" 
    echo "        -a : AGENT_IP            agent server ip"
    echo "        -i : AGENT_ID            agent server unique id"
    echo "        -p : AGENT_PORT          agent server port"
    echo " "
    echo "example ./AgentInstall.sh -t 1 -m 1.1.1.1" 
    echo "example ./AgentInstall.sh -t 1 -m 1.1.1.1 -a 2.2.2.2 -i MA_2.2.2.2" 
    echo "example ./AgentInstall.sh -t 2"
    echo "example ./AgentInstall.sh -t 2 -p 23003"
}

if [ -z "$1" ] ; then
    fPrintUsage
    exit 0
fi

if [ "$OS" = "$HP" ]; then
    l_BinType=`grep MASTER_AGENT_BIN_TYPE ./NNPAgent/MAgent/conf/MasterAgent.conf | awk -F'=' '{print $2}'`
    l_check=`echo $l_BinType | grep MADEF_ | wc -l`
    if [ $l_check -eq 1 ] ; then
        l_BinVer=`echo $l_BinType | awk -F'_' '{print $2}'`
    else
        l_BinVer=0
    fi
    l_Relase=`uname -r | awk -F'.' '{print $3}'`
    l_Hardware=`uname -m`
    if [ $l_Relase -le 11 ] ; then
        if [ $l_BinVer -ne 0 ] ; then
            echo "The agent version(11."$l_BinVer") does not match the OS version(11."$l_Relase")"
            echo "download NNPAgent_SMS_HP_11.00* , and try again"
            exit 0
        fi
    elif [ $l_Relase -le 23 ] ; then
        if [ $l_BinVer -ne 23 ] ; then
            echo "The agent version(11."$l_BinVer") does not match the OS version(11."$l_Relase")"
            echo "download NNPAgent_SMS_HP_11.23* , and try again"
            exit 0
        fi
    else
        if [ "$l_Hardware" = "ia64" ] ; then
            if [ $l_BinVer -ne 31 ] ; then
                echo "The agent version(11."$l_BinVer") does not match the OS version(11."$l_Relase")"
                echo "download NNPAgent_SMS_HP_11.31* , and try again"
                exit 0
            fi
        else
            if [ $l_BinVer -ne 23 ] ; then
                echo "This Machine is "$l_Hardware" "
                echo "download NNPAgent_SMS_HP_11.23* , and try again"
                exit 0
            fi
        fi
    fi
fi

##########################################################################
### File Add and Config : agentstart.sh , agentstop.sh, /etc/rc.nomni2 ###
##########################################################################

if [ "$1" = "uninstall" ]; then
    echo "uninstall.. "
    cd ./NNPAgent;./agentstop.sh;cd ../
    if [ -f /etc/rc.cygn2 ]; then
        echo "exit 0" > /etc/rc.cygn2
        \rm -f /etc/rc.cygn1
    fi

    if [ -f /usr/bin/plog ]; then
        \rm -f /usr/bin/plog 2> /dev/null
    fi
    echo "uninstall success"
    exit 0
else
    \rm -f /usr/bin/plog 2> /dev/null
	while getopts t:m:a:i:p:h opt
	do
	    case $opt in
		t)
		    TYPE=$OPTARG
		    ;;
		m)
		    MANAGER_INFO=$OPTARG
		    ;;
		a)
		    AGENT_INFO=$OPTARG
		    ;;
		i)
		    AGENT_KEY=$OPTARG
		    ;;
		p)
		    AGENT_PORT=$OPTARG
		    ;;
		h)
                    fPrintUsage
                    exit 0
		    ;;
		*)
		    echo "option error"
                    fPrintUsage
		    exit 0
		    ;;
	    esac
	done

	if [ -z "$TYPE" ] ; then
	    echo "usage error , use -t option"
	    fPrintUsage
	    exit 0
	fi

	if [ $TYPE -eq 1 ] ; then
	    # manager info set
	    if [ -z "$MANAGER_INFO" ] ; then
		echo "usage error , use -m option"
		exit 0
	    else
		l_PortCheck=`echo $MANAGER_INFO | grep : | wc -l`
		if [ $l_PortCheck -eq 1 ] ; then
		   MANAGER_IP=`echo $MANAGER_INFO | awk -F':' '{print $1}'` 
		   MANAGER1_PORT=`echo $MANAGER_INFO | awk -F':' '{print $2}'` 
		else
		   MANAGER_IP=$MANAGER_INFO
		   MANAGER1_PORT=31002
		fi
	    fi

	    # node info set
	    if [ -z "$AGENT_INFO" ] ; then
		NODEIP=`$CUR_PATH/NNPAgent/utils/INSTALL/getlocalip $MANAGER_IP $MANAGER1_PORT | awk -F'=' '{print $2}'`
		ip_check=`echo $NODEIP | wc -c`
		if [ $ip_check -le 10 ] ; then
		    echo "Can not connect to Manager Service, type the AGENT ip manually, use -a option "
		    exit 0
		fi
	    else
		NODEIP=$AGENT_INFO
	    fi


	elif [ $TYPE -eq 2 ] ; then
	    HOSTNAME=`hostname`
	else
	    echo "usage error , use -t option, value = 1 or 2"
	    exit 0
	fi


	if [ -z "$AGENT_KEY" ] ; then
  	        INSTALLDATE=`date +%Y%m%d%H%M%S`
	        HOSTNAME=`hostname`
	        AGENT_KEY="MA_"$HOSTNAME"_"$INSTALLDATE
	fi


	if [ $TYPE -eq 1 ] ; then
	    echo "MANAGER IP:PORT = " $MANAGER_IP":"$MANAGER1_PORT
	    echo "AGENT_IP        = " $NODEIP
	    echo "AGENT_ID        = " $AGENT_KEY
	    echo "AGENT_PORT      = " $AGENT_PORT
	else
	    echo "AGENT_ID        = " $AGENT_KEY
	    echo "AGENT_PORT      = " $AGENT_PORT
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
            $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/LIB/libpthread.sl /usr/lib/libpthread.sl 2> /dev/null
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
if [ "$OS" = "$HP" ]; then
    echo "UNIX95=ps;export UNIX95" >> agentstart.sh
fi
echo "agentcheck=\`grep PROCNAME $CUR_PATH/NNPAgent/MAgent/conf/MasterAgent.conf | awk -F= '{print \$2}'\`" >> agentstart.sh
echo "procname=\`ps -e -o args | grep -v grep | grep \$agentcheck\`" >> agentstart.sh
echo "for i in \$procname" >> agentstart.sh
echo "do" >> agentstart.sh
echo "    if [ \"\$agentcheck\" = \"\$i\" ] ; then" >> agentstart.sh
echo "        echo \$i \"is already running.\"" >> agentstart.sh
echo "        exit" >> agentstart.sh
echo "    fi" >> agentstart.sh
echo "done" >> agentstart.sh
echo "cd $CUR_PATH/NNPAgent/MAgent/bin; ./magentctl -start > /dev/null 2>&1" >> agentstart.sh
echo "cd $CUR_PATH/NNPAgent/MAgent/bin; ./magentctl -stop > /dev/null 2>&1" >> agentstop.sh

$EXECUR_PATH/chmod 755 $CUR_PATH/agentstart.sh $CUR_PATH/agentstop.sh
$EXECUR_PATH/mv $CUR_PATH/agentstart.sh $CUR_PATH/NNPAgent/
$EXECUR_PATH/mv $CUR_PATH/agentstop.sh $CUR_PATH/NNPAgent/

if [ $UNINSTALL_FLAG -eq 1 ] ; then
	./NNPAgent/utils/INSTALL/AgentInstall $*
else
	if [ $TYPE -eq 1 ] ; then
    		PARAMETER=`echo "-magent auip="$MANAGER_IP" makey="$AGENT_KEY" -minfo mip1="$MANAGER_IP" maip1="$NODEIP" "`
	else
    		PARAMETER=`echo "-magent auip=127.0.0.1 makey="$AGENT_KEY" "`
	fi
	./NNPAgent/utils/INSTALL/AgentInstall $PARAMETER
	if [ "$MANAGER1_PORT" != "21002" -a $TYPE -eq 1 ] ; then
	    ./NNPAgent/utils/ETC/ConfUpdate MANAGER1_PORT=$MANAGER1_PORT ./NNPAgent/MAgent/conf/ManagerInfo.conf
	fi
	if [ "$AGENT_PORT" != "31003" ] ; then
	    ./NNPAgent/utils/ETC/ConfUpdate MASTER_AGENT_LISTEN_PORT=$AGENT_PORT ./NNPAgent/MAgent/conf/MasterAgent.conf
            UDP_PORT=`expr $AGENT_PORT + 1 `
	    ./NNPAgent/utils/ETC/ConfUpdate USEREVENT_UDP_PORT=$UDP_PORT ./NNPAgent/SMSAgent/conf/SMSAgent.conf
        fi
        echo "#!/bin/sh" > "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        if [ "$OS" = "$SOLARIS" ]; then
            echo "LD_LIBRARY_PATH="$CUR_PATH"/NNPAgent/LIB" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
            echo "export LD_LIBRARY_PATH" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        fi
        echo "cd "$CUR_PATH"/NNPAgent/utils/ETC; ./plog -port "$UDP_PORT" \$*" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        echo "cd "$CUR_PATH"/NNPAgent/utils/ETC; ./plog -port 21004 \$* > /dev/null 2&>1 &" >> "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        $EXECUR_PATH/chmod 755 "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh
        $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/utils/ETC/plog.sh /usr/bin/plog 2> /dev/null

	./NNPAgent/utils/INSTALL/autorunctl -d=$CUR_PATH/NNPAgent -add=cygn
	cd ./NNPAgent;./agentstart.sh
	cd ..
fi
