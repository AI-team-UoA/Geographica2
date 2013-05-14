#! /bin/bash

dbFile=~benchmark/data-gr/toStore/geographica-ggarbis-onlyMunicipalities-dump.sql
logFile=/tmp/stdout

sudo service postgresql restart;
sudo su benchmark -c 'dropdb geographica-ggarbis-onlyMunicipalities';
sudo su benchmark -c 'createdb geographica-ggarbis-onlyMunicipalities';
sudo su benchmark -c "psql geographica-ggarbis-onlyMunicipalities -f ${dbFile}" |& tee ${logFile}

if test "`grep -i -e error ${logFile}`" = ""; then
	echo "PostgresSQL reseted: `date`"
else
	echo "Error! Check ${logFile}"
fi
