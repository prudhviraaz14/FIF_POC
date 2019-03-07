/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestAll.java-arc   1.0   Apr 09 2003 09:34:44   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestAll.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:44   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.Log4jConfig;
import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * Runs all JUnit tests for this component
 * @author goethalo
 */
public class TestAll {

    public static void main(String[] args) {
        junit.swingui.TestRunner.run(TestAll.class);
    }

    static {
        // Initialize
        try {
            Log4jConfig.init("test/test-messagecreator");
            MessageCreatorConfig.init("test/test-messagecreator");
        } catch (Exception e) {
        }
    }

    public static Test suite() {
        TestSuite suite =
            new TestSuite("Test for net.arcor.fif.messagecreator");
        //$JUnit-BEGIN$
        suite.addTest(TestMessageCreatorMetaData.suite());
        suite.addTest(TestMessageCreator.suite());
        suite.addTest(TestFIFReplyMessage.suite());
        //$JUnit-END$
        return suite;
    }
}
