/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gr.uoa.di.rdf.Geographica.graphdbsut;

import gr.uoa.di.rdf.Geographica2.systemsundertest.SystemUnderTest;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import org.apache.log4j.Logger;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.QueryLanguage;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.query.MalformedQueryException;
import org.eclipse.rdf4j.query.QueryEvaluationException;
import org.eclipse.rdf4j.query.TupleQueryResultHandlerException;
import org.eclipse.rdf4j.repository.manager.LocalRepositoryManager;

/**
 *
 * @author tioannid
 */
public class GraphDBSUT implements SystemUnderTest {

    // --------------------- Class Members ---------------------------------
    static Logger logger = Logger.getLogger(GraphDBSUT.class.getSimpleName());

    /* Utility class GraphDBSUT.GraphDB
    ** Similar to Strabon, encapsulates key objects of GraphDB
     */
    public static class GraphDB {

        // --------------------- Data Members ----------------------------------
        private final String baseDir;     // base directory for repository manager
        private final LocalRepositoryManager repositoryManager;   // repository manager
        private final String repositoryId;    // repository Id
        private Repository repository;  // repository
        private RepositoryConnection connection;    // repository connection

        // --------------------- Constructors ----------------------------------
        public GraphDB(String baseDir, String repositoryId) throws RuntimeException {
            this.baseDir = baseDir;
            // create a new embedded instance of GraphDB in baseDir
            // check if baseDir exists, otherwise throw exception
            File dir = new File(baseDir);
            if (!dir.exists()) {
                throw new RuntimeException("Directory " + baseDir + " does not exist.");
            }
            repositoryManager = new LocalRepositoryManager(dir);
            repositoryManager.initialize();
            this.repositoryId = repositoryId;
            // check if repository exists, otherwise throw exception
            if (!repositoryManager.hasRepositoryConfig(repositoryId)) {
                throw new RuntimeException("Repository " + repositoryId + " does not exist.");
            }
            repository = repositoryManager.getRepository(repositoryId);
            // create a repository connection, otherwise throw exception
            connection = repository.getConnection();
            if (connection == null) {
                throw new RuntimeException("Could not establish connection to repository " + repositoryId);
            }
        }

        // --------------------- Data Accessors --------------------------------
        public String getBaseDir() {
            return baseDir;
        }

        public LocalRepositoryManager getRepositoryManager() {
            return repositoryManager;
        }

        public String getRepositoryId() {
            return repositoryId;
        }

        public Repository getRepository() {
            return repository;
        }

        public RepositoryConnection getConnection() {
            return connection;
        }
    }

    /* Utility class GraphDBSUT.Executor
    ** Executes queries on GraphDB
     */
    static class Executor implements Runnable {

        // --------------------- Data Members ----------------------------------
        private String query;
        private GraphDB graphDB;
        private long[] returnValue;
        private BindingSet firstBindingSet;

        // --------------------- Constructors ----------------------------------
        public Executor(String query, GraphDB graphDB, int timeoutSecs) {
            this.query = query;
            this.graphDB = graphDB;
            this.returnValue = new long[]{timeoutSecs + 1, timeoutSecs + 1, timeoutSecs + 1, -1};
        }

        // --------------------- Data Accessors --------------------------------
        public long[] getRetValue() {
            return returnValue;
        }

        public BindingSet getFirstBindingSet() {
            return firstBindingSet;
        }

        // --------------------- Methods --------------------------------
        @Override
        public void run() {
            try {
                runQuery();
            } catch (MalformedQueryException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (QueryEvaluationException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (TupleQueryResultHandlerException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        public void runQuery() throws MalformedQueryException, QueryEvaluationException, TupleQueryResultHandlerException, IOException {

            logger.info("Evaluating query...");
            TupleQuery tupleQuery = graphDB.getConnection().prepareTupleQuery(QueryLanguage.SPARQL, query);                    

            long results = 0;

            long t1 = System.nanoTime();
            TupleQueryResult result = tupleQuery.evaluate();
            long t2 = System.nanoTime();

            if (result.hasNext()) {
                
                this.firstBindingSet =  result.next();
                results++;
            }
            while (result.hasNext()) {
                results++;
                result.next();
            }
            long t3 = System.nanoTime();

            logger.info("Query evaluated");
            this.returnValue = new long[]{t2 - t1, t3 - t2, t3 - t1, results};
        }
    }

    // --------------------- Data Members ----------------------------------
    private String baseDir;     // base directory for repository manager
    private String repositoryId;    // repository Id
    private GraphDB graphDB;
    private BindingSet firstBindingSet;

    // --------------------- Constructors ----------------------------------
    public GraphDBSUT(String baseDir, String repositoryId) {
        this.baseDir = baseDir;
        this.repositoryId = repositoryId;
    }

    // --------------------- Data Accessors --------------------------------
    @Override
    public BindingSet getFirstBindingSet() {
        return firstBindingSet;
    }

    // --------------------- Methods --------------------------------
    @Override
    public Object getSystem() {
        return graphDB;
    }

    @Override
    public void initialize() {
        try {
            graphDB = new GraphDB(baseDir, repositoryId);
        } catch (RuntimeException e) {
            logger.fatal("Cannot initialize GraphDB(\"" + baseDir + "\", \"" + repositoryId + "\"");
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            logger.fatal(sw.toString());
        }
    }

    @Override
    public long[] runQueryWithTimeout(String query, int timeoutSecs) throws Exception {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public long[] runUpdate(String query) throws MalformedQueryException, QueryEvaluationException, TupleQueryResultHandlerException, IOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void close() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void clearCaches() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void restart() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public String translateQuery(String query, String label) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
