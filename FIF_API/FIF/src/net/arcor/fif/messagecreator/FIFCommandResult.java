/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFCommandResult.java-arc   1.2   Mar 12 2004 10:26:44   goethalo  $
    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/FIFCommandResult.java-arc  $
 * 
 *    Rev 1.2   Mar 12 2004 10:26:44   goethalo
 * SPN-CCB-000020573: Fixed to not use newline characters for database client.
 * 
 *    Rev 1.1   Sep 09 2003 16:37:00   goethalo
 * IT-10800: added warning support.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;

/**
 * This class contains the FIF result for a specific command.
 * @author goethalo
 */
public class FIFCommandResult {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /*
     * The result states of the command.
     */

    /** The command was not executed by FIF */
    public static int NOT_EXECUTED = 0;

    /** The command was successfully executed by FIF */
    public static int SUCCESS = 1;

    /** The command was rolled back by FIF */
    public static int ROLLED_BACK = 2;

    /** The command failed */
    public static int FAILURE = 3;

    /**
     * The name of the command the result is for.
     */
    private String name = null;

    /**
     * The result of the command.
     */
    private int result = -1;

    /**
     * The list of results.
     */
    private ArrayList results = null;

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Constructor.
     * @param name    the name of the command.
     * @param result  the result state of the command.
     * @param results the results of the command.
     */
    public FIFCommandResult(String name, int result, ArrayList results) {
        this.name = name;
        this.result = result;
        this.results = results;
    }

    /**
     * Gets the errors of the command.
     * This is an <code>ArrayList</code> containing <code>FIFError</code> 
     * objects.
     * @return the errors of the command.
     */
    public ArrayList getResults() {
        return results;
    }

    /**
     * Gets the name of the command.
     * @return the name of the command.
     */
    public String getName() {
        return name;
    }

    /**
     * Gets the result of the command.
     * @return the result of the command.
     */
    public int getResult() {
        return result;
    }

    /**
     * Returns a string representation of the command result.
     * @param newLines  indicates whether newline characters should be used
     * @return a String containing the command result. 
     */
    public String toString(boolean newLines) {
        StringBuffer msg = new StringBuffer();

        msg.append(name);
        msg.append(" : ");
        if (result == SUCCESS) {
            if ((results != null) && (results.size() == 0)) {
                msg.append("Command successfully executed.");
            } else {
                msg.append("Command successfully executed. Warning messages:");
            }
        } else if (result == ROLLED_BACK) {
            msg.append("Command rolled back.");
        } else if (result == NOT_EXECUTED) {
            msg.append("Command not executed.");
        } else if (result == FAILURE) {
            msg.append("Command failed. Error messages:");
        }

        // Write the results if needed
        if ((result == SUCCESS) || (result == FAILURE)) {
            for (int i = 0;(results != null) && (i < results.size()); i++) {
                if (newLines) {
                    msg.append("\n  ");
                } else {
                    msg.append(", ");
                }
                msg.append(results.get(i));
            }
        }

        return msg.toString();
    }

    /**
     * Returns a string representation of the command result.
     * @see java.lang.Object#toString()
     */
    public String toString() {
        return (toString(true));
    }

}
