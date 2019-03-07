/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFRequest.java-arc   1.3   Mar 11 2010 13:16:12   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFRequest.java-arc  $
 * 
 *    Rev 1.3   Mar 11 2010 13:16:12   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.1   Jun 14 2004 15:43:06   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.List;

/**
 * @author goethalo
 *
 */
public class FIFRequest extends Request {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     */
    public FIFRequest() {
        super();
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the transaction ID of the request.
     * @return the transaction ID of the request, null if the request has 
     * no transaction ID.
     */
    public String getTransactionID() {
        Parameter transactionIDParam = getParam("transactionID");
        if ((transactionIDParam == null)
            || !(transactionIDParam instanceof SimpleParameter)) {
            return null;
        } else {
            return (((SimpleParameter) transactionIDParam).getValue());
        }
    }


	// looks for a FIF parameter in a FIF request, which can be a single request or a request list
    public String getParameterValue(List<String> searchParameters) {
		String value = null;
		for (String name : searchParameters) {
			Parameter parameter = getParam(name);
			if (parameter != null && parameter instanceof SimpleParameter) {
				value = ((SimpleParameter) parameter).getValue();
				if (value != null)
					break;
			}
		}
		return value;
	}
    
}
