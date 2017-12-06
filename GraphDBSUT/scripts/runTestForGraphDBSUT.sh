#!/bin/bash

# find the directory where the scripts is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo "BASE = $BASE"

# define DEBUG = false by default, unless the script's 1st argument is '-d'
DEBUG=false
if test "${1}" = "-d"; then
	DEBUG=true
	shift
fi

# retrieve the remaining arguments
ARGS=$*
#echo "ARGS = $ARGS"

# define the configuration file for the Apache LOG4J framework
LOG4J_CONFIGURATION=${BASE}/../../runtime/src/main/resources/log4j.properties
#echo "LOG4J_CONFIGURATION = $LOG4J_CONFIGURATION"

# change to the ../target directory to more easily create the classpath
cd ${BASE}/../target

# define the JVM options/parameters
JAVA_OPTS="-Xmx4g -Dregister-external-plugins=/home/tioannid/graphdb-free-8.3.1/lib/plugins -Dlog4j.configuration=file:${LOG4J_CONFIGURATION}"
#echo "JAVA_OPTS = $JAVA_OPTS"

# define the class path
CLASS_PATH="$(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)runtime/src/main/resources/timestamps.txt"

# define the executing-main class
MAIN_CLASS="gr.uoa.di.rdf.Geographica2.graphdbsut.RunGraphDB"

# define the run command
EXEC="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS ${ARGS}"

if ${DEBUG}; then
	echo ${EXEC}
else
	echo `date`
	eval ${EXEC}
	echo `date`
fi
