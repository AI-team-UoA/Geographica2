/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.runtime;

import gr.uoa.di.rdf.Geographica.experiments.Experiment;
import gr.uoa.di.rdf.Geographica.experiments.MacroMapSearchExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MacroRapidMappingExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MacroReverseGeocodingExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MicroAggregationsExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MicroJoinsExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MicroNonTopologicalExperiment;
import gr.uoa.di.rdf.Geographica.experiments.MicroSelectionsExperiment;
import gr.uoa.di.rdf.Geographica.experiments.SyntheticExperiment;
import gr.uoa.di.rdf.Geographica.experiments.SyntheticOnlyPointsExperiment;
import gr.uoa.di.rdf.Geographica.queries.QueriesSet;
import gr.uoa.di.rdf.Geographica.systemsundertest.ParliamentSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.StrabonSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;
import gr.uoa.di.rdf.Geographica.systemsundertest.UseekmSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.VirtuosoSUT;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.log4j.Logger;

/**
 * @author George Garbis <ggarbis@di.uoa.gr>
 * @author Kostis Kyzirakos <kkyzir@di.uoa.gr>
 */
public class Geographica {

	static Logger logger = Logger.getLogger(Geographica.class.getSimpleName());
	static Options options = null;

	public static void printHelp() {
		System.err.println("Usage: Geographica [options] (Strabon|Parliament|USeekM|Virtuoso) (run|print) (MicroNonTopological|MicroSelections|MicroJoins|MicroAggregations|MacroFireMonitoring|MacroRapidMapping|MacroReverseGeocoding|Synthetic|SyntheticOnlyPoints)+");
		System.err.println("For synthetic data experiments parameter N>0 is obligatory");
		HelpFormatter formatter = new HelpFormatter();
		formatter.printHelp( "Geographica", options );		
	}

	public static void main(String[] args) throws Exception {
		options = new Options();

		options.addOption("?", "help", false, "Print help message");
		options.addOption("q", "queries", true, "List of queries to run");
		options.addOption("d", "database", true, "Database for PostgreSQL (Strabon) / Virtuoso");
		options.addOption("u", "username", true, "Username for PostgreSQL (Strabon) / Virtuoso");
		options.addOption("P", "password", true, "Password for PostgreSQL (Strabon) / Virtuoso");
		options.addOption("p", "port", true, "Port for PostgreSQL (Strabon) / Virtuoso");
		options.addOption("n", "native", true, "Path for Native Repository (Strabon) (default: /home/benchmark/useekm)");
		options.addOption("h", "host", true, "Host for PostgreSQL (Strabon) / Virtuoso");
		options.addOption("r", "repetitions", true, "Repetitions for experiments (default: 5)");
		options.addOption("t", "timeout", true, "Timeout (seconds) for experiments (default 30mins)");
		options.addOption("m", "runtime", true, "Run time (minutes) for experiments (Macro scenarios) (default: 2hours)");
		options.addOption("s", "virtuosoStart", true, "Start-up script for Virtuoso");
		options.addOption("S", "virtuosoStop", true, "Stop script for Virtuoso");
		options.addOption("N", "syntheticN", true, "Parameter for synthetic experiments");
		options.addOption("l", "logpath", true, "Log path");
		
		CommandLine cmd = null;
		PosixParser parser = new PosixParser();
		SystemUnderTest	sut = null;


		for (int i = 0; i < args.length; i++)
			System.out.println("args["+i+"] = " + args[i]);

		try {
			cmd = parser.parse(options, args);

			// Print help if required
			if (cmd.hasOption("?")) {
				System.out.println("Checkpoint #1");
				printHelp();
				System.exit(0);
			}

			// Strabon properties
			// See SUT initialization
			String db = cmd.getOptionValue("d");;
			String user = (cmd.getOptionValue("u")!=null?cmd.getOptionValue("u"):"postgres");
			String passwd = (cmd.getOptionValue("P")!=null?cmd.getOptionValue("P"):"postgres");
			Integer port = Integer.parseInt((cmd.getOptionValue("p")!=null?cmd.getOptionValue("port"):"5432"));
			String host = (cmd.getOptionValue("h")!=null?cmd.getOptionValue("host"):"localhost");
			int repetitions = Integer.parseInt((cmd.getOptionValue("r")!=null?cmd.getOptionValue("r"):"5"));
			int timeoutSecs = (cmd.getOptionValue("t")!=null?Integer.parseInt(cmd.getOptionValue("t")):30*60); // 30 mins
			int runTimeInMinutes = (cmd.getOptionValue("m")!=null?Integer.parseInt(cmd.getOptionValue("runtime")):2*60); // 2 hours
			String pathForNativeRepository = (cmd.getOptionValue("n")!=null?cmd.getOptionValue("n"):"/home/benchmark/useekm"); 
			String start_script = cmd.getOptionValue("s");
			String stop_script = cmd.getOptionValue("S");
			String logPath = cmd.getOptionValue("l");
			// List of queries to run
			String queriesToRunString = cmd.getOptionValue("q");
			int[] queriesToRun = null;
			if (queriesToRunString != null) {
				String[] queriesToRunStringArray = queriesToRunString.split(" ");
				queriesToRun = new int[queriesToRunStringArray.length];
				for(int i=0; i<queriesToRunStringArray.length; i++) {
					queriesToRun[i] = Integer.parseInt(queriesToRunStringArray[i]);
				}
			}
			

			int N = Integer.parseInt((cmd.getOptionValue("N")!=null?cmd.getOptionValue("N"):"0"));
			
			args = cmd.getArgs();
			// Check arguments
			if (args.length < 3) {
				System.out.println("Checkpoint #2");
				printHelp();
				System.exit(-1);
			}
			
			// Initialize system under test
			if (args[0].equalsIgnoreCase("Strabon")) {
				if (db == null) {
					System.err.println("Strabon. No database given.");
					printHelp();
					System.exit(-1);
				}
				sut = new StrabonSUT(db, user, passwd, port, host);
			} else if (args[0].equalsIgnoreCase("Parliament")) {
				sut = new ParliamentSUT();
			} else if (args[0].equalsIgnoreCase("Virtuoso")) {
				if (db == null) {
					System.err.println("Virtuoso. No database given.");
					printHelp();
					System.exit(-1);
				}
				if (start_script == null || stop_script == null) {
					System.err.println("Virtuoso. One of start script of stop script is null.");
					printHelp();
					System.exit(-1);
				}
				sut = new VirtuosoSUT(db, user, passwd, port, host, start_script, stop_script);
			} else if (args[0].equalsIgnoreCase("uSeekM")) {
				if (db == null) {
					System.err.println("uSeekM. No database given.");
					printHelp();
					System.exit(-1);
				}
				sut = new UseekmSUT(db, user, passwd, port, host, pathForNativeRepository);
			} else {
				System.out.println("System under test '"+args[0]+"' not recognized.");
				printHelp();
				System.exit(-1);
			}

			logger.info("Arguments:");
			logger.info("Database:\t"+db);
			logger.info("Username:\t"+user);
			logger.info("Password:\t"+passwd);
			logger.info("Port:\t"+port);
			logger.info("Host:\t"+host);
			logger.info("Repetitions:\t"+repetitions);
			logger.info("Time out:\t"+timeoutSecs+" seconds");
			logger.info("Run time:\t"+runTimeInMinutes+"minutes");
			logger.info("Native repository:\t"+pathForNativeRepository);
			logger.info("N:\t"+N);
			logger.info("Queries to run:\t"+queriesToRunString);
			logger.info("Log Path:\t"+logPath);

	
			// Select and execute experiments
			Experiment experiment = null;
			for (int i= 2; i<args.length; i++){
				// Micro experiments
				if ( args[i].equalsIgnoreCase("MicroNonTopological") ) {
					experiment = new MicroNonTopologicalExperiment(sut, repetitions, timeoutSecs, queriesToRun, logPath);
				} else if ( args[i].equalsIgnoreCase("MicroSelections") ) {
					experiment = new MicroSelectionsExperiment(sut, repetitions, timeoutSecs, queriesToRun, logPath);
				} else if ( args[i].equalsIgnoreCase("MicroJoins") ) {
					experiment = new MicroJoinsExperiment(sut, repetitions, timeoutSecs, queriesToRun, logPath);
				} else if ( args[i].equalsIgnoreCase("MicroAggregations") ) {
					experiment = new MicroAggregationsExperiment(sut, repetitions, timeoutSecs, queriesToRun, logPath);
				// Macro experiments
				} else if ( args[i].equalsIgnoreCase("MacroReverseGeocoding") ) {
					experiment = new MacroReverseGeocodingExperiment(sut, repetitions, timeoutSecs, runTimeInMinutes, queriesToRun, logPath);
				} else if ( args[i].equalsIgnoreCase("MacroMapSearch") ) {
					experiment = new MacroMapSearchExperiment(sut, repetitions, timeoutSecs, runTimeInMinutes, queriesToRun, logPath);
				} else if ( args[i].equalsIgnoreCase("MacroRapidMapping") ) {
					experiment = new MacroRapidMappingExperiment(sut, repetitions, timeoutSecs, runTimeInMinutes, queriesToRun, logPath);
				// Synthetic
				} else if ( args[i].equalsIgnoreCase("Synthetic") ) {
					experiment = new SyntheticExperiment(sut, repetitions, timeoutSecs, N, queriesToRun, logPath);
				// Synthetic Only Points
				} else if ( args[i].equalsIgnoreCase("SyntheticOnlyPoints") ) {
					experiment = new SyntheticOnlyPointsExperiment(sut, repetitions, timeoutSecs, N, queriesToRun, logPath);
				} 
				else {
					System.err.println("Error: "+args[i]+" is not recognized.");
					System.err.println("Only MicroNonTopological, MicroSelections, MicroJoins, MicroAggreagations.");
					System.exit(-1);
				}

				// Run, test or print queries of experiments
				if ( args[1].equalsIgnoreCase("run") ) {
					logger.info("Start "+experiment.getClass().getName());
					experiment.run();
					logger.info("End "+experiment.getClass().getName());
				} else if ( args[1].equalsIgnoreCase("print") ) {
					System.out.println("\n"+experiment.getClass().getName()+"\n");
					QueriesSet qs = experiment.getQueriesSet();
					for(int j=0; j<qs.getQueriesN(); j++)
						System.out.println("\nQuery "+j+" - "+qs.getQuery(j, 0).getLabel()+":\n"+qs.getQuery(j, 0).getQuery());
				} else {
					System.out.println("Checkpoint #4");
					printHelp();
				}
			}
		} catch (ParseException e) {
			System.err.println( "Parsing failed.  Reason: " + e.getMessage() );
			// automatically generate the help statement
			System.out.println("Checkpoint #5");
			printHelp();
		}
		System.exit(0);
	}
}
