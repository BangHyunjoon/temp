#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

ALPHA_CPU_TYPE=`/usr/sbin/psrinfo -v | sed -n -e 's/^  The alpha \(.*\) processor.*$/\1/p' | head -n 1`
	case "$ALPHA_CPU_TYPE" in
	    "EV4 (21064)")
		UNAME_MACHINE="alpha" ;;
	    "EV4.5 (21064)")
		UNAME_MACHINE="alpha" ;;
	    "LCA4 (21066/21068)")
		UNAME_MACHINE="alpha" ;;
	    "EV5 (21164)")
		UNAME_MACHINE="alphaev5" ;;
	    "EV5.6 (21164A)")
		UNAME_MACHINE="alphaev56" ;;
	    "EV5.6 (21164PC)")
		UNAME_MACHINE="alphapca56" ;;
	    "EV5.7 (21164PC)")
		UNAME_MACHINE="alphapca57" ;;
	    "EV6 (21264)")
		UNAME_MACHINE="alphaev6" ;;
	    "EV6.7 (21264A)")
		UNAME_MACHINE="alphaev67" ;;
	    "EV6.8CB (21264C)")
		UNAME_MACHINE="alphaev68" ;;
	    "EV6.8AL (21264B)")
		UNAME_MACHINE="alphaev68" ;;
	    "EV6.8CX (21264D)")
		UNAME_MACHINE="alphaev68" ;;
	    "EV6.9A (21264/EV69A)")
		UNAME_MACHINE="alphaev69" ;;
	    "EV7 (21364)")
		UNAME_MACHINE="alphaev7" ;;
	    "EV7.9 (21364A)")
		UNAME_MACHINE="alphaev79" ;;
esac

#echo ${ALPHA_CPU_TYPE}
echo ${UNAME_MACHINE}

