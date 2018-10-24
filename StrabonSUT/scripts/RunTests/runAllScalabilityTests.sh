#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/StrabonSUT/Scalability/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/StrabonSUT/Scalability/LOGS" ]; then
    mkdir -p "${ResultsBaseDir}/StrabonSUT/Scalability/LOGS"
fi

#levels=(  "10K" "100K" "1M" "10M" )
levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        # clear system caches
        sudo /sbin/sysctl vm.drop_caches=3
        # creates/clears ${ResultsBaseDir}/StrabonSUT/Scalability/${level}
        # returns all arguments except experiment and
        # executes experiment
        ./strabon_args_scalability.sh ${level} | ./runTestsForStrabonSUT.sh /dev/stdin testslist_scalability.txt ${JVM_Xmx}
        # archive log
        mv ../../geographica_Scalability.log ${ResultsBaseDir}/StrabonSUT/Scalability/LOGS/geographica_Scalability_${level}.log
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/StrabonSUT/Scalability/${level}
done
