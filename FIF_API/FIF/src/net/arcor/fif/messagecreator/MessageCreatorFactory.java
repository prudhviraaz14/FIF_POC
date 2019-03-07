/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorFactory.java-arc   1.0   Apr 09 2003 09:34:38   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/MessageCreatorFactory.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.FIFException;

/**
 * Factory for creating message creators.
 * @author goethalo
 */
public class MessageCreatorFactory {

    /**
     * The map containing the creators.
     */
    private static Map creators = new HashMap();

    /**
     * Gets a message creator for a given action.
     * The <code>MessageCreator</code> object of the proper subtype
     * is returned.
     * @param action  the action to create the message creator for
     * @return a new <code>MessageCreator</code> object of the proper subtype.
     * @throws FIFException if the message creator could not be
     * created.
     */
    public static MessageCreator getMessageCreator(String action)
        throws FIFException {
        // Check if the creator exists in the map already
        MessageCreator mappedCreator = (MessageCreator)creators.get(action);

        // The creator exists already. Return it.
        if (mappedCreator != null) {
            return mappedCreator;
        }

        // The creator does not exist.  Create a new instance and add it
        // to the map
        synchronized (creators) {
            // Get the request class name
            ActionMapping mapping = MessageCreatorMetaData.getActionMapping(action);
            MessageCreatorDefinition creator =
                MessageCreatorMetaData.getMessageCreatorDefinition(
                    mapping.getCreatorType());
            String creatorClassName = creator.getClassName();

            // Get the message creator class
            Class creatorClass = null;
            try {
                creatorClass = (Class.forName(creatorClassName));
            } catch (ClassNotFoundException cnfe) {
                throw new FIFException(
                    "Could not find class " + creatorClassName,
                    cnfe);
            }

            // Create a new message creator object
            MessageCreator messageCreator = null;
            try {
                Class[] params = new Class[1];
                params[0] = String.class;
                Constructor constructor = creatorClass.getConstructor(params);
                Object[] param = new Object[1];
                param[0] = action;
                messageCreator = (MessageCreator) constructor.newInstance(param);
            } catch (Exception e) {
                throw new FIFException(
                    "Could not create class " + creatorClassName,
                    e);
            }

            // Add the creator to the map
            creators.put(action, messageCreator);

            // Return the message creator object
            return messageCreator;
        }
    }
}
