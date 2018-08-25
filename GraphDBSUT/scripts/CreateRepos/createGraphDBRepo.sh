# SYNTAX :
#    <script> repoConf RDFDir RDFFormat graphDBBaseDir
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME repoConf ntripleDir graphDBBaseDir
\trepoConf\t:\tconfiguration file for repo,
\tRDFDir\t:\tdirectory with the RDF data files to load,
\tRDFFormat\t:\tRDF format {N-TRIPLES | TRIG }
\tgraphDBBaseDir\t:\tbase directory of the GraphDB installation"

# Assumptions
# 1) The N-Triple files for the dataset are located in the ntripleDir directory
# 2) The rdf2rdf-1.0.1-2.3.1.jar is located in the same directory as the script
# 3) The pgrep command should be available
# 4) A "maps_to_contexts.txt" file exists in ntripleDir if context/graph IRIs need to be specified in TRIG files
# 5) The repoConf file has the appropriate repository name!

MAP_CONTEXTS_FILE="map_to_contexts.txt"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MAP_CONTEXTS_FILE=$BASE/$MAP_CONTEXTS_FILE

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments and assign them to variables
if (( $# != 4 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

RepoConfig=$BASE/$1
# echo $RepoConfig
#      1.2: extract the repository ID from the config file
RepoName=`grep -e "repositoryID" $RepoConfig | awk -F"\"" ' { printf $2 }'`
# echo $RepoName
NtripleDir=$2
# echo $NtripleDir
RDFFormat=${3^^}
# echo $RDFFormat
GraphDBBaseDir=$4
# echo $GraphDBBaseDir

#      1.3: check whether the directories (ntripleDir graphDBBaseDir) exist
dirs=(  "$NtripleDir" "$GraphDBBaseDir" )
for dir in "${dirs[@]}"; do
	if [ ! -d "$dir" ]; then
		echo "Directory $dir does not exist!"
		exit 2
	fi		
done

#      1.4: check whether the RDF format is N-Triples or TRIG
if [ "${RDFFormat}" != "TRIG" ] && [ "${RDFFormat}" != "N-TRIPLES" ]; then
    echo "Supported RDF formats are : {N-TRIPLES | TRIG}!"
    exit 3
fi

# STEP 2: Assess whether the script's preconditions are met
#      2.1: check whether the $GraphDBBaseDir/bin/preload exists
PreLoad_Exe="${GraphDBBaseDir}/bin/preload"
if [ ! -e "$PreLoad_Exe" ]; then
	echo "File $PreLoad_Exe does not exist!"
	exit 4
fi

#      2.2: check whether the repos $RepoName already exists
#      2.2.1: get the value of the <graphdb.home.data> in the <graphDBBaseDir>/conf/graphdb.properties configuration file
GraphDB_Properties_File="${GraphDBBaseDir}/conf/graphdb.properties" 
#echo "GraphDB Properties file is : $GraphDB_Properties_File"
matchedLine=`grep -e "^graphdb.home.data =" $GraphDB_Properties_File`
GraphDB_Data_Dir="${matchedLine##*= }"
# echo "GraphDB Data dir is : $GraphDB_Data_Dir"

#      2.2.2: check if <GraphDBDataDir>/repositories contains any of the repos (repoName )
repoDir="${GraphDB_Data_Dir}/repositories/${RepoName}"
# echo $repoDir 
if [ -d "$repoDir" ]; then
	echo "Repo $RepoName already exists in --> $repoDir"
	exit 5
fi		

# STEP 3: Terminate the GraphDB server process, if it's running
kill -9 `pgrep -f graphdb` > /dev/null 2>&1

# STEP 4: For the directory $NtripleDir create TRIG from N-Triple files
#      4.1: change working directory to $NtripleDir
cd $NtripleDir
#      4.2: if $RDFFormat is TRIG, convert N-Triples to TRIG
if [ "${RDFFormat}" = "TRIG" ]; then
    #      4.2.1: check if $MAP_CONTEXTS_FILE file exists
    if [ -e $MAP_CONTEXTS_FILE ]; then
            MapToContextFile_Exists=1
    else
            MapToContextFile_Exists=0
    fi
    #      4.2.2: For each N-Triple file in the $datafir do ...
    for i in *.nt; do 
    #      4.2.3: convert N-Triple file to TRIG with default graph using the rdf2rdf-1.0.1-2.3.1.jar program
            filename=$(basename "$i"); 
            extension="${filename##*.}"; 
            fname="${filename%.*}"; 
            trigfilename="${fname}.trig"; 
            java -jar "${BASE}/rdf2rdf-1.0.1-2.3.1.jar" $filename $trigfilename;
    #      4.2.4: if $MapToContextFile_Exists set the corresponding graph IRI in the TRIG file
            if [ $MapToContextFile_Exists -eq 1 ]; then
                    matchedline=`grep -e $i $MAP_CONTEXTS_FILE`
                    # echo "File $i found in file $MAP_CONTEXTS_FILE in line : $matchedline"
                    matchedcontext=`echo -e "$matchedline" | awk -F"\t" ' { printf $2 }'`
                    # echo "Corresponding context is : $matchedcontext"
                    sed -i 's+{$+'${matchedcontext}' {+' $trigfilename
                    echo "Modified graph name in TRIG file $trigfilename to $matchedcontext"
            fi
    done
    #      4.2.5: Set the filetype to TRIG
    rdffiletype='.trig'
else
    #      4.2.6: Set the filetype to N-TRIPLES
    rdffiletype='.nt'
fi
# STEP 5: Create $RepoName repository with config file $RepoConfig and load RDF files while measuring the elapsed time
time $PreLoad_Exe -c $RepoConfig *$rdffiletype

# STEP 6: Remove TRIG file to avoid allocating space
if [ "${RDFFormat}" = "TRIG" ]; then
    rm *.trig
fi

exit 0