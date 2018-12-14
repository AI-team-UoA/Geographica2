#!/bin/bash
# SYNTAX :
#    <script> action repetitions
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME action repetitions disprows testsfile
\action\t:\taction = {run | print},
\repetitions\t:\trepetitions (1..3)
\disprows\t:\tdisplayed rows (0..n)
\usePredicates\t:\tuse geospatial predicates if possible
\testsfile\t:\tfile with list of tests to run"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments and assign them to variables
if (( $# != 5 )); then
    if (( $# == "0" )); then # assign default values
        Action="run"
        Repetitions=3
        DispRows=0
        UsePredicates=false
        TestsFile="${BASE}/testslist_scalability.txt"
    else
        echo -e "Illegal number of parameters $SYNTAX"
        exit 1
    fi
else
    Action=${1}
    Repetitions=${2}
    DispRows=${3}
    UsePredicates=${4}
    TestsFile=${5}
fi

#echo "Action = ${Action}"
#echo "Repetitions = ${Repetitions}"
#echo "DispRows = ${DispRows}"
#echo "Use Geospatial Predicates = ${UsePredicates}"
#echo "TestsFile = ${TestsFile}"

# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Scalability/LOGS exists and create it if necessary
LogsDir="${ExperimentResultDir}/Scalability/LOGS"
if [ ! -d "${LogsDir}" ]; then
    echo "Will create ${LogsDir}"
    mkdir -p "${LogsDir}" > /dev/null 2>&1
else
    echo "${LogsDir} already exists"
fi

# Check if the file $TestsFile does exist
if [ ! -e ${TestsFile} ]; then
    echo "The file \"${TestsFile}\" with the testlist does not exist!"
    echo "Scalability" > ${TestsFile}
    echo "GraphDBSUT will run the following tests on one or more Scalability dataset(s)"
    cat ${TestsFile}
fi

#levels=( "10K" )
levels=(  "10K" "100K" "1M" "10M" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        repo="scalability_${level}"
        resultsDir="${ExperimentResultDir}/Scalability/${level}"
        logFullPathName="${LogsDir}/geographica_Scalability_${level}.log"
        # clear system caches
        sudo /sbin/sysctl vm.drop_caches=3
        # creates/clears ${resultsDir} with no error message
        # returns all arguments except experiment and
        # executes experiment
        mkdir -p "${resultsDir}" > /dev/null 2>&1
        echo "-bd \"${GraphDBDataDir}\" -rp ${repo} -cr false -dr ${DispRows} -r ${Repetitions} -uPred ${UsePredicates} -t 86400 -m 60 -l \"${resultsDir}\" ${Action}" | ./runTestsForGraphDBSUT.sh /dev/stdin ${TestsFile} ${JVM_Xmx} ${GraphDBBaseDir}
        # archive log
        mv ../../geographica_Scalability.log ${logFullPathName}
        # create report
        ${GeographicaScriptsDir}/createreport.sh ${resultsDir}
done
