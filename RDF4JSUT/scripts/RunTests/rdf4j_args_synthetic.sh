#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/RDF4JSUT/Synthetic exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/RDF4JSUT/Synthetic" ]; then
    mkdir -p "${ResultsBaseDir}/RDF4JSUT/Synthetic"
else # clear existing data
    rm -r ${ResultsBaseDir}/RDF4JSUT/Synthetic/*
fi

# return all arguments except the experiment name
echo "-bd \"${RDF4JRepoBaseDir}\" -rp synthetic -cr false -r 3 -t 3600 -l \"${ResultsBaseDir}/RDF4JSUT/Synthetic\" -N 512 run"