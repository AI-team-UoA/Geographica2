#!/bin/bash
# find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS" ]; then
    echo "Will create ${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS"
    mkdir -p "${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS"
else
    echo "${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS already exists"
fi

# Synthetic_Pois experiment
experiment="SyntheticPOIs"
TESTSFILE=${BASE}/"testslist_synthetic_pois.txt"

echo ${experiment} > ${TESTSFILE}
echo "GraphDBSUT will run the following test on Synthetic_Pois dataset"
cat ${TESTSFILE}
# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
echo "-bd \"${GraphDBBaseDir}\" -rp synthetic_pois -cr false -r 3 -t 3600 -l \"${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois\" -N 1024 print" | ./runTestsForGraphDBSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${GraphDBBaseDir}
# archive log
mv ../../geographica*.log ${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois/LOGS
#remove test file
rm ${TESTSFILE}

# create report
${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/GraphDBSUT/Synthetic_Pois