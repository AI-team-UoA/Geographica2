#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi
# User needs to check:
#   - system command that clears caches
#   - use ./graphdb_args_scalability.sh
#   - define the location of running script compared to the location of the geographica_Scalability.log

# Check if ${ExperimentResultDir}/Scalability/LOGS exists and create it if necessary
if [ ! -d "${ExperimentResultDir}/Scalability/LOGS" ]; then
    mkdir -p "${ExperimentResultDir}/Scalability/LOGS"
fi

levels=(  "10K" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        # clear system caches
        sudo /sbin/sysctl vm.drop_caches=3
        # creates/clears ${ExperimentResultDir}/Scalability/${level}
        # returns all arguments except experiment and
        # executes experiment
        ./graphdb_args_scalability.sh ${level} | ./runTestsForGraphDBSUT.sh /dev/stdin testslist_scalability.txt ${JVM_Xmx} ${GraphDBBaseDir}
        # archive log
        mv ../../geographica_Scalability.log ${ExperimentResultDir}/Scalability/LOGS/geographica_Scalability_${level}.log
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/Scalability/${level}
done