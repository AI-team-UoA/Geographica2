#! /bin/bash

sut=Parliament

# Reset 
./reset-parliament.sh &>> restarting-parliament.log

#mpstat -P ALL 2 &> /tmp/mpstat-ALL.out &
#iostat -m -c -d -t 2 &> /tmp/iostat.out &
#free -s 2 -m &> /tmp/free.out &


# -- Micro Selections points (queries 7, 8) --
results="/home/benchmark/Results/Parliament/parliament-rerun-select-gr-with-geoAsWKT"
e=MicroSelections
data=/home/benchmark/parliament/parliament-data/geographica-ggarbis-onlyMunicipalities-4326
cmd="sudo ./geographica-parliament.sh ${data} \
	-l ${results} \
    -r 1 -t 3600 \
	${sut} run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Micro Joins points (queries 7, 8) --
#results="/home/benchmark/Results/Parliament/parliament-point"
#e=MicroJoins
#data=/home/benchmark/parliament/parliament-data/geographica-gr-points-parliament
#cmd="sudo ./geographica-parliament.sh ${data} \
#	-l ${results} \
#    -r 1 -t 3600 \
#	-q '0' \
#	${sut} run ${e} &> ${results}/geographica-${e}.out"
#
#echo "`date`: Start: ${cmd}"
#eval "${cmd}"
#echo "`date`: End:  ${cmd}"

## -- Synthetic selections --
#results="/home/benchmark/Results/Parliament/parliament-synthetic-selections"
#e=Synthetic
#data="/home/benchmark/parliament/parliament-data/generator-512-POINT-parliament"
#cmd="sudo ./geographica-parliament.sh ${data} \
#	-l ${results} \
#    -r 3 -t 3600 \
#	-N 512 \
#	-q '12\ 13\ 14\ 15\ 16\ 17\ 18\ 19\ 20\ 21\ 22\ 23' \
#	${sut} run ${e} &> ${results}/geographica-${e}.out"
#
#echo "`date`: Start: ${cmd}"
#eval "${cmd}"
#echo "`date`: End:  ${cmd}"

