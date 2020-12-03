#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH


LINUX=Linux
SOLARIS=SunOS
HP=HP-UX
HP10=10
OSF=OSF1
AIX=AIX
UNIXWARE=Uinxware


OS=`uname -s`
CUR_SHELL=`echo $SHELL`
CUR_PATH=`/bin/pwd`

INSTALL_PATH=$CUR_PATH/NNPAgent/utils/INSTALL

INPUT_IP="$1"
IPFILE=$INSTALL_PATH/nodeipinfo.txt
REQUIREMENTS_FILE="./requirements"
MAGENT_KEY=""
MANAGER_IP=""
MANAGER_PORT=21002
AGENT_PORT=28003
MAGENT_IP=""
START_OPT=""
AUTO_START_OPT=""
IPCHK=""


case "$OS" in
$LINUX)
    if [ -f /bin/cut ]; then
        EXECUR_PATH="/bin"
    else
        EXECUR_PATH="/usr/bin"
    fi
    ;;
*)
        EXECUR_PATH="/usr/bin"
    ;;
esac


NOMNICHK=`/bin/grep pst1 /etc/inittab | $EXECUR_PATH/cut -f 1 -d ":"`
EXECUR_PATH="/usr/bin"
if [ "$OS" = "$LINUX" ]; then
        EXECUR_PATH="/bin"
fi


##########################################################################
### File Add and Config : agentstart.sh , agentstop.sh, /etc/rc.nomni2 ###
##########################################################################

if [ "$OS" = "$SOLARIS" ]; then
        LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/usr/platform/`arch -k`/lib:"$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH

elif [ "$OS" = "$HP" ]; then
        VS=`uname -r | cut -f 2 -d "."`
        if [ "$HP10" = "$VS" ]; then
            if [ ! -f /usr/lib/libpthread.sl ]; then
                $EXECUR_PATH/ln -s "$CUR_PATH"/NNPAgent/LIB/libpthread.sl /usr/lib/libpthread.sl
            fi

            LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:"$CUR_PATH"/NNPAgent/LIB
            export LD_LIBRARY_PATH
        fi

elif [ "$OS" = "$LINUX" ]; then
        if [ -f /usr/bin/gcc ]; then
                echo ""
#               echo "/usr/bin/gcc is exists"
        else
#               echo "/usr/bin/gcc is not exists"
                if [ "$CUR_SHELL" = "/bin/csh" ]; then
                        if [ $LD_LIBRARY_PATH ]; then
                            setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB
                        else
                            setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB
                        fi
                elif [ "$CUR_SHELL" = "/usr/bin/csh" ]; then
                        if [ $LD_LIBRARY_PATH ]; then
                            setenv LD_LIBRARY_PATH {$""LD_LIBRARY_PATH}:"$CUR_PATH"/NNPAgent/LIB
                        else
                            setenv LD_LIBRARY_PATH "$CUR_PATH"/NNPAgent/LIB
                        fi
                else
                            LD_LIBRARY_PATH=$""LD_LIBRARY_PATH:"$CUR_PATH"/NNPAgent/LIB
                            export LD_LIBRARY_PATH

                fi
                LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:"$CUR_PATH"/NNPAgent/LIB
                export LD_LIBRARY_PATH
        fi
fi


if [ "$OS" = "$SOLARIS" ]; then

        LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/usr/platform/`/usr/bin/arch -k`/lib:"$CUR_PATH"/NNPAgent/LIB
        export LD_LIBRARY_PATH

        EXEPATH="/usr/bin"
        `$EXEPATH/netstat -in > $IPFILE`
        NETSTAT=$EXEPATH/netstat
        GREP=$EXEPATH/grep
        CUT=$EXEPATH/cut
fi
if [ "$OS" = "$HP" ]; then
        EXEPATH="/usr/bin"
        `$EXEPATH/netstat -in > $IPFILE`
        NETSTAT=$EXEPATH/netstat
        GREP=/bin/grep
        CUT=/bin/cut
fi
if [ "$OS" = "$AIX" ]; then
        EXEPATH="/usr/bin"
        `/usr/sbin/netstat -in > $IPFILE`
        NETSTAT=/usr/sbin/netstat
        GREP=/usr/bin/grep
        CUT=/usr/bin/cut
fi
if [ "$OS" = "$UNIXWARE" ]; then
        EXEPATH="/usr/bin"
        `/usr/sbin/netstat -in > $IPFILE`
        NETSTAT=/usr/sbin/netstat
fi
if [ "$OS" = "$OSF" ]; then
        #EXEPATH="/usr/local/bin"
        EXEPATH="/usr/bin"
        `/usr/sbin/netstat -in > $IPFILE`
        NETSTAT=/usr/sbin/netstat
        GREP=/bin/grep
        CUT=/bin/cut
fi
if [ "$OS" = "$LINUX" ]; then
        EXEPATH="/bin"
        NETSTAT=/bin/netstat
        GREP=/bin/grep
        CUT=/bin/cut

        #TMPFILE=$CUR_PATH/SHELL/tmp.txt
        TMPFILE=$CUR_PATH/tmp.txt
        `/sbin/ifconfig -a | /bin/grep "inet addr:" > $TMPFILE`
        if [ -s $TMPFILE ]
        then
            while read LINEREAD
            do
                TMP=`echo $LINEREAD | /bin/cut -f 2 -d ":"`
                DATA=`echo $TMP | /bin/cut -f 1 -d " "`
                if [ "$DATA" = "127.0.0.1" ]; then
                    continue
                fi
                echo "ip ip ip" $DATA >> $IPFILE
            done < $TMPFILE
        fi
        $EXEPATH/rm $TMPFILE
fi

get_node_ipinfo()
{
    LINEPRINT=$INSTALL_PATH/a.out
    if [ -s $IPFILE ]
    then
        while read LINEREAD
        do
            echo $LINEREAD > $LINEPRINT
            IP=`/bin/awk '{print $1}' $LINEPRINT`
            if [ "$IP" = "lo0" ]; then
                continue
            fi
            IP=`/bin/awk '{print $3}' $LINEPRINT`
            if [ "$IP" = "<Link>" ]; then
                continue
            fi
            if [ "$IP" = "DLI" ]; then
                continue
            fi
            if [ "$OS" = "$AIX" ]; then
                CHK=`echo $IP | $CUT -f 1 -d "#"`
                if [ "$CHK" = "link" ]; then
                   continue
                fi
            fi

            IP=`/bin/awk '{print $4}' $LINEPRINT`
            CHK=`echo $IP | /bin/cut -f 1 -d "."`
            if [ "$IPCHK" = "$CHK" ]; then
                echo $IP
                return 0
            fi
        done < $IPFILE
    fi
}

get_manager_ipinfo()
{
    MANAGER_FILE=$CUR_PATH/manager.txt

    if [ -s $MANAGER_FILE ]
    then
        while read LINEREAD
        do
            $INSTALL_PATH/telnet.sh $LINEREAD $INSTALL_PATH $MANAGER_PORT
            result=`$GREP Connected $INSTALL_PATH/result.txt | $CUT -f 1 -d " "`
            if [ "$result" = "Connected" ]; then
                echo $LINEREAD
                return 0
            fi
        done < $MANAGER_FILE
   fi

 
}


setadmin() {
   pw="tcmujb#ej0@10"
   i=0
   j=6
   admin=""

   while [ "$i" -lt 6 ]; do
      admin="$admin""`echo $pw | cut -c"$j"`"
      i=`expr $i + 1`
      j=`expr $j - 1`
   done
   admin="$admin""`echo $pw | cut -c11`"
   admin="$admin""`echo $pw | cut -c12`"
   admin="$admin""`echo $pw | cut -c13`"
   admin="$admin""`echo $pw | cut -c10`"
   admin="$admin""`echo $pw | cut -c7`"
   admin="$admin""`echo $pw | cut -c9`"
   admin="$admin""`echo $pw | cut -c8`"
   export admin
}


#setadmin


print_top()
{
   clear; echo ""; echo ""; echo""
   echo "##################################################################"
   echo "#                                                                #"
   echo "#               POLESTAR AGENT Install Program                   #"
   echo "#                                                                #"
   echo "#       Copyright(C)2006 NKIA Co, Ltd. All Rights Reserved.      #"
   echo "#                                                                #"
   echo "##################################################################"
   echo ""
}

#
# Run install script
#

run_install()
{
   #echo""
   #print_top

   #echo " Installing Agent         -> continue..."
   #echo " Unpacking  Agent         -> continue..." 
   #gzip -d NNPAgent*.tar.gz;tar -xf NNPAgent*.tar
   #rm -f NNPAgent*.tar
 
   print_top
   echo " Installing Agent         -> continue..."
   #echo " Unpacking  Agent         -> finished."
   echo " Configure  Agent         -> continue..." 

   $CUR_PATH/NNPAgent/utils/ETC/ConfUpdate MASTER_AGENT_LISTEN_PORT=$AGENT_PORT $CUR_PATH/NNPAgent/MAgent/conf/MasterAgent.conf 

   ./AgentInstall.sh -magent auip=$MANAGER_IP makey=$MAGENT_KEY -minfo mip1=$MANAGER_IP maip1=$MAGENT_IP -start -addrc 

   print_top
   echo " Installing Agent         -> finished."
   #echo " Unpacking  Agent         -> finished."
   echo " Configure  Agent         -> finished." 

   echo ""
   echo " ******  AGENTS INSTALLED ******* "
   echo " * MANAGER IP : $MANAGER_IP "
   echo " * AGENT KEY : $MAGENT_KEY "
   echo " * AGENT IP : $MAGENT_IP "
   echo " * AGENT PORT : $AGENT_PORT "
   echo " ************************************ "

   
}

run_uninstall()
{
   echo""
   print_top

   echo " Uninstalling Agent       -> continue..."
   echo " deleting Agent           -> continue..." 
   gzip -d *.gz;tar -xf *.tar
   
   print_top
   echo " Installing Agent         -> continue..."
   echo " Unpacking  Agent         -> finished."
   echo " Configure  Agent         -> continue..." 

   ./AgentInstall.sh -magent auip=$MANAGER_IP makey=$MAGENT_KEY -minfo mip1=$MANAGER_IP maip1=$MAGENT_IP 
   
   print_top
   echo " Installing Agent         -> finished."
   echo " Unpacking  Agent         -> finished."
   echo " Configure  Agent         -> finished." 
}

get_magent_key()
{
    HOSTKEY=`hostname` 
    if [ "$INPUT_IP" = "" ]; then
        IP=`get_node_ipinfo`
        if [ "$IP" = "" ]; then
            echo ""
        else
            echo "MA_BKMS_$IP"
        fi
    else
        echo "MA_BKMS_$INPUT_IP"
    fi
}

get_magent_ip()
{
    if [ "$INPUT_IP" = "" ]; then
        IP=`get_node_ipinfo`
        if [ "$IP" = "" ]; then
            echo "Cannot get IP address of this machine!! Use this:"
            echo "    ./intall.sh [agent IP address]"
            exit 0
        else
            echo $IP 
        fi
    else
        echo $INPUT_IP 
    fi
}


check_requirements()
{
   print_top


   if [ !$REQUIREMENTS_FILE ]; then

      VALUE=`get_manager_ipinfo` 
      printf " Manager IP required, ["$VALUE"]? (Yes: Enter, No: Edit) : "
      read mip
      if [ "$mip" = "" ]; then
          mip=$VALUE 
      fi
      MANAGER_IP=$mip
      echo " Manager IP:" $MANAGER_IP

      IPCHK=`echo $MANAGER_IP | /bin/cut -f 1 -d "."`
      VALUE=`get_magent_key`

      if [ "$VALUE" = "" ]; then 
         echo " cannot get agent IP address. use this:"
         echo "   ./install.sh [agent IP address]" 
         exit 0
      fi

      printf " Agent Key required, ["$VALUE"]? (Yes: Enter, No: Edit) :"
      read makey
      if [ "$makey" = "" ]; then
          makey=$VALUE 
      fi

      MAGENT_KEY=$makey
      echo " AGENT ID:"$MAGENT_KEY

      MAGENT_IP=`get_magent_ip`

   fi

}

#
# Root user check
#
check_root_user()
{
   if [ $USER != 'root' ]; then
      echo "you should be \"root\" to run this script ..."
      exit 1
   fi
}

#
# Checking Agent Process
#

check_process()
{
    echo ""
    #printf " Check Agent Process? (Yes=Enter, No=N):"
    #read YesNo
    
    echo " * AGENT PROCESS CHECK * " 
    if [ "$YesNo" = "" ]; then
    while [ 1 ] 
    do
        echo ""
        echo " ps -ef | grep AGENT | grep -v grep"
        echo " ----------------------------"
        ps -ef | grep AGENT | grep -v "grep"  
    sleep 3
    done
    fi
}

check_network()
{
    #printf " Check Network Connection? (Yes=Enter, No=N):"
    #read YesNo
    
    echo " * AGENT PROCESS CHECK * " 
    if [ "$YesNo" = "" ]; then

    while [ 1 ]
    do
        echo " "
        echo "***************************************************************************" 
        echo " * manager connection check * "
        echo " netstat -an | grep $MANAGER_IP | grep $MANAGER_PORT"
        echo " ---------------------------------------"
            netstat -an | grep $MANAGER_IP | grep $MANAGER_PORT 
        
        echo " "
        echo " * agent connection check * "
        echo " netstat -an | grep $AGENT_PORT "
        echo " ---------------------------------------"
            netstat -an | grep $AGENT_PORT 

    sleep 3
    done

    fi
}


#
# main
#

main_install()
{
# ==== initialize phase ====
#  check_root_user

   check_requirements
# ==== install phase ====
   run_install

#   sleep 3
#   check_process

#   sleep 1
#   check_network

}

#
# starting point
#

main_install


