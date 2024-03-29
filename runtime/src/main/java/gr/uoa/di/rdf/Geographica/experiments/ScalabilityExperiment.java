/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (C) 2013, Pyravlos Team
 *
 */
package gr.uoa.di.rdf.Geographica.experiments;

import java.io.IOException;

import gr.uoa.di.rdf.Geographica.queries.ScalabilityQueriesSet;
import gr.uoa.di.rdf.Geographica.systemsundertest.SystemUnderTest;

import org.apache.log4j.Logger;

/**
 * @author Theofilos Ioannidis <tioannid@di.uoa.gr>
 */
public class ScalabilityExperiment extends Experiment {

    public ScalabilityExperiment(SystemUnderTest sut, int repetitions, int timeoutSecs, String logPath) throws IOException {
        this(sut, repetitions, timeoutSecs, null, logPath);
    }

    public ScalabilityExperiment(SystemUnderTest sut, int repetitions, int timeoutSecs, int[] queriesToRun, String logPath) throws IOException {
        // TODO - Create repository with scalabilityN 
        super(sut, repetitions, timeoutSecs, queriesToRun, logPath);
        logger = Logger.getLogger(ScalabilityExperiment.class.getSimpleName());
        queriesSet = new ScalabilityQueriesSet(sut);
    }
}
