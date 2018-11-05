
package testsuite;

import org.junit.Test;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.rules.ExpectedException;
import org.junit.runners.MethodSorters;
import org.junit.FixMethodOrder;

import static org.junit.Assert.*;

import java.io.File;
import java.io.FileOutputStream;
import java.net.URL;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;
import java.util.HashMap;
import java.util.Set;


import org.eclipse.rdf4j.model.*;
import org.eclipse.rdf4j.model.impl.GraphImpl;
import org.eclipse.rdf4j.query.BindingSet;
import org.eclipse.rdf4j.query.BooleanQuery;
import org.eclipse.rdf4j.query.GraphQuery;
import org.eclipse.rdf4j.query.GraphQueryResult;
import org.eclipse.rdf4j.query.MalformedQueryException;
import org.eclipse.rdf4j.query.QueryEvaluationException;
import org.eclipse.rdf4j.query.QueryLanguage;
import org.eclipse.rdf4j.query.TupleQuery;
import org.eclipse.rdf4j.query.TupleQueryResult;
import org.eclipse.rdf4j.repository.Repository;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFHandler;
import org.eclipse.rdf4j.rio.ntriples.NTriplesWriter;

import virtuoso.rdf4j.driver.*;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class VirtuosoTest extends TestBase{


    static String ctx = "http://demo.openlinksw.com/demo#this";
    static URL url;

    @Before
    public void setUp() throws Exception {
        super.setUp();

        String strurl = "http://dbpedia.org/data/Berlin.rdf";
        url = new URL(strurl);
    }



    @Test
    public void test1() throws Exception {
        RepositoryConnection con = null;
        try {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            con.clear(context);

            IRI subject = repository.getValueFactory().createIRI("urn:s");
            IRI predicate = repository.getValueFactory().createIRI("urn:p");
            IRI object = repository.getValueFactory().createIRI("urn:o");
            boolean rc;
            rc = con.getStatements(subject, predicate, object, false, context).hasNext();
            assertFalse("Graph wasn't cleared", rc);

            con.begin();
            con.add(subject, predicate, object, context);
            rc = con.getStatements(subject, predicate, object, false, context).hasNext();
            assertTrue("Data wasn't inserted", rc);
            con.rollback();
            rc = con.getStatements(subject, predicate, object, false, context).hasNext();
            assertFalse("Rollback doesn't work", rc);

        } finally {
            if (con != null)
                con.close();
        }
    }


    @Test
    public void test2() throws Exception {
        RepositoryConnection con = null;
        try {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            // test query data
            String query = "SELECT * FROM <" + context + "> WHERE {?s ?p ?o} LIMIT 1";

            log("Loading data from URL: " + url);
            con.add(url, "", RDFFormat.RDFXML, context);
            results = doTupleQuery(con, query);
            assertTrue("Empty ResultSet", (results.length > 0));

            con.clear(context);
            log("Clearing triple store");
            long sz = con.size(context);
            assertTrue("Graph wasn't cleared", (sz == 0));
        } finally {
            if (con != null)
                con.close();
        }
    }


    @Test public void test3() throws Exception
    {
        RepositoryConnection con = null;
        try
        {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
            URL dataFile = classLoader.getResource("data.nt");

            con.add(dataFile, "", RDFFormat.NTRIPLES, context);
            String query = "SELECT * FROM <" + context + "> WHERE {?s ?p ?o} LIMIT 1";
            results = doTupleQuery(con, query);
            assertTrue("ResultSet is EMPTY", (results.length > 0));

            log("Execute query with parameter binding");
            query = "SELECT ?s ?o FROM <" + context + "> WHERE {?s ?p ?o} LIMIT 1";
            HashMap<String, Value> bind = new HashMap<String, Value>();
            bind.put("s", repository.getValueFactory().createIRI("http://dbpedia.org/resource/BatMan"));
            bind.put("o", repository.getValueFactory().createIRI("http://sw.cyc.com/2006/07/27/cyc/Batman-TheComicStrip"));
            results = doTupleQuery(con, query, bind);
            assertTrue("ResultSet is EMPTY", (results.length > 0));
        }
        finally
        {
            if (con!=null)
                con.close();
        }
    }


    @Test
    public void test4() throws Exception {
        RepositoryConnection con = null;
        try {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            byte utf8data[] = {(byte) 0xd0, (byte) 0xbf, (byte) 0xd1, (byte) 0x80,
                    (byte) 0xd0, (byte) 0xb8, (byte) 0xd0, (byte) 0xb2,
                    (byte) 0xd0, (byte) 0xb5, (byte) 0xd1, (byte) 0x82};
            String utf8str = new String(utf8data, "UTF8");

            IRI un_testuri = repository.getValueFactory().createIRI("http://myopenlink.net/foaf/unicodeTest");
            IRI un_name = repository.getValueFactory().createIRI("http://myopenlink.net/foaf/name");
            Literal un_Value = repository.getValueFactory().createLiteral(utf8str);

            con.clear(context);
            log("Loading UNICODE single triple");
            con.add(un_testuri, un_name, un_Value, context);
            String query = "SELECT * FROM <" + context + "> WHERE {?s ?p ?o} LIMIT 1";
            results = doTupleQuery(con, query);
            assertTrue("ResultSet is Empty", results.length > 0);
            assertTrue("Col1 must be :"+un_testuri.toString(), results[0][0].toString().equals(un_testuri.toString()));
            assertTrue("Col2 must be :"+un_name.toString(), results[0][1].toString().equals(un_name.toString()));
            assertTrue("Col3 must be :"+un_Value.toString(), results[0][2].toString().equals(un_Value.toString()));

        } finally {
            if (con != null)
                con.close();
        }
    }


    @Test
    public void test5() throws Exception {
        RepositoryConnection con = null;
        try {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            IRI kingsleyidehen = repository.getValueFactory().createIRI("http://myopenlink.net/dataspace/person/kidehen");
            BNode snode = repository.getValueFactory().createBNode("kidehenNode");
            IRI name = repository.getValueFactory().createIRI("http://myopenlink.net/foaf/name");
            Literal nameValue = repository.getValueFactory().createLiteral("Kingsley Idehen");

            con.clear(context);
            log("Loading single triple");
            con.add(snode, name, nameValue, context);
            String query = "SELECT * FROM <" + context + "> WHERE {?s ?p ?o} LIMIT 1";
            results = doTupleQuery(con, query);
            assertTrue("ResultSet is EMPTY", (results.length>0));

            log("Casted value type");
            assertTrue("Col1 must be BNode",(results[0][0] instanceof BNode));
            assertTrue("Col2 must be IRI",(results[0][1] instanceof IRI));
            assertTrue("Col3 must be BNode",(results[0][2] instanceof Literal));


            results = null;
            log("Selecting property");
            query = "SELECT * FROM <" + context + "> WHERE {?s <http://myopenlink.net/foaf/name> ?o} LIMIT 1";
            results = doTupleQuery(con, query);
            assertTrue("ResultSet is EMPTY", (results.length>0));


            boolean exists = false;
            con.add(kingsleyidehen, name, nameValue, context);
            exists = con.hasStatement(kingsleyidehen, name, null, false, context);
            assertTrue("Statement wasn't added", exists);
            // test remove a statement
            con.remove(kingsleyidehen, name, nameValue, (Resource) context);
            // test statement removed
            exists = con.hasStatement(kingsleyidehen, name, null, false, context);
            assertFalse("Statement wasn't removed", exists);


            results = null;
            log("Statement exists (by resultset size)");
            con.add(kingsleyidehen, name, nameValue, context);
            exists = con.hasStatement(kingsleyidehen, name, null, false, context);
            assertTrue("Statement wasn't added", exists);
            query = "SELECT * FROM <" + context + "> WHERE {?s <http://myopenlink.net/foaf/name> ?o} LIMIT 1";
            results = doTupleQuery(con, query);
            assertTrue("ResultSet is EMPTY", (results.length>0));


            RepositoryResult<Statement> statements = null;
            // test getStatements and RepositoryResult implementation
            log("Retrieving statement (" + kingsleyidehen + " " + name + " " + null + ")");
            statements = con.getStatements(kingsleyidehen, name, null, false, context);
            assertTrue("ResultSet is EMPTY", statements.hasNext());
            while (statements.hasNext()) {
                Statement st = statements.next();
                // System.out.println("Statement found: (" + st.getSubject() + " " + st.getPredicate() + " " + st.getObject() + ")");
            }


            // test export and handlers
            File f = File.createTempFile("results.n3","txt"); 
            f.deleteOnExit();
            log("Writing the statements to file: (" + f.getAbsolutePath() + ")");
            RDFHandler ntw = new NTriplesWriter(new FileOutputStream(f));
            con.exportStatements(kingsleyidehen, name, null, false, ntw);
            assertTrue("File "+f.getAbsolutePath()+" wasn't created", f.exists());


            RepositoryResult<Resource> contexts = null;
            // test retrieve graph ids
            log("Retrieving graph ids");
            contexts = con.getContextIDs();
            assertTrue("contexts list is EMPTY", contexts.hasNext());
            while (contexts.hasNext()) {
                Value id = contexts.next();
                if ((id instanceof Literal))
                    log("Literal value for graphid found: (" + ((Literal) id).getLabel() + ")");
            }

            // test get size
            log("Retrieving triple store size");
            long sz = con.size(context);
            assertTrue("Graph size must be > 0", (sz > 0));

            // do ask
            boolean result = false;
            log("Sending ask query");
            query = "ASK FROM <" + context + "> {?s <http://myopenlink.net/foaf/name> ?o}";
            result = doBooleanQuery(con, query);
            assertTrue(" ASK must return TRUE", result);

            // do construct
            Graph g;
            boolean statementFound = false;
            log("Sending construct query");
            query = "CONSTRUCT {?s <http://myopenlink.net/mlo/handle> ?o} FROM <" + context + "> WHERE {?s <http://myopenlink.net/foaf/name> ?o}";
            g = doGraphQuery(con, query);
            Iterator<Statement> it = g.iterator();
            statementFound = true;
            while (it.hasNext()) {
                Statement st = it.next();
                if (!st.getPredicate().stringValue().equals("http://myopenlink.net/mlo/handle"))
                    statementFound = false;
            }
            assertTrue("CONSTRUCT return EMPTY graph", (g.size() > 0));

            // do describe
            statementFound = false;
            log("Sending describe query");
            query = "DESCRIBE ?s FROM <" + context + "> WHERE {?s <http://myopenlink.net/foaf/name> ?o}";
            g = doGraphQuery(con, query);
            Iterator<Statement> it1 = g.iterator();
            statementFound = it1.hasNext();
            assertTrue("DESCRIBE returns EMPTY resultSet", statementFound);


        } finally {
            if (con != null)
                con.close();
        }
    }


    @Test
    public void test6() throws Exception {
        RepositoryConnection con = null;
        try {
            // test add data to the repository
            IRI context = repository.getValueFactory().createIRI(ctx);
            Value[][] results = null;

            con = repository.getConnection();

            // test getNamespace
            Namespace testns = null;
            RepositoryResult<Namespace> namespaces = null;
            boolean hasNamespaces = false;

            namespaces = con.getNamespaces();
            while (namespaces.hasNext()) {
                Namespace ns = namespaces.next();
                // LOG("Namespace found: (" + ns.getName() + " " + ns.getPrefix() + ")");
                testns = ns;
            }

            
            // test getNamespaces and RepositoryResult implementation
            log("Retrieving namespaces");
            if (testns != null) {
                // LOG("Retrieving namespace (" + testns.getName() + " " + testns.getPrefix() + ")");
                String ns = con.getNamespace(testns.getPrefix());
                assertTrue("con.getNamespace('"+testns.getPrefix()+"') doesn't return Namespace", ns!=null);
            }
        } finally {
            if (con != null)
                con.close();
        }
    }





    private static boolean doBooleanQuery(RepositoryConnection con, String query) throws RepositoryException, MalformedQueryException, QueryEvaluationException {
        BooleanQuery resultsTable = con.prepareBooleanQuery(QueryLanguage.SPARQL, query);
        return resultsTable.evaluate();
    }

    private static Value[][] doTupleQuery(RepositoryConnection con, String query) throws RepositoryException, MalformedQueryException, QueryEvaluationException {
        return doTupleQuery(con, query, new HashMap<String, Value>());
    }

    private static Value[][] doTupleQuery(RepositoryConnection con, String query, HashMap<String, Value> bind) throws RepositoryException, MalformedQueryException, QueryEvaluationException {
        TupleQuery resultsTable = con.prepareTupleQuery(QueryLanguage.SPARQL, query);
        Set<String> keys = bind.keySet();
        for (String bindName : keys) {
            resultsTable.setBinding(bindName, bind.get(bindName));
        }
        TupleQueryResult bindings = resultsTable.evaluate();
        Vector<Value[]> results = new Vector<Value[]>();
        for (int row = 0; bindings.hasNext(); row++) {
            // System.out.println("RESULT " + (row + 1) + ": ");
            BindingSet pairs = bindings.next();

            List<String> names = bindings.getBindingNames();
            Value[] rv = new Value[names.size()];
            for (int i = 0; i < names.size(); i++) {
                String name = names.get(i);
                Value value = pairs.getValue(name);
                rv[i] = value;
                // if(column > 0) System.out.print(", ");
                // System.out.println("\t" + name + "=" + value);
                // vars.add(value);
                // if(column + 1 == names.size()) System.out.println(";");
            }
            results.add(rv);
        }
        return (Value[][]) results.toArray(new Value[0][0]);
    }

    private static Graph doGraphQuery(RepositoryConnection con, String query) throws RepositoryException, MalformedQueryException, QueryEvaluationException {
        GraphQuery resultsTable = con.prepareGraphQuery(QueryLanguage.SPARQL, query);
        GraphQueryResult statements = resultsTable.evaluate();
        Graph g = new GraphImpl();

        Vector<Value[]> results = new Vector<Value[]>();
        for (int row = 0; statements.hasNext(); row++) {
            Statement pairs = statements.next();
            g.add(pairs);
//			List<String> names = statements.getBindingNames();
//			Value[] rv = new Value[names.size()];
//			for (int i = 0; i < names.size(); i++) {
//				String name = names.get(i);
//				Value value = pairs.getValue(name);
//				rv[i] = value;
//			}
//			results.add(rv);
        }
//		return (Value[][]) results.toArray(new Value[0][0]);
        return g;
    }

}

