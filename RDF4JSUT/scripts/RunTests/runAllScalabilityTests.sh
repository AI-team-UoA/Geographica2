#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/RDF4JSUT/Scalability/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/RDF4JSUT/Scalability/LOGS" ]; then
    mkdir -p "${ResultsBaseDir}/RDF4JSUT/Scalability/LOGS"
fi

levels=(  "10K" "100K" "1M" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        # clear system caches
        sudo /sbin/sysctl vm.drop_caches=3
        # creates/clears ${ResultsBaseDir}/RDF4JSUT/Scalability/${level}
        # returns all arguments except experiment and
        # executes experiment
        ./rdf4j_args_scalability.sh ${level} | ./runTestsForRDF4JSUT.sh /dev/stdin testslist_scalability.txt -Xmx24g ${RDF4JRepoBaseDir}
        # archive log
        mv ../../geographica_Scalability.log ${ResultsBaseDir}/RDF4JSUT/Scalability/LOGS/geographica_Scalability_${level}.log
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/RDF4JSUT/Scalability/${level}
done
