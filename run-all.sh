#! /bin/bash

sut=$1

case ${sut} in
	Strabon)
		experiments=
#		experiments="${experiments} MicroNonTopological"
#		experiments="${experiments} MicroSelections"
#		experiments="${experiments} MicroJoins"
#		experiments="${experiments} MicroAggregations"
#		experiments="${experiments} MacroFireMonitoring"
#		experiments="${experiments} MacroRapidMapping"
#		experiments="${experiments} MacroReverseGeocoding"
#		experiments="${experiments} MacroMapSearch"
		experiments="${experiments} Synthetic"
	;;
	Parliament)
		experiments=
#		experiments="${experiments} MicroNonTopological"
#		experiments="${experiments} MicroSelections"
#		experiments="${experiments} MicroJoins"
#		experiments="${experiments} MicroAggregations"
#		experiments="${experiments} MacroFireMonitoring"
#		experiments="${experiments} MacroRapidMapping"
#		experiments="${experiments} MacroReverseGeocoding"
#		experiments="${experiments} MacroMapSearch"
#		experiments="${experiments} Synthetic"
	;;
	Virtuoso)
		experiments=
#		experiments="${experiments} MicroNonTopological" # supported: none
		experiments="${experiments} MicroSelections"     # supported: 7, 8
		experiments="${experiments} MicroJoins"          # supported: 0
#		experiments="${experiments} MicroAggregations"   # supported: none
#		experiments="${experiments} MacroFireMonitoring"
#		experiments="${experiments} MacroRapidMapping"
#		experiments="${experiments} MacroReverseGeocoding"
#		experiments="${experiments} MacroMapSearch"
#		experiments="${experiments} Synthetic"			# suppoerted: ???
	;;
	uSeekM)
		experiments=
#		experiments="${experiments} MicroNonTopological"
		experiments="${experiments} MicroSelections"
		experiments="${experiments} MicroJoins"
#		experiments="${experiments} MicroAggregations"
#		experiments="${experiments} MacroFireMonitoring"
#		experiments="${experiments} MacroRapidMapping"
#		experiments="${experiments} MacroReverseGeocoding"
#		experiments="${experiments} MacroMapSearch"
#		experiments="${experiments} Synthetic"
	;;
	*)
		echo "Usage: run-all.sh (Strabon|Parliament|Virtuoso|USeekM)"
		exit -1
	;;
esac

#sudo ./hide-results.sh
for e in ${experiments}; do
	echo "`date`: Restarting ${sut}"
	case ${sut} in
		#Strabon)
		#	./reset-postgres.sh &>> restarting-strabon.log
		#;;
		uSeekM)
			(cd /home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/; ./reset-useekm.sh)
		;;
		Parliament)
			./reset-parliament.sh &>> restarting-parliament.log
			case ${e} in
				Synthetic)
					parliamentData=/home/benchmark/parliament/parliament-data/geographica-synthetic
				;;
				*)
					parliamentData=/home/benchmark/parliament/parliament-data/geographica
				;;
			esac
		;;
		Virtuoso)
			./reset-virtuoso.sh &> restarting-virtuoso.log
		;;
	esac

	results="/home/benchmark/Results/Virtuoso/test-1"

	# Virtuoso
	virtuosoPath=/home/benchmark/rdf-stores/virtuoso-7
    cmd="sudo ./geographica.sh \
        --database db --username dba --password dba --port 5000 --host localhost \
        --virtuosoStart ${virtuosoPath}/virtuoso-start.sh \
        --virtuosoStop ${virtuosoPath}//virtuoso-stop.sh \
		-l ${results} \
		-q '0'
        -r 3 -t 3600 \
		${sut} run ${e} &> ${results}/geographica-${e}.out"

	# uSeekM
	#useekmNative="/home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories/geographica-gr"
	#cmd="sudo ./geographica.sh -d geographica-gr -l ${results} -n ${useekmNative} -r 3 -t 3600 -q '0\ 1\ 2' ${sut} run ${e} &> ${results}/geographica-${e}.out"


	echo "`date`: Start: ${cmd}"
	eval "${cmd}"
	echo "`date`: End:  ${cmd}"

#	# Parliament
#	sudo ./geographica-parliament.sh ${parliamentData} -r 1 -t 3600 -N 512	${sut} run ${e} &> geographica-${e}.out
#	echo "`date`: End   ./geographica.sh ${sut} run ${e}"
#

done
