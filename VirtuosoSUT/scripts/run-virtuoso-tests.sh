#! /bin/bash

BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

username=dba
password=p1r3as
port=1111
host=localhost

if test ! -d ${results}; then
	echo "Result directory ${results} does not exist!"
	exit
fi

# Reset Virtuoso
./reset-virtuoso.sh |& tee -a restarting-virtuoso.log

VIRTUOSO_HOME="/home/benchmark/rdf-stores/Virtuoso/virtuoso-7-test/"

# --  Micro Selections # supported: 7, 8 --
results="/home/benchmark/Results/Virtuoso/virtuoso-selections"
e=MicroSelections
db=geographica-gr-points
cmd="sudo ${BASE}/runVirtuoso.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
    --virtuosoStart ${VIRTUOSO_HOME}/bin/virtuoso-start.sh \
    --virtuosoStop ${VIRTUOSO_HOME}/bin/virtuoso-stop.sh \
	-l ${results} \
	-q '7\ 8' \
    -r 1 -t 3600 \
	run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Micro Joins # supported 0 --
#results="/home/benchmark/Results/Virtuoso/virtuoso-joins"
#e="MicroJoins"
#db=geographica-gr-points
#cmd="sudo ./geographica.sh \
#    --database db --username ${username} --password ${password} --port ${port} --host ${host} \
#    --virtuosoStart ${VIRTUOSO_HOME}/bin/virtuoso-start.sh \
#    --virtuosoStop ${VIRTUOSO_HOME}/bin/virtuoso-stop.sh \
#	-l ${results} \
#	-q '0' \
#    -r 3 -t 3600 \
#	${sut} run ${e} &> ${results}/geographica-${e}.out"
#echo "`date`: Start: ${cmd}"
#eval "${cmd}"
#echo "`date`: End:  ${cmd}"

db=generator-512-points
# -- Synthetic Joins # supported 0 --
results="/home/benchmark/Results/Virtuoso/virtuoso-synthetic-joins"
e="SyntheticOnlyPoints"
cmd="sudo ./geographica.sh \
    --database db --username ${username} --password ${password} --port ${port} --host ${host} \
    --virtuosoStart ${VIRTUOSO_HOME}/bin/virtuoso-start.sh \
    --virtuosoStop ${VIRTUOSO_HOME}/bin/virtuoso-stop.sh \
	-l ${results} \
	-N 512 \
	-q '12\ 13\ 14\ 15' \
    -r 3 -t 3600 \
	${sut} run ${e} &> ${results}/geographica-${e}.out"
echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

