# SYNTAX :
#    <script> repoDir repoIndexes RDFFileType trigDir
SCRIPT_NAME=`basename "$0"`
SYNTAX="
SYNTAX: $SCRIPT_NAME <repoDir> <-Xmx>
\t<repoDir>\t:\tdirectory where repo will be stored,
\t<-Xmx>\t\t:\tJVM max memory e.g. -Xmx6g"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 2 )); then
    echo -e "Illegal number of parameters $SYNTAX"
	exit 1
fi

#      1.2: assign arguments to variables
RepoDir=$1
#echo $RepoDir
JVM_Xmx=$2

#      1.3: check whether the directory (<repoDir>) does not exists
dirs=(  "$RepoDir" )
for dir in "${dirs[@]}"; do
	if [ ! -d "$dir" ]; then
		echo -e "Directory \"$dir\" does not exist!"
		exit 2
	fi		
done

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

# define the run command to QUERY_1 REPO
EXEC_QUERY_1_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS query \"1\" \"$RepoDir\""
#echo $EXEC_QUERY_1_REPO

# define the run command to QUERY_2 REPO
EXEC_QUERY_2_REPO="java $JAVA_OPTS -cp $CLASS_PATH $MAIN_CLASS query \"2\" \"$RepoDir\""
#echo $EXEC_QUERY_2_REPO

# execute commnads
echo -e "Validating repo \"${RepoDir}\""
echo -e "QUERY 1: Total Number of triples"
eval ${EXEC_QUERY_1_REPO}
echo -e "\nQUERY 2: Number of triples Per Graph"
eval ${EXEC_QUERY_2_REPO}

exit 0
