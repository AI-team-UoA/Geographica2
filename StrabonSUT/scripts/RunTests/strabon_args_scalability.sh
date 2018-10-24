#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/StrabonSUT/Scalability/${1} exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/StrabonSUT/Scalability/${1}" ]; then
    mkdir -p "${ResultsBaseDir}/StrabonSUT/Scalability/${1}"
else # clear existing data
    rm -r ${ResultsBaseDir}/StrabonSUT/Scalability/${1}/*
fi

# return all arguments except the experiment name
echo "-h localhost -db scalability_${1} -p 5432 -u postgres -P postgres -r 3 -t 86400 -m 60 -l \"${ResultsBaseDir}/StrabonSUT/Scalability/${1}\" run"