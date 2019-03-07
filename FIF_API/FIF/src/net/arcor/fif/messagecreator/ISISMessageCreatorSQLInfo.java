/*
 * $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ISISMessageCreatorSQLInfo.java-arc   1.1   Aug 02 2004 15:26:20   goethalo  $
 *
 * $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/messagecreator/ISISMessageCreatorSQLInfo.java-arc  $
 * 
 *    Rev 1.1   Aug 02 2004 15:26:20   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 */
package net.arcor.fif.messagecreator;

/**
 * Class containing the SQL info for the ISIS message creator.
 * @author goethalo
 *
 */
public class ISISMessageCreatorSQLInfo {

    private String action = null;
    private String tableName = null;
    private String tagName = null;
    private ISISMessageCreatorSQLInfo[] childSelects = null;

    /**
     * Constructor.
     * @param action	 the name of the action.
     * @param tableName  the table name.
     * @param tagName    the tag name.
     */
    public ISISMessageCreatorSQLInfo(
        String action,
        String tableName,
        String tagName) {
        this.action = action;
        this.tableName = tableName;
        this.tagName = tagName;
    }

    /**
     * Constructor.
     * @param action        the action name.
     * @param tableName     the table name.
     * @param tagName       the tag name.
     * @param childSelects  the child select statements.
     */
    public ISISMessageCreatorSQLInfo(
        String action,
        String tableName,
        String tagName,
        ISISMessageCreatorSQLInfo[] childSelects) {
        this.action = action;
        this.tableName = tableName;
        this.tagName = tagName;
        this.childSelects = childSelects;
    }

    /**
     * Constructor.
     * @param tableName  the table name.
     * @param tagName    the tag name.
     */
    public ISISMessageCreatorSQLInfo(String tableName, String tagName) {
        this.action = "";
        this.tableName = tableName;
        this.tagName = tagName;
    }

    /**
     * Gets the action.
     * @return  the action.
     */
    public String getAction() {
        return action;
    }

    /**
     * Gets the child selects.
     * @return the child selects.
     */
    public ISISMessageCreatorSQLInfo[] getChildSelects() {
        return childSelects;
    }

    /**
     * Gets the table name.
     * @return the table name.
     */
    public String getTableName() {
        return tableName;
    }

    /**
     * Gets the tag name.
     * @return the tag name.
     */
    public String getTagName() {
        return tagName;
    }

}
