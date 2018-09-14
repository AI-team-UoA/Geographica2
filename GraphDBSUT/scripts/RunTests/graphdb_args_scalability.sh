#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ResultsBaseDir} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/GraphDBSUT/Scalability/${1} exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/GraphDBSUT/Scalability/${1}" ]; then
    mkdir -p "${ResultsBaseDir}/GraphDBSUT/Scalability/${1}"
else # clear existing data
    rm -r ${ResultsBaseDir}/GraphDBSUT/Scalability/${1}/*
fi

#      2.2.1: get the value of the <graphdb.home.data> in the <graphDBBaseDir>/conf/graphdb.properties configuration file
GraphDB_Properties_File="${GraphDBBaseDir}/conf/graphdb.properties"
matchedLine=`grep -e "^graphdb.home.data =" $GraphDB_Properties_File`
GraphDB_Data_Dir="${matchedLine##*= }"
# if graphdb.home.data is not explicitly set then assign default path
if [ -z ${GraphDB_Data_Dir} ]; then
        GraphDB_Data_Dir="${GraphDBBaseDir}/data"
fi

# return all arguments except the experiment name
echo "-bd \"${GraphDB_Data_Dir}\" -rp scalability_${1} -cr false -r 3 -t 86400 -m 60 -l \"${ResultsBaseDir}/GraphDBSUT/Scalability/${1}\" run"