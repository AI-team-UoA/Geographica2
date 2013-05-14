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
	USeekM)
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

sudo ./hide-results.sh
for e in ${experiments}; do
	echo "`date`: Restarting ${sut}"
	case ${sut} in
		#Strabon)
		#	./reset-postgres.sh &>> restarting-strabon.log
		#;;
		Parliament)
			./reset-parliament.sh &>> restarting-parliament.log
		;;
		Virtuoso)
			./reset-virtuoso.sh &> restarting-virtuoso.log
		;;
	esac
	echo "`date`: ${sut} restarted"
	echo "`date`: Start ./geographica.sh ${sut} run ${e}"
	sudo ./geographica.sh ${sut} run ${e} \
		--database real --username dba --password dba --port 5000 --host localhost \
		--virtuosoStart "/home/benchmark/virtuoso/bin/virtuoso-start.sh" \
		--virtuosoStop "/home/benchmark/virtuoso/bin/virtuoso-stop.sh" \
		--repetitions 3 --timeout 3600 &> geographica-${e}.out
	echo "`date`: End   ./geographica.sh ${sut} run ${e}"
done
