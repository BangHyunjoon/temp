#! /bin/sh
# Copyright 2006 Nkia, Inc.  All rights reserved.
# Polestar auto start configure script
# Use subject to license terms.
#
#ident  "@(#)AgentConf.sh  v0.1     06/02/23 "

#OS defined
LINUX=Linux
SOLARIS=SunOS
HP=HP-UX
OSF=OSF1
AIX=AIX
UNIXWARE=Uinxware
MAC=Darwin
IRIX=IRIX64

#Usage
if [ ! -d $1 ]; then
        echo "config failed..[ $1 ] Directory not found"
        echo "Usage: $0 {install_directory} {[-add|-del]=rc_filename}"
        echo "add ex : ./AgentConf.sh /home/nkia/NNPAgent -add=rc.nomni2"
        echo "del ex : ./AgentConf.sh /home/nkia/NNPAgent -del=rc.nomni2"
        exit 0;
fi

#Current OS Config
OS=`uname -s`
CUR_SHELL=`echo $SHELL`
CUR_PATH=`/bin/pwd`
HOME_PATH=$1
LIN_TYPE=0 # 0:default, 1:suse , 2:ubuntu
SUSECHK=0
UBUNTUCHK=0

case "$OS" in
$LINUX)
        EXECUR_PATH="/bin"
        SUSECHK=`grep -i suse /etc/issue 2> /dev/null | wc -l`
        if [ $SUSECHK -eq 0 ]; then
            if [ -f /etc/SuSE-release ]; then
                SUSECHK=`grep -i suse /etc/SuSE-release | wc -l`
            fi
        fi
        if [ $SUSECHK -eq 0 ] ; then
            if [ -f /etc/lsb-release ]; then
                UBUNTUCHK=`grep -i ubuntu /etc/lsb-release | wc -l`
            fi
        fi
        if [ $SUSECHK -eq 1 ]; then
            LIN_TYPE=1
        fi
        if [ $UBUNTUCHK -ge 1 ]; then
            LIN_TYPE=2
        fi

        #NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/rc.nomni2" /etc/rc.d/rc.local`
        ;;
$MAC)
	EXECUR_PATH="/bin"
	;;
$IRIX)
	EXECUR_PATH="/sbin"
	;;
*)
        EXECUR_PATH="/usr/bin"
        ;;
esac

if [ "$OS" = "$MAC" ]; then
	RLEVEL=`/usr/bin/who -r | /usr/bin/cut -f 2 -d "-" | /usr/bin/cut -f 2 -d " "`
elif [ "$OS" = "$IRIX" ]; then
	RLEVEL=`/usr/bin/who -r | /usr/bin/cut -f 2 -d "-" | /usr/bin/cut -f 2 -d " "`
else
    if [ -f $EXECUR_PATH/cut ] ; then
        RLEVEL=`/usr/bin/who -r | $EXECUR_PATH/cut -f 2 -d "-" | $EXECUR_PATH/cut -f 2 -d " "`
    else
        RLEVEL=`/usr/bin/who -r | /usr/bin/cut -f 2 -d "-" | /usr/bin/cut -f 2 -d " "`
    fi
fi

case "$RLEVEL" in
2|3|4|5)
        ;;
*)
        RLEVEL="2345"
        ;;
esac

case "$OS" in
$MAC|$IRIX)
        RCTMP=`echo $2 | /usr/bin/cut -f 2 -d "="`
        ;;
$HP)
        RCTMP=`echo $2 | $EXECUR_PATH/cut -f 2 -d "="`
        ;;
*)
    if [ -f $EXECUR_PATH/cut ]; then
        RCTMP=`echo $2 | $EXECUR_PATH/cut -f 2 -d "="`
    else
        RCTMP=`echo $2 | /usr/bin/cut -f 2 -d "="`
    fi 
        ;;
esac

RCNAME2="rc."`echo $RCTMP"2"`
RCNAME1="rc."`echo $RCTMP"1"`
if [ ! $RCNAME2 ]; then
        RCNAME2="rc.nomni2"
        RCNAME1="rc.nomni1"
fi

case "$OS" in
$HP|$OSF)
        if [ $RCTMP = "nomni" ]; then
            NOMNICHK=`$EXECUR_PATH/grep pst1 /etc/inittab | $EXECUR_PATH/cut -f 1 -d ":"`
        else
            NOMNICHK=`$EXECUR_PATH/grep $RCTMP /etc/inittab | $EXECUR_PATH/cut -f 1 -d ":"`
        fi
        ;;
$LINUX)
    if [ $LIN_TYPE -eq 0 ]; then
        if [ -f /etc/rc.d/rc.local ]; then
            if [ $RCTMP = "nomni" ]; then
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/rc.nomni2" /etc/rc.d/rc.local`
            else
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/$RCNAME2" /etc/rc.d/rc.local`
            fi
        else
            if [ $RCTMP = "nomni" ]; then
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/rc.nomni2" /etc/rc.local`
            else
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/$RCNAME2" /etc/rc.local`
            fi
        fi
    elif [ $LIN_TYPE -eq 2 ]; then
            if [ $RCTMP = "nomni" ]; then
                NOMNICHKLIN=`ls /etc/init.d/e6nomni 2> /dev/null`
            else
                NOMNICHKLIN=`ls /etc/init.d/e7$RCTMP 2> /dev/null`
            fi

    else
        if [ -f /etc/init.d/boot.local ]; then
            if [ $RCTMP = "nomni" ]; then
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/rc.nomni2" /etc/init.d/boot.local`
            else
                NOMNICHKLIN=`$EXECUR_PATH/grep "/etc/$RCNAME2" /etc/init.d/boot.local`
            fi
        else
            NOMNICHKLIN=        
        fi
    fi
        ;;
$MAC)
        if [ $RCTMP = "nomni" ]; then
            NOMNICHKLIN=`/usr/bin/grep "/etc/rc.nomni1" /etc/rc.server`
        else
            NOMNICHKLIN=`/usr/bin/grep "/etc/$RCNAME2" /etc/rc.server`
        fi
        ;;
*)
        ;;
esac

if [ "$OS" = "$LINUX" ]; then
    if [ -f $EXECUR_PATH/cut ] ; then 
        OPT=`echo $2 | $EXECUR_PATH/cut -f 1 -d "="`
    else
        OPT=`echo $2 | /usr/bin/cut -f 1 -d "="`
    fi  
else
    OPT=`echo $2 | cut -f 1 -d "="`
fi
if [ "$OPT" = "-add" ]; then
        ################################################################
        ### File Add and Config : /etc/rc.nomni2 

        case "$OS" in
        $SOLARIS|$IRIX)
            if [ "$CUR_SHELL" = "/bin/csh" ]; then
                echo "#!" /bin/sh > $RCNAME2
                echo "#!" /bin/sh > $RCNAME1
            elif [ "$CUR_SHELL" = "/usr/bin/csh" ]; then
                echo "#!" /bin/sh > $RCNAME2
                echo "#!" /bin/sh > $RCNAME1
            else
                echo "#!" $CUR_SHELL > $RCNAME2
                echo "#!" $CUR_SHELL > $RCNAME1
            fi
            ;;
        *)
            echo "#!" $CUR_SHELL > $RCNAME2
            echo "#!" $CUR_SHELL > $RCNAME1
            ;;
        esac
        
        echo "LIMIT_CNT=0" >> $RCNAME1
        if [ $RCTMP = "atint" ]; then
            echo "while [ ! -f $HOME_PATH/utils/AUTOINSTALL/AgentAutoRun.sh ]" >> $RCNAME1
            echo "do" >> $RCNAME1
            echo "    echo \"not found auto agent install shell file!!\"" >> $RCNAME1
            echo "    if [ \$LIMIT_CNT = 500 ]" >> $RCNAME1
            echo "    then" >> $RCNAME1
            echo "        echo \"polestar agent auto install failed!!\"" >> $RCNAME1
        else
            echo "while [ ! -f $HOME_PATH/MAgent/bin/magentctl ]" >> $RCNAME1
            echo "do" >> $RCNAME1
            echo "    echo \"not found agent binary file!!\"" >> $RCNAME1
            echo "    if [ \$LIMIT_CNT = 500 ]" >> $RCNAME1
            echo "    then" >> $RCNAME1
            echo "        echo \"polestar agent start failed!!\"" >> $RCNAME1
        fi
        echo "        break" >> $RCNAME1
        echo "    fi" >> $RCNAME1
        echo "    sleep 60" >> $RCNAME1
        echo "    LIMIT_CNT=\`expr \$LIMIT_CNT + 1\`" >> $RCNAME1
        echo "done" >> $RCNAME1

        case "$OS" in
        $SOLARIS)
		if [ -f /etc/$RCNAME2 ]; then
		    echo "$EXECUR_PATH/rm -f /etc/$RCNAME2"
		    echo "$EXECUR_PATH/rm -f /etc/$RCNAME1"
		    $EXECUR_PATH/rm -f /etc/$RCNAME2
		    $EXECUR_PATH/rm -f /etc/$RCNAME1
                    if [ -f /etc/rc.nomni2 ]; then
		        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99polestar
                    elif [ -f /etc/rc$RLEVEL.d/S99ps_$RCTMP ]; then
		        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99ps_$RCTMP
                    fi
		fi
                if [ "$CUR_SHELL" = "/bin/csh" ]; then
                    echo "LD_LIBRARY_PATH="$HOME_PATH"/LIB" >> $RCNAME1
                    echo "export LD_LIBRARY_PATH" >> $RCNAME1
                else
                    echo "LD_LIBRARY_PATH="$HOME_PATH"/LIB" >> $RCNAME1
                    echo "export LD_LIBRARY_PATH" >> $RCNAME1
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "cd" $HOME_PATH"/utils/AUTOINSTALL; ../ETC/ShCmd 60 ./AgentAutoRun.sh" >> $RCNAME1
                else
                    #echo "cd" $HOME_PATH"/MAgent/bin; ./magentctl -start" >> $RCNAME1
                    echo "su - root -c \"LD_LIBRARY_PATH="$HOME_PATH"/LIB;export LD_LIBRARY_PATH;cd" $HOME_PATH"/MAgent/bin; ./magentctl -start > /dev/null 2>&1\"" >> $RCNAME1
                fi
                # add
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                else
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc_$RCTMP.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "echo \"polestar agent auto install success!!\"" >> $RCNAME1
                else
                    echo "echo \"polestar agent start success!!\"" >> $RCNAME1
                fi

                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME1
                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME2
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME1 /etc/
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME2 /etc/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME1 $HOME_PATH/utils/ETC/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME2 $HOME_PATH/utils/ETC/
                if [ "$RLEVEL" = "2345" ]; then
                    if [ $RCNAME2 = "rc.nomni2" ]; then 
                        $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/S99polestar /etc/rc3.d/
                    else
                        $HOME_PATH/utils/INSTALL/S99ps_make $RCNAME2 S99ps_$RCTMP $RCTMP
                        $EXECUR_PATH/chmod 755 $CUR_PATH/S99ps_$RCTMP
                        $EXECUR_PATH/cp -rf $CUR_PATH/S99ps_$RCTMP /etc/rc3.d/
                        $EXECUR_PATH/mv $CUR_PATH/S99ps_$RCTMP $HOME_PATH/utils/ETC/
                    fi
                else
                    if [ $RCNAME2 = "rc.nomni2" ]; then 
                        $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/S99polestar /etc/rc$RLEVEL.d/
                    else
                        $HOME_PATH/utils/INSTALL/S99ps_make $RCNAME2 S99ps_$RCTMP $RCTMP
                        $EXECUR_PATH/chmod 755 $CUR_PATH/S99ps_$RCTMP
                        $EXECUR_PATH/cp -rf $CUR_PATH/S99ps_$RCTMP /etc/rc$RLEVEL.d/
                        $EXECUR_PATH/mv $CUR_PATH/S99ps_$RCTMP $HOME_PATH/utils/ETC/
                    fi
                fi
                ;;
        $HP|$OSF)
                if [ -f /etc/$RCNAME2 ]; then
                    #echo "$EXECUR_PATH/rm -f /etc/$RCNAME2"
                    #echo "$EXECUR_PATH/rm -f /etc/$RCNAME1"
                    $EXECUR_PATH/rm -f /etc/$RCNAME2
                    $EXECUR_PATH/rm -f /etc/$RCNAME1
                    if [ -f /etc/rc.nomni2 ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99polestar
                    elif [ -f /etc/rc$RLEVEL.d/S99ps_$RCNAME2 ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99ps_$RCTMP
                    fi
                fi
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/S99polestar /etc/rc.nnpst
                else
                    $HOME_PATH/utils/INSTALL/S99ps_make $RCNAME2 S99ps_$RCTMP $RCTMP
                    $EXECUR_PATH/chmod 755 $CUR_PATH/S99ps_$RCTMP
                    $EXECUR_PATH/cp -rf $CUR_PATH/S99ps_$RCTMP /etc/rc.$RCTMP
                    $EXECUR_PATH/mv $CUR_PATH/S99ps_$RCTMP $HOME_PATH/utils/ETC/
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "cd" $HOME_PATH"/utils/AUTOINSTALL; ../ETC/ShCmd 60 ./AgentAutoRun.sh" >> $RCNAME1
                else
                    #echo "cd" $HOME_PATH"/MAgent/bin; ./magentctl -start" >> $RCNAME1
                    echo "su - root -c \"cd" $HOME_PATH"/MAgent/bin; ./magentctl -start > /dev/null 2>&1\"" >> $RCNAME1
                fi

                # add
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                else
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc_$RCTMP.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "echo \"polestar agent auto install success!!\"" >> $RCNAME1
                else
                    echo "echo \"polestar agent start success!!\"" >> $RCNAME1
                fi

                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME1
                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME2
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME1 /etc/
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME2 /etc/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME1 $HOME_PATH/utils/ETC/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME2 $HOME_PATH/utils/ETC/
                ;;
        $IRIX)
		if [ -f /etc/$RCNAME2 ]; then
		    echo "$EXECUR_PATH/rm -f /etc/$RCNAME2"
		    echo "$EXECUR_PATH/rm -f /etc/$RCNAME1"
		    $EXECUR_PATH/rm -f /etc/$RCNAME2
		    $EXECUR_PATH/rm -f /etc/$RCNAME1
                    if [ -f /etc/rc.nomni2 ]; then
		        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99polestar
                    elif [ -f /etc/rc$RLEVEL.d/S99ps_$RCTMP ]; then
		        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99ps_$RCTMP
                    fi
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "cd" $HOME_PATH"/utils/AUTOINSTALL; ../ETC/ShCmd 60 ./AgentAutoRun.sh" >> $RCNAME1
                else
                    #echo "cd" $HOME_PATH"/MAgent/bin; ./magentctl -start" >> $RCNAME1
                    echo "su - root -c \"cd" $HOME_PATH"/MAgent/bin; ./magentctl -start > /dev/null 2>&1\"" >> $RCNAME1
                fi

                # add
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                else
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc_$RCTMP.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "echo \"polestar agent auto install success!!\"" >> $RCNAME1
                else
                    echo "echo \"polestar agent start success!!\"" >> $RCNAME1
                fi

                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME1
                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME2
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME1 /etc/
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME2 /etc/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME1 $HOME_PATH/utils/ETC/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME2 $HOME_PATH/utils/ETC/
                if [ "$RLEVEL" = "2345" ]; then
                    if [ $RCNAME2 = "rc.nomni2" ]; then 
                        $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/S99polestar /etc/rc3.d/
                    else
                        $HOME_PATH/utils/INSTALL/S99ps_make $RCNAME2 S99ps_$RCTMP $RCTMP
                        $EXECUR_PATH/chmod 755 $CUR_PATH/S99ps_$RCTMP
                        $EXECUR_PATH/cp -rf $CUR_PATH/S99ps_$RCTMP /etc/rc3.d/
                        $EXECUR_PATH/mv $CUR_PATH/S99ps_$RCTMP $HOME_PATH/utils/ETC/
                    fi
                else
                    if [ $RCNAME2 = "rc.nomni2" ]; then 
                        $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/S99polestar /etc/rc$RLEVEL.d/
                    else
                        $HOME_PATH/utils/INSTALL/S99ps_make $RCNAME2 S99ps_$RCTMP $RCTMP
                        $EXECUR_PATH/chmod 755 $CUR_PATH/S99ps_$RCTMP
                        $EXECUR_PATH/cp -rf $CUR_PATH/S99ps_$RCTMP /etc/rc$RLEVEL.d/
                        $EXECUR_PATH/mv $CUR_PATH/S99ps_$RCTMP $HOME_PATH/utils/ETC/
                    fi
                fi
                ;;
        *)
                if [ -f /etc/$RCNAME2 ]; then
                    #echo "$EXECUR_PATH/rm -f /etc/$RCNAME2"
                    #echo "$EXECUR_PATH/rm -f /etc/$RCNAME1"
                    $EXECUR_PATH/rm -f /etc/$RCNAME1
                    $EXECUR_PATH/rm -f /etc/$RCNAME2
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "cd" $HOME_PATH"/utils/AUTOINSTALL; ../ETC/ShCmd 60 ./AgentAutoRun.sh" >> $RCNAME1
                else
                    #echo "cd" $HOME_PATH"/MAgent/bin; ./magentctl -start" >> $RCNAME1
                    echo "su - root -c \"cd" $HOME_PATH"/MAgent/bin; ./magentctl -start > /dev/null 2>&1\"" >> $RCNAME1
                fi

                # add
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                else
                    echo "echo \"$RCNAME1 execute !!\" > /tmp/rst_ckc_$RCTMP.log" >> $RCNAME2
                    echo "/etc/$RCNAME1 >> /dev/null 2>&1 &" >> $RCNAME2
                fi

                if [ $RCTMP = "atint" ]; then
                    echo "echo \"polestar agent auto install success!!\"" >> $RCNAME1
                else
                    echo "echo \"polestar agent start success!!\"" >> $RCNAME1
                fi

                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME1
                $EXECUR_PATH/chmod 755 $CUR_PATH/$RCNAME2
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME1 /etc/
                $EXECUR_PATH/cp -rf $CUR_PATH/$RCNAME2 /etc/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME1 $HOME_PATH/utils/ETC/
                $EXECUR_PATH/mv $CUR_PATH/$RCNAME2 $HOME_PATH/utils/ETC/
                ;;
        esac

        ##
        ################################################################


        ################################################################
        ### File Config : /etc/inittab(HPUX,OSF) or /etc/rc(AIX,MAC)

        case "$OS" in
        $SOLARIS)
                ;;
        $IRIX)
                ;;
        $HP|$OSF)
                $EXECUR_PATH/cp -rf /etc/inittab $HOME_PATH/utils/ETC/
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    if [ "$NOMNICHK" = "pst1" ]; then
                        echo "already exists pst1 : /etc/inittab"
                    else
                        echo "pst1:$RLEVEL:once:/etc/rc.nnpst start > /dev/null 2>&1 # auto start nnp agent service" >> /etc/inittab
                    fi
                else
                    if [ $RCTMP = "nims" ]; then
                        if [ "$NOMNICHK" = "nims" ]; then
                            echo "already exists nims : /etc/inittab"
                        else
                            echo "nims:$RLEVEL:once:/etc/rc.$RCTMP start > /dev/null 2>&1 # nims agent auto start service" >> /etc/inittab
                        fi
                    elif [ $RCTMP = "ninv" ]; then
                        if [ "$NOMNICHK" = "ninv" ]; then
                            echo "already exists ninv : /etc/inittab"
                        else
                            echo "ninv:$RLEVEL:once:/etc/rc.$RCTMP start > /dev/null 2>&1 # ninv agent auto start service" >> /etc/inittab
                        fi
                    elif [ $RCTMP = "cygn" ]; then
                        if [ "$NOMNICHK" = "cygn" ]; then
                            echo "already exists ninv : /etc/inittab"
                        else
                            echo "cygn:$RLEVEL:once:/etc/rc.$RCTMP start > /dev/null 2>&1 # ninv agent auto start service" >> /etc/inittab
                        fi

                    fi
                fi
                ;;

        $AIX)
                $EXECUR_PATH/cp -rf /etc/rc $HOME_PATH/utils/ETC/
                $EXECUR_PATH/cat /etc/rc | grep -v "exit 0" | grep -v $RCNAME2 > ./rc.dat
                echo "/etc/$RCNAME2" >> ./rc.dat
                echo "exit 0" >> ./rc.dat
                $EXECUR_PATH/chmod 554 $CUR_PATH/rc.dat
                $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/rc
                $EXECUR_PATH/mv $CUR_PATH/rc.dat $HOME_PATH/utils/ETC/
                ;;

        $MAC)
                if [ "$NOMNICHKLIN" ]; then
                    echo "already exists /etc/$RCNAME1 : /etc/rc.server"
                else
                    $EXECUR_PATH/cp -rf /etc/rc.server $HOME_PATH/utils/ETC/
                    $EXECUR_PATH/cat /etc/rc.server | grep -v "exit 0" | grep -v $RCNAME1 > ./rc.dat
                    echo "if [ -f /etc/$RCNAME1 ]; then" >> ./rc.dat
                    echo "sh /etc/$RCNAME1" >> ./rc.dat
                    echo "fi" >> ./rc.dat
                    echo "" >> ./rc.dat
                    echo "exit 0" >> ./rc.dat
                    $EXECUR_PATH/chmod 644 $CUR_PATH/rc.dat
                    $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/rc.server
                    $EXECUR_PATH/mv $CUR_PATH/rc.dat $HOME_PATH/utils/ETC/
                fi
                ;;

        $LINUX)
            if [ $LIN_TYPE -eq 0 ]; then        
                if [ -f /etc/rc.d/rc.local ]; then
                    if [ "$NOMNICHKLIN" ]; then
                        echo "already exists /etc/$RCNAME2 : /etc/rc.d/rc.local"
                    else
                        echo "/etc/$RCNAME2" >> /etc/rc.d/rc.local
                        chmod 744 /etc/rc.d/rc.local
                    fi
                else
                    if [ "$NOMNICHKLIN" ]; then
                        echo "already exists /etc/$RCNAME2 : /etc/rc.local"
                    else
                        $EXECUR_PATH/cp -rf /etc/rc.local $HOME_PATH/utils/ETC/
                        $EXECUR_PATH/cat /etc/rc.local | grep -v "exit 0" | grep -v $RCNAME2 > ./rc.local.dat
                        echo "/etc/$RCNAME2" >> ./rc.local.dat
                        echo "exit 0" >> ./rc.local.dat
                        $EXECUR_PATH/chmod 755 $CUR_PATH/rc.local.dat
                        $EXECUR_PATH/cp -rf $CUR_PATH/rc.local.dat /etc/rc.local
                        $EXECUR_PATH/mv $CUR_PATH/rc.local.dat $HOME_PATH/utils/ETC/
                    fi
                fi
            elif [ $LIN_TYPE -eq 2 ]; then        
                if [ "$NOMNICHKLIN" ]; then
                    if [ $RCTMP = "nomni" ]; then
                        echo "already exists e6nomni: /etc/init.d"
                    else
                        echo "already exists e7$RCTMP: /etc/init.d"
                    fi
                else
                    if [ $RCNAME2 = "rc.nomni2" ]; then
                        $EXECUR_PATH/cp -rf $HOME_PATH/utils/INSTALL/e6nomni /etc/init.d/
                    else
                        $HOME_PATH/utils/INSTALL/ubuntu_rcmake $RCNAME2 e7$RCTMP $RCTMP
                        $EXECUR_PATH/chmod 755 $CUR_PATH/e7$RCTMP
                        $EXECUR_PATH/cp -rf $CUR_PATH/e7$RCTMP /etc/init.d/
                        $EXECUR_PATH/mv $CUR_PATH/e7$RCTMP $HOME_PATH/utils/ETC/
                    fi
                    if [ $RCTMP = "nomni" ]; then
                        update-rc.d e6nomni defaults 99
                    else
                        echo "update-rc.d "$RCTMP
                        update-rc.d e7$RCTMP defaults 99
                    fi

                fi

            else                  
                if [ -f /etc/init.d/boot.local ]; then            
                    if [ "$NOMNICHKLIN" ]; then
                        echo "already exists /etc/$RCNAME2 : /etc/init.d/boot.local"
                    else
                        echo "/etc/$RCNAME2" >> /etc/init.d/boot.local
                    fi
                else
                    echo "Does not exist file(/etc/init.d/boot.local) in order to run the SMS Agent after OS Reboot."                
                fi            
            fi
                ;;

        *)
                if [ "$NOMNICHK" = "pst1" ]; then
                    echo "already exists pst1 : /etc/inittab"
                else
                    echo "pst1:$RLEVEL:once:/etc/$RCNAME2 > /dev/null 2>&1 # auto start nnp agent service" >> /etc/inittab
                fi
                ;;
        esac

        ##
        ################################################################

        ################################################################
        ## Display Config 

#        case "$OS" in
#        $SOLARIS)
#                echo "# ls [ $RCNAME2 ] #"
#                $EXECUR_PATH/ls -al /etc/rc*/*polestar
#                echo "# cat [ $RCNAME2 ] #"
#                echo "# cat [ $RCNAME1 ] #"
#                $EXECUR_PATH/cat /etc/$RCNAME2
#                $EXECUR_PATH/cat /etc/$RCNAME1
#                ;;
#        $LINUX)
#                echo "# ls [ $RCNAME2 ] #"
#                $EXECUR_PATH/ls -al /etc/rc*/*polestar
#                echo "# cat [ $RCNAME2 ] #"
#                echo "# cat [ $RCNAME1 ] #"
#                $EXECUR_PATH/cat /etc/rc.d/init.d/$RCNAME2
#                $EXECUR_PATH/cat /etc/rc.d/init.d/$RCNAME1
#                ;;
#        *)
#                echo "# ls [ $RCNAME2 ] #"
#                $EXECUR_PATH/grep pst1 /etc/inittab
#                echo "# cat [ $RCNAME2 ] #"
#                echo "# cat [ $RCNAME1 ] #"
#                $EXECUR_PATH/cat /etc/$RCNAME2
#                $EXECUR_PATH/cat /etc/$RCNAME1
#                ;;
#        esac

        ##
        ################################################################
elif [ "$OPT" = "-del" ]; then
        case "$OS" in
        $SOLARIS)
                if [ -f /etc/rc$RLEVEL.d/S99polestar ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99polestar
                        echo "# [ rc script file Delete Success ] #"
                fi
                if [ -f /etc/rc$RLEVEL.d/S99ps_$RCTMP ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99ps_$RCTMP
                        echo "# [ rc script file delete Success ] #"
                fi
                ;;

        $IRIX)
                if [ -f /etc/rc$RLEVEL.d/S99polestar ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99polestar
                        echo "# [ rc script file Delete Success ] #"
                fi
                if [ -f /etc/rc$RLEVEL.d/S99ps_$RCTMP ]; then
                        $EXECUR_PATH/rm -f /etc/rc$RLEVEL.d/S99ps_$RCTMP
                        echo "# [ rc script file delete Success ] #"
                fi
                ;;
        $LINUX)
            if [ $SUSECHK -eq 0 ]; then            
                if [ -f /etc/rc.d/rc.local ]; then
                    $EXECUR_PATH/cp -rf /etc/rc.d/rc.local $HOME_PATH/utils/ETC/
                    #$EXECUR_PATH/cat /etc/rc.d/rc.local | grep -v rc.nomni2 > ./rc.local.del.dat
                    $EXECUR_PATH/cat /etc/rc.d/rc.local | grep -v $RCNAME2 > ./rc.local.del.dat
                    $EXECUR_PATH/chmod 755 $CUR_PATH/rc.local.del.dat
                    $EXECUR_PATH/cp -rf $CUR_PATH/rc.local.del.dat /etc/rc.d/rc.local
                    $EXECUR_PATH/mv $CUR_PATH/rc.local.del.dat $HOME_PATH/utils/ETC/
                else
                    $EXECUR_PATH/cp -rf /etc/rc.local ./rc.local_def
                    $EXECUR_PATH/cat /etc/rc.local | grep -v rc.nomni2 > ./rc.local.del.dat
                    $EXECUR_PATH/chmod 755 $CUR_PATH/rc.local.del.dat
                    $EXECUR_PATH/cp -rf $CUR_PATH/rc.local.del.dat /etc/rc.local
                fi
            else    
                if [ -f /etc/init.d/boot.local ]; then
                    cp -rf /etc/init.d/boot.local $HOME_PATH/utils/ETC/
                    #cat /etc/init.d/boot.local | grep -v rc.nomni2 > ./boot.local.del.dat
                    cat /etc/init.d/boot.local | grep -v $RCNAME2 > ./boot.local.del.dat
                    chmod 755 $CUR_PATH/boot.local.del.dat
                    cp -rf $CUR_PATH/boot.local.del.dat /etc/init.d/boot.local
                    mv $CUR_PATH/boot.local.del.dat $HOME_PATH/utils/ETC/
                fi             
            fi
                ;;
        $AIX)
                $EXECUR_PATH/cp -rf /etc/rc ./rc_def
                $EXECUR_PATH/cat /etc/rc | grep -v $RCNAME2 > ./rc.dat
                $EXECUR_PATH/chmod 554 $CUR_PATH/rc.dat
                $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/rc
                ;;
        $MAC)
                $EXECUR_PATH/cp -rf /etc/rc.server ./rc_def
                $EXECUR_PATH/cat /etc/rc.server | grep -v $RCNAME2 > ./rc.dat
                $EXECUR_PATH/chmod 554 $CUR_PATH/rc.dat
                $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/rc.server
                ;;
        $HP|$OSF)
                if [ $RCNAME2 = "rc.nomni2" ]; then
                    if [ -f /etc/rc.nnpst ]; then
                        $EXECUR_PATH/rm -f /etc/rc.nnpst
                    fi
                fi
                if [ $RCTMP = "nims" ]; then
                    if [ -f /etc/rc.$RCTMP ]; then
                        $EXECUR_PATH/rm -f /etc/rc.$RCTMP
                    fi
                elif [ $RCTMP = "ninv" ]; then
                    if [ -f /etc/rc.$RCTMP ]; then
                        $EXECUR_PATH/rm -f /etc/rc.$RCTMP
                    fi
                fi

#                $EXECUR_PATH/cp -rf /etc/inittab $HOME_PATH/utils/ETC/
#                if [ $RCNAME2 = "rc.nomni2" ]; then
#                    $EXECUR_PATH/cat /etc/inittab | grep -v pst1 > ./rc.dat
#                    $EXECUR_PATH/chmod 666 $CUR_PATH/rc.dat
#                    $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/inittab
#                    if [ -f /etc/nnpst ]; then
#                        $EXECUR_PATH/rm -f /etc/nnpst
#                    fi
#                fi
#                if [ $RCTMP = "nims" ]; then
#                    $EXECUR_PATH/cat /etc/inittab | grep -v nims > ./rc.dat
#                    $EXECUR_PATH/chmod 666 $CUR_PATH/rc.dat
#                    $EXECUR_PATH/cp -rf $CUR_PATH/rc.dat /etc/inittab
#                    if [ -f /etc/rc.$RCTMP ]; then
#                        $EXECUR_PATH/rm -f /etc/rc.$RCTMP
#                    fi
#                fi
                ;;
        *)
                ;;
        esac

        case "$OS" in
        *)
                if [ -f /etc/$RCNAME2 ]; then
                        $EXECUR_PATH/rm -f /etc/$RCNAME2
                        echo "# [ /etc/$RCNAME2 Delete Success ] #"
                        $EXECUR_PATH/rm -f /etc/$RCNAME1
                        echo "# [ /etc/$RCNAME1 Delete Success ] #"
                fi
                ;;
        esac

else
        echo "Usage: $0 {install_directory} {[-add|-del]=rc_filename}"
        echo "ex add) ./AgentConf.sh /home/nkia/NNPAgent -add=nomni"
        echo "ex del) ./AgentConf.sh /home/nkia/NNPAgent -del=nomni"
        exit 0
fi

exit 0;
