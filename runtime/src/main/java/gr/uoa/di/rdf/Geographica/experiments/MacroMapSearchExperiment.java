/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.experiments;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

import gr.uoa.di.rdf.Geographica.queries.MacroMapSearchQueriesSet;
import gr.uoa.di.rdf.Geographica.queries.QueriesSet.QueryStruct;
import gr.uoa.di.rdf.Geographica.systemsundertest.ParliamentSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.StrabonSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.UseekmSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;

import org.apache.log4j.Logger;
import org.openrdf.query.Binding;
import org.openrdf.query.BindingSet;

import com.hp.hpl.jena.query.QuerySolution;

/**
 * @author George Garbis <ggarbis@di.uoa.gr>
 */
public class MacroMapSearchExperiment extends MacroExperiment {
	
	public MacroMapSearchExperiment(SystemUnderTest sut, int repetitions, int timeoutSecs, int runTimeInMinutes, String logPath) throws IOException {
		super(sut, repetitions, timeoutSecs, runTimeInMinutes, logPath);
		logger = Logger.getLogger(MacroMapSearchExperiment.class.getSimpleName());
		queriesSet = new MacroMapSearchQueriesSet(sut);
		this.runTimeInMinutes = runTimeInMinutes;
	}
	
	@Override
	public void run() {
		
		QueryStruct queryStruct = null;
		long time;

		measurements = new long[4];

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

					logger.info("Executing query (" + queryI + ", " + repetitionI + "): "	+ queryStruct.getQuery());

					measurements =  sut.runQueryWithTimeout(queryStruct.getQuery(), timeoutSecs);
					
					if (queryI == 0) {
						if (sut instanceof StrabonSUT) {
							BindingSet firstBindingSet = ((StrabonSUT)sut).getFirstBindingSet();
							Binding geo = firstBindingSet.getBinding("wkt");
							((MacroMapSearchQueriesSet)queriesSet).setCurrentPoint(geo.getValue().stringValue());
						}
						if (sut instanceof UseekmSUT) {
							BindingSet firstBindingSet = ((UseekmSUT)sut).getFirstBindingSet();
							Binding geo = firstBindingSet.getBinding("wkt");
							((MacroMapSearchQueriesSet)queriesSet).setCurrentPoint(geo.getValue().stringValue());
						}
						else if (sut instanceof ParliamentSUT) {
							QuerySolution firstQuerySolution = ((ParliamentSUT)sut).getFirstQuerySolution();
							((MacroMapSearchQueriesSet)queriesSet).setCurrentPoint(firstQuerySolution.getLiteral("wkt").getString());
						} else {
							logger.error("sut not recognizable");
						}
					}
					
					logger.info("Query executed ("
									+ queryI + ", "	+ repetitionI + "): "
									+ measurements[0] + " + "
									+ measurements[1] + " = "
									+ measurements[2] + ", "
									+ measurements[3] + "\n");
				
					try {
						printStatisticsPerQuery(this.getClass().getSimpleName(), queryI, repetitionI, queryStruct, measurements);
					} catch (IOException e) {
						logger.error("While printing statistics (cold, " + queryI + ")");
						StringWriter sw = new StringWriter();
						e.printStackTrace(new PrintWriter(sw));
						String stacktrace = sw.toString();
						logger.error(stacktrace);
					}
				}
				
				time = System.currentTimeMillis() - t1;
				logger.info("Executed " + repetitionI+" - "+time+"/"+runTimeInMinutes*60000);
				if (time > runTimeInMinutes*60000) {
					logger.info("Finish at: " + time);
					break;
				}
				repetitionI++;
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
}

