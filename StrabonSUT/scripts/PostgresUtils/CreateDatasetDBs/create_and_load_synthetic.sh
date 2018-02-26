# SYNTAX: <scriptname> <arg1: database name> <arg2: dirpath with N-Triple files to load> <arg3: Strabon root path>
# Precondition 1 : there must exist ~/Strabon
# Precondition 2 : Postgres should be installed and its binaries exist in the PATH

# recreate database <arg1> and optimize
sudo -u postgres `which dropdb` ${1}
sudo -u postgres `which createdb` ${1} -T template_postgis
sudo -u postgres `which psql` -c 'VACUUM ANALYZE;' ${1}

# create the class path for java
cd ${3}/runtime/target
export CLASS_PATH="$(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)"

# load N-Triple files in default graph
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/POINT.nt"
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/LINESTRING.nt"
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/HEXAGON_SMALL.nt"
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/HEXAGON_LARGE.nt"
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/HEXAGON_LARGE_CENTER.nt"

# verify that default graph has the expected number of triples
java -Xmx4g -cp $CLASS_PATH eu.earthobservatory.runtime.postgis.QueryOp localhost 5432 ${1} postgres postgres "SELECT (count(*) as ?count) WHERE { ?s ?p ?o .}" TRUE

# return to home directory
cd ~
