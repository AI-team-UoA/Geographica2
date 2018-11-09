#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ExperimentResultDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ExperimentResultDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ExperimentResultDir}/Synthetic/LOGS exists and create it if necessary
if [ ! -d "${ExperimentResultDir}/Synthetic/LOGS" ]; then
    echo "Will create ${ExperimentResultDir}/Synthetic/LOGS"
    mkdir -p "${ExperimentResultDir}/Synthetic/LOGS"
else
    echo "${ExperimentResultDir}/Synthetic/LOGS already exists"
fi

# Check if there is a parameter. If there is it should contain a sublist of
# the test list for the Synthetic dataset
if (( $# != 1 )); then
    # in case no arguments are present then assign the default file with tests
    TESTSFILE="testslist_synthetic.txt"
else # else use the file in argument 1
    TESTSFILE=${1}
fi

# Check if the file $TESTSFILE does exist
if [ ! -e ${TESTSFILE} ]; then
    echo "The file \"${TESTSFILE}\" with the testlist does not exist!"
    return 2;
else
    echo "RDF4JSUT will run the following tests on Synthetic dataset"
    cat ${TESTSFILE}
fi

# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
./rdf4j_args_synthetic.sh | ./runTestsForRDF4JSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${RDF4JRepoBaseDir}
# archive log
mv ../../geographica*.log ${ExperimentResultDir}/Synthetic/LOGS
# create report
${GeographicaScriptsDir}/createreport.sh ${ExperimentResultDir}/Synthetic