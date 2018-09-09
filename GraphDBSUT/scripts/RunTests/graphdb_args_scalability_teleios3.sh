#!/bin/bash

echo "-bd \"/home/journal/graphdb-free-8.5.0/data\" -rp scalability_${1} -cr false -r 3 -t 86400 -m 60 -l \"/home/journal/Results56/GraphDBSUT/Scalability/${1}\" run"
