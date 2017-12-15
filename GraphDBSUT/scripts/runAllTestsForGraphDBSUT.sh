#!/bin/bash

# find the directory where the scripts is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo "BASE = $BASE"

# retrieve the name of the file with all arguments except the experiment name
ARGS_FILE=${1}
#echo "ARGS_FILE = $ARGS_FILE"
# read the line from the ARGS_FILE which contains all arguments except the experiment name
ARGS_NO_EXPERIMENT=`< $ARGS_FILE`
#echo "ARGS_NO_EXPERIMENT = $ARGS_NO_EXPERIMENT"

# retrieve the name of the file with all the experiments
EXPERIMENT_LIST_FILE=`realpath ${2}`
#echo "EXPERIMENT_LIST_FILE = $EXPERIMENT_LIST_FILE"

# define the configuration file for the Apache LOG4J framework
LOG4J_CONFIGURATION=${BASE}/../../runtime/src/main/resources/log4j.properties
#echo "LOG4J_CONFIGURATION = $LOG4J_CONFIGURATION"

# define the JVM options/parameters
JAVA_OPTS="-Xmx5g -Dregister-external-plugins=/home/tioannid/graphdb-free-8.3.1/lib/plugins -Dlog4j.configuration=file:${LOG4J_CONFIGURATION}"
#echo "JAVA_OPTS = $JAVA_OPTS"

# change to the ../target directory to more easily create the classpath
cd ${BASE}/../target
# define the class path
CLASS_PATH="$(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)runtime/src/main/resources/timestamps.txt"

# define the executing-main class
MAIN_CLASS="gr.uoa.di.rdf.Geographica2.graphdbsut.RunGraphDB"

# run all experiments
START_TIME=`date`
while read experiment; do
  echo "====> Experiment : $experiment"
  # set the ARGS
  ARGS="$ARGS_NO_EXPERIMENT $experiment"
  #echo "ARGS = $ARGS"
  # define the run command
  EXEC="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS ${ARGS}"
  # record start time of experiment
  EXPIR_START_TIME=$SECONDS

  eval ${EXEC}

  # record end time of experiment
  DURATION_SECS=$(($SECONDS-$EXPIR_START_TIME))
  DURATION_HOURS=$(($DURATION_SECS / 3600))
  DURATION_REMAINING_SECS=$(($DURATION_SECS % 3600))
  echo "-------------------------------" >> geographica.log
  echo "Experiment Duration : $DURATION_HOURS hours $((DURATION_REMAINING_SECS / 60)) min and $((DURATION_REMAINING_SECS % 60)) secs" >> geographica.log
  
  # record hardware description used by the experiment
  echo "-------------------------------" >> geographica.log
  echo "Host used : $HOSTNAME" >> geographica.log

  CPU_INFO=`lscpu`
  echo "-------------------------------" >> geographica.log
  echo "CPU Used " >> geographica.log
  echo $CPU_INFO >> geographica.log
  MEM_INFO=`cat /proc/meminfo`
  echo "-------------------------------" >> geographica.log
  echo "MEMORY Info " >> geographica.log
  echo $MEM_INFO >> geographica.log

  mv geographica.log ../geographica_${experiment}.log
  
done < $EXPERIMENT_LIST_FILE
END_TIME=`date`

# print test duration
echo "Start time = $START_TIME"
echo "End time = $END_TIME"
