#! /bin/bash

cd /home/benchmark/rdf-stores/uSeekM/uSeekM-native-repositories

db=geographica-gr
logFile=/tmp/stdout

dropdb ${db}
rm -rf ${db}

tar xvzf ${db}.tar.gz

sudo service postgresql restart;
sudo su benchmark -c "dropdb ${db}";
sudo su benchmark -c "createdb ${db}";
sudo su benchmark -c "psql ${db} -f ${db}-dump.sql" |& tee ${logFile}

if test "`grep -i -e error ${logFile}`" = ""; then
	echo "uSeekM (${db}) reseted: `date`"
else
	echo "Error! Check ${logFile}"
fi
