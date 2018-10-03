#!/bin/bash

# Example execution from within a Geographica/scripts subfolder in TELEIOS3
# source ./prepareRunEnvironment.sh teleios3 `hg parents | head -1 | cut -d ":" -f2`

# SYNTAX :
#    <script> environment
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <environment> <changeset>
\t<environment>\t:\tEnvironment the Geographica will run {TELEIOS3 | VM}
\t<changeset>\t:\tGeographica mercurial changeset"

# STEP 0: Find the directory where the script is located in, Geographica/scripts
export GeographicaScriptsDir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 2 )); then
    echo -e "Illegal number of parameters $SYNTAX"
    exit 1
fi
#      1.2: read the arguments
Environment=${1^^}
Changeset=${2}      # should be a number nn or nnn

# STEP 2: Set the values of the exported environment variables

# TELEIOS3 is considered the default environment, 
# VM is the development environment, but more environments
# can be added by editing the following IF-THEN-ELSE structure
if [ "$Environment" == "VM" ]; then
    # common for all SUTs
    export DatasetBaseDir="/media/sf_VM_Shared/PHD/Geographica2_Datasets"
    export ResultsBaseDir="/media/sf_VM_Shared/PHD/Results_Store/VM_Results"
    # GraphDBSUT only
    export GraphDBBaseDir="/home/tioannid/graphdb-free-8.6.1"
    # RDF4JSUT only
    export JVM_Xmx="-Xmx16g"
    export RDF4JRepoBaseDir="/media/sf_VM_Shared/PHD/RDF4J_LuceneRepos/server"
    # StrabonSUT only
    export StrabonBaseDir="/home/tioannid/NetBeansProjects/PhD/Strabon"
    export StrabonLoaderBaseDir="/home/tioannid/NetBeansProjects/PhD/StrabonLoader"
else
    # common for all SUTs
    export DatasetBaseDir="/home/journal/Geographica_Datasets"
    export ResultsBaseDir="/home/journal"
    # GraphDBSUT only
    export GraphDBBaseDir="/home/journal/graphdb-free-8.6.1"
    # RDF4JSUT only
    export JVM_Xmx="-Xmx24g"
    export RDF4JRepoBaseDir="/home/journal/RDF4J_LuceneRepos/server"
    # StrabonSUT only
    export StrabonBaseDir="/home/journal/Strabon"
    export StrabonLoaderBaseDir="/home/journal/StrabonLoader"
fi

export ResultsBaseDir="${ResultsBaseDir}/Results${Changeset}"
