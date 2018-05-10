# SYNTAX :
#    <script> RepoBaseDir DatasetBaseDir JVM_Xmx
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <RepoBaseDir> <JVM_Xmx>
\t<RepoBaseDir>\t:\tbase directory where repos are stored,
\t<JVM_Xmx>\t\t:\tJVM max memory e.g. -Xmx6g"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 2 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

RepoBaseDir=${1}
JVM_Xmx=${2}

echo -e "`date`\n"
# Real World dataset
./validateRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld ${JVM_Xmx}
# Synthetic dataset
./validateRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic ${JVM_Xmx}
# Real World dataset - Points only!
./validateRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld_Points ${JVM_Xmx}
# Synthetic dataset - Points Of Interest only!
./validateRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic_POIs ${JVM_Xmx}
