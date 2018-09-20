#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ResultsBaseDir} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi
# User needs to check:
#   - system command that clears caches
#   - use ./graphdb_args_scalability.sh
#   - define the location of running script compared to the location of the geographica_Scalability.log

# Check if ${ResultsBaseDir}/GraphDBSUT/Scalability/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/GraphDBSUT/Scalability/LOGS" ]; then
    mkdir -p "${ResultsBaseDir}/GraphDBSUT/Scalability/LOGS"
fi

#levels=(  "10K" "100K" "1M" "10M" )
levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        # clear system caches
        sudo /sbin/sysctl vm.drop_caches=3
        # creates/clears ${ResultsBaseDir}/GraphDBSUT/Scalability/${level}
        # returns all arguments except experiment and
        # executes experiment
        ./graphdb_args_scalability.sh ${level} | ./runTestsForGraphDBSUT.sh /dev/stdin testslist_scalability.txt -Xmx24g ${GraphDBBaseDir}
        # archive log
        mv ../../geographica_Scalability.log ${ResultsBaseDir}/GraphDBSUT/Scalability/LOGS/geographica_Scalability_${level}.log
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/GraphDBSUT/Scalability/${level}
done
