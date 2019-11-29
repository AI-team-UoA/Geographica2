# SYNTAX :
#    <script> DatasetBaseDir GraphDBBaseDir EnableGeoSPARQLPlugin IndexingAlgorithm IndexingPrecision ReportDaemonIP ReportDaemonPort
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <DatasetBaseDir> <GraphDBBaseDir> <EnableGeoSPARQLPlugin> <IndexingAlgorithm> <IndexingPrecision> <ReportDaemonIP> <ReportDaemonPort>
\t<DatasetBaseDir>\t:\tbase directory under which RDF dataset triple files are stored in various subdirectories,
\t<GraphDBBaseDir>\t:\tGraphDB base installation directory,
\tEnableGeoSPARQLPlugin\t:\ttrue|false,
\tIndexingAlgorithm\t:\tquad|geohash,
\tIndexingPrecision\t:\tquad=(1..25), geohash=(1..24),
\tReportDaemonIP\t:\treport daemon IP,
\tReportDaemonPort\t:\treport daemon port"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 7 )); then
    # in case no arguments are present there might be environment variables defined
    # globally ! Please check and then exit if necessary
    if [ -z ${DatasetBaseDir+x} ] || [ -z ${GraphDBBaseDir+x} ] || [ -z ${EnableGeoSPARQLPlugin+x} ] || [ -z ${IndexingAlgorithm+x} ] || [ -z ${IndexingPrecision+x} ] || [ -z ${CompletionReportDaemonIP+x} ] || [ -z ${CompletionReportDaemonPort+x} ] ; then
        echo -e "Illegal number of parameters $SYNTAX"
	echo "some or all of the following environment variables {DatasetBaseDir, GraphDBBaseDir, EnableGeoSPARQLPlugin, IndexingAlgorithm, IndexingPrecision} is/are not set";
	return 1    # return instead of exit because we need to source the script
    fi
else
    echo -e "All parameters defined will override default values of Geographica prepareRunEnvironment.sh"
    export DatasetBaseDir=${1}
    export GraphDBBaseDir=${2}
    export EnableGeoSPARQLPlugin=${3}
    export IndexingAlgorithm=${4}
    export IndexingPrecision=${5}
    export ReportDaemonIP=${6}
    export ReportDaemonPort=${7}
fi

echo -e "`date`\n"

# Real World dataset
#./createGraphDBRepo.sh realworld.ttl ${DatasetBaseDir}/RealWorldWorkload/NO_CRS/RealWorld TRIG ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Synthetic dataset
#./createGraphDBRepo.sh synthetic.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic N-TRIPLES ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Real World dataset - Points only!
#./createGraphDBRepo.sh realworld_points.ttl ${DatasetBaseDir}/RealWorldWorkload/NO_CRS/RealWorld_Points TRIG ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Synthetic dataset - Points Of Interest only!
#./createGraphDBRepo.sh synthetic_pois.ttl ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs N-TRIPLES ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Census dataset
#./createGraphDBRepo.sh census.ttl ${DatasetBaseDir}/Census/NO_CRS N-TRIPLES ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}


# exit 0;

# OSM+CORINE2012 datasets - Scalability 10K, 100K, 1M, 10M, 100M, 500M
levels=( "10K" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        ./createGraphDBRepo.sh scalability_${level}.ttl ${DatasetBaseDir}/Scalability/${level} N-TRIPLES ${GraphDBBaseDir} ${EnableGeoSPARQLPlugin} ${IndexingAlgorithm} ${IndexingPrecision} ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
done
