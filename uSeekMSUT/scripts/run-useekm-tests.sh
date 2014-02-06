#! /bin/bash

BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

username=postgres
password=postgres
port=5432
host=localhost

# Reset uSeekM
(cd /home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/; ./reset-useekm.sh)

# runtime is in minutes
# 	120 mins = 2 hours
# 	1200 mins = 20 hours
# timeout is in seconds
#	3600 secs = 1 hour

# Macro Compute Statistics
results="/home/benchmark/Results/uSeekM/compute-statistics-2"
db=geographica-gr
native=/home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/${db}
e=MacroComputeStatistics
cmd="sudo ${BASE}/runUSeekM.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	--native ${native} \
	--logpath ${results} \
	--runtime 120 \
	--queries '0\ 1\ 3' \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"
echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# Macro Compute Statistics
results="/home/benchmark/Results/uSeekM/geocoding"
db=geocoding-useekm
native=/home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/${db}
e=MacroGeocoding
cmd="sudo ${BASE}/runUSeekM.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	--native ${native} \
	--logpath ${results} \
	--runtime 120 \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"
echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"
