IP=$1
PATH=$2

LINUX=Linux
SOLARIS=SunOS
HP=HP-UX
OSF=OSF1
AIX=AIX
UNIXWARE=Uinxware

OS=`/bin/uname -s`

if [ "$OS" = "$LINUX" ]; then
        EXEPATH="/usr/bin"
fi
if [ "$OS" = "$SOLARIS" ]; then
        EXEPATH="/bin"
fi
if [ "$OS" = "$HP" ]; then
        EXEPATH="/bin"
fi
if [ "$OS" = "$AIX" ]; then
        EXEPATH="/bin"
fi
if [ "$OS" = "$UNIXWARE" ]; then
        EXEPATH="/bin"
fi
if [ "$OS" = "$OSF" ]; then
        EXEPATH="/bin"
fi

EXE="$EXEPATH/telnet $IP 21002 <<EOF > $PATH/result.txt 2>&1"
`$PATH/../ETC/ShCmd 2 $EXE`
