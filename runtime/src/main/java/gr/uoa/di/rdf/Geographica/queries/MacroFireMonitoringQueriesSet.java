/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.queries;

import gr.uoa.di.rdf.Geographica.systemsundertest.StrabonSUT;
import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Random;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

/**
 * @author George Garbis <ggarbis@di.uoa.gr>
 */
public class MacroFireMonitoringQueriesSet extends QueriesSet {

	static Logger logger = Logger.getLogger(MacroFireMonitoringQueriesSet.class.getSimpleName());
	
	List<String> timestamps = null;
	private String timestamp;
	private int queriesN; // IMPORTANT: Add/remove queries in getQuery implies changing queriesN
	Random rn;
	
	@SuppressWarnings("unchecked")
	public MacroFireMonitoringQueriesSet(SystemUnderTest sut) throws IOException {
		super(sut);
		String timestampsPath = "classes/timestamps.txt";
//		String timestampsPath = "src/main/resources/timestamps.txt";
		timestamps = (List<String>)FileUtils.readLines(new File(timestampsPath));
		rn = new Random(0);

		queriesN = 2;	
		
	}

	@Override
	public int getQueriesN() { return queriesN; }
	
	@Override
	public QueryStruct getQuery(int queryIndex, int repetition) {
		
		String query = null, label = null;
		
		// IMPORTANT: Add/remove queries in getQuery implies changing queriesN and changing case numbers
		switch (queryIndex) {
	
			case 0:	
				
				String temp = timestamps.get(rn.nextInt(timestamps.size()));
				this.timestamp = temp.split("\t")[0];
				
				//Q1 Associate Municipality
				query = prefixes
					+ "INSERT {GRAPH <"+hotspots+"> { ?h gag:hasMunicipality ?mun }} \n"
					+ "WHERE { \n"
					+ "SELECT ?h (SAMPLE(?mLabel) AS ?mun) \n"
					+ "  WHERE { \n"
					+ "   GRAPH <"+hotspots+"> {"
					+ "    ?h rdf:type noa:Hotspot ; \n"
					+ "	      "+hotspots_hasGeometry+" ?hGeo ; \n"
					+ "       noa:hasAcquisitionTime "+this.timestamp+"^^xsd:dateTime. \n"
					+ "    ?hGeo "+hotspots_asWKT+" ?hGeoWKT . \n"
					+ "   } \n"
					+ "   GRAPH <"+gadm+"> { \n" 
					+ "      ?m rdf:type gag:Δήμος ; \n"
					+ "         rdfs:label ?mLabel ; \n"
					+ "         "+gadm_hasGeometry+" ?mGeo . \n"
					+ "      ?mGeo "+gadm_asWKT+" ?mGeoWKT . \n"
					+ "   } \n"
					+(sut instanceof StrabonSUT?
					"    FILTER(strdf:intersects(?hGeoWKT, ?mGeoWKT)) . \n"
					:"    FILTER(geof:sfIntersects(?hGeoWKT, ?mGeoWKT)) . \n"
					)
					+ "  } \n"
					+ "  GROUP BY ?h \n"
					+ "} \n"
				;
				label = "AssociateMunicipality";
				break;

			case 1:
				//Q2 Delete sea hotspots
				query = prefixes
					+ "INSERT {GRAPH <"+hotspots+"> {?hGeo noa:isDiscarded \"1\"^^xsd:integer.} } \n"
					+ "WHERE { \n"
					+ " GRAPH <"+hotspots+"> { \n"
					+ "  ?h rdf:type noa:Hotspot ; \n"
					+ "     noa:hasAcquisitionTime "+this.timestamp+"^^xsd:dateTime ; \n"
					+ "     "+hotspots_hasGeometry+" ?hGeo . \n"
					+ "  ?hGeo "+hotspots_asWKT+" ?hGeoWKT . \n"
					+ "  OPTIONAL { ?h gag:hasMunicipality ?mun . } \n"
					+ "  FILTER(!bound(?mun)) . \n"
					+ "} } \n"
				;
				label = "DeleteSeaHotspots";
				break;

			case 2:
				//Q3 Refine Partial Sea Hotspots
				query = prefixes
					+ "INSERT { GRAPH <"+hotspots+"> { ?hGeo noa:isDiscarded \"1\"^^xsd:integer . \n"
					+ "                                ?hGeoNew "+hotspots_asWKT+" ?diff } } \n"
					+ "WHERE { \n" 
					+ "  SELECT  ?hGeo (strdf:intersection(?hGeoWKT, strdf:union(?cGeoWKT)) AS ?dif) (URI(CONCAT(str(?hGeo), \"refined\")) AS ?hGeoNew) \n"
					+ "  WHERE {  \n"
					+ "    GRAPH <"+hotspots+"> { \n"
					+ "      ?h rdf:type noa:Hotspot ; \n"
					+ "         noa:hasAcquisitionTime "+this.timestamp+"^^xsd:dateTime;  \n"
					+ "    	    "+hotspots_hasGeometry+" ?hGeo . \n"
					+ "      ?hGeo "+hotspots_asWKT+" ?hGeoWKT . \n"
					+ "    } \n"
					+ "    GRAPH <"+gadm+"> { \n"
					+ "      ?c  rdf:type gag:GeometryPart ; \n"
					+ "    	     "+gadm_hasGeometry+" ?cGeo . \n" 
					+ "      ?cGeo "+gadm_asWKT+" ?cGeoWKT . \n"
					+ "    } \n"
					+ "    FILTER(strdf:mbbIntersects(?hGeoWKT, ?cGeoWKT)) . \n"
					+ "  } \n"
					+ "  GROUP BY ?hGeo \n"
					+ "  HAVING strdf:overlaps(?hGeoWKT, strdf:union(?cGeoWKT)) \n"
					+ "} \n"
				;
				label = "RefineCoastHotspots";
				break;
				
			default:
				logger.error("No such query number exists:"+queryIndex);
		}
		
		return new QueryStruct(query, label);
	}
	
}
