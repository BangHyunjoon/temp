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
echo "CUR_PATH=$CUR_PATH"
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

if [ ! -f /etc/rc.atint1 ]; then
    ../INSTALL/autorunctl -d="$CUR_PATH"/NNPAgent -add=atint
fi

if [ $1 ]; then
    echo "AGENT_WEBSERVER_IP=$1"
    ../ETC/TextUpdate WEBSERVER_IP=$1 ./agent_inst_d.sh
else 
    if [ -f ./wip.sh ]; then
        ./wip.sh
    fi
fi

for i in `ps -ef | grep agent_inst_d.sh | grep -v grep | awk '{print $2}'`
do
    pid=`echo $i | cut -d' ' -f1`

    echo "kill -9 $pid"
    kill -9 $pid

done

chmod 700 ./agent_inst_d.sh


if [ -f /usr/bin/nohup ]; then
    /usr/bin/nohup ./agent_inst_d.sh &
elif [ -f /bin/nohup ]; then
    /bin/nohup ./agent_inst_d.sh &
elif [ -f /usr/local/bin/nohup ]; then
    /usr/local/bin/nohup ./agent_inst_d.sh &
elif [ -f /usr/sbin/nohup ]; then
    /usr/sbin/nohup ./agent_inst_d.sh &
elif [ -f /sbin/nohup ]; then
    /sbin/nohup ./agent_inst_d.sh &
elif [ -f /usr/local/sbin/nohup ]; then
    /usr/local/sbin/nohup ./agent_inst_d.sh &
fi


exit 0
