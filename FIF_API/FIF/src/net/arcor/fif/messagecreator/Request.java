/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/Request.java-arc   1.1   Jan 30 2008 13:08:12   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/Request.java-arc  $
 * 
 *    Rev 1.1   Jan 30 2008 13:08:12   schwarje
 * IT-20058: Redesign of FIF service bus client
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.HashMap;
import java.util.Map;

import net.arcor.fif.common.FIFException;

/**
 * This is the base class for all request types that are supported by the
 * message creator package.
 *
 * @author goethalo
 */
public abstract class Request {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The action the request is related to.
     */
    private String action = null;

    /**
    	 * The parameters of the message. The key is a string containing the name of
    	 * the parameter. The value is a Parameter object.
     */
    private Map params = null;

    private int recycleStage = 0;
    
    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     */
    protected Request() {
        this.params = new HashMap();
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the action.
     * @return String
     */
    public String getAction() {
        return action;
    }

    /**
     * Returns the params.
     * @return Map
     */
    public Map getParams() {
        return params;
    }

    /**
     * Gets a parameter.
     * @param name  the name of the parameter to get the value from.
     * @return a Parameter object
     *         null if the parameter does not exist.
     */
    public Parameter getParam(String name) {
        return ((Parameter) params.get(name));
    }

    public int getRecycleStage() {
		return recycleStage;
	}

	public void setRecycleStage(int recycleStage) {
		this.recycleStage = recycleStage;
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
     * Sets the params.
     * @param params The params to set
     * @throws FIFException if the passed in parameter map is null
     */
    public void setParams(Map params) throws FIFException {
        if (params == null) {
            throw new FIFException(
                "Cannot set params because a null pointer was passed "
                    + "in to setParams(Map params).");
        }

        this.params = params;
    }

    /**
     * Adds a parameter to the parameter map.
     * @param param  the parameter to be added
     * @throws FIFException if the passed in parameter is null
     */
    public void addParam(Parameter param) throws FIFException {
        if (param == null) {
            throw new FIFException(
                "Cannot add parameter because a null pointer was passed "
                    + "to addParams(param).");
        }
        params.put(param.getName(), param);
    }

    /**
     * Represents this object as a String.
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("Class: " + this.getClass().getName());
        sb.append("\nAction: " + action);
        Object[] list = params.values().toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((Parameter) list[i]).toString());
        }
        return (sb.toString());
    }
}