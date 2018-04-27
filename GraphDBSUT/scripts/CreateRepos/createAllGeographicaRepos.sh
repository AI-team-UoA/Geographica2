GraphDBBaseDir=${1}
# Real World dataset
./createGraphDBRepo.sh realworld.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/RealWorldWorkload/WGS84/RealWorld $GraphDBBaseDir
# Synthetic dataset
./createGraphDBRepo.sh synthetic.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/SyntheticWorkload/Synthetic $GraphDBBaseDir
# Real World dataset - Points only!
./createGraphDBRepo.sh realworld_points.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/RealWorldWorkload/WGS84/RealWorld_Points $GraphDBBaseDir
# Synthetic dataset - Points Of Interest only!
./createGraphDBRepo.sh synthetic_pois.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/SyntheticWorkload/Synthetic_POIs $GraphDBBaseDir
