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
        } else if (args[0].equalsIgnoreCase("query")) {
            System.out.println("RDF4J queried repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.queryRecordCountInNativeRepo(Integer.parseInt(args[1]), args[2]) + " msecs");
        } else if (args[0].equalsIgnoreCase("load")) {
            System.out.println("RDF4J loaded file \"" + args[3] + "\" in repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.loadTRIGInNativeRepo(args[3], args[2], args[1]) + " msecs");
        } else if (args[0].equalsIgnoreCase("dirload")) {
            System.out.println("RDF4J loaded all files from \"" + args[3] + "\" in repo \"" + args[1] + "\" in " + Rdf4jSUT.RDF4J.loadTRIGDirInNativeRepo(args[3], args[2], args[1], Boolean.parseBoolean(args[4])) + " msecs");
        }
    }
}
