# SYNTAX :
#    <script> DatasetBaseDir RDF4JRepoBaseDir JVM_Xmx ReportDaemonIP ReportDaemonPort
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <DatasetBaseDir> <RDF4JRepoBaseDir> <JVM_Xmx> <ReportDaemonIP> <ReportDaemonPort>
\t<DatasetBaseDir>\t:\tbase directory under which RDF dataset triple files are stored in various subdirectories,
\t<RDF4JRepoBaseDir>\t:\tbase directory where RDF4J repos are stored,
\t<JVM_Xmx>\t\t:\tJVM max memory e.g. -Xmx6g,
\tReportDaemonIP\t:\treport daemon IP,
\tReportDaemonPort\t:\treport daemon port"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 5 )); then
    # in case no arguments are present there might be environment variables defined
    # globally ! Please check and then exit if necessary
    if [ -z ${DatasetBaseDir+x} ] || [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${JVM_Xmx+x} ] || [ -z ${CompletionReportDaemonIP+x} ] || [ -z ${CompletionReportDaemonPort+x} ]; then
        echo -e "Illegal number of parameters $SYNTAX"
	echo "As an alternative, some or all of the following environment variables {DatasetBaseDir, RDF4JRepoBaseDir, JVM_Xmx, ReportDaemonIP, ReportDaemonPort} is/are not set";
	return 1    # return instead of exit because we need to source the script
    fi
else
    echo -e "All parameters defined will override default values of Geographica prepareRunEnvironment.sh"
    export DatasetBaseDir=${1}
    export RDF4JRepoBaseDir=${2}
    export JVM_Xmx=${3}
    export CompletionReportDaemonIP=${4}
    export CompletionReportDaemonPort=${5}
fi

RemoveIfExists=true

echo -e "`date`\n"

HasLucene=false  # enable Lucene for all repositories of RDF4J to improve geospatial query evaluation
# Real World dataset
#WKTIdxList="http://www.opengis.net/ont/geosparql#asWKT http://geo.linkedopendata.gr/corine/ontology#asWKT http://dbpedia.org/property/asWKT http://geo.linkedopendata.gr/gag/ontology/asWKT http://www.geonames.org/ontology#asWKT http://teleios.di.uoa.gr/ontologies/noaOntology.owl#asWKT http://linkedgeodata.org/ontology/asWKT"
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} realworld ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/NO_CRS/RealWorld ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Synthetic dataset
#WKTIdxList="http://geographica.di.uoa.gr/generator/pointOfInterest/asWKT http://geographica.di.uoa.gr/generator/stateCenter/asWKT http://geographica.di.uoa.gr/generator/state/asWKT http://geographica.di.uoa.gr/generator/landOwnership/asWKT http://geographica.di.uoa.gr/generator/road/asWKT"
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} synthetic ${RemoveIfExists} "spoc,posc" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Real World dataset - Points only!
#WKTIdxList="http://www.opengis.net/ont/geosparql#asWKT http://dbpedia.org/property/asWKT http://www.geonames.org/ontology#asWKT"
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} realworld_points ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/NO_CRS/RealWorld_Points ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Synthetic dataset - Points Of Interest only!
#WKTIdxList="http://www.opengis.net/ont/geosparql#asWKT http://geographica.di.uoa.gr/generator/pointOfInterest/asWKT"
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} synthetic_pois ${RemoveIfExists} "spoc,posc" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
# Census dataset
#WKTIdxList="http://geographica.di.uoa.gr/cencus/ontology#asWKT"
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} census ${RemoveIfExists} "spoc,posc" n-triples ${DatasetBaseDir}/Census/NO_CRS ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}

#exit 0;

# OSM+CORINE2012 datasets - Scalability 10K, 100K, 1M, 10M, 100M, 500M
WKTIdxList="http://www.opengis.net/ont/geosparql#asWKT"
levels=(  "10K" )
#levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        ./createRDF4JRepo.sh ${RDF4JRepoBaseDir} scalability_${level} ${RemoveIfExists} "spoc,posc" n-triples ${DatasetBaseDir}/Scalability/${level} ${JVM_Xmx} ${HasLucene} "${WKTIdxList}" ${CompletionReportDaemonIP} ${CompletionReportDaemonPort}
done