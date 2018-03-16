GraphDBBaseDir=~/graphdb-free-8.4.1
# Real World dataset
./createGraphDBRepo.sh contextenabled.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/RealWorldWorkload/RealWorldWorkloadGeographica2_WGS84 $GraphDBBaseDir
# Synthetic dataset
./createGraphDBRepo.sh contextdisabled.ttl ~/NetBeansProjects/PhD/Geographica_Misc/Datasets/SyntheticWorkloadGeographica2 $GraphDBBaseDir
