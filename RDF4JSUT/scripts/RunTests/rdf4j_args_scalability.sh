#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Scalability/${1} exists and create it if necessary
if [ ! -d "${ExperimentResultDir}/Scalability/${1}" ]; then
    mkdir -p "${ExperimentResultDir}/RDF4JSUT/Scalability/${1}"
#else # clear existing data
   # rm -r ${ResultsBaseDir}/Scalability/${1}/*
fi

# return all arguments except the experiment name
echo "-bd \"${RDF4JRepoBaseDir}\" -rp scalability_${1} -cr false -dr 0 -r 3 -t 86400 -m 60 -l \"${ExperimentResultDir}/Scalability/${1}\" run"