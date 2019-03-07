/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreator.java-arc   1.1   Jun 14 2004 15:43:12   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/XSQLMessageCreator.java-arc  $
 * 
 *    Rev 1.1   Jun 14 2004 15:43:12   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:46   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Hashtable;

import net.arcor.fif.common.FIFException;
import oracle.xml.xsql.XSQLRequest;

import org.apache.log4j.Logger;

/**
 * This class converts requests to messages by using XSQL transformations.
 * @author goethalo
 */
public class XSQLMessageCreator extends FIFMessageCreator {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(XSQLMessageCreator.class);

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @see java.lang.Object#Object()
     */
    public XSQLMessageCreator(String action) throws FIFException {
        super(action);
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Generates a message for a given request.
     * @see net.arcor.fif.messagecreator.MessageCreator#generateMessage(Request)
     */
    protected Message generateMessage(Request request) throws FIFException {
        // Log the start of the creation
        logger.info("Creating XSQL message for action: " + getAction() + "...");

        // Create the URL for the file name to process
        SimpleParameter param =
            (SimpleParameter) getCreatorParams().get("filename");
        String xsqlFileName =
            MessageCreatorConfig.getPath("messagecreator.XSQL.Directory")
                + param.getValue();
        logger.debug("Using XSQL file: " + xsqlFileName);
        URL url = createURL(xsqlFileName);

        // Construct a new XSQL Page request
        XSQLRequest xsqlrequest = new XSQLRequest(url);

        // Create the XSQL parameters
        Hashtable params = createXSQLParams(request);

        // Process the XSQL
        StringWriter resultStringWriter = new StringWriter();
        StringWriter errorStringWriter = new StringWriter();
        xsqlrequest.process(
            params,
            new PrintWriter(resultStringWriter),
            new PrintWriter(errorStringWriter));

        // Check for errors
        String errors = errorStringWriter.toString();
        if ((errors != null) && (errors.trim().length() != 0)) {
            throw new FIFException(
                "Could not create message for action "
                    + getAction()
                    + "because an error occured in the XSQL processor:\n"
                    + errors);
        }

        // Log the successful generation
        logger.info(
            "Succesfully created XSQL message for action: " + getAction());
        if (logger.isDebugEnabled()) {
            logger.debug("Contents:\n" + resultStringWriter.toString());
        }

        return (new FIFMessage(resultStringWriter.toString()));
    }


    /**
     * Validates the parameter metadata for the creator type.
     * Ensures that only SimpleParameters are passed to this creator type.
     * @param pmd  the parameter metadata to validate
     * @throws FIFException if the validation failed.
     */
    protected void validateParamMetaData(ArrayList pmd) throws FIFException {
        for (int i = 0; i < pmd.size(); i++) {
            if (!(pmd.get(i) instanceof SimpleParameterMetaData)) {
                throw new FIFException(
                    "The XSQLMessageCreator only supports parameters of "
                        + "type SimpleParameter. Parameter type found in "
                        + "action mapping of the metadata file: "
                        + pmd.get(i).getClass().getName());
            }
        }
    }

    /**
     * Generates an URL from a filename.
     * @param fileName  the name of the file to generate the URL for.
     * @return the URL of the file
     */
    private URL createURL(String fileName) throws FIFException {
        URL url = null;
        try {
            url = new URL(fileName);
        } catch (MalformedURLException ex) {
            File f = new File(fileName);
            try {
                String path = f.getAbsolutePath();
                String fs = System.getProperty("file.separator");
                if (fs.length() == 1) {
                    char sep = fs.charAt(0);
                    if (sep != '/') {
                        path = path.replace(sep, '/');
                    }
                    if (path.charAt(0) != '/') {
                        path = '/' + path;
                    }
                }
                path = "file://" + path;
                url = new URL(path);
            } catch (MalformedURLException e) {
                throw new FIFException(
                    "Cannot create url for "
                        + fileName
                        + ". Action: "
                        + getAction());
            }
        }
        return url;
    }

    /**
     * Creates the XSQL parameters based on the request parameters and the
     * parameter metadata.
     * @param request  the request to create the XSQL parameters for.
     * @return a <code>Hashtable</code> containing the XSQL parameters.
     * @throws FIFException
     */
    private Hashtable createXSQLParams(Request request) throws FIFException {
        // Loop through the parameters request parameters
        Hashtable XSQLParams = new Hashtable();
        ArrayList mpmd = getMessageParamMetaData();
        for (int i = 0; i < mpmd.size(); i++) {
            // Get the parameter metadata and the parameter
            ParameterMetaData pmd = (ParameterMetaData) mpmd.get(i);
            Parameter param = (Parameter) request.getParam(pmd.getName());

            // Make sure it is a Simple Parameter
            if (!(param instanceof SimpleParameter)) {
                throw new FIFException(
                    "Wrong parameter type found: "
                        + param.getClass().getName()
                        + ". The XSQLMessageCreator "
                        + "only supports SimpleParameter objects.");
            }

            // Add the parameter to the map
            XSQLParams.put(pmd.getName(), ((SimpleParameter) param).getValue());
        }

        return XSQLParams;
    }

}
