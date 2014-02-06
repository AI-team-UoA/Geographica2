#! /bin/bash

BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Reset 
(
if test "`hostname`" = "teleios2"; then
	cd /home/benchmark/parliament/parliament-data
else # teleios3 and pathway
	cd /home/benchmark/rdf-stores/Parliament/parliament/parliament-data
fi
./reset-kb.sh
echo "KB reseted: `date`" &>> restarting-parliament.log)

#mpstat -P ALL 2 &> /tmp/mpstat-ALL.out &
#iostat -m -c -d -t 2 &> /tmp/iostat.out &
#free -s 2 -m &> /tmp/free.out &

parliament_data=
if test "`hostname`" = "teleios2"; then
	parliament_data=/home/benchmark/parliament/parliament-data
else # teleios3 and pathway
	parliament_data=/home/benchmark/rdf-stores/Parliament/parliament/parliament-data
fi

# runtime is in minutes
# 	120 mins = 2 hours
# 	1200 mins = 20 hours
# timeout is in seconds
#	3600 secs = 1 hour

# -- Macro Geocoding --
results="/home/benchmark/Results/Parliament/geocoding"
e=MacroGeocoding
data=${parliament_data}/geocoding
cmd="sudo ${BASE}/runParliament.sh ${data} \
	--logpath ${results} \
	--runtime 120 \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Macro Compute Statistics --
results="/home/benchmark/Results/Parliament/compute-statistics-short"
e=MacroComputeStatistics
data=${parliament_data}/geographica
cmd="sudo ${BASE}/runParliament.sh ${data} \
	--logpath ${results} \
	--runtime 120 \
    --queries '0\ 1\ 3' \
	--timeout 3600 \
	run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"
