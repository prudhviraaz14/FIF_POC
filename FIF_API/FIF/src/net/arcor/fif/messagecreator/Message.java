/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/Message.java-arc   1.4   Nov 25 2010 15:01:58   wlazlow  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/Message.java-arc  $
 * 
 *    Rev 1.4   Nov 25 2010 15:01:58   wlazlow
 * IT-k-29265
 * 
 *    Rev 1.3   May 13 2009 10:43:52   lejam
 * Added action member variable IT-24729,IT-25224
 * 
 *    Rev 1.2   Sep 19 2005 15:23:22   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.1   Jun 14 2004 15:43:08   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:36   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.IOException;
import java.io.StringReader;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.ParsingErrorHandler;

import org.apache.log4j.Logger;
import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Abstract base class for all message types.
 * @author goethalo
 */
public abstract class Message {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    protected static Logger logger = Logger.getLogger(Message.class);

    /**
     * The message text.
     */
    private String text = null;

    /**
     * The action the request is related to.
     */
    private String action = null;

    
    private String jmsReplyTo=null;
    private String jmsCorrelationId=null;
    /*-------------*
     * CONSTRUCTOR *
     *-------------*/

    /**
     * Constructor.
     */
    public Message() {
    }

    /**
     * Constructor.
     * @param text  the message text to set.
     */
    public Message(String text) {
        this.text = text;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Gets the XML document.
     * @return the XML document.
     */
    public Document getDocument() throws FIFException {
        try {
            DOMParser parser = new DOMParser();
            ParsingErrorHandler handler = new ParsingErrorHandler();
            parser.setErrorHandler(handler);
            parser.setEntityResolver(new EntityResolver());
            parser.parse(new InputSource(new StringReader(text)));

            if (handler.isError()) {
                logger.error(
                    "XML Parsing Errors while generating XML document "
                        + "for message: "
                        + text);
                throw new FIFException(
                    "XML parser reported the following errors:\n"
                        + handler.getErrors());
            }
            return (parser.getDocument());
        } catch (SAXException e) {
            throw new FIFException("Cannot parse message string " + text, e);
        } catch (IOException e) {
            throw new FIFException("Cannot parse message string " + text, e);
        }
    }

    /**
     * Sets the message text
     * @param text  the message text to set.
     */
    public void setMessage(String text) {
        this.text = text;
    }

    /**
     * Gets the message XML in text format.
     * @return the message XML string.
     */
    public String getMessage() throws FIFException {
        return text;
    }

	/**
     * Sets the action.
     * @param action The action to set
     */
    public void setAction(String action) throws FIFException {
        if ((action == null) || (action.trim().length() == 0)) {
            throw new FIFException(
                "Cannot set action because the passed "
                    + "in action is null or empty");
        }

        this.action = action;
    }

    /**
     * Returns the action.
     * @return String
     */
    public String getAction() {
        return action;
    }

	public String getJmsReplyTo() {
		return jmsReplyTo;
	}

	public void setJmsReplyTo(String jmsReplyTo) {
		this.jmsReplyTo = jmsReplyTo;
	}

	public String getJmsCorrelationId() {
		return jmsCorrelationId;
	}

	public void setJmsCorrelationId(String jmsCorrelationId) {
		this.jmsCorrelationId = jmsCorrelationId;
	}
}
