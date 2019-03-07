/*
 $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ActionComparator.java-arc   1.1   May 13 2009 10:43:16   lejam  $

 $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ActionComparator.java-arc  $
 * 
 *    Rev 1.1   May 13 2009 10:43:16   lejam
 * Added Message as possible object type IT-24729,IT-25224
 * 
 *    Rev 1.0   Dec 05 2006 17:08:34   makuier
 * Initial revision.
 * 
 *    Rev 1.6   Sep 19 2005 15:24:00   banania
 * Added use of entity resolver for finding dtds.
 * 
 *    Rev 1.5   Aug 02 2004 15:26:22   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.4   Jul 15 2004 12:15:16   goethalo
 * SPN-CCB-000023940: Added code to take care of encoding problems for incoming XML.
 * 
 *    Rev 1.3   Jun 14 2004 15:43:10   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.2   Jul 25 2003 09:15:28   goethalo
 * IT-9750
 * 
 *    Rev 1.1   Jul 16 2003 15:01:20   goethalo
 * Changes for IT-9750
 * 
 *    Rev 1.0   Apr 09 2003 09:34:42   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.util.Comparator;
import net.arcor.fif.common.FIFException;

/**
 * Class that compares the priority of the FIF requests. 
 * It is used for sorting the FIF request list.
 * @author makuier
 */
public class ActionComparator implements Comparator  {

	public int compare(Object req1, Object req2) {
		String requestAction1 = "";
		String requestAction2 = "";
		
		if(req1 instanceof FIFRequest)
			requestAction1 = ((FIFRequest)req1).getAction();
		else if (req1 instanceof Message)
			requestAction1 = ((Message)req1).getAction();
			
		if(req2 instanceof FIFRequest)
			requestAction2 = ((FIFRequest)req2).getAction();
		else if (req2 instanceof Message)
			requestAction2 = ((Message)req2).getAction();

		int requestPriority1 = getActionPriority(requestAction1);
		int requestPriority2 = getActionPriority(requestAction2);
		
		return (requestPriority2-requestPriority1);
	}
    private int getActionPriority(String actionName) {
        int priority = 0;
    	try {
        	String actionPrio = MessageCreatorConfig.getSetting("messagecreator."+actionName);
        	priority = Integer.parseInt(actionPrio);
        } catch (FIFException fe) {
        	// Ignore 
        }
    	return priority;
    }
}