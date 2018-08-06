GraphDBBaseDir=${1}
# Real World dataset
./createGraphDBRepo.sh realworld.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/RealWorldWorkload/WGS84/RealWorld $GraphDBBaseDir
# Synthetic dataset
./createGraphDBRepo.sh synthetic.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/SyntheticWorkload/Synthetic $GraphDBBaseDir
# Real World dataset - Points only!
./createGraphDBRepo.sh realworld_points.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/RealWorldWorkload/WGS84/RealWorld_Points $GraphDBBaseDir
# Synthetic dataset - Points Of Interest only!
./createGraphDBRepo.sh synthetic_pois.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/SyntheticWorkload/Synthetic_POIs $GraphDBBaseDir

# CORINE2012+OSM dataset - Scalability 10K
./createGraphDBRepo.sh scalability_10K.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/10K $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 100K
./createGraphDBRepo.sh scalability_100K.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/100K $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 1M
./createGraphDBRepo.sh scalability_1M.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/1M $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 10M
./createGraphDBRepo.sh scalability_10M.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/10M $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 100M
./createGraphDBRepo.sh scalability_100M.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/100M $GraphDBBaseDir
# CORINE2012+OSM dataset - Scalability 500M
./createGraphDBRepo.sh scalability_500M.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/Scalability/500M $GraphDBBaseDir
