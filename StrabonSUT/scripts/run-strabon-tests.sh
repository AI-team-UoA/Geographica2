#! /bin/bash

BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

username=postgres
password=postgres
port=5432
host=localhost

# # Reset 
# dbFile=~benchmark/data-gr/toStore/geographica-ggarbis-onlyMunicipalities-dump.sql
# logFile=/tmp/stdout
# 
# sudo service postgresql restart;
# sudo su benchmark -c 'dropdb geographica-ggarbis-onlyMunicipalities';
# sudo su benchmark -c 'createdb geographica-ggarbis-onlyMunicipalities';
# sudo su benchmark -c "psql geographica-ggarbis-onlyMunicipalities -f ${dbFile}" |& tee ${logFile}
# 
# if test "`grep -i -e error ${logFile}`" = ""; then
#     echo "PostgresSQL reseted: `date`"
# else
#     echo "Error! Check ${logFile}"
# fi
# # Reset stop

#mpstat -P ALL 2 &> /tmp/mpstat-ALL.out &
#iostat -m -c -d -t 2 &> /tmp/iostat.out &
#free -s 2 -m &> /tmp/free.out &

# -- Macro Geocoding --
results="/home/benchmark/Results/Strabon/geocoding"
e=MacroGeocoding
db=geocoding
cmd="sudo ${BASE}/runStrabon.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	--logpath ${results} \
	--runtime 120 \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Macro Compute Statistics --
results="/home/benchmark/Results/Strabon/compute-statistics-2"
e=MacroComputeStatistics
db=geographica-ggarbis-onlyMunicipalities
cmd="sudo ${BASE}/runStrabon.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	--logpath ${results} \
	--runtime 120 \
    --queries '0\ 1\ 3' \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"
