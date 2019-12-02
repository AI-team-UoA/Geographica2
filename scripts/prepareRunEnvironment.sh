#!/bin/bash

# Example execution from within a Geographica/scripts subfolder in TELEIOS3
# source ./prepareRunEnvironment.sh teleios3 `hg parents | head -1 | cut -d ":" -f2` GraphDBSUT "run graphdb tests"

# SYNTAX :
#    <script> environment
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <environment> <changeset> <activesut> <short description>
\t<environment>\t:\tEnvironment the Geographica will run {TELEIOS3 | VM}
\t<changeset>\t:\tGeographica mercurial changeset
\t<activesut>\t:\tActive SUT
\t<shortdesc>\t:\tExperiment short description"

# STEP 0: Find the directory where the script is located in, Geographica/scripts
export GeographicaScriptsDir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 4 )); then
    echo -e "Illegal number of parameters $SYNTAX"
    return 1
fi
#      1.2: read the arguments
Environment=${1^^}
Changeset=${2}      # should be a number nn or nnn
# set the active SUT
export ActiveSUT=${3}
ShortDesc=${4}

# STEP 2: Set the values of the exported environment variables

# formulate the results folder name
DateTimeISO8601=`date --iso-8601='date'`
export ResultsDirName="${Changeset}#_${DateTimeISO8601}_${ShortDesc}"

# TELEIOS3 is considered the default environment, 
# VM is the development environment, but more environments
# can be added by editing the following IF-THEN-ELSE structure
if [ "$Environment" == "VM" ]; then
    # common for all SUTs
    export DatasetBaseDir="/media/sf_VM_Shared/PHD/Geographica2_Datasets"
    export ResultsBaseDir="/media/sf_VM_Shared/PHD/Results_Store/VM_Results"
    export CompletionReportDaemonIP="127.0.0.1"
    export CompletionReportDaemonPort="3333"
    # GraphDBSUT only
    export GraphDBBaseDir="/media/sf_VM_Shared/PHD/graphdb-free-8.11.1"
    # RDF4JSUT only
    export JVM_Xmx="-Xmx8g"
    export RDF4JRepoBaseDir="/media/sf_VM_Shared/PHD/RDF4J_LuceneRepos/server"
    # StrabonSUT only
    export StrabonBaseDir="/home/tioannid/NetBeansProjects/PhD/Strabon"
    export StrabonLoaderBaseDir="/home/tioannid/NetBeansProjects/PhD/StrabonLoader"
    # VirtuosoSUT only
    export VirtuosoBaseDir="/home/tioannid/NetBeansProjects/PhD/vso"
    export VirtuosoDataDir="${VirtuosoBaseDir}/repos"
else
    # common for all SUTs
    export DatasetBaseDir="/home/journal/Geographica_Datasets"
    export ResultsBaseDir="/home/journal"
    export CompletionReportDaemonIP="10.0.10.13" # TELEIO4
    export CompletionReportDaemonPort="3333"
    # GraphDBSUT only
    export GraphDBBaseDir="/home/journal/graphdb-free-8.8.1"
    # RDF4JSUT only
    export JVM_Xmx="-Xmx24g"
    export RDF4JRepoBaseDir="/home/journal/RDF4J_LuceneRepos/server"
    # StrabonSUT only
    export StrabonBaseDir="/home/journal/Strabon"
    export StrabonLoaderBaseDir="/home/journal/StrabonLoader"
    # VirtuosoSUT only
    export VirtuosoBaseDir="/home/journal/vso"
    export VirtuosoDataDir="${VirtuosoBaseDir}/repos"
fi

# read the GraphDB data directory from the config file
GraphDB_Properties_File="${GraphDBBaseDir}/conf/graphdb.properties"
matchedLine=`grep -e "^graphdb.home.data =" $GraphDB_Properties_File`
export GraphDBDataDir="${matchedLine##*= }"
# if graphdb.home.data is not explicitly set then assign default path
if [ -z ${GraphDBDataDir} ]; then
        export GraphDBDataDir="${GraphDBBaseDir}/data"
fi

# GraphDB dependent, environment independent
export EnableGeoSPARQLPlugin=false
export IndexingAlgorithm=geohash
export IndexingPrecision=11


# define Results base directory
export ExperimentResultDir="${ResultsBaseDir}/${ActiveSUT}/${ResultsDirName}"
