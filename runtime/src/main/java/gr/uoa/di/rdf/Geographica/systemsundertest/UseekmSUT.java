/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.systemsundertest;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.log4j.Logger;
import org.openrdf.query.BindingSet;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.QueryLanguage;
import org.openrdf.query.TupleQuery;
import org.openrdf.query.TupleQueryResult;
import org.openrdf.query.TupleQueryResultHandlerException;
import org.openrdf.query.Update;
import org.openrdf.query.UpdateExecutionException;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.sail.Sail;
import org.openrdf.sail.nativerdf.NativeStore;

import com.useekm.indexing.IndexingSail;
import com.useekm.indexing.postgis.PostgisIndexMatcher;
import com.useekm.indexing.postgis.PostgisIndexerSettings;

/**
 * @author George Garbis <ggarbis@di.uoa.gr>
 * @author Kostis Kyzirakos <kkyzir@di.uoa.gr>
 * 
 */
public class UseekmSUT implements SystemUnderTest {
	static Logger logger = Logger.getLogger(UseekmSUT.class.getSimpleName());

	private BindingSet firstBindingSet;

	private String db = null;
	private String user = null;
	private String passwd = null;
	private Integer port = null;
	private String host = null;
	private String nativePath = null;

	private SailRepository repository;
	private RepositoryConnection conn;

	public UseekmSUT(String db, String user, String passwd, Integer port, String host, String pathForNativeRepository) throws Exception {
		this.db = db;
		this.user = user;
		this.passwd = passwd;
		this.port = port;
		this.host = host;
		this.nativePath = pathForNativeRepository;
	}

	public BindingSet getFirstBindingSet() {return firstBindingSet;}
	
	@Override
	public void initialize() {
		// Problematic dependencies - start
		try {
			//Initialize the sail you want to use
			Sail sail = new NativeStore(new File(nativePath));

			//Initialize the datasource to be used for connections to Postgres:
			BasicDataSource pgDatasource = new BasicDataSource();
			pgDatasource.setDriverClassName("org.postgresql.Driver");
			pgDatasource.setUrl("jdbc:postgresql://"+this.host+":"+this.port+"/"+this.db);
			pgDatasource.setUsername(this.user); // adapt to your needs
			pgDatasource.setPassword(this.passwd); // adapt to your needs

			//Initialize the settings for the Postgis Indexer:
			PostgisIndexerSettings settings = new PostgisIndexerSettings();
			settings.setDataSource(pgDatasource);
			//specify statements that should be indexed:
			PostgisIndexMatcher matcher1 = new PostgisIndexMatcher();
			matcher1.setPredicate("http://www.opengis.net/ont/geosparql#asWKT"); //to index statements with this predicate, adapt to your needs
			//PostgisIndexMatcher matcher2 = new PostgisIndexMatcher();
			//matcher2.setPredicate("http://www.w3.org/2000/01/rdf-schema#label");
			//matcher2.setSearchConfig("simple");
			PostgisIndexMatcher matcherCLC_asWKT = new PostgisIndexMatcher();
			matcherCLC_asWKT.setPredicate("http://geo.linkedopendata.gr/corine/ontology#asWKT"); //= "<http://geo.linkedopendata.gr/corine/ontology#asWKT>";
			logger.debug("Indexing: http://geo.linkedopendata.gr/corine/ontology#asWKT");
			PostgisIndexMatcher matcherDBPedia_asWKT = new PostgisIndexMatcher();
			matcherDBPedia_asWKT.setPredicate("http://dbpedia.org/property/asWKT"); //= "<http://dbpedia.org/property/asWKT>";
			logger.debug("Indexing: http://dbpedia.org/property/asWKT");
			// gadm for gag
			PostgisIndexMatcher matcherGADM_asWKT = new PostgisIndexMatcher();
			matcherGADM_asWKT.setPredicate("http://geo.linkedopendata.gr/gag/ontology/asWKT"); //= "<http://geo.linkedopendata.gr/gag/ontology/asWKT>";
			logger.debug("Indexing: http://geo.linkedopendata.gr/gag/ontology/asWKT");
			PostgisIndexMatcher matcherGeoNames_asWKT = new PostgisIndexMatcher();
			matcherGeoNames_asWKT.setPredicate("http://www.geonames.org/ontology#asWKT"); //= "<http://www.geonames.org/ontology#asWKT>";
			logger.debug("Indexing: http://www.geonames.org/ontology#asWKT");
			PostgisIndexMatcher matcherHotspots_asWKT = new PostgisIndexMatcher();
			matcherHotspots_asWKT.setPredicate("http://teleios.di.uoa.gr/ontologies/noaOntology.owl#asWKT"); //= "<http://teleios.di.uoa.gr/ontologies/noaOntology.owl#asWKT>";
			logger.debug("Indexing: http://teleios.di.uoa.gr/ontologies/noaOntology.owl#asWKT");
			PostgisIndexMatcher matcherLGD_asWKT = new PostgisIndexMatcher();
			matcherLGD_asWKT.setPredicate("http://linkedgeodata.org/ontology/asWKT"); //= "<http://linkedgeodata.org/ontology/asWKT>";
			logger.debug("Indexing: http://linkedgeodata.org/ontology/asWKT");
			// add matchers for each predicate for wich statements need to be indexed:
			//settings.setMatchers(Arrays.asList(new PostgisIndexMatcher[] { matcher1, matcher2 }));
			settings.setMatchers(Arrays.asList(new PostgisIndexMatcher[] { matcherCLC_asWKT, matcherDBPedia_asWKT, matcherGADM_asWKT, matcherGeoNames_asWKT, matcherHotspots_asWKT, matcherLGD_asWKT }));
			settings.setMatchers(Arrays.asList(new PostgisIndexMatcher[] { matcher1 }));
			//Initialize the IndexingSail that wraps your BigdataSail:
			IndexingSail idxSail = new IndexingSail(sail, settings);

			//Wrap in a SailRepository:
			repository = new SailRepository(idxSail);
			repository.initialize();
			conn = repository.getConnection();

		} catch (RepositoryException e) {
			logger.fatal("Cannot initialize useekm");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);		
		}
		// Problematic dependencies - end
	}

	@Override
	public void close() {
		logger.info("Closing..");
		try {
			conn.close();
			repository.shutDown();

			String[] unlock_useekm = {"/bin/sh", "-c" , "rm -fr "+nativePath+"/lock"};
			Process pr = Runtime.getRuntime().exec(unlock_useekm);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while unlocking USeekM");
			} else {
				logger.info("USeekM unlocked");
			}
			
		} catch (Exception e) {}

		finally {
			if (conn != null)
				conn = null;
			if (repository != null)
				repository = null;
			if (firstBindingSet != null)
				firstBindingSet = null;
			System.gc();
		}
		
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			logger.fatal("Cannot clear caches");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}
		logger.info("Closed (caches not cleared)");
	}

	static class Executor implements Runnable {
		private String query;
		private RepositoryConnection conn;
		private long[] returnValue;
		private BindingSet firstBindingSet;

		public Executor(String query, RepositoryConnection conn, int timeoutSecs) {
			this.query = query;
			this.conn = conn;
			this.returnValue = new long[]{timeoutSecs+1, timeoutSecs+1, timeoutSecs+1, -1};
		}
		public long[] getRetValue() {return returnValue;}
		public BindingSet getFirstBindingSet() {return firstBindingSet;}

		public void run() {	try {
			runQuery();
		} catch (MalformedQueryException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (QueryEvaluationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (RepositoryException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		}

		public void runQuery() throws RepositoryException, MalformedQueryException, QueryEvaluationException {
			logger.info("Evaluating query...");

			TupleQuery tupleQuery = conn.prepareTupleQuery(QueryLanguage.SPARQL, query);

			long results = 0;

			long t1 = System.nanoTime();
			TupleQueryResult result = tupleQuery.evaluate();
			long t2 = System.nanoTime();

			if (result.hasNext()) { 
				this.firstBindingSet = result.next();
				results++;
			}
			while (result.hasNext()) {
				results++;
				result.next();
			}
			long t3 = System.nanoTime();

			logger.info("Query evaluated");
			this.returnValue = new long[]{t2-t1, t3-t2, t3-t1, results};
		}   
	}

	@Override
	public long[] runQueryWithTimeout(String query, int timeoutSecs) throws Exception {
		//maintains a thread for executing the doWork method
		final ExecutorService executor = Executors.newFixedThreadPool(1);
		//set the executor thread working
		Executor runnable = new Executor(query, this.conn, timeoutSecs);

		final Future<?> future = executor.submit(runnable);
		boolean isTimedout = false;
		//check the outcome of the executor thread and limit the time allowed for it to complete
		long tt1 = System.nanoTime();
		try {
			logger.debug("Future started");
			future.get(timeoutSecs, TimeUnit.SECONDS);
			logger.debug("Future end");
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (ExecutionException e) {
			e.printStackTrace();
		} catch (TimeoutException e) {
			isTimedout = true;
			logger.info("time out!");
			logger.info("Restarting Useekm...");
			this.restart();
			logger.info("Closing Useekm...");
			this.close();
		}
		finally {
			logger.debug("Future canceling...");
			future.cancel(true);
			logger.debug("Executor shutting down...");
			executor.shutdown();
			try {
				logger.debug("Executor waiting for termination...");
				executor.awaitTermination(timeoutSecs, TimeUnit.SECONDS);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			System.gc();
		}

		logger.debug("RetValue: "+runnable.getRetValue());

		if (isTimedout) {
			long tt2 = System.nanoTime();
			return new long[]{tt2-tt1, tt2-tt1, tt2-tt1, -1};
		} else {
			this.firstBindingSet = runnable.getFirstBindingSet();
			return runnable.getRetValue();
		}
	}

	@Override
	public long[] runUpdate(String query) throws MalformedQueryException,
	QueryEvaluationException, TupleQueryResultHandlerException,
	IOException {
		logger.info("Executing update...");
		long t1 = System.nanoTime();


		Update update = null;
		try {
			update = conn.prepareUpdate(QueryLanguage.SPARQL, query);
		} catch (RepositoryException e) {
			logger.error("[Useekm.update]", e);
		}

		logger.info("[Useekm.update] executing update query: " + query);

		try {
			update.execute();
		} catch (UpdateExecutionException e) {
			logger.error("[Strabon.update]", e);
		}

		long t2 = System.nanoTime();
		logger.info("Update executed");

		long[] ret = {-1, -1, t2 - t1, -1};
		return ret;
	}

	@Override
	public void clearCaches() {
		String[] stop_postgres = {"/bin/sh", "-c" , "service postgresql stop"};
		String[] clear_caches = {"/bin/sh", "-c" , "sync && echo 3 > /proc/sys/vm/drop_caches"};
		String[] start_postgres = {"/bin/sh", "-c" , "service postgresql start"};

		Process pr;

		try {
			logger.info("Clearing caches...");

			pr = Runtime.getRuntime().exec(stop_postgres);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while stoping postgres");
			}

			pr = Runtime.getRuntime().exec(clear_caches);
			pr.waitFor();

			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while clearing caches");
			}

			pr = Runtime.getRuntime().exec(start_postgres);
			pr.waitFor();

			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while clearing caches");
			}

			Thread.sleep(5000);
			logger.info("Caches cleared");
		} catch (Exception e) {
			logger.fatal("Cannot clear caches");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}
	}

	@Override
	public void restart() {

		String[] restart_postgres = {"/bin/sh", "-c" , "service postgresql restart"};
		String[] unlock_useekm = {"/bin/sh", "-c" , "rm -r /home/benchmark/useekm/lock"};

		Process pr;

		try {
			logger.info("Restarting Useekm (Postgres) ...");

			pr = Runtime.getRuntime().exec(restart_postgres);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while stoping postgres");
			}

			pr = Runtime.getRuntime().exec(unlock_useekm);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while unlocking USeekM");
			}
			Thread.sleep(5000);

			//Initialize the sail you want to use
			Sail sail = new NativeStore(new File(nativePath));

			//Initialize the datasource to be used for connections to Postgres:
			BasicDataSource pgDatasource = new BasicDataSource();
			pgDatasource.setDriverClassName("org.postgresql.Driver");
			pgDatasource.setUrl("jdbc:postgresql://"+this.host+":"+this.port+"/"+this.db);
			pgDatasource.setUsername(this.user); // adapt to your needs
			pgDatasource.setPassword(this.passwd); // adapt to your needs

			// Problematic dependencies - start
			//Initialize the settings for the Postgis Indexer:
			PostgisIndexerSettings settings = new PostgisIndexerSettings();
			settings.setDataSource(pgDatasource);
			//specify statements that should be indexed:
			PostgisIndexMatcher matcher1 = new PostgisIndexMatcher();
			matcher1.setPredicate("http://www.opengis.net/ont/geosparql#asWKT"); //to index statements with this predicate, adapt to your needs
			//PostgisIndexMatcher matcher2 = new PostgisIndexMatcher();
			//matcher2.setPredicate("http://www.w3.org/2000/01/rdf-schema#label");
			//matcher2.setSearchConfig("simple");
			// add matchers for each predicate for wich statements need to be indexed:
			//settings.setMatchers(Arrays.asList(new PostgisIndexMatcher[] { matcher1, matcher2 }));
			settings.setMatchers(Arrays.asList(new PostgisIndexMatcher[] { matcher1 }));

			//Initialize the IndexingSail that wraps your BigdataSail:
			IndexingSail idxSail = new IndexingSail(sail, settings);

			if (conn != null) {
				try { conn.close(); } catch (Exception e) {};
				conn = null;
			}
			if (repository != null) {
				try { repository.shutDown(); } catch (Exception e) {};
				repository = null;
			}
			if (firstBindingSet != null)
				firstBindingSet = null;
			
			System.gc();

			
			//Wrap in a SailRepository:
			repository = new SailRepository(idxSail);
			repository.initialize();
			conn = repository.getConnection();
			// Problematic dependencies - end
			logger.info("Useekm (Postgres) restarted");
		} catch (Exception e) {
			logger.fatal("Cannot restart Strabon");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}

	}
	
	@Override
	public Object getSystem() {
		return this.repository;
	}
	
	public String translateQuery(String query, String label) { 
		return query;
	}
}
