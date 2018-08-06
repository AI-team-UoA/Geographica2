/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica2.queries;

import gr.uoa.di.rdf.Geographica2.systemsundertest.SystemUnderTest;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.log4j.Logger;

/**
 * @author Theofilos Ioannidis <tioannid@di.uoa.gr>
 */
public class ScalabilityQueriesSet extends QueriesSet {

    static Logger logger = Logger.getLogger(ScalabilityQueriesSet.class.getSimpleName());

    // Template to create spatial selection queries
    private final String spatialSelectionQryTemplate = prefixes
            + "\n select ?s1 ?o1 where { \n"
            + " ?s1 ASWKT1 ?o1 . \n"
            + "  FILTER(geof:FUNCTION(?o1, GIVEN_SPATIAL_LITERAL)). "
            + "}  \n";

    private String spatialJoinQryTemplate = prefixes
            + "\n select ?s1 ?s2 where { \n"
            + " ?s1 ASWKT1 ?o1 . \n"
            + " ?s2 ASWKT2 ?o2} . \n"
            + " FILTER(?s1 != ?s2). \n"
            + " FILTER(geof:FUNCTION(?o1, ?o2)). \n"
            + "} \n";

    private String givenPolygonFile = "givenPolygonVrilissia.txt";
    private String givenPolygon;
    private String spatialDatatype = "<http://www.opengis.net/ont/geosparql#wktLiteral>";
    private String givenPoint = "\"POINT(-52.33052551746367 4.939113845399675)\"^^" + spatialDatatype; // somewhere in French Guyane
    
    public ScalabilityQueriesSet(SystemUnderTest sut) throws IOException {
        super(sut);
        // redefine the prefixes to include just the necessary prefixes
        prefixes = "PREFIX geof: <http://www.opengis.net/def/function/geosparql/> \n"
                + "PREFIX geo: <http://www.opengis.net/ont/geosparql#> \n"
                + "PREFIX ext: <http://rdf.useekm.com/ext#> \n"
                + "\n";
        queriesN = 2; // IMPORTANT: Add/remove queries in getQuery implies changing queriesN

        // read static Polygon from external file which might be used in spatial selection queries
        InputStream is = getClass().getResourceAsStream("/" + givenPolygonFile);
        BufferedReader in = new BufferedReader(new InputStreamReader(is));
        givenPolygon = in.readLine();
        givenPolygon = "\"" + givenPolygon + "\"^^" + spatialDatatype;
        in.close();
        in = null;
        is.close();
        is = null;
    }

    @Override
    public QueryStruct getQuery(int queryIndex, int repetition) {

        String query = null, label = null;

        // IMPORTANT: Add/remove queries in getQuery implies changing queriesN and changing case numbers
        switch (queryIndex) {

            case 0:
                // SC1 - Find all polygons of CORINE_2012 that spatially intersect with a given point
                label = "SC1_Intersects_Corine_GivenPoint";
                query = spatialSelectionQryTemplate;
                query = query.replace("ASWKT1", default_asWKT);
                query = query.replace("GIVEN_SPATIAL_LITERAL", givenPoint);
                query = query.replace("FUNCTION", "sfIntersects");
                break;

            case 1:
                // SC2 - Find all polygons of CORINE_2012 that spatially intersect with a given line
                label = "SC2_Corine_Polygons_Intersect";
                query = spatialJoinQryTemplate;
                query = query.replace("ASWKT1", default_asWKT);
                query = query.replace("ASWKT2", default_asWKT);
                query = query.replace("FUNCTION", "sfIntersects");
                break;

            default:
                logger.error("No such query number exists:" + queryIndex);
        }

        String translatedQuery = sut.translateQuery(query, label);
        return new QueryStruct(translatedQuery, label);
    }
}
