#!/bin/bash
# find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS" ]; then
    echo "Will create ${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS"
    mkdir -p "${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS"
else
    echo "${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS already exists"
fi

# Synthetic_Pois experiment
experiment="Synthetic"
TESTSFILE=${BASE}/"testslist_synthetic_pois.txt"

echo ${experiment} > ${TESTSFILE}
echo "StrabonSUT will run the following test on Synthetic_Pois dataset"
cat ${TESTSFILE}
# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
echo "-h localhost -db synthetic_pois -p 5432 -u postgres -P postgres -q \"12 13 14 15 16 17 18 19 20 21 22 23\" -r 3 -t 3600 -l \"${ResultsBaseDir}/StrabonSUT/Synthetic_Pois\" -N 1024 run" | ./runTestsForStrabonSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx}

# archive log
mv ../../geographica*.log ${ResultsBaseDir}/StrabonSUT/Synthetic_Pois/LOGS
#remove test file
rm ${TESTSFILE}

# create report
${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/StrabonSUT/Synthetic_Pois