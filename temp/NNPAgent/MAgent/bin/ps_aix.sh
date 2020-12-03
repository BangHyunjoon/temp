while [ 1 ]
do
date
echo "     PID    TTY STAT  TIME PGIN  SIZE   RSS   LIM  TSIZ   TRS %CPU %MEM COMMAND"
ps gv | grep "AGEN"
sleep 5
echo " "
done
