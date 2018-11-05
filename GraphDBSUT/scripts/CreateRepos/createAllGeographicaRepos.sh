# SYNTAX :
#    <script> RepoBaseDir DatasetBaseDir
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <DatasetBaseDir> <GraphDBBaseDir>
\t<DatasetBaseDir>\t:\tbase directory under which RDF dataset triple files are stored in various subdirectories,
\t<GraphDBBaseDir>\t:\tGraphDB base installation directory"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 2 )); then
    # in case no arguments are present there might be environment variables defined
    # globally ! Please check and then exit if necessary
    if [ -z ${DatasetBaseDir+x} ] || [ -z ${GraphDBBaseDir+x} ]; then
        echo -e "Illegal number of parameters $SYNTAX"
	echo "As an alternative, some or all of the following environment variables {DatasetBaseDir, GraphDBBaseDir} is/are not set";
	return 1    # return instead of exit because we need to source the script
    fi
else
        export DatasetBaseDir=${1}
        export GraphDBBaseDir=${2}
fi

echo -e "`date`\n"

# Real World dataset
#./createGraphDBRepo.sh realworld.ttl ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld TRIG $GraphDBBaseDir
# Synthetic dataset
#./createGraphDBRepo.sh synthetic.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic N-TRIPLES $GraphDBBaseDir
# Real World dataset - Points only!
#./createGraphDBRepo.sh realworld_points.ttl ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld_Points N-TRIPLES $GraphDBBaseDir
# Synthetic dataset - Points Of Interest only!
./createGraphDBRepo.sh synthetic_pois.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs N-TRIPLES $GraphDBBaseDir

exit 0;
# OSM+CORINE2012 datasets - Scalability 10K, 100K, 1M, 10M, 100M, 500M
levels=(  "10K" "100K" "1M" "10M" "100M" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        ./createGraphDBRepo.sh scalability_${level}.ttl ${DatasetBaseDir}/Scalability/${level} N-TRIPLES $GraphDBBaseDir
done
