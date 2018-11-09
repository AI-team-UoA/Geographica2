#!/bin/bash
# SYNTAX :
#    <script> action repetitions
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME action repetitions disprows
\action\t:\taction = {run | print},
\repetitions\t:\trepetitions (1..3)
\disprows\t:\tdisplayed rows (0..n)"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments and assign them to variables
if (( $# != 3 )); then
    if (( $# == "0" )); then # assign default values
        Action="run"
        Repetitions=3
        DispRows=0
    else
        echo -e "Illegal number of parameters $SYNTAX"
        exit 1
    fi
else
    Action=$1
    Repetitions=$2
    DispRows=$3
fi

#echo "Action = ${Action}"
#echo "Repetitions = ${Repetitions}"
#echo "DispRows = ${DispRows}"

# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${GraphDBBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {GraphDBBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Census/LOGS exists and create it if necessary
if [ ! -d "${ExperimentResultDir}/Census/LOGS" ]; then
    echo "Will create ${ExperimentResultDir}/Census/LOGS"
    mkdir -p "${ExperimentResultDir}/Census/LOGS"
else
    echo "${ExperimentResultDir}/Census/LOGS already exists"
fi

# Census experiment
experiment="MacroGeocoding"
TESTSFILE=${BASE}/"testslist_census.txt"

echo ${experiment} > ${TESTSFILE}
echo "GraphDBSUT will run the following test on Census dataset"
cat ${TESTSFILE}
# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
echo "-bd \"${GraphDBDataDir}\" -rp census -cr false -dr ${DispRows} -r ${Repetitions} -t 3600 -l \"${ExperimentResultDir}/Census\" -N 1024 ${Action}" | ./runTestsForGraphDBSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${GraphDBBaseDir}
# archive log
mv ../../geographica*.log ${ExperimentResultDir}/Census/LOGS
#remove test file
rm ${TESTSFILE}

# create report
${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/Census