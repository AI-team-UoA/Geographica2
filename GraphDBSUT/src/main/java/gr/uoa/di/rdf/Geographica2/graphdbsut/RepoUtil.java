/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gr.uoa.di.rdf.Geographica2.graphdbsut;

import org.apache.log4j.Logger;

/**
 *
 * @author Ioannidis Theofilos <tioannid@yahoo.com>
 * @since 19/02/2019
 * @description Perform GeoSPARQL plugin actions for the GraphDB repositories
 * @syntax 1: RepoUtil <enableGeoSPAEQLPlugin={true | false}> <indexingAlgorith>
 * <indexingPrecision> <baseDir> <repoID>
 */
public abstract class RepoUtil {

    static Logger logger = Logger.getLogger(RepoUtil.class.getSimpleName());
    static String baseDir;
    static String repoID;
    static String indexingAlgorith;     // { quad | geohash }
    static int indexingPrecision;       // quad=(<=25) , geohash=(<=24)

    public static void main(String[] args) throws Exception {
        boolean enableGeoSPAEQLPlugin = Boolean.parseBoolean(args[0]);
        if (enableGeoSPAEQLPlugin) { // configure and enable GeoSPARQL plugin
            indexingAlgorith = args[1];
            indexingPrecision = Integer.parseInt(args[2]);
            baseDir = args[3];
            repoID = args[4];
            try {
                long t1 = GraphDBSUT.GraphDB.execGeoSPARQL_UpdateConfiguration(indexingAlgorith, indexingPrecision, baseDir, repoID);
                logger.info("GraphDB configured and enabled GeoSPARQL plugin for repo \"" + repoID + "\" in "
                        + t1 + " msecs");
                long t2 = GraphDBSUT.GraphDB.execGeoSPARQL_ForceReindex(baseDir, repoID);
                logger.info("GraphDB forced re-index GeoSPARQL plugin for repo \"" + repoID + "\" in "
                        + t2 + " msecs");
            } catch (Exception e) {
                System.out.println(e.getMessage());
            }
        } else if (!enableGeoSPAEQLPlugin) { // disable GeoSPARQL plugin
            baseDir = args[1];
            repoID = args[2];
            logger.info("GraphDB disabled GeoSPARQL plugin for repo \"" + repoID + "\" in "
                    + (GraphDBSUT.GraphDB.execGeoSPARQL_DisablePlugin(baseDir, repoID)) + " msecs");
        } 
    }
}
