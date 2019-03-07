/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/ISISUtils.java-arc   1.4   Aug 02 2004 15:26:16   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/ISISUtils.java-arc  $
 * 
 *    Rev 1.4   Aug 02 2004 15:26:16   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.3   Dec 08 2003 13:12:04   goethalo
 * Improved the offset approach.
 * 
 *    Rev 1.2   Nov 26 2003 17:49:42   goethalo
 * Intermediate checkin. (made default offset to be 480)
 * 
 *    Rev 1.1   Nov 25 2003 18:14:52   goethalo
 * Intermediate checkin.
 *
 *    Rev 1.0   Nov 17 2003 16:02:16   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Class containing XSLT utility functions for the ISIS migration.
 * @author goethalo
 */
public class ISISUtils {

    /**
     * Map containing the last used stepID for a specific action.
     * Needed to perform referencing.
     */
    private static Map steps = new HashMap();

    /**
     * Map containing the last used time offset for a specific date.
     */
    private static Map offsets = new HashMap();

    /**
     * The initial offset to use.
     */
    private static final int initialOffSet = (8 * 60);

    /**
     * The time interval between offsets.
     */
    private static final int offsetInterval = 3;

    /**
     * The date format used by FIF.
     */
    private static SimpleDateFormat sdfFIF =
        new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");

    /**
     * Sets the last step ID for an action.
     * @param action the name of the action.
     * @param stepID the step ID.
     */
    public static void setLastStepID(String action, String stepID) {
        steps.put(action, stepID);
    }

    /**
     * Gets the last step ID for an action.
     * @param action the action to set the step ID for.
     * @return the last step ID.
     */
    public static String getLastStepID(String action) {
        return ((String) steps.get(action));
    }

    /**
     * Gets the offset date.
     * @return the new date.
     */
    public static String getOffSetDate(String inputDate) {
        // Parse the date
        Date date = null;
        try {
            synchronized (sdfFIF) {
                date = sdfFIF.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Strip off the time
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        date = cal.getTime();

        // Find it in map
        Integer lastOffSet = (Integer) offsets.get(date);

        if (lastOffSet == null) {
            lastOffSet = new Integer(initialOffSet);
        } else {
            lastOffSet = new Integer(lastOffSet.intValue() + offsetInterval);
        }

        // Put the new value in the map
        offsets.put(date, lastOffSet);

        // Return new date offset
        cal.add(Calendar.MINUTE, lastOffSet.intValue());
        String newDate = null;
        synchronized (sdfFIF) {
            newDate = sdfFIF.format(cal.getTime());
        }
        return (newDate);
    }

    /**
     * Clears the offset map.
     *
     */
    public static void clearOffSets() {
        offsets = new HashMap();
    }
}
