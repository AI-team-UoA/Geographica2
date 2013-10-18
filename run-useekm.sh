#! /bin/bash

sut=uSeekM
username=postgres
password=postgres
port=5432
host=localhost

# Reset uSeekM
(cd /home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/; ./reset-useekm.sh)

# Micro Selections # supported: 7, 8
results="/home/benchmark/Results/uSeekM/useekm-points"
db=geographica-gr-points-useekm
native=/home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/geographica-gr-points-useekm
e=MicroSelections
cmd="sudo ./geographica.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	-n ${native} \
	-l ${results} \
	-q '7\ 8' \
    -r 3 -t 3600 \
	${sut} run ${e} &> ${results}/geographica-${e}.out"
echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# Micro Joins # supported: 0
results="/home/benchmark/Results/uSeekM/useekm-points"
db=geographica-gr-points-useekm
native=/home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/geographica-gr-points-useekm
e=MicroJoins
cmd="sudo ./geographica.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	-n ${native} \
	-l ${results} \
	-q '0' \
    -r 3 -t 3600 \
	${sut} run ${e} &> ${results}/geographica-${e}.out"
echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"
