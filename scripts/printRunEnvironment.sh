#!/bin/bash

# common for all SUTs
echo "GeographicaScriptsDir = $GeographicaScriptsDir"
echo "DatasetBaseDir = $DatasetBaseDir"
echo "ResultsBaseDir = $ResultsBaseDir"
# GraphDBSUT only
echo "GraphDBBaseDir = $GraphDBBaseDir"
echo "GraphDB_Data_Dir = ${GraphDB_Data_Dir}"
# RDF4JSUT only
echo "JVM_Xmx = $JVM_Xmx"
echo "RDF4JRepoBaseDir = $RDF4JRepoBaseDir"
# StrabonSUT only
echo "StrabonBaseDir = $StrabonBaseDir"
echo "StrabonLoaderBaseDir = $StrabonLoaderBaseDir"