package gr.uoa.di.rdf.Geographica.useekm;

import gr.uoa.di.rdf.Geographica.systemsundertest.RunSystemUnderTest;

import org.apache.log4j.Logger;

public class RunUSeekM extends RunSystemUnderTest {
	static Logger logger = Logger.getLogger(RunUSeekM.class.getSimpleName());

	@Override
	protected void addOptions() {
		super.addOptions();
		
		options.addOption("h", "host", true, "Server");
		options.addOption("db", "database", true, "Database");
		options.addOption("p", "port", true, "Port (default: 5432)");
		options.addOption("n", "native", true, "Path for Native Repository");
		options.addOption("u", "username", true, "Username");
		options.addOption("P", "password", true, "Password");
	}

	@Override
	protected void logOptions() {
		super.logOptions();
		
		logger.info("Excluded options");
		logger.info("Server:\t"+cmd.getOptionValue("host"));
		logger.info("Database:\t"+cmd.getOptionValue("database"));
		logger.info("Port:\t"+cmd.getOptionValue("port"));
		logger.info("Native:\t"+cmd.getOptionValue("native"));
		logger.info("Username:\t"+cmd.getOptionValue("username"));
		logger.info("Password:\t"+cmd.getOptionValue("password"));
	}

	protected void initSystemUnderTest() throws Exception {
		String host = (cmd.getOptionValue("host")!=null?cmd.getOptionValue("host"):"localhost");
		String db = cmd.getOptionValue("database");
		int port = (cmd.getOptionValue("port")!=null?Integer.parseInt(cmd.getOptionValue("port")):1521);
		String pathForNativeRepository = cmd.getOptionValue("native");
		String user = cmd.getOptionValue("username");
		String password = cmd.getOptionValue("password");

		sut = new UseekmSUT(db, user, password, port, host, pathForNativeRepository);		
	}

	public static void main(String[] args) throws Exception {
		RunSystemUnderTest runUSeekM = new RunUSeekM();
		
		runUSeekM.run(args);
	}
}
