/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gr.uoa.di.rdf.Geographica2.graphdbsut;

/**
 *
 * @author Ioannidis Theofilos <tioannid@yahoo.com>
 * @since 19/02/2019
 * @description Perform GeoSPARQL plugin actions for the GraphDB repositories
 * @syntax 1: RepoUtil {plugin-enable | plugin-disable} <repodir>
 */
public abstract class RepoUtil {

    static String baseDirString;
    static String repoId;
    static int queryNo;
    public static void main(String[] args) throws Exception {
        if (args[0].equalsIgnoreCase("plugin-enable")) { // configure and enable GeoSPARQL plugin
            baseDirString = args[1];
            repoId = args[2];
            try {
            long t1 = GraphDBSUT.GraphDB.excGeoSPARQLDDLQuery(baseDirString, repoId, 1);
            System.out.println("GraphDB configured and enabled GeoSPARQL plugin for repo \"" + repoId + "\" in " + 
                   t1 + " msecs");
            } catch (Exception e) {
                System.out.println(e.getMessage());
            }
        } else if (args[0].equalsIgnoreCase("plugin-disable")) { // disable GeoSPARQL plugin
            baseDirString = args[1];
            repoId = args[2];
            System.out.println("GraphDB disabled GeoSPARQL plugin for repo \"" + repoId + "\" in " + 
                    (GraphDBSUT.GraphDB.excGeoSPARQLDDLQuery(baseDirString, repoId, 3) )+ " msecs");
        }
    }
}
