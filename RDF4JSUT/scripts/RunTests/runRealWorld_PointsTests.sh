#!/bin/bash
SCRIPT_NAME=`basename "$0"`
# in case no arguments are present there might be environment variables defined
# globally ! Please check and then exit if necessary
if [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${ResultsBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
    echo "${SCRIPT_NAME}: One or all of the following environment variables {RDF4JRepoBaseDir, ResultsBaseDir, JVM_Xmx} is/are not set";
    return 1    # return instead of exit because we need to source the script
fi

# Check if ${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS exists and create it if necessary
if [ ! -d "${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS" ]; then
    echo "Will create ${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS"
    mkdir -p "${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS"
else
    echo "${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS already exists"
fi

# RealWorld_Points experiment comprises 2 queries from MicroSelections and
# one query from MicroJoins
experiments=( "MicroSelections" "MicroJoins" )
querylists=( "-q \"7 8\"" "-q \"0\"" )
TESTSFILE="testslist_realworld_points.txt"

# PART 1 : Execute Q14, Q15 (relative positions 7 and 8) of the MicroSelections experiment
# PART 2 : Execute Q18 (relative position 0) of the MicroJoins experiment
for index in "${!experiments[@]}"; do
    echo ${experiments[$index]} > ${TESTSFILE}
    echo "RDF4JSUT will run the following test on RealWorld_Points dataset"
    cat ${TESTSFILE}
    # clear system caches
    sudo /sbin/sysctl vm.drop_caches=3
    # returns all arguments except experiment and
    # executes experiment
    echo "-bd \"${RDF4JRepoBaseDir}\" -rp realworld_points -cr false -dr 0 ${querylists[$index]} -r 3 -t 3600 -m 60 -l \"${ResultsBaseDir}/RDF4JSUT/RealWorld_Points\" run" | ./runTestsForRDF4JSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${RDF4JRepoBaseDir}
    # archive log
    mv ../../geographica*.log ${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS
done


echo ${EXPERIMENT_MICROJOINS} > ${TESTSFILE}
echo "RDF4JSUT will run the following test on RealWorld_Points dataset"
cat ${TESTSFILE}
# clear system caches
sudo /sbin/sysctl vm.drop_caches=3
# returns all arguments except experiment and
# executes experiment
echo "-bd \"${RDF4JRepoBaseDir}\" -rp realworld_points -cr false -dr 0 ${MICROJOINS_QUERYLIST} -r 3 -t 3600 -m 60 -l \"${ResultsBaseDir}/RDF4JSUT/RealWorld_Points\" run" | ./runTestsForRDF4JSUT.sh /dev/stdin ${TESTSFILE} ${JVM_Xmx} ${RDF4JRepoBaseDir}
# archive log
mv ../../geographica*.log ${ResultsBaseDir}/RDF4JSUT/RealWorld_Points/LOGS

# create report
${GeographicaScriptsDir}/createreport.sh ${ResultsBaseDir}/RDF4JSUT/RealWorld_Points