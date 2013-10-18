#! /bin/bash

sut=Strabon
username=postgres
password=postgres
port=5432
host=localhost

# Reset 

mpstat -P ALL 2 &> /tmp/mpstat-ALL.out &
iostat -m -c -d -t 2 &> /tmp/iostat.out &
free -s 2 -m &> /tmp/free.out &


# -- Micro Selections points (queries 7, 8) --
results="/home/benchmark/Results/Strabon/strabon-point"
e=MicroSelections
db=geographica-gr-strabon
cmd="sudo ./geographica.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	-l ${results} \
    -r 1 -t 3600 \
	-q '7\ 8' \
	${sut} run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Micro Joins points (queries 7, 8) --
results="/home/benchmark/Results/Strabon/strabon-point"
e=MicroJoins
db=geographica-gr-strabon
cmd="sudo ./geographica.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	-l ${results} \
    -r 1 -t 3600 \
	-q '0' \
	${sut} run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"

# -- Synthetic points --
results="/home/benchmark/Results/Strabon/strabon-point"
e=SyntheticOnlyPoints
db=generator-512-points-strabon
cmd="sudo ./geographica.sh \
    --database ${db} --username ${username} --password ${password} --port ${port} --host ${host} \
	-l ${results} \
    -r 1 -t 3600 \
	-N 512 \
	-q '12\ 13\ 14\ 15'
	${sut} run ${e} &> ${results}/geographica-${e}.out"

echo "`date`: Start: ${cmd}"
eval "${cmd}"
echo "`date`: End:  ${cmd}"
