#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

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
        ./rdf4j_args_scalability.sh ${level} | ./runTestsForRDF4JSUT.sh /dev/stdin testslist_scalability.txt ${JVM_Xmx} ${RDF4JRepoBaseDir}
        # archive log
        mv ../../geographica_Scalability.log ${ExperimentResultDir}/Scalability/LOGS/geographica_Scalability_${level}.log
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/Scalability/${level}
done