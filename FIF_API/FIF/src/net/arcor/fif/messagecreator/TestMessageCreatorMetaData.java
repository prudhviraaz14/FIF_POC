/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestMessageCreatorMetaData.java-arc   1.0   Apr 09 2003 09:34:44   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestMessageCreatorMetaData.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:44   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;

import net.arcor.fif.common.FIFException;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * JUnit test class for the MessageCreatorMetaData.
 * @author goethalo
 */
public class TestMessageCreatorMetaData extends TestCase {

    /**
     * Constructor for TestMessageCreatorMetaData
     * @param arg0
     */
    public TestMessageCreatorMetaData(String arg0) {
        super(arg0);
    }

    /**
     * Tests that the request definitions are parsed correctly.
     */
    public void testRequestDefinitionsPositive() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);


            // Parse the data
            MessageCreatorMetaData.init();

            // Ensure that the request definitions
            // parsed correctly
            String requestClass =
                MessageCreatorMetaData.getRequestClassName("FIF");

            assertTrue(requestClass.equals(
                "net.arcor.fif.messagecreator.FIFRequest"));
        } catch (FIFException mce) {
            mce.printStackTrace();
            if (mce.getDetail() != null)
                mce.getDetail().printStackTrace();
            fail("Parsing of request definitions should have succeeded");
        }
    }

    /**
     * Tests that a wrong request definition results in an error.
     */
    public void testRequestDefinitionsNegative() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-requestdef-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of request definition should have failed");
        } catch (FIFException mce) {
            // Exception caught. Success...
        }
    }

    /**
     * Tests that the message definitions are parsed correctly.
     */
    public void testMessageDefinitionsPositive() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // Ensure that the request definitions
            // parsed correctly
            String messageClass =
                MessageCreatorMetaData.getMessageClassName("FIF");

            assertTrue(messageClass.equals(
                "net.arcor.fif.messagecreator.FIFMessage"));
        } catch (FIFException mce) {
            fail("Parsing of message definitions should have succeeded");
        }
    }

    /**
     * Tests that a wrong message definition results in an error.
     */
    public void testMessageDefinitionsNegative() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-messagedef-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of message definition should have failed");
        } catch (FIFException mce) {
        }
    }

    /**
     * Tests that the message creation definitions are parsed correctly.
     */
    public void testMessageCreatorDefinitionsPositive() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // Ensure that the request creator definitions
            // parsed correctly
            MessageCreatorDefinition mcd =
                MessageCreatorMetaData.getMessageCreatorDefinition("xslt");

            assertTrue(mcd.getClassName().equals(
                "net.arcor.fif.messagecreator.XSLTMessageCreator"));

            // Ensure that the creator parameters parsed correctly
            ArrayList params = mcd.getParamNames();
            assertTrue(((String)params.get(0)).equals("filename"));
        } catch (FIFException mce) {
            fail("Parsing of message creator definitions should have succeeded");
        }
    }

    /**
     * Tests that a wrong message creator definition results in an error.
     */
    public void testMessageCreatorDefinitionsNegative() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-creatordef-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of message creator definition should have failed");
        } catch (FIFException mce) {
        }
    }

    /**
     * Tests that the action mappings are parsed correctly.
     */
    public void testActionMappingsPositive() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

        } catch (FIFException mce) {
            fail("Action mapping parsing should have succeeded. " + mce);
        }
    }

    /**
     * Tests that wrong action mappings result in an error.
     */
    public void testActionMappingsNegative() {
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-actionmapping1-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of action mapping should have failed (part 1)");
        } catch (FIFException fe) {
            // Test passed
        }
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-actionmapping2-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of action mapping should have failed (part 2)");
        } catch (FIFException fe) {
            // Test passed
        }
        try {
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-wrong-actionmapping3-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);

            // Parse the data
            MessageCreatorMetaData.init();

            // This should have thrown an exception
            fail("Parsing of action mapping should have failed (part 3)");
        } catch (FIFException fe) {
            // Test passed
        }
    }

    /**
     * Defines the tests of this class as members of the test suite.
     * @return Test
     */
    public static Test suite() {
        return new TestSuite(TestMessageCreatorMetaData.class);
    }

}

