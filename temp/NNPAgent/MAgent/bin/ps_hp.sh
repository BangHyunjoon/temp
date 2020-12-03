export UNIX95=1

while [ 1 ]
do
date
echo " PID   PPID VSZ  PCPU ARGS"
ps -e -o pid -o ppid -o vsz -o pcpu -o args | grep "AGENT"
sleep 5
echo " "
done
