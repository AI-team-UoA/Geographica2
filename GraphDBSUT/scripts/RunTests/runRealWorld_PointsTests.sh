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
        TestsFile="${BASE}/testslist_realworld_points.txt"
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
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/RealWorld_Points/LOGS exists and create it if necessary
LogsDir="${ExperimentResultDir}/RealWorld_Points/LOGS"
if [ ! -d "${LogsDir}" ]; then
    echo "Will create ${LogsDir}"
    mkdir -p "${LogsDir}"
else
    echo "${LogsDir} already exists"
fi

# Check if the file $TestsFile does exist
if [ ! -e ${TestsFile} ]; then
    echo "The file \"${TestsFile}\" with the testlist does not exist!"
    return 2;
else
    echo "GraphDBSUT will run the following tests on RealWorld_Points dataset"
    cat ${TestsFile}
fi

# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# IMPORTANT!!! - RealWorld_Points scenario concerns <realworld_points> repo
#              with queries Q7, Q8 from MicroSelections and Q0 from MicroJoins
# executes experiment MicroSelections
echo "MicroSelections" > ${TestsFile}
QueryList="\"7,8\""
echo "-bd \"${GraphDBDataDir}\" -rp realworld_points -cr false -dr ${DispRows} -q ${QueryList} -r ${Repetitions} -t 3600 -m 60 -l \"${ExperimentResultDir}/RealWorld_Points\" ${Action}" | ./runTestsForGraphDBSUT.sh /dev/stdin ${TestsFile} ${JVM_Xmx} ${GraphDBBaseDir}
# archive log
mv ../../geographica*.log ${LogsDir}
# executes experiment MicroJoins
echo "MicroJoins" > ${TestsFile}
QueryList="\"0\""
echo "-bd \"${GraphDBDataDir}\" -rp realworld_points -cr false -dr ${DispRows} -q ${QueryList} -r ${Repetitions} -t 3600 -m 60 -l \"${ExperimentResultDir}/RealWorld_Points\" ${Action}" | ./runTestsForGraphDBSUT.sh /dev/stdin ${TestsFile} ${JVM_Xmx} ${GraphDBBaseDir}
# archive log
mv ../../geographica*.log ${LogsDir}
# create report
${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/RealWorld_Points