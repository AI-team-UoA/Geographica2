# SYNTAX :
#    <script> <RDF4JRepoBaseDir> <JVM_Xmx>
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <RDF4JRepoBaseDir> <JVM_Xmx>
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
        export RDF4JRepoBaseDir=${1}
        export JVM_Xmx=${2}
fi

echo -e "`date`\n"

# Real World dataset
#./validateRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld ${JVM_Xmx}
# Synthetic dataset
#./validateRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic ${JVM_Xmx}
# Real World dataset - Points only!
#./validateRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld_Points ${JVM_Xmx}
# Synthetic dataset - Points Of Interest only!
#./validateRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic_POIs ${JVM_Xmx}

# OSM+CORINE2012 datasets - Scalability 10K, 100K, 1M, 10M, 100M, 500M
levels=(  "10K" "100K" "1M" "10M" "100M" "500M" )
for level in "${levels[@]}"; do
    ./validateRDF4JRepo.sh ${RDF4JRepoBaseDir}/repositories/scalability_${level} ${JVM_Xmx}
done