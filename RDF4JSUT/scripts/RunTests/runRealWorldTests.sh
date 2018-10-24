#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS" ]; then
    echo "Will create ${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS"
    mkdir -p "${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS"
else
    echo "${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS already exists"
fi

# Check if there is a parameter. If there is it should contain a sublist of
# the test list for the RealWorld dataset
if (( $# != 1 )); then
    # in case no arguments are present then assign the default file with tests
    TESTSFILE="testslist_realworld.txt"
else # else use the file in argument 1
    TESTSFILE=${1}
fi

# Check if the file $TESTSFILE does exist
if [ ! -e ${TESTSFILE} ]; then
    echo "The file \"${TESTSFILE}\" with the testlist does not exist!"
    return 2;
else
    echo "RDF4JSUT will run the following tests on RealWorld dataset"
    cat ${TESTSFILE}
fi

# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
./rdf4j_args_realworld.sh | ./runTestsForRDF4JSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${RDF4JRepoBaseDir}
# archive log
mv ../../geographica*.log ${ResultsBaseDir}/RDF4JSUT/RealWorld/LOGS
# create report
${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/RDF4JSUT/RealWorld