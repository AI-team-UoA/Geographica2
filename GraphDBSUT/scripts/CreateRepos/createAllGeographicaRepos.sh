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
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

DatasetBaseDir=${1}
GraphDBBaseDir=${2}

echo -e "`date`\n"

# Real World dataset
#./createGraphDBRepo.sh realworld.ttl ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld TRIG $GraphDBBaseDir
# Synthetic dataset
#./createGraphDBRepo.sh synthetic.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic N-TRIPLES $GraphDBBaseDir
# Real World dataset - Points only!
#./createGraphDBRepo.sh realworld_points.ttl ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld_Points N-TRIPLES $GraphDBBaseDir
# Synthetic dataset - Points Of Interest only!
#./createGraphDBRepo.sh synthetic_pois.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs N-TRIPLES $GraphDBBaseDir

# CORINE2012+OSM dataset - Scalability 10K
./createGraphDBRepo.sh scalability_10K.ttl ${DatasetBaseDir}/Scalability/10K N-TRIPLES $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 100K
./createGraphDBRepo.sh scalability_100K.ttl ${DatasetBaseDir}/Scalability/100K N-TRIPLES $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 1M
./createGraphDBRepo.sh scalability_1M.ttl ${DatasetBaseDir}/Scalability/1M N-TRIPLES $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 10M
./createGraphDBRepo.sh scalability_10M.ttl ${DatasetBaseDir}/Scalability/10M N-TRIPLES $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 100M
./createGraphDBRepo.sh scalability_100M.ttl ${DatasetBaseDir}/Scalability/100M N-TRIPLES $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 500M
./createGraphDBRepo.sh scalability_500M.ttl ${DatasetBaseDir}/Scalability/500M N-TRIPLES $GraphDBBaseDir
