PROCNAME=$1
#for i in `ps -ef | grep "$PROCNAME -N" | grep -v grep | awk '{print $2}'`
for i in `ps -ef | grep Micro_nk_lpar | grep -v grep | awk '{print $2}'`
do

	pid=`echo $i | cut -d' ' -f1`

	#echo "kill -9 $pid"
	kill -9 $pid

done


for i in `ps -ef | grep nk_Perfstat | grep -v grep | awk '{print $2}'`
do

	pid=`echo $i | cut -d' ' -f1`

	#echo "kill -9 $pid"
	kill -9 $pid

done
