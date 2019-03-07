/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestFactory.java-arc   1.0   Apr 09 2003 09:34:42   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/RequestFactory.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import net.arcor.fif.common.FIFException;

/**
 * Factory for creating requests.
 * @author goethalo
 */
public class RequestFactory {

    /**
     * Creates a request for a given action name.
     * A new <code>Request</code> object of the proper subtype is returned.
     * @param action  the action to create the request for
     * @return a new <code>Request</code> object of the proper subtype.
     * @throws FIFException if the request could not be created.
     */
    public static Request createRequest(String action) throws FIFException {
        // Get the request class name
        ActionMapping mapping = MessageCreatorMetaData.getActionMapping(action);
        MessageCreatorDefinition creator =
            MessageCreatorMetaData.getMessageCreatorDefinition(
                mapping.getCreatorType());
        String requestClassName =
            MessageCreatorMetaData.getRequestClassName(
                creator.getInputRequestType());

        // Get the request class
        Class requestClass = null;
        try {
            requestClass = (Class.forName(requestClassName));
        } catch (ClassNotFoundException cnfe) {
            throw new FIFException(
                "Could not find class " + requestClassName,
                cnfe);
        }

        // Create a new request object
        Request request = null;
        try {
            request = (Request) requestClass.newInstance();
        } catch (Exception e) {
            throw new FIFException(
                "Could not create class " + requestClassName,
                e);
        }

        request.setAction(action);

        return request;
    }
}
