/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.virtuoso;

import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.apache.log4j.Logger;
import org.openrdf.model.BNode;
import org.openrdf.model.Literal;
import org.openrdf.model.URI;
import org.openrdf.model.impl.BNodeImpl;
import org.openrdf.model.impl.LiteralImpl;
import org.openrdf.model.impl.URIImpl;
import org.openrdf.query.Binding;
import org.openrdf.query.BindingSet;
import org.openrdf.query.MalformedQueryException;
import org.openrdf.query.QueryEvaluationException;
import org.openrdf.query.TupleQueryResultHandlerException;
import org.openrdf.query.impl.BindingImpl;
import org.openrdf.repository.sparql.query.SPARQLQueryBindingSet;

import virtuoso.jdbc3.VirtuosoExtendedString;
import virtuoso.jdbc3.VirtuosoRdfBox;


/**
 * @author Kostis Kyzirakos <kkyzir@di.uoa.gr>
 *
 */
public class VirtuosoSUT implements SystemUnderTest {
	static Logger logger = Logger.getLogger(SystemUnderTest.class.getSimpleName());
	private BindingSet firstBindingSet;

	private Connection virtuoso;

	private String database = null;
	private String user = null;
	private String passwd = null;
	private Integer port = null;
	private String host = null;
	private String script_start = null;
	private String script_stop = null;

	public VirtuosoSUT(String database, String user, String passwd, Integer port, String host, String startScript, String stopScript) throws Exception {
		this.database = database;
		this.user = user;
		this.passwd = passwd;
		this.port = port;
		this.host = host;
		this.script_start = startScript;
		this.script_stop = stopScript;
	}

	public BindingSet getFirstBindingSet() {return firstBindingSet;}
	
	@Override
	public void initialize() {
		try {
			Class.forName("virtuoso.jdbc3.Driver");
			virtuoso = DriverManager.getConnection("jdbc:virtuoso://"+this.host+":"+this.port, this.user, this.passwd);
		} catch (Exception e) {
			logger.fatal("Cannot initialize virtuoso");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}
	}

	@Override
	public void close() {
		logger.info("Closing..");

		try {
			if (this.virtuoso != null && !this.virtuoso.isClosed()) {
				this.virtuoso.close();
				firstBindingSet = null;
			}
			System.gc();

		} catch (SQLException e) {
			e.printStackTrace();
		}

		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			logger.fatal("Cannot close Virtuoso");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}
		logger.info("Closed (caches not cleared)");
	}

	@Override
	public Object getSystem() {
		return virtuoso;
	}

	@Override
	public void clearCaches() {
		String[] stopCommand = {"/bin/sh", "-c" , script_stop + " " + database};
		String[] clear_caches = {"/bin/sh", "-c" , "sync && echo 3 > /proc/sys/vm/drop_caches"};
		String[] startCommand = {"/bin/sh", "-c" , script_start + " " + database};

		Process pr;

		try {
			logger.info("Clearing caches...");

			pr = Runtime.getRuntime().exec(stopCommand);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while stoping virtuoso");
			}

			//Thread.sleep(5);
			//String[] check_virtuoso = {"/bin/sh", "-c", "ps -ef | grep 'virtuoso +wait' >> /tmp/virtuoso-stop.log"};
			//pr = Runtime.getRuntime().exec(check_virtuoso);
			//pr.waitFor();
		
			
			pr = Runtime.getRuntime().exec(clear_caches);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while clearing caches");
			}

			logger.info("Starting virtuoso:...database: "+database+", command: "+script_start);
			pr = Runtime.getRuntime().exec(startCommand);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while starting Virtuoso");
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
		String[] stopCommand = {"/bin/sh", "-c" , script_stop + " " + database};
		String[] startCommand = {"/bin/sh", "-c" , script_start + " " + database};

		Process pr;

		try {
			logger.info("Restarting Virtuoso (server) ...");

			pr = Runtime.getRuntime().exec(stopCommand);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while stoping virtuoso");
			}
			pr = Runtime.getRuntime().exec(startCommand);
			pr.waitFor();
			if ( pr.exitValue() != 0) {
				logger.error("Something went wrong while starting virtuoso");
			}

			Thread.sleep(5000);

			virtuoso = DriverManager.getConnection("jdbc:virtuoso://"+this.host+":"+this.port, this.user, this.passwd);
			firstBindingSet = null;
			logger.info("Virtuoso (server) restarted");
		} catch (Exception e) {
			logger.fatal("Cannot restart virtuoso");
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			String stacktrace = sw.toString();
			logger.fatal(stacktrace);
		}
	}

	static class Executor implements Runnable {
		private String query;
		private Connection virtuoso;
		private long[] returnValue;
		private BindingSet firstBindingSet;

		public Executor(String query, Connection virtuoso, int timeoutSecs) {
			this.query = query;
			this.virtuoso = virtuoso;
			this.returnValue = new long[]{timeoutSecs+1, timeoutSecs+1, timeoutSecs+1, -1};
		}
		public long[] getRetValue() {return returnValue;}
		public BindingSet getFirstBindingSet() {return firstBindingSet;}

		public void run() {	try {
			runQuery();
		} catch (MalformedQueryException e) {
			e.printStackTrace();
		} catch (QueryEvaluationException e) {
			e.printStackTrace();
		} catch (TupleQueryResultHandlerException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} }

		public void runQuery() throws MalformedQueryException, QueryEvaluationException, TupleQueryResultHandlerException, IOException, SQLException {
			logger.info("Evaluating query...");

			long results = 0;

			long t1 = System.nanoTime();
			Statement st = virtuoso.createStatement();
			ResultSet rs = st.executeQuery("sparql " + query);
			long t2 = System.nanoTime();

			if (rs.next()) {

				ResultSetMetaData rsmd = rs.getMetaData();
				int cnt = rsmd.getColumnCount();
				Object o;
				SPARQLQueryBindingSet bset = new SPARQLQueryBindingSet(1);

				for (int i = 1; i <= cnt; i++) {
					String var = rsmd.getColumnLabel(i);
					Binding b;
					o = rs.getObject(i);
					if (o instanceof VirtuosoExtendedString) {
						VirtuosoExtendedString result = (VirtuosoExtendedString)o;
						if (result.iriType == VirtuosoExtendedString.IRI) {							
							URI value = new URIImpl(result.str);
							b = new BindingImpl(var, value);
						} else {
							assert (result.iriType == VirtuosoExtendedString.BNODE);
							BNode value = new BNodeImpl(result.str);
							b = new BindingImpl(var, value);
						} 
					} else { 
						assert o instanceof VirtuosoRdfBox;
						VirtuosoRdfBox result = (VirtuosoRdfBox) o;
						String literalLang = result.getLang();
						String literalType = result.getType();
						String literalLabel = result.rb_box.toString();
						Literal value;
						if (literalLang != null) {
							value = new LiteralImpl(literalLabel, literalLang);
						} else if (literalType != null) {
							value = new LiteralImpl(literalLabel, new URIImpl(literalType));
						} else {
							value = new LiteralImpl(literalLabel);
						}
						b = new BindingImpl(var, value);
					}

					bset.addBinding(b);
				}

				this.firstBindingSet = bset;
				results++;
			}

			while (rs.next()) {
				results++;
			}
			long t3 = System.nanoTime();

			logger.info("Query evaluated");
			this.returnValue = new long[]{t2-t1, t3-t2, t3-t1, results};
		}   
	}

	@Override
	public long[] runQueryWithTimeout(String query, int timeoutSecs)
			throws Exception {
		//maintains a thread for executing the doWork method
		final ExecutorService executor = Executors.newFixedThreadPool(1);
		//set the executor thread working
		Executor runnable = new Executor(query, virtuoso, timeoutSecs);

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
			logger.info("Restarting Virtuoso...");
			this.restart();
			logger.info("Closing Virtuoso...");
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
		return null;
	}
	
	public String translateQuery(String query, String label) {
		
		String translatedQuery = query;
		
//		givenPoint = "bif:st_point(23.71622, 37.97945)";
//		givenRadius = "2.93782";
		
		if (label.equals("Intersects_GeoNames_Point_Buffer")) {
			translatedQuery = translatedQuery.replace("geof:sfWithin", "bif:st_within");
			translatedQuery = translatedQuery.replace("geof:buffer(\"POINT(23.71622 37.97945)\"^^<http://www.opengis.net/ont/geosparql#wktLiteral>, 3000, <http://www.opengis.net/def/uom/OGC/1.0/metre>)", "bif:st_point(23.71622, 37.97945), 2.93782");
		} else if (label.equals("Intersects_GeoNames_Point_Distance")) {
			translatedQuery = translatedQuery.replace("geof:distance", "bif:st_distance");
			translatedQuery = translatedQuery.replace(", <http://www.opengis.net/def/uom/OGC/1.0/metre>:", "");
		} else if (label.equals("Area_CLC")) {
			translatedQuery = null;
		} else if (label.equals("Equals_GeoNames_DBPedia")) {
			translatedQuery = translatedQuery.replace("geof:sfEquals(?o1, ?o2)", "bif:st_within(?o1, ?o2, 0)");
		} else if (label.contains("Synthetic_Join_Distance_")
				||  label.contains("Synthetic_Selection_Distance_")) {
			translatedQuery = translatedQuery.replace("http://www.opengis.net/ont/geosparql#wktLiteral", "http://www.openlinksw.com/schemas/virtrdf#Geometry");
			translatedQuery = translatedQuery.replace("geof:distance", "bif:st_distance");
			translatedQuery = translatedQuery.replace(", <http://www.opengis.net/def/uom/OGC/1.0/metre>", "");
			
			String[] querySplitted = translatedQuery.split("<= ");
			if (querySplitted.length == 2) {
				String distanceString = query.split("<= ")[1];
				distanceString = distanceString.split("\\)")[0];
				double distanceInMeter = Double.parseDouble(distanceString);
				double distanceInKm = distanceInMeter / 1000;
				translatedQuery = translatedQuery.replace(distanceString, String.format("%f", distanceInKm));
			}
		}
		
		return translatedQuery;
	}
}
