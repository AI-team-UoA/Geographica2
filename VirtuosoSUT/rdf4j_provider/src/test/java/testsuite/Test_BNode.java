/*
 *  $Id$
 *
 *  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 *  project.
 *
 *  Copyright (C) 1998-2016 OpenLink Software
 *
 *  This project is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; only version 2 of the License, dated June 1991.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */

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

import java.net.URL;
import java.util.*;

import org.eclipse.rdf4j.model.*;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryResult;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.model.impl.ContextStatementImpl;


@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class Test_BNode extends TestBase {


    @Test
    public void test1() throws Exception {
        Test_OneRow(false);
    }

    @Test
    public void test2() throws Exception {
        Test_OneRow(true);
    }

    @Test
    public void test3() throws Exception {
        Test_Batch(false);
    }

    @Test
    public void test4() throws Exception {
        Test_Batch(true);
    }

    @Test
    public void test5() throws Exception {
        Test_ImportFromFile(false);
    }

    @Test
    public void test6() throws Exception {
        Test_ImportFromFile(false);
    }



    public void Test_OneRow(boolean insertBNodeAsIRI)  throws Exception {

        repository.setInsertBNodeAsVirtuosoIRI(insertBNodeAsIRI);
        RepositoryConnection con = null;
        boolean rc;

        try {
            con = repository.getConnection();

            // test add data to the repository
            boolean ok = true;
            String query = null;
            RepositoryResult<Statement> rs;
            Statement st;
            ValueFactory vfac = repository.getValueFactory();
            IRI context = vfac.createIRI("test:blank");
            Object o;

            con.clear(context);

            // Data for one row operation
            BNode bn1 = vfac.createBNode();//"a1");
            BNode bn2 = vfac.createBNode();//"a2");
            IRI ns1 = repository.getValueFactory().createIRI("t:s1");
            IRI np = repository.getValueFactory().createIRI("t:p");
            IRI no = repository.getValueFactory().createIRI("t:o1");

            if (insertBNodeAsIRI)
                log("Test with One Row operation (BNode as Virtuoso IRI)");
            else
                log("Test with One Row operation (BNode as Virtuoso Native BNode)");


            log("Insert data with BNodes");

            con.add(ns1, np, bn1, context);
            con.add(bn2, np, no, context);

            log("Inserted data:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();


            rs = con.getStatements(ns1, np, null, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            o = st.getObject();
            assertTrue("Value must be BNode", (o instanceof BNode));
            bn1 = (BNode)o;
            log("Got bn1="+bn1);

            rs = con.getStatements(null, np, no, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            o = st.getSubject();
            assertTrue("Value must be BNode", (o instanceof BNode));
            bn2 = (BNode)o;
            log("Got bn2="+bn2);
            assertNotEquals("Error bn1 == bn2", bn1, bn2);


            log("Try hasStatement with BNodes");

            rc = con.hasStatement(ns1, np, bn1, false, context);
            assertTrue("hasStatement return FALSE for bn1", rc);
            log("hasStatement with bn1 OK");

            rc = con.hasStatement(bn2, np, no, false, context);
            assertTrue("hasStatement return FALSE for bn2", rc);
            log("hasStatement with bn2 OK");



            log("Try getStatements with BNodes");

            rs = con.getStatements(ns1, np, bn1, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), ns1);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np);
            assertEquals("Wrong value in Object", st.getObject(), bn1);
            log("getStatements with bn1 OK");


            rs = con.getStatements(bn2, np, no, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), bn2);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np);
            assertEquals("Wrong value in Object", st.getObject(), no);
            log("getStatements with bn2 OK");


            log("Try remove with BNodes");

            con.remove((Resource)ns1, np, bn1, context);

            log("After remove triple:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();

            rc = con.hasStatement(ns1, np, bn1, false, context);
            assertFalse("Triple with bn1 wasn't removed", rc);
            log("remove with bn1 OK");


            con.remove((Resource)bn2, np, no, context);
            log("After remove triple:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();

            rc = con.hasStatement(bn2, np, no, false, context);
            assertFalse("Triple with bn2 wasn't removed", rc);
            log("remove with bn2 OK");


            if (!insertBNodeAsIRI) {
                log("Insert data with BNode bn1 again (new BNode ID must be assigned)");

                con.add(ns1, np, bn1, context);

                log("Inserted data:");
                rs = con.getStatements(null, null, null, false, context);
                while (rs.hasNext()) {
                    log(rs.next().toString());
                }
                rs.close();

                rs = con.getStatements(ns1, np, null, false, context);
                assertTrue("ResultSet is EMPTY", rs.hasNext());
                st = rs.next();
                o = st.getObject();
                assertTrue("Value must be BNode", (o instanceof BNode));
                BNode bnew = (BNode)o;
                log("Got bnew="+bnew);

                assertNotEquals("Error bn1 == bnew", st.getSubject(), bn2);
            }

        }
        finally {
            if (con != null)
                con.close();
        }
    }


    public static void Test_Batch(boolean insertBNodeAsIRI) throws Exception {

        repository.setInsertBNodeAsVirtuosoIRI(insertBNodeAsIRI);

        RepositoryConnection con = null;
        try {
            con = repository.getConnection();

            // test add data to the repository
            String query = null;
            RepositoryResult<Statement> rs;
            Statement st;
            ValueFactory vfac = repository.getValueFactory();
            IRI context = vfac.createIRI("test:blank");
            Object o;
            ArrayList<Statement> arr;

            con.clear(context);

            // Data for one row operation
            BNode ba = vfac.createBNode();//"a");
            BNode bb = vfac.createBNode();//"b");
            IRI np1 = repository.getValueFactory().createIRI("t:p1");
            IRI np2 = repository.getValueFactory().createIRI("t:p2");
            IRI np3 = repository.getValueFactory().createIRI("t:p3");
            IRI no1 = repository.getValueFactory().createIRI("t:o1");
            IRI no3 = repository.getValueFactory().createIRI("t:o3");

            // -------------------
            //  Try batch insert :
            //
            //  _:a  t:p1 t:o1
            //  _:a  t:p2 _:b
            //  _:b  t:p3 t:o3
            // -------------------

            if (insertBNodeAsIRI)
                log("Test with Batch Operation (BNode as Virtuoso IRI)");
            else
                log("Test with Batch Operation (BNode as Virtuoso Native BNode)");


            log("Insert data with BNodes");

            arr = new ArrayList<>();
            arr.add(new ContextStatementImpl(ba, np1, no1, context));
            arr.add(new ContextStatementImpl(ba, np2, bb, context));
            arr.add(new ContextStatementImpl(bb, np3, no3, context));

            con.add(arr, context);

            log("Inserted data:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();

            rs = con.getStatements(null, np1, no1, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            o = st.getSubject();
            assertTrue("Value must be BNode", (o instanceof BNode));
            ba = (BNode) o;
            log("Got ba=" + ba);

            rs = con.getStatements(null, np3, no3, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            o = st.getSubject();
            assertTrue("Value must be BNode", (o instanceof BNode));
            bb = (BNode) o;
            log("Got bb=" + bb);
            assertNotEquals("Error ba == bb", ba, bb);


            log("Try hasStatement with BNodes");
            boolean rc;

            rc = con.hasStatement(ba, np1, no1, false, context);
            assertTrue("hasStatement return FALSE for ba", rc);
            log("hasStatement with ba OK");

            rc = con.hasStatement(ba, np2, bb, false, context);
            assertTrue("hasStatement return FALSE for ba & bb", rc);
            log("hasStatement with ba & bb OK");

            rc = con.hasStatement(bb, np3, no3, false, context);
            assertTrue("hasStatement return FALSE for bb", rc);
            log("hasStatement with ba OK");


            log("Try getStatements with BNodes");

            rs = con.getStatements(ba, np1, no1, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), ba);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np1);
            assertEquals("Wrong value in Object", st.getObject(), no1);
            log("getStatements with ba OK");


            rs = con.getStatements(ba, np2, bb, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), ba);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np2);
            assertEquals("Wrong value in Object", st.getObject(), bb);
            log("getStatements with ba & bb OK");

            rs = con.getStatements(bb, np3, no3, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), bb);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np3);
            assertEquals("Wrong value in Object", st.getObject(), no3);
            log("getStatements with bn2 OK");


            log("Try remove with BNodes");

            arr = new ArrayList<>();
            arr.add(new ContextStatementImpl(ba, np1, no1, context));
            arr.add(new ContextStatementImpl(ba, np2, bb, context));

            con.remove(arr, context);

            log("After remove 2 triple:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();

            rc = con.hasStatement(ba, np1, no1, false, context);
            assertFalse("Triple with ba wasn't removed", rc);
            log("remove with ba OK");

            rc = con.hasStatement(ba, np2, bb, false, context);
            assertFalse("Triple with ba & bb wasn't removed", rc);
            log("remove with ba & bb OK");


            arr = new ArrayList<>();
            arr.add(new ContextStatementImpl(bb, np3, no3, context));

            con.remove(arr, context);

            log("After remove triple:");
            rs = con.getStatements(null, null, null, false, context);
            while (rs.hasNext()) {
                log(rs.next().toString());
            }
            rs.close();

            rc = con.hasStatement(bb, np3, no3, false, context);
            assertFalse("Triple with bb wasn't removed", rc);
            log("remove with bb OK");
        }
        finally {
            if (con != null) {
                con.close();
            }
        }
    }


    public static void Test_ImportFromFile(boolean insertBNodeAsIRI) throws Exception {

        repository.setInsertBNodeAsVirtuosoIRI(insertBNodeAsIRI);

        RepositoryConnection con = null;
        try {
            con = repository.getConnection();

            // test add data to the repository
            boolean ok = true;
            String query = null;
            RepositoryResult<Statement> rs;
            Statement st;
            ValueFactory vfac = repository.getValueFactory();
            IRI context = vfac.createIRI("test:blank");

            con.clear(context);

            IRI ns = repository.getValueFactory().createIRI("http://localhost/publications/journals/Journal3/1967");
            IRI np = repository.getValueFactory().createIRI("http://swrc.ontoware.org/ontology#editor");
            IRI np1 = repository.getValueFactory().createIRI("http://xmlns.com/foaf/0.1/name");


            if (insertBNodeAsIRI)
              log("Test Import data from File (BNode as Virtuoso IRI)");
            else
              log("Test Import data from File (BNode as Virtuoso Native BNode)");


            log("Insert data with BNodes from file sp2b.n3");

            ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
            URL dataFile = classLoader.getResource("sp2b.n3");

	        long start_time = System.currentTimeMillis();
	        con.begin();
	        con.add(dataFile, "", RDFFormat.N3, context);
   	        con.commit();
	        long end_time = System.currentTimeMillis();
 	        log("Time :"+(end_time-start_time)+" ms");

   	        long count = con.size(context);
 	        log("Inserted :"+count+" triples");



            log("Try getStatements with BNodes");

            rs = con.getStatements(ns, np, null, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            assertEquals("Wrong value in Subject", st.getSubject(), ns);
            assertEquals("Wrong value in Predicate", st.getPredicate(), np);

            BNode[] bn_arr = new BNode[3];
            bn_arr[0] = (BNode)st.getObject();
            assertTrue("ResultSet have not 2 row", rs.hasNext());

            st = rs.next();
            bn_arr[1] = (BNode)st.getObject();
            assertTrue("ResultSet have not 3 row", rs.hasNext());

            st = rs.next();
            bn_arr[2] = (BNode)st.getObject();
            rs.close();

            log("BNodes loaded OK");
            HashSet<String> data = new HashSet<String>();
            data.add("Rajab Sikora");
            data.add("Yukari Pitcairn");
            data.add("Reyes Kluesner");
            Object o_val;
            Literal l_val;

            rs = con.getStatements(bn_arr[0], np1, null, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            log("Got =["+st.getObject()+"]\n for BNode:"+bn_arr[0]+"\n");
            o_val = st.getObject();

            assertTrue(""+o_val+" must be Literal", (o_val instanceof Literal));

            l_val = (Literal)o_val;
            assertTrue("Wrong data was received ="+o_val, data.contains(l_val.getLabel()));
            data.remove(l_val.getLabel());
            rs.close();

            rs = con.getStatements(bn_arr[1], np1, null, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            log("Got =["+st.getObject()+"]\n for BNode:"+bn_arr[1]+"\n");
            o_val = st.getObject();

            assertTrue(""+o_val+" must be Literal", (o_val instanceof Literal));
            l_val = (Literal)o_val;
            assertTrue("Wrong data was received ="+o_val, data.contains(l_val.getLabel()));
            data.remove(l_val.getLabel());
            rs.close();

            rs = con.getStatements(bn_arr[2], np1, null, false, context);
            assertTrue("ResultSet is EMPTY", rs.hasNext());
            st = rs.next();
            log("Got =["+st.getObject()+"]\n for BNode:"+bn_arr[2]+"\n");
            o_val = st.getObject();

            assertTrue(""+o_val+" must be Literal", (o_val instanceof Literal));
            l_val = (Literal)o_val;
            assertTrue("Wrong data was received ="+o_val, data.contains(l_val.getLabel()));
            data.remove(l_val.getLabel());
            rs.close();

        }
        finally {
            if (con != null) {
                con.close();
            }
        }
    }

}
