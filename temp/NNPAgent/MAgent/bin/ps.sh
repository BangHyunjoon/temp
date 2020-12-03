while [ 1 ]
do
date
echo " PID   PPID VSZ  RSS   PMEM PCPU ARGS"
ps -e -o pid -o ppid -o vsz -o rss -o pmem -o pcpu -o args | grep "AGENT"
sleep 1
echo " "
done
