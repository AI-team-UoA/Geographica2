#!/bin/bash

# User needs to check:
#   - system command that clears caches
#   - use ./graphdb_args_scalability_teleios3.sh or ./graphdb_args_scalability_vm.sh or edit them appropriately
#   - define the GraphDB base folder
#   - define the location of running script compared to the location of the geographica_Scalability.log
#   - define the location of the result LOGS folder
levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        sudo /sbin/sysctl vm.drop_caches=3
        ./graphdb_args_scalability_teleios3.sh ${level} | ./runTestsForGraphDBSUT.sh /dev/stdin testslist_scalability.txt -Xmx24g ~/graphdb-free-8.5.0
        mv ../../geographica_Scalability.log ~/Results54/GraphDBSUT/Scalability/LOGS/geographica_Scalability_${level}.log
done
