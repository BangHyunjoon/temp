DATE=`date`
JAVA_HOME=/usr/java/default
echo "[$DATE] child : $JAVA_HOME/bin/java -jar -Dsetup_dir=/home/cams/NNPAgent -Dagent_java=$JAVA_HOME wasagent.jar"
cd ../..
$JAVA_HOME/bin/java -jar -Dsetup_dir=/home/cams/NNPAgent -Dagent_java=$JAVA_HOME wasagent.jar<< EOF
\n
