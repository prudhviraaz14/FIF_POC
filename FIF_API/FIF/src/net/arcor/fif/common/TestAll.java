/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/TestAll.java-arc   1.0   Apr 09 2003 09:34:32   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/TestAll.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * Runs all the tests of the common package.
 * @author goethalo
 */
public class TestAll {

    public static Test suite() {
        TestSuite suite = new TestSuite("Test for net.arcor.fif.common");
        //$JUnit-BEGIN$
        suite.addTest(new TestSuite(TestCryptoUtils.class));
        //$JUnit-END$
        return suite;
    }
}
