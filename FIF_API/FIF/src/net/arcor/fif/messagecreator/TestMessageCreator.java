/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestMessageCreator.java-arc   1.1   Jul 16 2003 15:00:56   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/TestMessageCreator.java-arc  $
 * 
 *    Rev 1.1   Jul 16 2003 15:00:56   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:44   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.db.DatabaseConfig;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * @author goethalo
 */
public class TestMessageCreator extends TestCase {

    private Logger logger = Logger.getLogger(TestMessageCreator.class);
    
    /**
     * Constructor for TestMessageCreator.
     * @param arg0
     */
    public TestMessageCreator(String arg0) {
        super(arg0);
    }

    /**
     * Tests the creation of a simple XSLT message
     */
    public void testMessageCreationSimpleXSLT() {
        try {
            logger.info("START TEST: testMessageCreationSimpleXSLT");
            // Initialize testcase
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);
            MessageCreatorMetaData.init();

            // Check the SIMPLE action
            // Create a Simple Request object
            Request req = RequestFactory.createRequest("simpleActionXSLT");

            // Populate the request
            req.addParam(new SimpleParameter("firstParameter", "value1"));

            // Get a message creator
            MessageCreator mc =
                MessageCreatorFactory.getMessageCreator(req.getAction());

            // Create the message
            mc.createMessage(req);
            
            logger.info("END TEST: testMessageCreationSimpleXSLT");
        } catch (FIFException mce) {
            logger.error("TEST FAILED: " , mce);
            fail("Could not create the message. " + mce);
        }
    }

    /**
     * Tests the creation of a complex XSLT message
     */
    public void testMessageCreationComplexXSLT() {
        try {
            logger.info("START TEST: testMessageCreationComplexXSLT");
            
            // Initialize testcase
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);
            MessageCreatorMetaData.init();

            // Check the COMPLEX action
            // Create a Complex Request object
            Request req = RequestFactory.createRequest("complexActionXSLT");

            // Populate the request
            // Add first param
            req.addParam(new SimpleParameter("firstParameter", "value1"));

            // Create second param and add it to request
            ParameterList list = new ParameterList("secondParameter");
            // Add 10 list items
            for (int i = 0; i < 10; i++) {
                ParameterListItem item = new ParameterListItem();
                item.addParam(new SimpleParameter("subParam1", "subValue1"));
                item.addParam(new SimpleParameter("subParam3", "subValue3"));
                list.addItem(item);
            }                
            req.addParam(list);

            // Add third param
            req.addParam(new SimpleParameter("thirdParameter", "value3"));

            // Create fourth param and add it to request
            list = new ParameterList("fourthParameter");
            // Add 10 list items
            for (int i = 0; i < 10; i++) {
                ParameterListItem item = new ParameterListItem();
                item.addParam(new SimpleParameter("subParam1", "subValue1"));
                ParameterList subList = new ParameterList("subParamList2");
                
                // Add 5 sublist items
                for (int j = 0; j < 5; j++) {
                    ParameterListItem subItem = new ParameterListItem();   
                    subItem.addParam(
                        new SimpleParameter("subsubParam1", "subsubValue1"));
                    subList.addItem(subItem);                        
                }                        
                item.addParam(subList);
                list.addItem(item);
            }       
            req.addParam(list);

            // Get a message creator
            MessageCreator mc =
                MessageCreatorFactory.getMessageCreator(req.getAction());

            // Create the message
            mc.createMessage(req);
            
            logger.info("END TEST: testMessageCreationComplexXSLT");
        } catch (FIFException mce) {
            logger.error("TEST FAILED: ", mce);
            fail("Could not create the message. " + mce);
        }
    }

    /**
     * Tests the creation of a simple XSQL message
     */
    public void testMessageCreationSimpleXSQL() {
        try {
            logger.info("START TEST: testMessageCreationSimpleXSQL");
            
            // Initialize testcase
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);
            MessageCreatorMetaData.init();
            DatabaseConfig.init("test/test-messagecreator");

            // Check the SIMPLE action
            // Create a Simple Request object
            Request req = RequestFactory.createRequest("simpleActionXSQL");

            // Populate the request
            req.addParam(new SimpleParameter("firstParameter", "value1"));

            // Get a message creator
            MessageCreator mc =
                MessageCreatorFactory.getMessageCreator(req.getAction());

            // Create the message
            mc.createMessage(req);
            
            logger.info("END TEST: testMessageCreationSimpleXSQL");
        } catch (FIFException mce) {
            logger.error("TEST FAILED: ", mce);
            fail("Could not create the message. " + mce);
        }
    }

    /**
     * Tests that the validation of mandatory fields on a request
     * is performed correctly.
     */
    public void testMessageCreatorValidation() {
        // SIMPLE ACTION TEST
        try {
            logger.info("START TEST: testMessageCreatorValidation");
            
            // Initialize testcase
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);
            MessageCreatorMetaData.init();

            // Create a Simple Request object and forget a mandatory filed
            Request req = RequestFactory.createRequest("simpleActionXSLT");

            // Populate an optional value
            req.addParam(new SimpleParameter("secondParameter", "value2"));

            // Get a message creator
            MessageCreator mc =
                MessageCreatorFactory.getMessageCreator(req.getAction());

            // Create the message
            mc.createMessage(req);

            fail("Message Creator validation test failed for Simple action");
        } catch (FIFException mce) {
            // Test passed
            logger.info("Validation failed as expected: ", mce);
        }

        // COMPLEX ACTION TEST
        try {
            // Initialize testcase
            MessageCreatorMetaData.setMetaDataFile(
                MessageCreatorConfig.getPath("messagecreator.MetaDataDir")
                    + "test-working-messagecreator-metadata.xml");
            MessageCreatorMetaData.setInitialized(false);
            MessageCreatorMetaData.init();

            // Create a Complex Request object
            Request req = RequestFactory.createRequest("complexActionXSLT");

            // Populate the request
            // Add first param
            req.addParam(new SimpleParameter("firstParameter", "value1"));

            // Create second param and add it to request
            ParameterList list = new ParameterList("secondParameter");
            for (int i = 0; i < 10; i++) {
                ParameterListItem item = new ParameterListItem();
                item.addParam(new SimpleParameter("subParam1", "subValue1"));
                item.addParam(new SimpleParameter("subParam3", "subValue3"));
                list.addItem(item);
            }                
            req.addParam(list);

            // Add third param
            req.addParam(new SimpleParameter("thirdParameter", "value3"));

            // Create fourth param and add it to request
            list = new ParameterList("fourthParameter");
            // Add 10 list items
            for (int i = 0; i < 10; i++) {
                ParameterListItem item = new ParameterListItem();
                item.addParam(new SimpleParameter("subParam1", "subValue1"));
                ParameterList subList = new ParameterList("subParamList2");
                item.addParam(subList);
                list.addItem(item);
            }       
            req.addParam(list);

            // Get a message creator
            MessageCreator mc =
                MessageCreatorFactory.getMessageCreator(req.getAction());

            // Create the message
            mc.createMessage(req);

            fail("Message Creator validation test failed for Complex action");
        } catch (FIFException mce) {
            logger.info("Validation failed as expected: ", mce);
        }

        logger.info("END TEST: testMessageCreatorValidation");
    }

    /**
     * Defines the tests of this class as members of the test suite.
     * @return Test
     */
    public static Test suite() {
        return new TestSuite(TestMessageCreator.class);
    }

}
