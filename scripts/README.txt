GEOGRAPHICA 2 INSTRUCTIONS

1) GENERAL INSTRUCTIONS

1.1) Clone from the Public Mercurial directory

   $ pwd
    /home/user
   $ hg clone http://hg.strabon.di.uoa.gr/Geographica2
   $ cd Geographica ; pwd
    /home/user/Geographica      # Geographica 2 base directory
   $ cd scripts ; pwd
    /home/user/Geographica/scripts  # Geographica 2 scripts directory

1.2) Install SUTs Software Dependencies (server distribution packages, if needed)

    Some SUTs, such as GraphDB, will require for proper execution of the experiments
    to have the appropriate distribution software installed. For example, you
    will need to go to the examples/maven-installer subdirectory of the distribution 
    and run:

    $ mvn install


1.3) Configure Geographica 2 for a specific System Under Test (SUT)

    Geographica 2 is designed to be run from a terminal. Since this benchmark 
    usually launches long-running tasks, sometimes on a remote machine, to avoid 
    lose of work by connection drops, a terminal multiplexer such as GNU screen
    is suggested as the terminal provider for your experiments.

    The scripts/prepareRunEnvironment.sh is a script through which the user can
    define Geographica 2 runtime environment variable values, define the number 
    of desired environments and assign them names and define each SUT's specific
    environment variable values. The script is preconfigured with a "VM" environment
    which was used for development and small size tests and an default environment
    which is not named (any other name other than "VM" will match it) is the production
    environment (commonly, a remote server). The user can play with the IF-THEN-
    ELSE structure and define as many different named environments suit his needs.
    
    The Geographica 2 runtime environment variables belong to 3 categories:
    a) ScriptArgs: these are the script arguments which represent the basic
                interface for running experiments. These are:
        i) Environment: arg #1, case-insensitive name for the environment, i.e. "VM"
       ii) Changeset:   arg #2, mercurial changeset number, useful for developers
                            extending the benchmark
      iii) ActiveSUT:   arg #3, name of the SUT that will be tested, i.e. GraphDBSUT
       iv) ShortDesc:   arg #4, short description that will describe the results
                            directory
    b) Dynamic: they are calculated by the script using script arguments and
                other environment variable values.
        i) GeographicaScriptsDir: directory location of the prepareRunEnvironment.sh
                        i.e. /home/user/Geographica/scripts
       ii) DateTimeISO8601: date in the form YYYY-MM-DD
      iii) ResultsDirName: the directory name for results of the test. It is
                        contains the Changeset, the DateTimeISO8601 and the
                        ShortDesc.
       iv) GraphDBDataDir: directory for GraphDB repositories
        v) ExperimentResultDir: the full directory name for the experiment, which
                        will contain ResultsBaseDir, ActiveSUT and ResultsDirName
    c) UserDefined:  these are set by the user and usually represent SUTs server
                base directories, SUTs repository locations, SUTs result directories,
                Java VM maximum memory allocation, etc.
       i) DatasetBaseDir: environment base directory for source datasets
      ii) ResultsBaseDir: environment results base directory
     iii) GraphDBBaseDir: base dir for GraphDB installation
      iv) JVM_Xmx: Java VM max memory allocation
       v) RDF4JRepoBaseDir: RDF4J repo base directory
        etc..
                