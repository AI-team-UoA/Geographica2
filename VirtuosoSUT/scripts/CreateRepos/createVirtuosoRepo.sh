#! /bin/bash

# Stores N-Triples in Virtuoso

# SYNTAX :
#    <script> repoDir repoId repoIndexes RDFFileType tripleFileDir -Xmx
SCRIPT_NAME=`basename "$0"`

MAP_CONTEXTS_FILE="map_to_contexts.txt"

# STEP 0: Find the directory where the script is located in
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MAP_CONTEXTS_FILE=$BASE/$MAP_CONTEXTS_FILE

function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

function help() {
	echo "Usage: $SCRIPT_NAME [options] <tripleFileDir>"
	echo "Store files in named graphs in Virtuoso. No default graph exists!"
	echo "A named graph should be defined for every file!"
	echo "	-U, --username: username (default: dba)"
	echo "	-P, --password: password (default: dba)" 
	echo "	-d, --database: database (default: database)"
        echo "  -c, --config:   configuration file (default: virtuoso.ini)"
	echo "	-h, --help:		print help"
}

DEFAULT_INI="virtuoso.ini"
DEFAULT_CONTEXT="<http://geographica.gr>"

# Default option values
db="database"
config=$DEFAULT_INI
username="dba"
password="dba"

# If arguments exist, check the 1st argument for short or long versions
# of options
while  [ $# -gt 0 ] && [ "${1:0:1}" == "-" ]; do
	case ${1} in
		-h | --help)
			help
			exit
		;;
		-d | --database)
			db=${2}
			shift; shift
		;;
		-U | --username)
			username=${2}
			shift; shift
		;;
		-P | --password)
			password=${2}
			shift; shift
		;;
                -c | --config)
                        config=${2}
                        shift; shift
	esac
done

dbPath="${VirtuosoDataDir}/${db}"
#echo "dbPath = $dbPath"
binPath="${VirtuosoBaseDir}/bin"
echo "binPath = $binPath"
tmpPath="${dbPath}/tmp"
#echo "tmpPath = $tmpPath"

echo "Creating Virtuoso database: ${dbPath}"

if test ! -d ${tmpPath}; then
	echo "Creating directory ${tmpPath}"
        mkdir -p "${tmpPath}" # 2>/dev/null
        cp ${BASE}/INI_Files/${config} ${dbPath}/${DEFAULT_INI}
fi

# change current directory to the repo folder
cd ${dbPath}
# start virtuoso and wait some 5 sec for it to start
sudo /sbin/sysctl -w vm.swappiness=10
${binPath}/virtuoso-t -c ${dbPath}/${DEFAULT_INI}
sleep 10

# STEP 1: Validate the script's syntax
#      1.1: check number of arguments
if (( $# != 1 )); then
        help
	exit 1
fi

#      1.2: assign arguments to variables
TripleFileDir=${1}
#echo "TripleFileDir = ${TripleFileDir}"

#      1.3: check whether the directory (<TripleFileDir>) do not exist
if [ ! -d "${TripleFileDir}" ]; then
        echo -e "Directory \"${TripleFileDir}\" does not exist.\nNo Triple files to load!"
        exit 2
fi		

# STEP 4: For the directory $TripleFileDir create TRIG from N-Triple files
#      4.1: change working directory to $NtripleDir
cd $TripleFileDir

#      4.2.1: check if $MAP_CONTEXTS_FILE file exists
if [ -e $MAP_CONTEXTS_FILE ]; then
        MapToContextFile_Exists=1
else
        MapToContextFile_Exists=0
fi
#      4.2.2: For each N-Triple file in the $TripleFileDir do ...
for i in *.nt; do 
    filename=$(basename "$i"); 
    extension="${filename##*.}"; 
    fname="${filename%.*}"; 
#      4.2.4: if $MapToContextFile_Exists set the corresponding graph IRI in the TRIG file
    if [ $MapToContextFile_Exists -eq 1 ]; then
        matchedline=`grep -e $i $MAP_CONTEXTS_FILE`
        if [ "x${matchedline}" != "x" ]; then
            # echo "File $i found in file $MAP_CONTEXTS_FILE in line : $matchedline"
            namedGraph=`echo -e "$matchedline" | awk -F"\t" ' { printf $2 }'`
        else
            namedGraph=${DEFAULT_CONTEXT}
        fi
        # echo "Corresponding context is : $matchedcontext"
        # strip the < > characters from namedGraph
        namedGraph=${namedGraph%>}
        namedGraph=${namedGraph#<}
        echo "Corresponding context is : $namedGraph"
        # create file with namedGraph as its contents
        echo ${namedGraph} > ${fname}.graph
        # create named graph in Virtuoso database
        EXEC_CMD="${binPath}/isql 1111 ${username} ${password} verbose=on banner=off prompt=off echo=ON errors=stdout exec=\"sparql create graph <${namedGraph}>;\""
        echo ${EXEC_CMD}
        eval ${EXEC_CMD}
    fi
done



exit 0;

while test $# -gt 0; do
        
        exit 0;

	file=${1}
	namedGraph=${2}
	shift; shift;

	echo "File: ${file}"
	cp ${file} ${tmpPath}
	echo ${namedGraph} > ${tmpPath}/${file##*/}.graph

	${binPath}/isql -U ${username} -P ${password} exec="sparql create graph <${namedGraph}>;"
	echo "Graph ${namedGraph} created.";

done

exit 0;

t1=$(timer)
# Create one more index
${binPath}/isql -U ${username} -P ${password} exec="CREATE BITMAP INDEX RDF_QUAD_PGOS ON DB.DBA.RDF_QUAD (G, P, O, S) PARTITION (O VARCHAR (-1, 0hexffff));"
t01=$(timer)
echo "Create PGOS: $((t01-t1))secs"
${binPath}/isql -U ${username} -P ${password} exec="ld_dir_all('.', '*.nt', '');select * from db.dba.load_list;"
t02=$(timer)
echo "Load files: $((t02-t01)) secs"
echo "Files to be loaded:"

${binPath}/isql -U ${username} -P ${password} exec="rdf_loader_run();"
t03=$(timer)
echo "Load RDF: $((t03-t02))"
t04=$(timer)
wait
echo "Wait: $((t04-t03))"
t05=$(timer)
${binPath}/isql -U ${username} -P ${password} exec="statistics DB.DBA.RDF_QUAD;"
t06=$(timer)
echo "Gather statistics: $((t06-t05))"
${binPath}/isql -U ${username} -P ${password} exec="checkpoint;"
t07=$(timer)
echo "Checkpoint: $((t07-t06))"
t2=$(timer)
echo "Storing time all: $((t2-t1)) secs"

rm ${tmpPath}/*