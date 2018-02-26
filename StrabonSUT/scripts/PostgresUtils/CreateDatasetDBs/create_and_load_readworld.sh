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

# load N-Triple files in different contexts
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/gag.nt" -g http://geographica.di.uoa.gr/dataset/gag
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/corine.nt" -g http://geographica.di.uoa.gr/dataset/clc
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/linkedgeodata.nt" -g http://geographica.di.uoa.gr/dataset/lgd
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/geonames.nt" -g http://geographica.di.uoa.gr/dataset/geonames
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/dbpedia.nt" -g http://geographica.di.uoa.gr/dataset/dbpedia
java -Xmx4g -cp $CLASS_PATH  eu.earthobservatory.runtime.postgis.StoreOp localhost 5432 ${1} postgres postgres "${2}/hotspots.nt" -g http://geographica.di.uoa.gr/dataset/hotspots

# verify that each graph has the expected number of triples
java -Xmx4g -cp $CLASS_PATH eu.earthobservatory.runtime.postgis.QueryOp localhost 5432 ${1} postgres postgres "SELECT ?g (count(*) as ?count) WHERE { GRAPH ?g {?s ?p ?o .} } GROUP BY ?g" TRUE

# return to home directory
cd ~
