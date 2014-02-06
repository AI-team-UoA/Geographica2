#! /bin/bash

logFile=/tmp/stdout

VIRTUOSO_HOME="/home/benchmark/rdf-stores/Virtuoso/virtuoso-7-test"
${VIRTUOSO_HOME}/bin/virtuoso-stop.sh
echo "`date`: Virtuoso stoped"; 

db="geographica-gr-points"
rm -rf ${VIRTUOSO_HOME}/${db}
echo "`date`: Directory ${db} deleted"; 
(cd ${VIRTUOSO_HOME}; tar xvzf ${db}.tar.gz)
echo "`date`: Directory ${db} recreated"; 

db="generator-512-POINT"
rm -rf ${VIRTUOSO_HOME}/${db}
echo "`date`: Directory ${db} deleted"; 
(cd ${VIRTUOSO_HOME}; tar xvzf ${db}.tar.gz)
echo "`date`: Directory ${db} recreated"; 

#${VIRTUOSO_HOME}/bin/virtuoso-start.sh geo
#echo "`date`: Virtuso started"; 


