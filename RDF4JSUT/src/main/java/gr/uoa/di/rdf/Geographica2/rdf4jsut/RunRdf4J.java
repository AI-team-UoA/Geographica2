/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gr.uoa.di.rdf.Geographica2.rdf4jsut;

import gr.uoa.di.rdf.Geographica2.systemsundertest.RunSystemUnderTest;

import org.apache.log4j.Logger;

/**
 *
 * @author Ioannidis Theofilos <tioannid@yahoo.com>
 */
public class RunRdf4J extends RunSystemUnderTest {

    private static final Logger logger = Logger.getLogger(RunRdf4J.class.getSimpleName());

    @Override
    protected void addOptions() {
        super.addOptions();

        options.addOption("rd", "repodir", true, "RepoDir");
    }

    @Override
    protected void logOptions() {
        super.logOptions();

        logger.info("Excluded options");
        logger.info("RepoDir:\t" + cmd.getOptionValue("repodir"));
    }
    
    @Override
    protected void initSystemUnderTest() throws Exception {
        String repodir = (cmd.getOptionValue("repodir") != null ? cmd.getOptionValue("repodir") : "");
        sut = new Rdf4jSUT(repodir);
    }

    public static void main(String[] args) throws Exception  {
        RunSystemUnderTest runSUT = new RunRdf4J();
        runSUT.run(args);
    }    
}
