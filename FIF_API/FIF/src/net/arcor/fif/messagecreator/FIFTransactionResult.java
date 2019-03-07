/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFTransactionResult.java-arc   1.6   Jul 25 2007 21:00:52   makuier  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFTransactionResult.java-arc  $
 * 
 *    Rev 1.6   Jul 25 2007 21:00:52   makuier
 * package name added.
 * 
 *    Rev 1.5   Jan 17 2007 18:03:46   makuier
 * literals for cancelation and postponement added.
 * SPN-FIF-000046682
 * 
 *    Rev 1.4   Jun 15 2004 16:19:36   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.3   Jun 14 2004 15:43:06   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.2   Mar 12 2004 10:26:46   goethalo
 * SPN-CCB-000020573: Fixed to not use newline characters for database client.
 */
package net.arcor.fif.messagecreator;

import java.util.ArrayList;

/**
 * This class represents the result of a FIF transaction.
 * It is extracted from the FIF reply message by the 
 * <code>FIFReplyMessage</code> class.
 * @author goethalo
 */
public class FIFTransactionResult {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /* Execution states */

    /** The FIF reply is invalid */
    public static int INVALID_REPLY = 0;

    /** The command was not executed by FIF */
    public static int NOT_EXECUTED = 1;

    /** The command was successfully executed by FIF */
    public static int SUCCESS = 2;

    /** The command failed */
    public static int FAILURE = 3;

    /** The command failed */
    public static int CANCELED = 4;

    /** The command failed */
    public static int POSTPONED = 5;

    /**
     * The ID of the transaction this result is related to.
     */
    private String transactionID = null;

    /**
     * The action name of the transaction this result is related to.
     */
    private String actionName = null;

    /**
     * The action name of the transaction this result is related to.
     */
    private String packageName = null;

    /**
     * The result of the FIF transaction.
     */
    private int result = INVALID_REPLY;

    /**
     * The results of the individual commands in the transaction.
     */
    private ArrayList results = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     */
    public FIFTransactionResult() {
        results = new ArrayList();
    }

    /**
     * Adds a result of a command.
     * @param result  the result to be added.
     */
    public void addResult(FIFCommandResult result) {
        results.add(result);
    }

    /**
     * Gets the action name.
     * @return the action name.
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * Gets the result.
     * @return the result.
     */
    public int getResult() {
        return result;
    }

    /**
     * Gets the results.
     * @return the results.
     */
    public ArrayList getResults() {
        return results;
    }

    /**
     * Gets the transaction ID.
     * @return the transaction ID.
     */
    public String getTransactionID() {
        return transactionID;
    }

    /**
     * Determines whether the reply is valid.
     * @return boolean true if the reply is valid, false if not.
     */
    public boolean isValid() {
        return (result != INVALID_REPLY);
    }

    /**
     * Sets the action name.
     * @param actionName  the action name to set
     */
    public void setActionName(String actionName) {
        this.actionName = actionName;
    }

    /**
     * Sets the result.
     * @param result  the result to set.
     */
    public void setResult(int result) {
        this.result = result;
    }

    /**
     * Sets the transaction ID.
     * @param transactionID  the transaction ID to set.
     */
    public void setTransactionID(String transactionID) {
        this.transactionID = transactionID;
    }

    /**
     * Returns a string representation of the transaction result.
     * @param newLines  indicates whether to use newlines in the string 
     *                  representation.
     * @param forList   indicates whether the transaction is part of a 
     *                  transaction list.
     * @return a String containing the transaction result.  
     */
    public String toString(boolean newLines, boolean forList) {
        StringBuffer msg = new StringBuffer();
        if (result == INVALID_REPLY) {
            msg.append("Invalid reply.");
        }
        if (result == SUCCESS) {
            msg.append("Transaction succeeded.");
        } else if (result == FAILURE) {
            msg.append("Transaction failed.");
        } else if (result == NOT_EXECUTED) {
            msg.append("Transaction not executed.");
            return (msg.toString());
        }
        for (int i = 0; i < results.size(); i++) {
            if (newLines == true) {
                msg.append("\n");
            } else {
                if (i == 0) {
                    if (result == SUCCESS) {
                        msg.append(" Warnings: ");
                    } else {
                        msg.append(" Errors: ");
                    }
                } else {
                    msg.append(", ");
                }
            }
            msg.append(((FIFCommandResult) results.get(i)).toString(newLines));
        }
        return msg.toString();
    }

    /**
     * Returns a string representation of the transaction result.
     * @param newLines  indicates whether to use newlines in the string 
     *                  representation. 
     * @return a String containing the transaction result.  
     */
    public String toString(boolean newLines) {
        return toString(newLines, false);
    }

    /**
     * Returns a string representation of the transaction result.
     * @return a String containing the transaction result.  
     */
    public String toString() {
        return toString(true, false);
    }

	public String getPackageName() {
		return packageName;
	}

	public void setPackageName(String packageName) {
		this.packageName = packageName;
	}
}
