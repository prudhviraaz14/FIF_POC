/*
 * $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/SendMessage.java-arc   1.2   Aug 02 2004 15:26:12   goethalo  $
 *
 * $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/SendMessage.java-arc  $
 * 
 *    Rev 1.2   Aug 02 2004 15:26:12   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.1   Mar 02 2004 11:18:36   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 */
package net.arcor.fif.apps;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.transport.MessageSender;
import net.arcor.fif.transport.TransportManager;

import org.apache.log4j.Logger;

/**
 * This application sends a message to a queue.
 * <b>Usage:</b>
 * <code>java net.arcor.fif.apps.SendMessage <i>filename.xml</i></code>
 * <b>Property file</b>
 * The property file is defaulted to SendMessage.
 * The <code>fif.propertyfile</code> system property can be set to another property
 * file if needed.
 * To do this the following syntax can be used for starting the application:
 * <code>java -Dfif.propertyfile=AnotherFile net.arcor.fif.apps.SendMessage
 * <i>filename.xml</i> <i>[-queue queueAlias]</i></code>
 * Where <i>queuename</i> is the alias name of the queue to put the message in. 
 *  
 * @author goethalo
 */
public class SendMessage {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(SendMessage.class);

    /**
     * Initializes the application.
     * @throws FIFException
     */
    private static void init(String configFile) throws FIFException {
        // Initialize the logger
        Log4jConfig.init(configFile);

        logger.info(
            "Initializing application with property file "
                + configFile
                + "...");

        // Initialize the transport manager if the message should be sent
        TransportManager.init(configFile);

        logger.info("Successfully initialized application.");
    }

    /**
     * Shuts down the application.
     * @throws FIFException
     */
    private static void shutdown() {
        boolean success = true;
        logger.info("Shutting down application...");
        try {
            // Shut down the transport manager if needed
            TransportManager.shutdown();
        } catch (Exception e) {
            success = false;
            logger.error("Cannot shutdown transport manager", e);
        }

        if (success) {
            logger.info("Successfully shut down application.");
        } else {
            logger.error("Errors while shutting down application.");
        }
    }

    /**
     * Prints the usage of this application on the stdout.
     */
    private static void usage() {
        System.out.println("SendMessage: Sends a message to the queue.");
        System.out.println(
            "\nUsage: SendMessage filename.xml [-queue queueAlias]");
        System.out.println(
            "Where queueAlias is the alias name of the queue to put the message in.");
        System.exit(0);
    }

    /**
     * Main.
     */
    public static void main(String[] args) {
        if ((args.length != 1) && (args.length != 3)) {
            usage();
        }

        String fileName = args[0];

        // Get the queue name
        String queue = "outqueue";
        if (args.length == 3) {
            if (args[1].startsWith("-queue")) {
                queue = args[2];
            } else {
                usage();
            }
        }

        // Set the config file name
        String configFile = "SendMessage.properties";
        if (System.getProperty("fif.propertyfile") != null) {
            configFile = System.getProperty("fif.propertyfile");
        }

        try {
            // Initialize the application
            init(configFile);

            // Create the request
            BufferedReader in = new BufferedReader(new FileReader(fileName));
            StringBuffer sb = new StringBuffer();
            String line = null;
            do {
                line = in.readLine();
                if (line != null) {
                    sb.append(line);
                    sb.append("\n");
                }
            } while (line != null);

            // Send the message, if needed
            MessageSender sender = TransportManager.createSender(queue);
            sender.start();
            sender.sendMessage(sb.toString());
            sender.shutdown();
            logger.info(
                "Sent message to queue "
                    + queue
                    + " ("
                    + sender.getJmsClient().getQueueName()
                    + ")...");
        } catch (FIFException e) {
            logger.fatal("Cannot send message.", e);
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            logger.fatal("File not found.", e);
            e.printStackTrace();
        } catch (IOException e) {
            logger.fatal("Cannot read file", e);
            e.printStackTrace();
        } finally {
            shutdown();
        }
    }
}
