package gr.uoa.di.rdf.Geographica2.graphdbsut;

import gr.uoa.di.rdf.Geographica2.systemsundertest.RunSystemUnderTest;

import org.apache.log4j.Logger;

public class RunGraphDB extends RunSystemUnderTest {

    private static final Logger logger = Logger.getLogger(RunGraphDB.class.getSimpleName());

    @Override
    protected void addOptions() {
        super.addOptions();

        options.addOption("bd", "basedir", true, "BaseDir");
        options.addOption("rp", "repository", true, "RepositoryID");
        options.addOption("cr", "create", true, "CreateRepository");
    }

    @Override
    protected void logOptions() {
        super.logOptions();

        logger.info("Excluded options");
        logger.info("BaseDir:\t" + cmd.getOptionValue("basedir"));
        logger.info("RepositoryID:\t" + cmd.getOptionValue("repository"));
        logger.info("CreateRepository:\t" + cmd.getOptionValue("create"));
    }

    @Override
    protected void initSystemUnderTest() throws Exception {
        String basedir = (cmd.getOptionValue("basedir") != null ? cmd.getOptionValue("basedir") : "");
        String repository = cmd.getOptionValue("repository");
        boolean create = Boolean.parseBoolean(cmd.getOptionValue("create"));
        sut = new GraphDBSUT(basedir, repository, create);
    }

    public static void main(String[] args) throws Exception  {
        RunSystemUnderTest runSUT = new RunGraphDB();
        runSUT.run(args);
    }
}
