#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

get_cpu_new_version()
{

    type=`getconf _SC_CPU_VERSION`
    #echo $type

    let "var1=0x20B"
    let "var2=0x20C"
    let "var3=0x20E"
    let "var4=0x2FF"
    let "var5=0x300"
    #echo "var=$var1,$var2,$var3,$var4,$var5"

    if [ "$type" -lt "$var1" ] ; then
        echo "UNKNOWN"
    elif [ "$type" -ge "$var2" -a "$type" -le "$var3" ] ; then
        echo "Motorola"
    elif [ "$type" -le "$var4" ] ; then
        echo "PA-RISC"
    elif [ "$type" -eq "$var1" ] ;then
        echo "ia64"
    else
        echo "UNKNOWN"
    fi
}

get_cpu_version()
{
   case `getconf CPU_VERSION` in
      # ???) echo "Itanium[TM] 2" ;;
      768) echo "Itanium[TM] 1" ;;
      532) echo "PA-RISC 2.0" ;;
      529) echo "PA-RISC 1.2" ;;
      528) echo "PA-RISC 1.1" ;;
      523) echo "PA-RISC 1.0" ;;
        *) return 1 ;;
   esac

   return 0

}  # get_cpu_version()

get_cpu_model()
{

  # plan A (getconf CPU_CHIP_TYPE)
  ##################################
  if [ "$OSVER" -ge 1100 ]; then
    typeset -i2 bin
    bin=`getconf CPU_CHIP_TYPE`
    typeset -i16 hex
    hex=2#`echo $bin | sed -e 's/2#//' -e 's/.....$//'`
    model_num=`echo $hex | cut -c4-`
    case $model_num in
       b) model_name=PA7200   ;;
       d) model_name=PA7100LC ;;
       e) model_name=PA8000   ;;
       f) model_name=PA7300LC ;;
      10) model_name=PA8200   ;;
      11) model_name=PA8500   ;;
      12) model_name=PA8600   ;;
      13) model_name=PA8700   ;;
      14) model_name=PA8800   ;;
      15) model_name=PA8750   ;;
      30) model_name=Itanium[TM]  ;;
      # ??) model_name=Itanium2[TM] ;;
       *) model_name=         ;;
    esac
    [ -n "$model_name" ] && { echo $model_name ; return 0 ; }
  fi

  # plan B (sched.models)
  #########################
  MODEL=`uname -m | cut -d/ -f2`

  LINE=`grep "^$MODEL" <<EoF
/* @(#) $Header: /samsrc/mo/data/sched.models 73.20 2001-03-29 07:57:14-07 tkop\
ren Exp $ */
600     1.0     PA7000
635     1.0     PA7000
645     1.0     PA7000
700     1.1     PA7000
705     1.1a    PA7000
715     1.1c    PA7100LC
710     1.1a    PA7000
712     1.1c    PA7100LC
720     1.1a    PA7000
722     1.1c    PA7100LC
725     1.1c    PA7100LC
728     1.1d    PA7200
730     1.1a    PA7000
735     1.1b    PA7100
742     1.1b    PA7100
743     1.1c    PA7100LC
744     1.1e    PA7300
745     1.1b    PA7100
747     1.1b    PA7100
750     1.1a    PA7000
755     1.1b    PA7100
770     1.1d    PA7200
777     1.1d    PA7200
778     1.1e    PA7300
779     1.1e    PA7300
780     2.0     PA8000
781     2.0     PA8000
782     2.0     PA8200
800     1.0     PA7000
801     1.1c    PA7100LC
802     2.0     PA8000
803     1.1e    PA7300
804     2.0     PA8000
806     1.1c    PA7100LC
807     1.1a    PA7000
808     1.0     PA7000
809     1.1d    PA7200
810     2.0     PA8000
811     1.1c    PA7100LC
813     1.1e    PA7300
815     1.0     PA7000
816     1.1c    PA7100LC
817     1.1a    PA7000
819     1.1d    PA7200
820     2.0     PA8000
821     1.1d    PA7200
822     1.0     PA7000
825     1.0     PA7000
826     1.1c    PA7100LC
827     1.1a    PA7000
829     1.1d    PA7200
831     1.1d    PA7200
832     1.0     PA7000
834     1.0     PA7000
835     1.0     PA7000
837     1.1a    PA7000
839     1.1d    PA7200
840     1.0     PA7000
841     1.1d    PA7200
842     1.0     PA7000
845     1.0     PA7000
847     1.1a    PA7000
849     1.1d    PA7200
850     1.0     PA7000
851     1.1d    PA7200
852     1.0     PA7000
855     1.0     PA7000
856     1.1c    PA7100LC
857     1.1a    PA7000
859     1.1d    PA7200
860     1.0     PA7000
861     2.0     PA8000
865     1.0     PA7000
867     1.1a    PA7000
869     1.1d    PA7200
870     1.0     PA7000
871     2.0     PA8000
877     1.1a    PA7000
879     2.0     PA8000
887     1.1b    PA7100
889     2.0     PA8000
890     1.0     PA7000
891     1.1b    PA7100
892     1.1b    PA7100
893     2.0     PA8000
897     1.1b    PA7100
898     2.0     PA8200
899     2.0     PA8200
F10     1.1a    PA7000
F20     1.1a    PA7000
H20     1.1a    PA7000
F30     1.1a    PA7000
G30     1.1a    PA7000
H30     1.1a    PA7000
I30     1.1a    PA7000
G40     1.1a    PA7000
H40     1.1a    PA7000
I40     1.1a    PA7000
G50     1.1b    PA7100
H50     1.1b    PA7100
I50     1.1b    PA7100
G60     1.1b    PA7100
H60     1.1b    PA7100
I60     1.1b    PA7100
G70     1.1b    PA7100
H70     1.1b    PA7100
I70     1.1b    PA7100
E25     1.1c    PA7100LC
E35     1.1c    PA7100LC
E45     1.1c    PA7100LC
E55     1.1c    PA7100LC
T500    1.1b    PA7100
T520    1.1b    PA7100
T540    2.0     PA8000
K100    1.1d    PA7200
K200    1.1d    PA7200
K210    1.1d    PA7200
K220    1.1d    PA7200
K230    1.1d    PA7200
K400    1.1d    PA7200
K410    1.1d    PA7200
K420    1.1d    PA7200
DXO     1.1c    PA7100LC
DX0     1.1c    PA7100LC
DX5     1.1c    PA7100LC
D200    1.1c    PA7100LC
D210    1.1c    PA7100LC
D310    1.1c    PA7100LC
D410    1.1d    PA7200
D250    1.1d    PA7200
D350    1.1d    PA7200
J200    1.1d    PA7200
J210    1.1d    PA7200
C100    1.1d    PA7200
J220    2.0     PA8000
J280    2.0     PA8000
S715    1.1e    PA7300
S760    1.1e    PA7300
D650    2.0     PA8000
J410    2.0     PA8000
J400    2.0     PA8000
J210XC  1.1d    PA7200
J2240   2.0     PA8200
C200+   2.0     PA8200
C240+   2.0     PA8200
C180    2.0     PA8000
C180-XP 2.0     PA8000
C160    2.0     PA8000
C160L   1.1e    PA7300
C140    2.0     PA8000
C130    2.0     PA8000
C120    1.1e    PA7300
C115    1.1e    PA7300
C110    1.1d    PA7200
C360    2.0     PA8500
B160L   1.1e    PA7300
B132L   1.1e    PA7300
B120    1.1e    PA7300
B115    1.1e    PA7300
S700i   1.1e    PA7300
S744    1.1e    PA7300
D330    1.1e    PA7300
D230    1.1e    PA7300
D320    1.1e    PA7300
D220    1.1e    PA7300
D360    1.1d    PA7200
K360    2.0     PA8000
K370    2.0     PA8200
K460    2.0     PA8000
K460-EG 2.0     PA8000
K460-XP 2.0     PA8000
K260    2.0     PA8000
K260-EG 2.0     PA8000
D260    1.1d    PA7200
D270    2.0     PA8000
D280    2.0     PA8000
D370    2.0     PA8000
D380    2.0     PA8000
D390    2.0     PA8000
R380    2.0     PA8000
R390    2.0     PA8000
K250    2.0     PA8000
K450    2.0     PA8000
K270    2.0     PA8200
K470    2.0     PA8200
K380    2.0     PA8200
K580    2.0     PA8200
V2200   2.0     PA8200
V2250   2.0     PA8200
V2500   2.0     PA8500
V2600   2.0     PA8600
V2650   2.0     PA8700
V2700   2.0     PA8700
A180    1.1e    PA7300LC
A180c   1.1e    PA7300LC
A400-36 2.0     PA8500
A400-44 2.0     PA8500
A400-5X 2.0     PA8600
A400-7X 2.0     PA8700
A400-8X 2.0     PA8700
A500-36 2.0     PA8500
A500-44 2.0     PA8500
A500-55 2.0     PA8600
A500-5X 2.0     PA8600
A500-7X 2.0     PA8700
A500-8X 2.0     PA8700
B1000   2.0     PA8500
B2000   2.0     PA8500
B2600   2.0     PA8700
C3000   2.0     PA8500
C3600   2.0     PA8600
C3700   2.0     PA8700
C3750   2.0     PA8700
J5000   2.0     PA8500
J5600   2.0     PA8600
J6000   2.0     PA8600
J6700   2.0     PA8700
J6750   2.0     PA8700
J7000   2.0     PA8500
J7600   2.0     PA8600
SD16000 2.0     PA8600
SD32000 2.0     PA8600
SD64000 2.0     PA8600
S16K-A  2.0     PA8700
N8K-A   2.0     PA8700
N4000-36        2.0     PA8500
N4000-44        2.0     PA8500
N4000-55        2.0     PA8600
N4000-5X        2.0     PA8600
N4000-7X        2.0     PA8700
N4000-6X        2.0     PA8700
N4000-8X        2.0     PA8700
N4000-8Y        2.0     PA8700
N4000-8Z        2.0     PA8700
N4000-9X        2.0     PA8700
L1000-36        2.0     PA8500
L1000-44        2.0     PA8500
L1000-5X        2.0     PA8600
L1000-8X        2.0     PA8700
L1500-6x        2.0     PA8700
L1500-7x        2.0     PA8700
L1500-8x        2.0     PA8700
L1500-9x        2.0     PA8700
L2000-36        2.0     PA8500
L2000-44        2.0     PA8500
L2000-5X        2.0     PA8600
L2000-8X        2.0     PA8700
L3000-55        2.0     PA8600
L3000-5x        2.0     PA8600
L3000-6x        2.0     PA8700
L3000-7x        2.0     PA8700
L3000-8x        2.0     PA8700
L3000-9x        2.0     PA8700
i2000           Itanium(TM)
g4000           Itanium(TM)
u16000          Itanium(TM)
ia64            Itanium(TM)
EoF
`

  [ -z "$LINE" ] && return 1
  echo $LINE | awk '{print $NF}' 2>/dev/null
  return 0

}  # end get_cpu_model()

CPU_type=`get_cpu_version | cut -f 1 -d " "`
#CPU_model=`get_cpu_model`
CPU_model=$(grep -i $(model | tr "/" " " | awk '{print $NF}') /usr/sam/lib/mo/sched.models | awk '{print $NF}')

disk=`vgdisplay -v $1  | grep "PV Name" | cut -f 4  -d "/"`
vendor=`/usr/sbin/diskinfo /dev/rdsk/${disk} | grep vendor | cut -f 2 -d ":"`
type=`/usr/sbin/diskinfo /dev/rdsk/${disk} | grep type | cut -f 2 -d ":"`
size=`/usr/sbin/diskinfo /dev/rdsk/${disk} | grep size | cut -f 2 -d ":" | cut -f 2 -d " "`
size=`expr ${size} / 1024`

echo "DISKDEVICE    : ${disk}"
echo "DISKVENDOR    : ${vendor}"
echo "DISKTYPE      : ${type}"
echo "DISKSIZE      : ${size}"
echo "CUPMODEL      : ${CPU_model}"
echo "CUPTYPE       : ${CPU_type}"
