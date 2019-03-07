/*
 * $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFTransactionListResult.java-arc   1.2   Aug 02 2004 15:26:20   goethalo  $
 *
 * $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFTransactionListResult.java-arc  $
 * 
 *    Rev 1.2   Aug 02 2004 15:26:20   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.1   Jun 15 2004 16:19:36   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Jun 14 2004 15:42:04   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.util.LinkedList;
import java.util.List;

/**
 * This class represents the result of a FIF transaction list.
 * It is extracted from the FIF reply list message by the 
 * <code>FIFReplyListMessage</code> class.
 * @author goethalo
 */
public class FIFTransactionListResult {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /* Execution states */

    /** The FIF reply is invalid */
    public static int INVALID_REPLY = 0;

    /** The transaction was successfully executed by FIF */
    public static int SUCCESS = 1;

    /** The transaction failed in FIF */
    public static int FAILURE = 2;

    /**
     * The ID of the transaction list this result is related to.
     */
    private String transactionListID = null;

    /**
     * The name of the transaction list this result is related to.
     */
    private String listName = null;

    /**
     * The result of the FIF transaction.
     */
    private int result = INVALID_REPLY;

    /**
     * The results of the individual replies in the transaction.
     */
    private List replies = null;

    /**
     * The top-level errors.
     */
    private List errors = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     */
    public FIFTransactionListResult() {
        replies = new LinkedList();
        errors = new LinkedList();
    }

    /**
     * Adds an individual transaction reply to the list.
     * @param reply  the reply to be added.
     */
    public void addReply(FIFReplyMessage reply) {
        replies.add(reply);
    }

    /**
     * Adds a top-level error.
     * @param error  the top-level error to be added.
     */
    public void addError(FIFError error) {
        errors.add(error);
    }

    /**
     * Gets the list name.
     * @return the list name.
     */
    public String getListName() {
        return listName;
    }

    /**
     * Gets the result.
     * @return the result.
     */
    public int getResult() {
        return result;
    }

    /**
     * Gets the replies.
     * @return the <code>List</code> containing the 
     * <code>FIFReplyMessage</code> objects.
     */
    public List getReplies() {
        return replies;
    }

    /**
     * Gets the transaction list ID.
     * @return the transaction list ID.
     */
    public String getTransactionListID() {
        return transactionListID;
    }

    /**
     * Determines whether the reply is valid.
     * @return boolean true if the reply is valid, false if not.
     */
    public boolean isValid() {
        return (result != INVALID_REPLY);
    }

    /**
     * Sets the list name.
     * @param listName  the list name to set
     */
    public void setListName(String listName) {
        this.listName = listName;
    }

    /**
     * Sets the result.
     * @param result  the result to set.
     */
    public void setResult(int result) {
        this.result = result;
    }

    /**
     * Sets the transaction list ID.
     * @param transactionListID  the transaction list ID to set.
     */
    public void setTransactionListID(String transactionListID) {
        this.transactionListID = transactionListID;
    }

    /**
     * Returns a string representation of the transaction list result.
     * @param newLines  indicates whether to use newlines in the string 
     *                  representation.
     * @return a String containing the transaction list result.  
     */
    public String toString(boolean newLines) {
        StringBuffer msg = new StringBuffer();
        if (result == INVALID_REPLY) {
            msg.append("Invalid reply.");
        }
        if (result == SUCCESS) {
            msg.append("Transaction list succeeded.");
        } else if (result == FAILURE) {
            msg.append("Transaction list failed.");
        }
        for (int i = 0; i < replies.size(); i++) {
            if (newLines == true) {
                msg.append("\n");
            } else {
                if (i == 0) {
                    msg.append(" Details: ");
                } else {
                    msg.append(", ");
                }
            }
            try {
                FIFReplyMessage reply = (FIFReplyMessage) replies.get(i);
                msg.append("=== Action name: ");
                msg.append(reply.getActionName());
                msg.append(", Transaction ID: ");
                msg.append(reply.getTransactionID());
                msg.append(" ===");
                if (newLines == true) {
                    msg.append("\n");
                } else {
                    msg.append(" : ");
                }
                msg.append(reply.getResult().toString(newLines));
                if (newLines == true) {
                    msg.append("\n");
                } else {
                    msg.append("; ");
                }
            } catch (Exception e) {
                msg.append("Exception while printing transaction list result:");
                msg.append(e);
            }
        }
        return (msg.toString());
    }

    /**
     * Returns a string representation of the transaction result.
     * @return a String containing the transaction result.  
     */
    public String toString() {
        return toString(true);
    }

}
