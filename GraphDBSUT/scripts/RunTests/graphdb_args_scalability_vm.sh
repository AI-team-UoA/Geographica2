#!/bin/bash

echo "-bd \"/media/sf_VM_Shared/PHD/GraphDB_Repos\" -rp scalability_${1} -cr false -r 3 -t 18000 -m 60 -l \"/media/sf_VM_Shared/PHD/Results_Store/DEVNULL/GraphDBSUT/Scalability/${1}\" run"
