/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/MessageCreator.java-arc   1.5   Oct 19 2015 15:16:10   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/MessageCreator.java-arc  $
 * 
 *    Rev 1.5   Oct 19 2015 15:16:10   schwarje
 * PPM-100743_181773: made populateAndDefault public
 * 
 *    Rev 1.4   Aug 20 2014 07:08:50   schwarje
 * PPM-143282: improved support for regular expression checks of input parameters
 * 
 *    Rev 1.3   Nov 21 2013 08:52:38   schwarje
 * IT-k-32850: generic validation of input parameters configured in metadata (first use case: CCB date format)
 * 
 *    Rev 1.2   Jun 01 2010 18:05:30   schwarje
 * IT-26029: updates
 * 
 *    Rev 1.1   Jul 16 2003 14:59:42   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:38   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Map;

import net.arcor.fif.common.FIFException;
import net.arcor.fif.common.FileUtils;

import org.apache.log4j.Logger;

/**
 * Abstract base class for all message creator types.
 *
 * @author goethalo
 */
public abstract class MessageCreator {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(MessageCreator.class);

    /**
     * The action name this message creator is realted to
     */
    private String action = null;

    /**
     * The metadata about the message creator parameters
     */
    private Map creatorParams = null;

    /**
     * The metadata about the message parameters.
     */
    private ArrayList messageParamMetaData = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param action  the name of the action to create the
     *                 <code>MessageCreator</code> for.
     */
    public MessageCreator(String action) throws FIFException {
        setAction(action);
        ActionMapping mapping = MessageCreatorMetaData.getActionMapping(action);
        setCreatorParams(mapping.getCreatorParams());
        setMessageParamMetaData(mapping.getMessageParams());
    }

    /**
     * Validates the parameter metadata for the creator type.
     * Override this method in a derived class if the MessageCreator has
     * special requirements for the metadata.
     * This method is called once when the parameter metadata is validated.
     * @param pmd  the parameter metadata to validate
     * @throws FIFException if the validation failed.
     */
    protected void validateParamMetaData(ArrayList pmd) throws FIFException {
        // Do nothing in this base class implementation
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * @return String
     */
    public String getAction() {
        return action;
    }

    /**
     * @return ArrayList
     */
    public Map getCreatorParams() {
        return creatorParams;
    }

    /**
     * @return ArrayList
     */
    public ArrayList getMessageParamMetaData() {
        return messageParamMetaData;
    }

    /**
     * Sets the action.
     * @param action The action to set
     */
    protected void setAction(String action) throws FIFException {
        if (action == null || action.trim().length() == 0) {
            throw new FIFException(
                "Cannot create message creator because passed in action is "
                    + "null or empty");
        }
        this.action = action;
    }

    /**
     * Sets the creatorParams.
     * @param creatorParams The creatorParams to set
     */
    protected void setCreatorParams(Map creatorParams) throws FIFException {
        if (creatorParams == null) {
            throw new FIFException(
                "Cannot create message creator because passed in "
                    + "creatorParams is null");
        }
        this.creatorParams = creatorParams;
    }

    /**
     * Sets the messageParamMetaData.
     * @param messageParamMetaData The messageParamMetaData to set
     */
    protected void setMessageParamMetaData(ArrayList messageParamMetaData)
        throws FIFException {
        if (messageParamMetaData == null) {
            throw new FIFException(
                "Cannot create message creator because passed in "
                    + "messageParamMetaData is null");
        }
        this.messageParamMetaData = messageParamMetaData;
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Creates a message for a request.
     * @param request  the request the create the message for.
     * @return Message
     * @throws FIFException
     */
    final public Message createMessage(Request request) throws FIFException {

        // Populate the default values and validate
        populateDefaultsAndValidate(request);

        // Generate the message
        Message message = generateMessage(request);

        // Write the message to an output file, if needed
        writeToOutputFile(message);

        return message;
    }

    /**
     * Generates the message for a given request.
     * This abstract method should be implemented by the child classes.
     * @param request  the request to generate the message for
     * @return Message
     * @throws FIFException
     */
    protected abstract Message generateMessage(Request request)
        throws FIFException;

    /**
     * Populates the default values on a request and validates the request.
     * This method first populates the default values on the request parameters.
     * It then validates that all mandatory parameters are provided in the
     * message,
     * @param request   the request to populate and validate.
     * @throws FIFException if the validation fails.
     */
    public void populateDefaultsAndValidate(Request request)
        throws FIFException {
        // Loop through the parameter metadata, populate the default value
        // and validate each parameter
        for (int i = 0; i < messageParamMetaData.size(); i++) {
            // Delegate to the recursive method
            populateAndValidateParameter(
                request,
                (ParameterMetaData) messageParamMetaData.get(i),
                null,
                null);
        }
    }

    /**
     * Populates the default value if needed and validates a parameter
     * given its parameter metadata
     * @param request        the request to populate and validate
     * @param paramMetaData  the parameter metadata for the parameter
     *                       to populate the default value on and to validate
     * @param parentPath     the path to the parent of the parameter.
     *                       Needed for recursion.
     * @param itemIndexPath  the index path of the list item to validate.
     * @throws FIFException
     */
    private void populateAndValidateParameter(
        Request request,
        ParameterMetaData paramMetaData,
        ArrayList parentPath,
        ArrayList itemIndexPath)
        throws FIFException {
    	SimpleParameter transactionIDParam = (SimpleParameter)request.getParam("transactionID");
    	String transactionID = (transactionIDParam != null) ? transactionIDParam.getValue() : null;
        if (paramMetaData instanceof SimpleParameterMetaData) {
            // Validations for a simple parameter
            SimpleParameterMetaData spmd =
                (SimpleParameterMetaData) paramMetaData;
            Parameter param =
                getRequestParam(request, parentPath, itemIndexPath, spmd.getName());

            // Ensure that the parameter is a SimpleParameter
            if ((param != null) && !(param instanceof SimpleParameter)) {
                throw new FIFInvalidRequestException(
                    "The parameter "
                        + spmd.getName()
                        + "is of incorrect type."
                        + "Expected type: SimpleParameter, Type in request object: "
                        + param.getClass().getName());
            }

            SimpleParameter sp =
                (param != null ? (SimpleParameter) param : null);

            if (spmd.isMandatory()) {
                // The parameter is mandatory, check that it exists.
                if (sp == null) {
                    // The parameter is mandatory and should be provided
                    throw new FIFInvalidRequestException(
                        "Mandatory parameter "
                            + spmd.getName()
                            + " missing from request, action name: " + request.getAction() 
                            + ", transactionID: " + transactionID);
                }

                // Validate the value of the parameter
                if ((sp.getValue() == null)
                    || (sp.getValue().trim().length() == 0)) {
                    throw new FIFInvalidRequestException(
                        "No value provided for the mandatory parameter "
                            + spmd.getName() + ". Action name: " + request.getAction() 
                            + ", transactionID: " + transactionID);
                }
            } else {
                // The parameter is not mandatory.
                // Set the default value if needed.
                populateDefaultValue(request, sp, spmd, parentPath, itemIndexPath);
            }
            
            // generically validate the parameter with the method mentioned in the metadata
            if (spmd.getValidationMethod() != null && sp != null && sp.getValue() != null && sp.getValue().trim().length() != 0)
            	validateParameter(sp.getName(), sp.getValue(), spmd.getValidationMethod());
            
        } else if (paramMetaData instanceof ParameterListMetaData) {
            // Validate the parameter list
            ParameterListMetaData plmd = (ParameterListMetaData) paramMetaData;
            Parameter param =
                getRequestParam(request, parentPath, itemIndexPath, plmd.getName());

            // Bail out if the parameter is null and not mandatory
            if ((param == null) && (!plmd.isMandatory())) {
                return;
            }

            // The parameter list is mandatory and should be provided
            if (param == null) {
                throw new FIFInvalidRequestException(
                    "Mandatory parameter list "
                        + plmd.getName()
                        + " missing from request. Action name: " + request.getAction() 
                        + ", transactionID: " + transactionID);
            }

            // Validate its type
            if (!(param instanceof ParameterList)) {
                throw new FIFInvalidRequestException(
                    "The parameter "
                        + plmd.getName()
                        + "is of incorrect type."
                        + "Expected type: ListParameter, Type in request object: "
                        + param.getClass().getName() + ". Action name: " + request.getAction() 
                        + ", transactionID: " + transactionID);
            }

            // Make sure that there is at least one item in the list
            ParameterList list = (ParameterList) param;
            if ((plmd.isMandatory()) && (list.getItemCount() < 1)) {
                throw new FIFInvalidRequestException(
                    "The mandatory parameter list "
                        + plmd.getName()
                        + " does not contain any list items. Action name: " + request.getAction() 
                        + ", transactionID: " + transactionID);
            }

            // Validate the items in the list
            // Get the metadata for the list parameters
            Object[] paramListMetaData = plmd.getParamsMetaData().toArray();

            // Add the curent parameter to the parent path
            if (parentPath == null) {
                parentPath = new ArrayList();
            }
            parentPath.add(plmd.getName());

            // Validate the parameters for each list item
            for (int items = 0; items < list.getItemCount(); items++) {
                // Add the current index path
                if (itemIndexPath == null) {                
                    itemIndexPath = new ArrayList();
                }                    
                itemIndexPath.add(new Integer(items));
                
                // Loop through all parameters in the list item and validate them
                for (int i = 0; i < paramListMetaData.length; i++) {
                    // The sneaky recursion to validate each list parameter
                    populateAndValidateParameter(
                        request,
                        (ParameterMetaData) paramListMetaData[i],
                        parentPath,
                        itemIndexPath);
                }
                
                // Remove the last index path
                itemIndexPath.remove(itemIndexPath.size()-1);
            }

            // Remove the current parameter from the parent path
            parentPath.remove(plmd.getName());
        } else {
            throw new FIFInvalidRequestException(
                "Unknown class type sent to validateParameter: "
                    + paramMetaData.getClass().getName());
        }
    }

    private void validateParameter(String name, String value,
			String validationMethodString) throws FIFException {
		logger.debug("Validating parameter " + name	+ " , value " + value
				+ " with validation method " + validationMethodString	+ ".");
		
		try {
			Method validationMethod = ParameterValidator.class.getMethod(
					validationMethodString, 
					new Class[]{ String.class, String.class });
			validationMethod.invoke(null, name, value);
		} catch (SecurityException e) {
			logger.warn("Error while processing validation method " + validationMethodString
					+ ". Skipping this validation.", e);
		} catch (NoSuchMethodException e) {
			logger.warn("Error while processing validation method " + validationMethodString
					+ ". Skipping this validation.", e);
		} catch (IllegalArgumentException e) {
			logger.warn("Error while processing validation method " + validationMethodString
					+ ". Skipping this validation.", e);
		} catch (IllegalAccessException e) {
			logger.warn("Error while processing validation method " + validationMethodString
					+ ". Skipping this validation.", e);
		} catch (InvocationTargetException e) {
			throw (FIFException)e.getTargetException();
		}
	}

	/**
     * Retrieves a request parameter given a parentPath and a name.
     * @param request        the request to get the parameter from.
     * @param parentPath     the path to the parent of the parameter.
     *                       This list should should start with the top parent
     *                       and end with the direct parent.
     * @param itemIndexPath  the index path of the list item to get the 
     *                       parameter from.
     * @param name           the name of the parameter to retrieve.
     * @return the <code>Parameter</object>, null if the parameter was
     * not found.
     */
    private Parameter getRequestParam(
        Request request,
        ArrayList parentPath,
        ArrayList itemIndexPath,
        String name) throws FIFException {
        // If the parentPath is empty, return from the root level
        if ((parentPath == null) || (parentPath.size() == 0)) {
            return request.getParam(name);
        }
        // If the parentPath is not empty, go to the right level and
        // get the parameter.
        ParameterList paramList =
            (ParameterList) request.getParam((String) parentPath.get(0));
        int itemIndex = ((Integer)itemIndexPath.get(0)).intValue();            
        for (int i = 1; i < parentPath.size(); i++) {
            paramList =
                (ParameterList) paramList.getItem(itemIndex).getParam(
                    (String) parentPath.get(i));
            itemIndex = ((Integer)itemIndexPath.get(i)).intValue();                     
        }

        // Return the parameter
        return paramList.getItem(itemIndex).getParam(name);
    }

    /**
     * Adds a request parameter given a parentPath and a name.
     * @param request        the request to add the parameter to.
     * @param parentPath     the path to the parent of the parameter to be added.
     *                       This list should should start with the top parent
     *                       and end with the direct parent.
     * @param itemIndexPath  the index path of the list item to add the 
     *                       parameter to.
     * @param param          the parameter to add.
     */
    private void addRequestParam(
        Request request,
        ArrayList parentPath,
        ArrayList itemIndexPath,
        Parameter param)
        throws FIFException {
        // If the parentPath is empty, return from the root level
        if ((parentPath == null) || (parentPath.size() == 0)) {
            request.addParam(param);
            return;
        }

        // If the parentPath is not empty, go to the right level and
        // add the parameter.
        ParameterList paramList =
            (ParameterList) request.getParam((String) parentPath.get(0));
        int itemIndex = ((Integer)itemIndexPath.get(0)).intValue();
        for (int i = 1; i < parentPath.size(); i++) {
            paramList =
                (ParameterList) paramList.getItem(itemIndex).getParam(
                    (String) parentPath.get(i));
            itemIndex = ((Integer)itemIndexPath.get(i)).intValue();                     
        }

        // Add the parameter
        paramList.getItem(itemIndex).addParam(param);
    }

    /**
     * Sets the default value on a parameter, if needed.
     * @param request        the request the parameter is related to.
     * @param param          the parameter to set the default value on.
     * @param spmd           the parameter metadata.
     * @param parentPath     the parent path to the parameter.
     * @param itemIndexPath  the index path of the list item that contains the 
     *                       parameter.
     * @throws FIFException
     */
    private void populateDefaultValue(
        Request request,
        SimpleParameter param,
        SimpleParameterMetaData spmd,
        ArrayList parentPath,
        ArrayList itemIndexPath)
        throws FIFException {
        // Do not populate a default value if the parameter is mandatory
        if (spmd.isMandatory()) {
            return;
        }

        // Do not populate the default value if there is a value set
        // on the parameter
        if ((param != null) && (param.getValue() != null)) {
            return;
        }

        // Get the default value
        String defaultValue = spmd.getDefaultValue();
        if (defaultValue == null) {
            defaultValue = "";
        }

        // Set the default value
        if (param == null) {
            // Create a new parameter and add it to the
            // request parameters
            param = new SimpleParameter(spmd.getName(), defaultValue);
            addRequestParam(request, parentPath, itemIndexPath, param);
        } else {
            // Set the default value on the parameter
            param.setValue(defaultValue);
        }
    }

    /**
     * Writes the generated message to an output file.
     * The message is only written to the output file if the
     * <code>messagecreator.WriteOutputFiles</code> flag in the configuration
     * file is set to <code>TRUE</code>.
     * @param message  the message to be written to a file.
     * @throws FIFException
     */
    private void writeToOutputFile(Message message) throws FIFException {
        // Bail out if the message should not be written to a output file
        if (!MessageCreatorConfig
            .getBoolean("messagecreator.WriteOutputFiles")) {
            return;
        }

        String fileName =
            FileUtils.writeToOutputFile(
                message.getMessage(),
                MessageCreatorConfig.getPath("messagecreator.OutputDir"),
                getAction(),
                ".xml",
                true);

        logger.info("Wrote output to: " + fileName);
    }
}
