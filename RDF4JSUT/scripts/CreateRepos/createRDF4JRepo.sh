# SYNTAX :
#    <script> repoDir repoId repoIndexes RDFFileType tripleFileDir -Xmx
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <repoDir> <repoId> <removeFlag> <repoIndexes> <RDFFileType> <tripleFileDir> <-Xmx>
\t<repoDir>\t:\tdirectory where repo will be stored,
\t<repoId>\t:\trepository Id,
\t<removeFlag>\t:\tremove repository if it exists,
\t<repoIndexes>\t:\tindexes to create for the repo,
\t<RDFFileType>\t:\tRDF file type,
\t<tripleFileDir>\t:\tdirectory for RDF triple files to load,
\t<-Xmx>\t\t:\tJVM max memory e.g. -Xmx6g"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 7 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

#      1.2: assign arguments to variables
RepoDir=$1
#echo $RepoDir
RepoID=$2
#echo $RepoID
RemoveFlag=${3^^}
#echo $RemoveFlag
RepoIndexes=$4
#echo $RepoIndexes
RDFFileType=$5
#echo $RDFFileType
TripleFileDir=$6
#echo $TripleFileDir
JVM_Xmx=$7


#      1.3: check whether the directory (<fileDir>) do not exist
dirs=(  "$TripleFileDir" )
for dir in "${dirs[@]}"; do
	if [ ! -d "$dir" ]; then
		echo -e "Directory \"$dir\" does not exist.\nNo Triple files to load!"
		exit 2
	fi		
done

#      1.4: check whether the directory (<repoDir>) exists
if [ "$RemoveFlag" == "FALSE" ]
then
dirs=(  "${RepoDir}/repositories/${RepoID}" )
for dir in "${dirs[@]}"; do
	if [ -d "$dir" ]; then
		echo -e "A repository might already exist in directory \"$dir\".\nRemove it manually"
		exit 2
	fi		
done
fi

# STEP 2: Prepare options for LOG4J, JAVA VM, CLASS PATH and MAIN CLASS		

# define the configuration file for the Apache LOG4J framework, which is common
# for all Geographica and is located in the Runtime module
LOG4J_CONFIGURATION=${BASE}/../../../runtime/src/main/resources/log4j.properties
#echo "LOG4J_CONFIGURATION = $LOG4J_CONFIGURATION"

# define the JVM options/parameters
JAVA_OPTS="${JVM_Xmx} -Dlog4j.configuration=file:${LOG4J_CONFIGURATION}"
#echo "JAVA_OPTS = $JAVA_OPTS"

# change to the ../target directory to more easily create the classpath
cd ${BASE}/../../target
# define the class path
CLASS_PATH="$(for file in `ls -1 *.jar`; do myVar=$myVar./$file":"; done;echo $myVar;)"

# define the executing-main class
MAIN_CLASS="gr.uoa.di.rdf.Geographica2.rdf4jsut.RepoUtil"

# define the run command to CREATE REPO
EXEC_CREATE_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS createman \"$RepoDir\" \"$RepoID\" \"$RemoveFlag\" \"$RepoIndexes\""
#echo $EXEC_CREATE_REPO

# define the run command to LOAD RDF FILES FROM DIR TO REPO
EXEC_LOAD_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS dirloadman \"$RepoDir\" \"$RepoID\" \"$RDFFileType\" \"$TripleFileDir\" false"
#echo $EXEC_LOAD_REPO

# execute commnads
eval ${EXEC_CREATE_REPO}
eval ${EXEC_LOAD_REPO}

# print repository size in MB
echo -e "RDF4J repository \"${RepoDir}:${RepoID}\" has size: `du -hs -BM ${RepoDir}/repositories/${RepoID} | cut -d 'M' -f 1`MB"
exit 0
