/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestAll.java-arc   1.0   Apr 09 2003 09:34:48   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestAll.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * Runs all the tests of the transport package.
 * @author goethalo
 */
public class TestAll {

    public static void main(String[] args) {
        junit.swingui.TestRunner.run(TestAll.class);
    }

    public static Test suite() {
        TestSuite suite = new TestSuite("Test for net.arcor.fif.transport");
        //$JUnit-BEGIN$
        suite.addTest(TestMQJMSClient.suite());
        suite.addTest(TestTransportManager.suite());
        //$JUnit-END$
        return suite;
    }
}
