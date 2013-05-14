/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.experiments;

import gr.uoa.di.rdf.Geographica.queries.MacroFireMonitoringQueriesSet;
import gr.uoa.di.rdf.Geographica.queries.QueriesSet.QueryStruct;
import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.apache.log4j.Logger;

/**
 * @author George Garbis <ggarbis@di.uoa.gr>
 */
public class MacroFireMonitoringExperiment extends MacroExperiment {
	
	private long[] updateruns;

	public MacroFireMonitoringExperiment(SystemUnderTest sut, int repetitions,
			int timeoutSecs, int runTimeInMinutes, String logPath) throws IOException {
		super(sut, repetitions, timeoutSecs, runTimeInMinutes, logPath);
		logger = Logger.getLogger(MacroFireMonitoringExperiment.class.getSimpleName());
		queriesSet = new MacroFireMonitoringQueriesSet(sut);
		this.runTimeInMinutes = runTimeInMinutes;
	}

	public void run() {
		QueryStruct queryStruct = null;

		long time;
		updateruns = new long[4];

		// It's pointless to consider warm and cold caches about updates
		sut.clearCaches();
		sut.initialize();
		logger.info("Clear caches and initialize sut before updates");

		int repetitionI = 0;
		int queryI = 0;
		long t1 = System.currentTimeMillis();
		while (true) {
			try {
				for (queryI = 0; queryI < queriesSet.getQueriesN(); queryI++) {
					queryStruct = queriesSet.getQuery(queryI, repetitionI);

					logger.info("Executing update (" + queryI + ", " + repetitionI + "): "	+ queryStruct.getQuery());

					updateruns = sut.runUpdate(queryStruct.getQuery());
					logger.info("Update executed ("
									+ queryI + ", "	+ repetitionI + "): "
									+ updateruns[0] + " + "
									+ updateruns[1] + " = "
									+ updateruns[2] + ", "
									+ updateruns[3]);
					
					try {
						printStatisticsPerQuery(this.getClass().getSimpleName(), queryI, repetitionI, queryStruct, updateruns);
					} catch (IOException e) {
						logger.error("While printing statistics (cold, " + queryI + ")");
						StringWriter sw = new StringWriter();
						e.printStackTrace(new PrintWriter(sw));
						String stacktrace = sw.toString();
						logger.error(stacktrace);
					}
				}
				
				repetitionI++;
				time = System.currentTimeMillis() - t1;
				logger.info("Executed " + repetitionI+" - "+time+"/"+runTimeInMinutes*60000);
				if ( time > runTimeInMinutes*60000) {
					logger.info("Finish at: " + time);
					break;
				}
				
			} catch (Exception e) {
				logger.error("While evaluating update(cold, " 
						+ queryI + ", " + repetitionI + ")");
				StringWriter sw = new StringWriter();
				e.printStackTrace(new PrintWriter(sw));
				String stacktrace = sw.toString();
				logger.error(stacktrace);
				sut.close();
				sut.clearCaches();
				sut.initialize();
			}
		}
		
		try {
			printStatisticsAll(this.getClass().getSimpleName(), repetitionI, time);
		} catch (IOException e) {
			logger.error("While printing statistics (cold, " + queryI + ")");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.error(stacktrace);
		}
		

		sut.close();
		sut.clearCaches();
		
	}
	
	@SuppressWarnings("all")
	public void printStatistics(String experiment, int repetitions)
			throws IOException {

		FileWriter fstream;
		BufferedWriter out;
		String filePath;
		File file;

		// If not exists create experiment folder
		String dirPath = logPath + sut.getClass().getSimpleName() + "-" + experiment;
		File dir = new File(dirPath);
		if (!dir.exists()) {
			logger.info("Creating directory: " + dirPath);
			boolean result = dir.mkdir();
			if (result) {
				logger.info("Directory created");
			}
		}

		// Create short file
		filePath = dirPath + "/" + experiment;
		file = new File (filePath);
		if (!file.createNewFile()) {
			logger.error("File "+filePath+" already exists");
		}
		
		// Print short mode
		fstream = new FileWriter(filePath, true);
		
		out = new BufferedWriter(fstream);

		out.write(repetitions + "\n");
		out.close();
		logger.info("Statistiscs printed: " + filePath);
		
		out.close();

		logger.info("Statistiscs printed: " + filePath);
	}
}
