# SYNTAX :
#    <script> RepoBaseDir DatasetBaseDir JVM_Xmx
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <RepoBaseDir> <DatasetBaseDir> <JVM_Xmx>
\t<RepoBaseDir>\t:\tbase directory where repos are stored,
\t<DatasetBaseDir>\t:\tbase directory under which RDF dataset triple files are stored in various subdirectories,
\t<JVM_Xmx>\t\t:\tJVM max memory e.g. -Xmx6g"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 3 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

RepoBaseDir=${1}
DatasetBaseDir=${2}
JVM_Xmx=${3}
RemoveIfExists=true

echo -e "`date`\n"
# Real World dataset
./createRDF4JRepo.sh ${RepoBaseDir} repoRealWorld ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld $JVM_Xmx
# Synthetic dataset
./createRDF4JRepo.sh ${RepoBaseDir} repoSynthetic ${RemoveIfExists} "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic $JVM_Xmx
# Real World dataset - Points only!
./createRDF4JRepo.sh ${RepoBaseDir} repoRealWorld_Points ${RemoveIfExists} "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld_Points $JVM_Xmx
# Synthetic dataset - Points Of Interest only!
./createRDF4JRepo.sh ${RepoBaseDir} repoSynthetic_POIs ${RemoveIfExists} "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs $JVM_Xmx
