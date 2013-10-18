#!/bin/bash
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# where to store the generated files
OUTPUT_PATH=${BASE}/generator

# how many element to generate (per axis)
ELEMENTS_PER_AXIS=1024

DEBUG=false
case ${1} in
	-d)
		DEBUG=true
		shift
	;;
	-h)
		echo "Usage: ${0} <output-path> <elements-per-axis>"
		exit
	;;
esac


args=$*

if [[ $# -eq 0 ]] ; then
	args="${OUTPUT_PATH} ${ELEMENTS_PER_AXIS}"
else
	OUTPUT_PATH=${1}
	ELEMENTS_PER_AXIS=${2}	
fi

if test ! -d ${OUTPUT_PATH}; then
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
