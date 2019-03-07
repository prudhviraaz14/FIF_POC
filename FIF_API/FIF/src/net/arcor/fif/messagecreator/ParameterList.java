/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterList.java-arc   1.2   Aug 02 2004 15:26:22   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ParameterList.java-arc  $
 * 
 *    Rev 1.2   Aug 02 2004 15:26:22   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.1   Jul 16 2003 15:00:12   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:40   goethalo
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.util.ArrayList;
import java.util.List;

import net.arcor.fif.common.FIFException;

/**
 * This class contains represents a parameter list.
 * It contains <code>ParameterListItem</code> objects which
 * contain <code>Parameter</code> objects.
 * @author goethalo
 */
public class ParameterList extends Parameter {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The list of items.
     */
    private List items = null;

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @param name  the name of the parameter list
     * @throws FIFException
     */
    public ParameterList(String name) throws FIFException {
        super(name);
        items = new ArrayList();
    }

    /**
     * Constructor
     * @param name   the name of the parameter list
     * @param items  the list of items
     * @throws FIFException
     */
    public ParameterList(String name, List items) throws FIFException {
        super(name);
        if (items == null) {
            throw new FIFException(
                "Cannot create ParameterList because the passed "
                    + "in items object is null");
        }
        this.items = items;
    }

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Returns the parameter list items.
     * @return List
     */
    public List getItems() {
        return items;
    }

    /**
     * Sets the parameter list items.
     * @param items The parameter list items to set
     */
    public void setItems(List items) throws FIFException {
        if (items == null) {
            throw new FIFException(
                "Cannot set a null items object in " + "setItems()");
        }
        this.items = items;
    }

    /**
     * Adds a parameter list item to the list.
     * @param item the parameter list item to be added
     * @throws FIFException if the passed in parameter list item is null
     */
    public void addItem(ParameterListItem item) throws FIFException {
        if (item == null) {
            throw new FIFException(
                "Cannot add parameter list item because a null pointer was "
                    + " passed to addItem(item).");
        }
        items.add(item);
    }

    /**
     * Gets a parameter list item from the list.
     * @param index  the index of parameter list item to get.
     * @return the <code>ParameterListItem</code> at the given index.
     * @throws FIFException if the passed in index is out of bounds.
     */
    public ParameterListItem getItem(int index) throws FIFException {
        if (index >= getItemCount()) {
            throw new FIFException("Passed in index is out of bounds in getItem(index).");
        }
        return ((ParameterListItem) items.get(index));
    }

    /**
     * Returns the number of parameter list items in the list.
     * @return the number of items in the list.
     */
    public int getItemCount() {
        return items.size();
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * @see net.arcor.fif.messagecreator.Parameter#equals(java.lang.Object)
     */
    public boolean equals(Object obj) {
        return (
            (obj != null)
                && (obj instanceof ParameterList)
                && (((Parameter) obj).getName() == getName()));
    }

    /**
     * Writes the contents of this object as a <code>String</code>
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("\nParameterList (");
        sb.append("name: ");
        sb.append(getName());
        sb.append(", items: ");
        Object[] list = items.toArray();
        for (int i = 0; i < list.length; i++) {
            sb.append(((ParameterListItem) list[i]).toString());
        }
        sb.append(")");
        return sb.toString();
    }
}
