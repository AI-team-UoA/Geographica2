package gr.uoa.di.rdf.Geographica.virtuoso;

import gr.uoa.di.rdf.Geographica2.systemsundertest.RunSystemUnderTest;

import org.apache.log4j.Logger;

public class RunVirtuoso extends RunSystemUnderTest {
	static Logger logger = Logger.getLogger(RunVirtuoso.class.getSimpleName());

	@Override
	protected void addOptions() {
		super.addOptions();

		options.addOption("h", "host", true, "Server");
		options.addOption("db", "database", true, "Database");
		options.addOption("p", "port", true, "Port");

		options.addOption("u", "username", true, "Username");
		options.addOption("P", "password", true, "Password");

		options.addOption("s", "scriptStart", true,
				"Start-up script for Virtuoso");
		options.addOption("S", "scriptStop", true,
				"Stop script for Virtuoso");
	}

	@Override
	protected void logOptions() {
		super.logOptions();
		
		logger.info("Excluded options");
		logger.info("Server:\t"+cmd.getOptionValue("host"));
		logger.info("Database:\t"+cmd.getOptionValue("database"));
		logger.info("Port:\t"+cmd.getOptionValue("port"));
		logger.info("Username:\t"+cmd.getOptionValue("username"));
		logger.info("Password:\t"+cmd.getOptionValue("password"));
		
		logger.info("Start script:\t"+cmd.getOptionValue("scriptStart"));
		logger.info("Stop script:\t"+cmd.getOptionValue("scriptStop"));
	}

	protected void initSystemUnderTest() throws Exception {
		String host = (cmd.getOptionValue("host")!=null?cmd.getOptionValue("host"):"localhost");
		String db = cmd.getOptionValue("database");
		int port = (cmd.getOptionValues("port")!=null?Integer.parseInt(cmd.getOptionValue("port")):1521);		
		String user = cmd.getOptionValue("username");
		String password = cmd.getOptionValue("password");
		String startScript = cmd.getOptionValue("s");
		String stopScript = cmd.getOptionValue("S");
		
		sut = new VirtuosoSUT(db, user, password,   port, host, startScript, stopScript);
	}

	public static void main(String[] args) throws Exception {
		RunSystemUnderTest runVirtuoso = new RunVirtuoso();
		
		runVirtuoso.run(args);
	}
	
}
