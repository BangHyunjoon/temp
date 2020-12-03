#!/bin/sh

NAS_GW=""
NAS_NETWORK=""

if [ "$1" ] ; then
    NAS_GW=$1
    NAS_NETWORK=$2
    echo "NAS_GW[$NAS_GW], NAS_NETWORK[$NAS_NETWORK]"
else
    echo "Input arg error : <NAS gateway ip addr>"
    exit 255
fi

function cmd_to_exec
{
  unset mask
  unset interface
  mask=${5#-m}
  interface=${6#-i}
  if [ $1 = "host" -a -n "$mask" ] ; then
     echo "netmask not allowed when adding a route with TYPE"
     exit 1
  fi
  if [ $mask ] ; then
     if [ "`echo $mask | cut -c 1,2`" != "0x" ] ; then
         unset i
         unset j
         i=5
         if [ "`echo $mask | cut -f $i -d .`" != "" ] ; then
             echo "Invalid netmask"
             exit 1
         else
             i=`expr $i - 1`
             while [ $i -gt 0 ] ; do
                  j=`echo $mask | cut -f $i -d .`
                  if [ "$j" = "" ] ; then
                      echo "Invalid netmask"
                      exit 1
                  fi
                  if [ $j -lt 0 -o $j -gt 255 ] ; then
                      echo "Warning : The netmask is not valid and may result to ambiguity"
                  fi
                  i=`expr $i - 1`
              done
          fi
      fi
  fi
  #if [ test -z 'lsdev -C -S1 -F name -l inet0' ] ; then
  #    mkdev -t inet
  #fi

  unset arg2
  if [ $mask ] ; then
      arg2=-netmask,$mask
  else
      arg2=
  fi
  unset arg
  if [ $8 = "yes" ] ; then
      arg=-interface
  else
      arg=-hopcount,$4
  fi
  unset arg3
  if [[ $interface != '' && $interface != 'any     Use any available interface' ]] ; then
      arg3=`echo $interface | awk '{ print $1 }'`
      arg3=-if,$arg3
  else
      arg3=
  fi
  unset arg4
  if [ $7 = "yes" ] ; then
      arg4=-active_dgd
  else
      arg4=
  fi
  unset arg5
  if [ $9 = "0" ] ; then
      arg5=
  else
      arg5=-policy,$9
  fi
  unset arg6
  if [ ${10} = "1" ] ; then
      arg6=
  else
      arg6=-weight,${10}
  fi
  unset arg7
  if [ ${11} = "no" ] ; then
      arg7=
  else
      arg7=-P
  fi
  chdev -l inet0 $arg7 -a route=$1,$arg,$arg2,$arg3,$arg4,$arg5,$arg6,-static,$2,$3
  unset arg
  unset arg2
  unset arg3
  unset arg4
  unset arg5
  unset arg6
  unset arg7
  unset mask
  unset interface
}

cmd_to_exec 'net' "$NAS_NETWORK" "$NAS_GW" '0' -m'' -i'' 'no' 'no' '0' '1' 'no'

exit 0

