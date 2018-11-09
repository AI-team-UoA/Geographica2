#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Synthetic exists and create it if necessary
if [ ! -d "${ExperimentResultDir}/Synthetic" ]; then
    mkdir -p "${ExperimentResultDir}/Synthetic"
else # clear existing data
    rm -r ${ExperimentResultDir}/Synthetic/*
fi

# return all arguments except the experiment name
echo "-bd \"${RDF4JRepoBaseDir}\" -rp synthetic -cr false -dr 0 -r 3 -t 3600 -l \"${ExperimentResultDir}/Synthetic\" -N 512 run"