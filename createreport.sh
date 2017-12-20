#!/bin/bash
# run with no arguments from within the directory which contains the results for all experiments

cd ${1}

# iterate over each experiment folder
for dir in `ls -1d *Experiment`; do

	# change to the target directory
	cd ${dir}
	
	# set output file name
	REPORT_FILE="../${dir}.csv"

    # delete file if it exists
	if [ -f $REPORT_FILE ]; then
		rm $REPORT_FILE
	fi

	# get experiment name
	EXPERIMENT_NAME=`echo ${dir} | cut -d '-' -f 2`
	EXPERIMENT_NAME=`echo $EXPERIMENT_NAME | sed 's/Experiment//' -`

	if [[ "$EXPERIMENT_NAME" =~ ^(MicroNonTopological|MicroSelections|MicroJoins|MicroAggregations|Synthetic)$ ]]; then
		for file in `ls -1 *long`; do 		
			QUERY_NO=`echo $file | cut -d '-' -f 1`
			QUERY_NAME=`echo $file | cut -d '-' -f 2`
			QUERY_TYPE=`echo $file | cut -d '-' -f 3`
			QUERY_RESULTS=`cut -d ' ' -f 1,2,3,4 $file`
			# display contents
			echo -e "$QUERY_NO $QUERY_NAME $QUERY_TYPE $QUERY_RESULTS" >> $REPORT_FILE
		done

	elif [[ "$EXPERIMENT_NAME" =~ ^(MacroMapSearch)$ ]]; then
		files=( "Get_Around_POIs" "Get_Around_Roads" "Thematic_Search" )
		for file in "${files[@]}"; do 		
			REPORT_FILE="../${dir}_${file}.csv"
			awk '{ print $4 " " $1 " " $2 " " $3}' $file >> $REPORT_FILE
		done
	elif [[ "$EXPERIMENT_NAME" =~ ^(MacroRapidMapping)$ ]]; then
		files=( "Get_CLC_areas" "Get_coniferous_forests_in_fire" "Get_highways" "Get_hotspots" "Get_municipalities" "Get_road_segments_affected_by_fire")
		for file in "${files[@]}"; do 		
			REPORT_FILE="../${dir}_${file}.csv"
			awk '{ print $4 " " $1 " " $2 " " $3}' $file >> $REPORT_FILE
		done
	elif [[ "$EXPERIMENT_NAME" =~ ^(MacroReverseGeocoding)$ ]]; then
		files=( "Find_Closest_Motorway" "Find_Closest_Populated_Place" )
		for file in "${files[@]}"; do 		
			REPORT_FILE="../${dir}_${file}.csv"
			awk '{ print $4 " " $1 " " $2 " " $3}' $file >> $REPORT_FILE
		done	
	else
		echo "Malakies"
	fi

# change to parent directory
cd ..

done
	

