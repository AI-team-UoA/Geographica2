# SYNTAX :
#    <script> repoDir repoIndexes RDFFileType trigDir
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <repoDir> <repoIndexes> <RDFFileType> <fileDir>
\t<repoDir>\t:\tdirectory where repo will be stored,
\t<repoIndexes>\t:\tindexes to create for the repo,
\t<RDFFileType>\t:\tRDF file type,
\t<fileDir>\t:\tdirectory for RDF triple files to load"

# Assumptions
# 1) The N-Triple files for the dataset are located in the ntripleDir directory
# 2) The rdf2rdf-1.0.1-2.3.1.jar is located in the same directory as the script
# 3) The pgrep command should be available
# 4) A "maps_to_contexts.txt" file exists in ntripleDir if context/graph IRIs need to be specified in TRIG files
# 5) The repoConf file has the appropriate repository name!

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 4 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

#      1.2: assign arguments to variables
RepoDir=$1
#echo $RepoDir
RepoIndexes=$2
#echo $RepoIndexes
RDFFileType=$3
#echo $RDFFileType
TripleFileDir=$4
#echo $TripleFileDir

#      1.3: check whether the directory (<fileDir>) do not exist
dirs=(  "$TripleFileDir" )
for dir in "${dirs[@]}"; do
	if [ ! -d "$dir" ]; then
		echo -e "Directory \"$dir\" does not exist.\nNo Triple files to load!"
		exit 2
	fi		
done

#      1.4: check whether the directory (<repoDir>) exists
dirs=(  "$RepoDir" )
for dir in "${dirs[@]}"; do
	if [ -d "$dir" ]; then
		echo -e "A repository might already exist in directory \"$dir\".\nRemove it manually"
		exit 2
	fi		
done

# STEP 2: Prepare options for LOG4J, JAVA VM, CLASS PATH and MAIN CLASS		

# define the configuration file for the Apache LOG4J framework, which is common
# for all Geographica and is located in the Runtime module
LOG4J_CONFIGURATION=${BASE}/../../../runtime/src/main/resources/log4j.properties
#echo "LOG4J_CONFIGURATION = $LOG4J_CONFIGURATION"

# define the JVM options/parameters
JAVA_OPTS="-Xmx4g -Dlog4j.configuration=file:${LOG4J_CONFIGURATION}"
#echo "JAVA_OPTS = $JAVA_OPTS"

# change to the ../target directory to more easily create the classpath
cd ${BASE}/../../target
# define the class path
CLASS_PATH="$(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)"

# define the executing-main class
MAIN_CLASS="gr.uoa.di.rdf.Geographica2.rdf4jsut.RepoUtil"

# define the run command to CREATE REPO
EXEC_CREATE_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS create \"$RepoDir\" \"$RepoIndexes\""
#echo $EXEC_CREATE_REPO

# define the run command to LOAD RDF FILES FROM DIR TO REPO
EXEC_LOAD_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS dirload \"$RepoDir\" \"$RDFFileType\" \"$TripleFileDir\" false"
#echo $EXEC_LOAD_REPO

# execute commnads
eval ${EXEC_CREATE_REPO}
eval ${EXEC_LOAD_REPO}

# print repository size in MB
echo -e "RDF4J repository \"${RepoDir}\" has size: `du -hs -BM $RepoDir | cut -d 'M' -f 1`MB"
exit 0