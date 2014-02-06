#!/bin/bash
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DEBUG=false
if test "$1" = "-d"; then
	DEBUG=true
	shift
fi

PARLIAMENT_DATA=$1
if test ! -f ${1}/ParliamentConfig.txt -a ! "${2}" = "print"; then
	echo "File '${1}/ParliamentConfig.txt'" does not exist;
	exit -1
fi
shift
args=$*

#PARLIAMENT_DATA=${HOME}/parliament/parliament-data/geographica
export LD_LIBRARY_PATH=${BASE}/../../runtime/src/main/resources/parliament-dependencies/linux-64:${LD_LIBRARY_PATH}
export DYLD_LIBRARY_PATH=${BASE}/../../runtime/src/main/resources/parliament-dependencies/linux-64:$DYLD_LIBRARY_PATH
export PARLIAMENT_CONFIG_PATH=${PARLIAMENT_DATA}/ParliamentConfig.txt

LOG4J_CONFIGURATION=${BASE}/../../runtime/src/main/resources/log4j.properties

cd ${BASE}/../target
EXEC="java -Xmx20000M \
	 -cp $(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)runtime/src/main/resources/timestamps.txt  \
     -Dgeographica.system=Parliament \
     -Djava.library.path=${LD_LIBRARY_PATH} \
     -DPARLIAMENT_CONFIG_PATH=${PARLIAMENT_CONFIG_PATH} \
     -DLD_LIBRARY_PATH=${LD_LIBRARY_PATH} \
     -DDYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} \
	 -Dlog4j.configuration=file:${LOG4J_CONFIGURATION} \
     gr.uoa.di.rdf.Geographica.parliament.RunParliament \
	 ${args}"
	#-Dlog4j.debug \

if ${DEBUG}; then
	echo ${EXEC}
    echo -Dgeographica.system=Parliament 
	echo -Djava.library.path=${LD_LIBRARY_PATH} 
	echo -DPARLIAMENT_CONFIG_PATH=${PARLIAMENT_CONFIG_PATH} 
	echo -DLD_LIBRARY_PATH=${LD_LIBRARY_PATH} 
	echo -DDYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH} 
else
	echo `date`
	eval ${EXEC}
	echo `date`
fi

