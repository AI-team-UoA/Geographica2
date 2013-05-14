#!/bin/bash
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FILES=(
'/home/benchmark/virtuoso/vad/dbpedia/DBPedia-EL-geosparql-prefixes-nogDayMonth-after1400-uniq.nt'
'/home/benchmark/virtuoso/vad/clc/CLC-GR-geosparql-prefixes-valid.nt'
'/home/benchmark/virtuoso/vad/gag/GAG-geosparql-prefixes-onlyMunicipalities.nt'
'/home/benchmark/virtuoso/vad/geonames/Geonames-GR-fullgeosparql-prefixes.nt'
'/home/benchmark/virtuoso/vad/hotspots/Hotspots-2007-GeoSPARQL-prefixes.nt'
'/home/benchmark/virtuoso/vad/lgd/LGD-GR-geosparql-prefixes-uniq.nt'
)

cd generators/target
for file in ${FILES[*]} ;
do
	echo $file
	java -Xmx22000M \
	-cp $(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;) \
	gr.uoa.di.rdf.Geographica.generators.Dummy \
	${file} > ${file}.vituoso.nt
done
