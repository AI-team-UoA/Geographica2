# SYNTAX :
#    <script> DatasetBaseDir RDF4JRepoBaseDir JVM_Xmx
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <DatasetBaseDir> <RDF4JRepoBaseDir> <JVM_Xmx>
\t<DatasetBaseDir>\t:\tbase directory under which RDF dataset triple files are stored in various subdirectories,
\t<RDF4JRepoBaseDir>\t:\tbase directory where RDF4J repos are stored,
\t<JVM_Xmx>\t\t:\tJVM max memory e.g. -Xmx6g"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 3 )); then
    # in case no arguments are present there might be environment variables defined
    # globally ! Please check and then exit if necessary
    if [ -z ${DatasetBaseDir+x} ] || [ -z ${RDF4JRepoBaseDir+x} ] || [ -z ${JVM_Xmx+x} ]; then
        echo -e "Illegal number of parameters $SYNTAX"
	echo "As an alternative, some or all of the following environment variables {DatasetBaseDir, RDF4JRepoBaseDir, JVM_Xmx} is/are not set";
	return 1    # return instead of exit because we need to source the script
    fi
else
        export DatasetBaseDir=${1}
        export RDF4JRepoBaseDir=${2}
        export JVM_Xmx=${3}
fi

RemoveIfExists=true

echo -e "`date`\n"

# Real World dataset
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} repoRealWorld ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld $JVM_Xmx
# Synthetic dataset
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} repoSynthetic ${RemoveIfExists} "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic $JVM_Xmx
# Real World dataset - Points only!
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} repoRealWorld_Points ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld_Points $JVM_Xmx
# Synthetic dataset - Points Of Interest only!
#./createRDF4JRepo.sh ${RDF4JRepoBaseDir} repoSynthetic_POIs ${RemoveIfExists} "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs $JVM_Xmx

# OSM+CORINE2012 datasets - Scalability 10K, 100K, 1M, 10M, 100M, 500M
levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
        ./createRDF4JRepo.sh ${RDF4JRepoBaseDir} scalability_${level} ${RemoveIfExists} "" n-triples ${DatasetBaseDir}/Scalability/${level} $JVM_Xmx
done