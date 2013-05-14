#!/bin/bash
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# where to store the generated files
OUTPUT_PATH=${BASE}/generator

# how many element to generate (per axis)
ELEMENTS_PER_AXIS=1024

DEBUG=false
if test "$1" = "-d"; then
	DEBUG=true
	shift
fi

args=$*

if [[ $# -eq 0 ]] ; then
	args="${OUTPUT_PATH} ${ELEMENTS_PER_AXIS}"
fi

if [[ -d ${OUTPUT_PATH} ]] ; then
	mkdir ${OUTPUT_PATH}
fi

cd ${BASE}/generators/target
EXEC="java -Xmx22000M \
	-cp $(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;) \
	gr.uoa.di.rdf.Geographica.generators.SyntheticGenerator \
	${args}"

if ${DEBUG}; then
	echo ${EXEC}
else
	echo `date`
	eval ${EXEC}
	echo `date`
fi
