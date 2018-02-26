#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MicroNonTopological
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MicroSelections
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MicroJoins
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MicroAggregations
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MacroMapSearch
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MacroRapidMapping
#./runStrabon.sh -h localhost -db geographica2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -m 60 -l "/home/journal/Geographica_Results/Strabon-Results" run MacroReverseGeocoding
./runStrabon.sh -h localhost -db synthetic2 -p 5432 -u postgres -P postgres -r 3 -t 3600 -l "/home/journal/Geographica_Results/Strabon-Results" -N 512 run Synthetic
