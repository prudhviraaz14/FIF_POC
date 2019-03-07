/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestMQJMSClient.java-arc   1.0   Apr 09 2003 09:34:48   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestMQJMSClient.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import java.util.ResourceBundle;

import javax.jms.QueueReceiver;
import javax.jms.QueueSender;

import net.arcor.fif.common.FIFException;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Tests the MQJMSSetup class.
 * @author goethalo
 */
public class TestMQJMSClient extends TestCase {
    /**
     * The setup object to be used by this test.
     */
    private static JMSClient jmsClient = null;

    /**
     * Constructor for TestMQJMSSetup.
     * @param arg0
     */
    public TestMQJMSClient(String arg0) {
        super(arg0);
    }

    /**
     * Tests the creation of a receiver
     */
    public void testCreateReceiver() {
        // Retrieve the information
        ResourceBundle config = ResourceBundle.getBundle("test/test-transport");

        // Create an jmsClient object with the data from the bundle
        jmsClient =
            new MQJMSClient(
                config.getString("transport.inqueue.QueueName"),
                false,
                config.getString("transport.inqueue.AcknowledgeMode"),
                config.getString("transport.inqueue.QueueManagerName"),
                config.getString("transport.inqueue.QueueManagerHostName"),
                config.getString("transport.inqueue.QueueManagerPortNumber"),
                config.getString("transport.inqueue.QueueManagerChannelName"),
                config.getString(
                    "transport.inqueue.QueueManagerTransportType"),
                config.getString("transport.inqueue.Encoding"));

        // Test
        try {
            jmsClient.setup();
            jmsClient.start();
            QueueReceiver rec = jmsClient.createReceiver();
            jmsClient.shutdown();
        } catch (FIFException fe) {
            fail("Could not create a receiver." + fe);
        }
    }

    /**
     * Tests the creation of a sender
     */
    public void testCreateSender() {
        // Retrieve the information
        ResourceBundle config = ResourceBundle.getBundle("test/test-transport");

        // Create an jmsClient object with the data from the bundle
        jmsClient =
            new MQJMSClient(
                config.getString("transport.outqueue.QueueName"),
                false,
                config.getString("transport.inqueue.AcknowledgeMode"),
                config.getString("transport.outqueue.QueueManagerName"),
                config.getString("transport.outqueue.QueueManagerHostName"),
                config.getString("transport.outqueue.QueueManagerPortNumber"),
                config.getString("transport.outqueue.QueueManagerChannelName"),
                config.getString(
                    "transport.outqueue.QueueManagerTransportType"),
                config.getString("transport.outqueue.Encoding"));

        // Test
        try {
            jmsClient.setup();
            jmsClient.start();
            QueueSender sender = jmsClient.createSender();
            jmsClient.shutdown();
        } catch (FIFException fe) {
            fail("Could not create a sender." + fe);
        }
    }

    /**
     * Defines the tests of this class as members of the test suite.
     * @return Test
     */
    public static Test suite() {
        return new TestSuite(TestMQJMSClient.class);
    }

}
