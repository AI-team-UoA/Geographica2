/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gr.uoa.di.rdf.Geographica2.rdf4jsut;

import org.eclipse.rdf4j.rio.RDFFormat;

/**
 *
 * @author Ioannidis Theofilos <tioannid@yahoo.com>
 * @since 08/05/2018
 * @description Perform all actions for the RDF4J repositories
 * @syntax 1: RepoUtil <create> <repodir>
 *         2: RepoUtil <load> <repodir> <RDFFormatString> <file>
 *         3: RepoUtil <dirload> <repodir> <trigfiledir> <printflag>
 */
public abstract class RepoUtil {

    public static void main(String[] args) throws Exception {
        if (args[0].equalsIgnoreCase("create")) {
            System.out.println("RDF4J created repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.createNativeRepo(args[1], (args.length==2)?"":args[2]) + " msecs");
        } else if (args[0].equalsIgnoreCase("createman")) {
            System.out.println("RDF4J created with manager repo \"" + args[1] + ":" + args[2] + "\" in " + Rdf4jSUT.RDF4J.createNativeRepoWithManager(args[1], args[2],  Boolean.parseBoolean(args[3]), (args.length==3)?"":args[4]) + " msecs");
        } else if (args[0].equalsIgnoreCase("query")) {
            System.out.println("RDF4J queried repo \"" + args[2] + "\" in " + Rdf4jSUT.RDF4J.queryRecordCountInNativeRepo(Integer.parseInt(args[1]), args[2]) + " msecs");
        } else if (args[0].equalsIgnoreCase("queryman")) {
            System.out.println("RDF4J queried with manager repo \"" + args[2] + "\" in " + Rdf4jSUT.RDF4J.queryNativeRepoWithManager(args[1], args[2], Integer.parseInt(args[3])) + " msecs");
        } else if (args[0].equalsIgnoreCase("load")) {
            System.out.println("RDF4J loaded file \"" + args[3] + "\" in repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.loadInNativeRepo(args[1], args[2], args[3]) + " msecs");
        } else if (args[0].equalsIgnoreCase("loadman")) {
            System.out.println("RDF4J loaded with manager file \"" + args[2] + "\" in repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.loadInNativeRepoWithManager(args[1], args[2], args[3], args[4]) + " msecs");
        } else if (args[0].equalsIgnoreCase("dirload")) {
            System.out.println("RDF4J loaded all files from \"" + args[3] + "\" in repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.loadDirInNativeRepo(args[1], args[2], args[3], Boolean.parseBoolean(args[4])) + " msecs");
        } else if (args[0].equalsIgnoreCase("dirloadman")) {
            System.out.println("RDF4J loaded with manager all files from \"" + args[3] + "\" in repo \"" + args[1] + ":" + args[2] + "\" in " + Rdf4jSUT.RDF4J.loadDirInNativeRepoWithManager(args[1], args[2], args[3], args[4], Boolean.parseBoolean(args[5])) + " msecs");
        }
    }
}
