RepoBaseDir=${1}
DatasetBaseDir=${2}
ResultsFile="RepoCreation.log"

# Real World dataset
./createRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld >> $ResultsFile
# Synthetic dataset
./createRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic >> $ResultsFile
# Real World dataset - Points only!
./createRDF4JRepo.sh ${RepoBaseDir}/repoRealWorld_Points "spoc,posc,cosp" trig ${DatasetBaseDir}/RealWorldWorkload/WGS84/RealWorld_Points >> $ResultsFile
# Synthetic dataset - Points Of Interest only!
./createRDF4JRepo.sh ${RepoBaseDir}/repoSynthetic_POIs "" n-triples ${DatasetBaseDir}/SyntheticWorkload/Synthetic_POIs >> $ResultsFile