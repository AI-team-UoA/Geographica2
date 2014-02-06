#!/bin/bash
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DEBUG=false
if test "${1}" = "-d"; then
	DEBUG=true
	shift
fi

args=$*

LOG4J_CONFIGURATION=${BASE}/../../runtime/src/main/resources/log4j.properties

cd ${BASE}/../target
EXEC="java -Xmx20000M \
	 -cp $(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)runtime/src/main/resources/timestamps.txt  \
     -Dlog4j.configuration=file:${LOG4J_CONFIGURATION} \
     gr.uoa.di.rdf.Geographica.useekm.RunUSeekM ${args}"

if ${DEBUG}; then
	echo ${EXEC}
else
	echo `date`
	eval ${EXEC}
	echo `date`
fi
