/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/examples/MessageCreatorExample.java-arc   1.1   Oct 07 2003 14:51:06   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/examples/MessageCreatorExample.java-arc  $
 * 
 *    Rev 1.1   Oct 07 2003 14:51:06   goethalo
 * Changes for IT-9811 - Internet By Call with Registration
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.examples;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.Log4jConfig;
import net.arcor.fif.db.DatabaseConfig;
import net.arcor.fif.messagecreator.MessageCreator;
import net.arcor.fif.messagecreator.MessageCreatorConfig;
import net.arcor.fif.messagecreator.MessageCreatorFactory;
import net.arcor.fif.messagecreator.Request;
import net.arcor.fif.messagecreator.RequestFactory;
import net.arcor.fif.messagecreator.SimpleParameter;

import org.apache.log4j.Logger;

/**
 * Example application for the FIF MessageCreator.
 * This application illustrates how to create the different
 * types of messages.
 * @author goethalo
 */
public final class MessageCreatorExample {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger =
        Logger.getLogger(MessageCreatorExample.class);

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Message Creator example application.
     * @param args
     */
    public static void main(String[] args) {
        try {
            // Set the config file name
            String configFile = "examples/example-messagecreator";

            // Initialize the logger
            Log4jConfig.init(configFile);

            // Initialize the database
            DatabaseConfig.init(configFile);

            // Initialize the message creator
            MessageCreatorConfig.init(configFile);

            // Get the message creators
            MessageCreator mcXSQL =
                MessageCreatorFactory.getMessageCreator("findCustomer");
            MessageCreator mcXSLT =
                MessageCreatorFactory.getMessageCreator(
                    "findServiceSubscription");

            for (int i = 0; i < 1000; i++) {
                // XSQL
                Request request = RequestFactory.createRequest("findCustomer");
                request.addParam(
                    new SimpleParameter("customerNumber", "%" + i));
                mcXSQL.createMessage(request);

                // XSLT
                request =
                    RequestFactory.createRequest("findServiceSubscription");
                request.addParam(
                    new SimpleParameter("accessNumber", "1111;11;11" + i));
                request.addParam(new SimpleParameter("customerNumber", "111"));
                mcXSLT.createMessage(request);
            }
        } catch (FIFException fe) {
            // Print the exceptions.
            // Just in case that log4j did not initialize properly.
            fe.printStackTrace();
            logger.fatal(fe.getMessage());
        } finally {
            // Shut down message creator
            try {
                MessageCreatorConfig.shutdown();
            } catch (Exception e) {
                logger.fatal("Cannot shutdown message creator", e);                
            }
            // Shut down the database
            try {
                DatabaseConfig.shutdown();
            } catch (Exception e) {
                logger.fatal("Cannot shutdown database connection", e);
            }
        }
    }
}
