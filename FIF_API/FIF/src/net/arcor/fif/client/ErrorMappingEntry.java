package net.arcor.fif.client;

/**
 * This class represents an entry in the error-mapping table.
 * The error mapping table is used for translating 'cryptic' error messages
 * returned by FIF to a more comprehensible error message.
 * @author goethalo
 */
public class ErrorMappingEntry {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/
     
    /**
     * The error number.
     */
    private String number = null;
    
    /**
     * The error message.
     */
    private String message = null;

    /*---------*
     * METHODS *
     *---------*/
         
    /**
     * Constructor.
     * @param number   the error number.
     * @param message  the error message.
     */
    public ErrorMappingEntry(String number, String message) {
        this.number = number;
        this.message = message;
    }
        
    /**
     * Gets the error message.
     * @return the error message.
     */
    public String getMessage() {
        return message;
    }

    /**
     * Gets the error number.
     * @return the error number.
     */
    public String getNumber() {
        return number;
    }
}
