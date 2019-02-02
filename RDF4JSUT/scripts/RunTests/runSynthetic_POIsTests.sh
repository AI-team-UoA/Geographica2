#!/bin/bash
# SYNTAX :
#    <script> action repetitions
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME action repetitions disprows testsfile
\action\t:\taction = {run | print},
\repetitions\t:\trepetitions (1..3)
\disprows\t:\tdisplayed rows (0..n)
\testsfile\t:\tfile with list of tests to run"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments and assign them to variables
if (( $# != 4 )); then
    if (( $# == "0" )); then # assign default values
        Action="run"
        Repetitions=3
        DispRows=0
        TestsFile="${BASE}/testslist_synthetic_pois.txt"
    else
        echo -e "Illegal number of parameters $SYNTAX"
        exit 1
    fi
else
    Action=$1
    Repetitions=$2
    DispRows=$3
    TestsFile=${4}
fi

#echo "Action = ${Action}"
#echo "Repetitions = ${Repetitions}"
#echo "DispRows = ${DispRows}"
#echo "TestsFile = ${TestsFile}"

# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Synthetic_Pois/LOGS exists and create it if necessary
LogsDir="${ExperimentResultDir}/Synthetic_Pois/LOGS"
if [ ! -d "${LogsDir}" ]; then
    echo "Will create ${LogsDir}"
    mkdir -p "${LogsDir}" > /dev/null 2>&1
else
    echo "${LogsDir} already exists"
fi

# Check if the file $TestsFile does exist
if [ ! -e ${TestsFile} ]; then
    echo "The file \"${TestsFile}\" with the testlist does not exist!"
    echo "Synthetic" > ${TestsFile}
    echo "RDF4JSUT will run the following tests on Synthetic_Pois dataset"
    cat ${TestsFile}
fi

# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
echo "-bd \"${RDF4JRepoBaseDir}\" -rp synthetic_pois -q \"12 13 14 15 16 17 18 19 20 21 22 23\" -cr false -dr ${DispRows} -r ${Repetitions} -t 3600 -l \"${ExperimentResultDir}/Synthetic_Pois\" -N 1024 ${Action}" | ./runTestsForRDF4JSUT.sh /dev/stdin ${TestsFile} ${JVM_Xmx}
# archive log
mv ../../geographica*.log ${LogsDir}
# create report
${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/Synthetic_Pois