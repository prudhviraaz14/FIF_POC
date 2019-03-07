/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSLTMessageCreator.java-arc   1.1   Jun 14 2004 15:43:12   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSLTMessageCreator.java-arc  $
 * 
 *    Rev 1.1   Jun 14 2004 15:43:12   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import net.arcor.fif.common.DOMSerializer;
import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;
import net.arcor.fif.common.XSLTErrorListener;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;

/**
 * This class converts requests to messages by using XSLT transformations.
 * @author goethalo
 */
public class XSLTMessageCreator extends FIFMessageCreator {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(XSLTMessageCreator.class);

    /**
     * The name of the XSLT file to process.
     */
    String xsltFileName = null;

    /**
     * The XSLT transformer.
     */
    private Transformer transformer = null;

    /**
     * The XSLT error listener.
     */
    private XSLTErrorListener listener = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @see java.lang.Object#Object()
     */
    public XSLTMessageCreator(String action) throws FIFException {
        super(action);
        init();
    }

    /**
     * Generates a message for a given request.
     * @see net.arcor.fif.messagecreator.MessageCreator#generateMessage(Request)
     */
    protected Message generateMessage(Request request) throws FIFException {
        // Log the start of the creation
        logger.info("Creating XSLT message for action: " + getAction() + "...");

        // Generate an XML representation of the request
        logger.debug("Generating XML representation of request...");
        Document doc = RequestSerializer.serialize(request);

        // Log and write the resulting XML document, if needed
        if ((MessageCreatorConfig
            .getBoolean("messagecreator.XSLT.WriteIntermediateFiles"))
            || (logger.isDebugEnabled())) {
            StringWriter sw = new StringWriter();
            try {
                DOMSerializer ds = new DOMSerializer();
                ds.serialize(doc, sw);
                if (logger.isDebugEnabled()) {
                    logger.debug(
                        "Generated XML representation of request:\n"
                            + sw.toString());
                }
                writeXML(sw.toString());
            } catch (IOException e) {
                logger.error("Cannot write XML representation of request.", e);
            }
        }

        // Transform the document
        logger.debug("Transforming XML representation with XSLT...");
        StringWriter sw = new StringWriter();

        // Clear the errors from the listener
        listener.clear();

        try {
            // Transform the document
            transformer.transform(new DOMSource(doc), new StreamResult(sw));

            // Check the error listener
            if (listener.isError()) {
                throw new FIFException(
                    "XSLT transformer reported the following errors:\n"
                        + listener.getErrors());
            } else if (listener.isWarning()) {
                logger.warn(
                    "XSLT transformer reported warnings:\n"
                        + listener.getWarnings());
            }
        } catch (Exception e) {
            throw new FIFException(
                "Cannot transform Request. Action: "
                    + getAction()
                    + "XSLT File: "
                    + xsltFileName,
                e);
        }

        // Log the successful generation
        logger.info(
            "Successfully created XSLT message for action: " + getAction());
        if (logger.isDebugEnabled()) {
            logger.debug("Contents:\n" + sw.toString());
        }

        // Create the Message object
        return (new FIFMessage(sw.toString()));
    }

    /**
     * Initializes the object.
     * @throws FIFException
     */
    private void init() throws FIFException {
        // Read the XSLT file
        File xsltFile = null;
        SimpleParameter param =
            (SimpleParameter) getCreatorParams().get("filename");
        xsltFileName =
            MessageCreatorConfig.getPath("messagecreator.XSLT.Directory")
                + param.getValue();
        xsltFile = new File(xsltFileName);
        if (!xsltFile.exists()) {
            throw new FIFException(
                "Cannot find XSLT file for Action: "
                    + getAction()
                    + ". Filename: "
                    + xsltFileName);
        }
        logger.debug("Using XSLT file: " + xsltFileName);

        // Create an XSLT transformer
        StreamSource xsltSource = new StreamSource(xsltFile);
        TransformerFactory transFact = TransformerFactory.newInstance();
        Templates cachedXSLT;
        try {
            cachedXSLT = transFact.newTemplates(xsltSource);
            transformer = cachedXSLT.newTransformer();
            listener = new XSLTErrorListener();
            transformer.setErrorListener(listener);
        } catch (TransformerConfigurationException e) {
            logger.error(
                "Error while creating XSLT transformer for action "
                    + getAction(),
                e);
            throw new FIFException(
                "Cannot create XSLT transformer for action " + getAction(),
                e);
        }
    }

    /**
     * Writes the XML representation of the request to an output file.
     * The message is only written to the output file if the
     * <code>messagecreator.XSLT.WriteIntermediateFiles</code> flag in the
     * configuration file is set to <code>TRUE</code>.
     * @param xml  the xml to be written to a file.
     * @throws FIFException
     */
    private void writeXML(String xml) throws FIFException {
        // Bail out if the xml should not be written to a output file
        if (!MessageCreatorConfig
            .getBoolean("messagecreator.XSLT.WriteIntermediateFiles")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                xml,
                MessageCreatorConfig.getPath(
                    "messagecreator.XSLT.IntermediateDir"),
                getAction() + "-request",
                ".xml",
                true);

        logger.info("Wrote intermediate XML file to: " + fileName);
    }

}
