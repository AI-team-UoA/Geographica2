#!/bin/bash

# common for all SUTs
echo "All SUTs"
echo "--------"
echo "GeographicaScriptsDir = $GeographicaScriptsDir"
echo "DatasetBaseDir = $DatasetBaseDir"
echo "ResultsBaseDir = $ResultsBaseDir"
echo "ResultsDirName = $ResultsDirName"
echo "ActiveSUT = $ActiveSUT"
echo "ExperimentResultDir = $ExperimentResultDir"
echo "CompletionReportDaemonIP = $CompletionReportDaemonIP"
echo "CompletionReportDaemonPort = $CompletionReportDaemonPort"
echo ""
# GraphDBSUT only
echo "GraphDB SUT"
echo "-----------"
echo "GraphDBBaseDir = $GraphDBBaseDir"
echo "GraphDBDataDir = $GraphDBDataDir"
echo ""
# RDF4JSUT only
echo "RDF4J SUT"
echo "---------"
echo "JVM_Xmx = $JVM_Xmx"
echo "RDF4JRepoBaseDir = $RDF4JRepoBaseDir"
echo ""
# StrabonSUT only
echo "Strabon SUT"
echo "-----------"
echo "StrabonBaseDir = $StrabonBaseDir"
echo "StrabonLoaderBaseDir = $StrabonLoaderBaseDir"
echo ""
# Virtuoso SUT only
echo "Virtuoso SUT"
echo "-----------"
echo "VirtuosoBaseDir = $VirtuosoBaseDir"
echo "VirtuosoDataDir = $VirtuosoDataDir"