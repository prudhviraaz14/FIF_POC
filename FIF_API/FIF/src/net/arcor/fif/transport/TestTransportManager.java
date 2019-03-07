/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestTransportManager.java-arc   1.0   Apr 09 2003 09:34:48   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/transport/TestTransportManager.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:48   goethalo
 * Initial revision.
*/
package net.arcor.fif.transport;

import javax.jms.JMSException;
import javax.jms.Message;

import org.apache.log4j.Logger;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit tests for the TransportManager class
 * @author goethalo
 */
public class TestTransportManager extends TestCase {

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(TestTransportManager.class);

    /**
     * Constructor for TestTransportManager.
     * @param arg0
     */
    public TestTransportManager(String arg0) {
        super(arg0);
    }

    /**
     * Tests the transport manager.
     */
    public void testTransportManager() {
        String config = "test/test-transport";

        try {
            Log4jConfig.init(config);
            TransportManager.init(config);
            MessageReceiver receiver = TransportManager.createReceiver("inqueue");
            receiver.start();
            Message msg = null;
            do {
                msg = receiver.receiveMessageNoWait();
                if (msg != null) {
                    msg.acknowledge();
                    logger.info("received message: " + msg.toString());
                }


            } while (msg != null);

            TransportManager.createSender("outqueue");
            TransportManager.shutdown();
        } catch (FIFException fe) {
            fail("Could not initialize transport manager: " + fe);
        } catch (JMSException e) {
			fail("Could not acknowledge message");
		}

    }

    /**
     * Defines the tests of this class as members of the test suite.
     * @return Test
     */
    public static Test suite() {
        return new TestSuite(TestTransportManager.class);
    }

}
