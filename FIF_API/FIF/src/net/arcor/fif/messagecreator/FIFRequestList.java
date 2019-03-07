/*
 * $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFRequestList.java-arc   1.9   Mar 11 2010 13:16:12   schwarje  $
 *
 * $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/FIFRequestList.java-arc  $
 * 
 *    Rev 1.9   Mar 11 2010 13:16:12   schwarje
 * IT-26029: Decomissioning MQReader
 * 
 *    Rev 1.7   Jun 04 2009 12:37:30   schwarje
 * SPN-FIF-000087150: propagate request list parameters to each single request
 * 
 *    Rev 1.5   Nov 07 2008 11:40:04   makuier
 * handling manual rollback added.
 * 
 *    Rev 1.4   Aug 08 2008 15:49:58   wlazlow
 * IT-21113
 * 
 *    Rev 1.3   Aug 16 2007 19:23:08   lejam
 * Added support for OMTSOrderId on the request list level IT-19036
 * 
 *    Rev 1.2   Dec 22 2006 11:33:28   schwarje
 * TF: added method for retrieving object
 * 
 *    Rev 1.1   Dec 05 2006 17:10:16   makuier
 * Sorting the request list according to the action prioties.
 * IT-16444
 * 
 *    Rev 1.0   Jun 14 2004 15:42:04   goethalo
 * Initial revision.
 */
package net.arcor.fif.messagecreator;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import net.arcor.fif.common.FIFException;

/**
 * Class representing a bundle of FIF requests. It contains several request
 * objects wrapped in a request list object.
 * 
 * @author goethalo
 */
public class FIFRequestList extends Request {

	/*------------------*
	 * MEMBER VARIABLES *
	 *------------------*/

	/**
	 * The name of the request list.
	 */
	private String name = null;

	/**
	 * The ID of the request list.
	 */
	private String id = null;

	/**
	 * The OMTSOrderID of the request list.
	 */
	private String OMTSOrderID = null;

	/**
	 * The manualRollback of the request list.
	 */
	private String manualRollback = null;

	/**
	 * The HeadeList of the request list.
	 */
	private List<SimpleParameter> headerList = null;

	
	/**
	 * The list of the bundled requests.
	 */
	private List requests = null;

	/*--------------*
	 * CONSTRUCTORS *
	 *--------------*/

	/**
	 * Constructor.
	 */
	public FIFRequestList() {
		super();
		requests = new LinkedList();
	}

	/*---------------------*
	 * GETTERS AND SETTERS *
	 *---------------------*/

	/**
	 * Gets the name of the request list.
	 * 
	 * @return the name of the request list.
	 */
	public String getName() {
		return name;
	}

	/**
	 * Gets the ID of the request list.
	 * 
	 * @return the ID of the request list.
	 */
	public String getID() {
		return id;
	}

	/**
	 * Gets the OMTSOrderID of the request list.
	 * 
	 * @return the OMTSOrderID of the request list.
	 */
	public String getOMTSOrderID() {
		return OMTSOrderID;
	}

	/**
	 * Gets the manualRollback of the request list.
	 * 
	 * @return the manualRollback of the request list.
	 */
	public String getManualRollback() {
		return manualRollback;
	}

	/**
	 * Gets the HeaderList of the request list.
	 * 
	 * @return the HeaderList of the request list.
	 */
	public List<SimpleParameter> getHeaderList() {
		return headerList;
	}
	
	/**
	 * Returns the action.
	 * 
	 * @return String
	 */
	public String getAction() {
		return null;
	}

	/**
	 * Sets the name of the request list.
	 * 
	 * @param name
	 *            the name to set.
	 * @throws FIFException
	 *             if the name could not be set.
	 */
	public void setName(String name) throws FIFException {
		if ((name == null) || (name.trim().length() == 0)) {
			throw new FIFException(
					"Cannot set request list name because the passed "
							+ "in name is null or empty");
		}
		this.name = name;
	}

	/**
	 * Sets the ID of the request list.
	 * 
	 * @param id
	 *            the ID to set.
	 * @throws FIFException
	 *             if the ID could not be set.
	 */
	public void setID(String id) throws FIFException {
		if ((id == null) || (id.trim().length() == 0)) {
			throw new FIFException(
					"Cannot set request list id because the passed "
							+ "in id is null or empty");
		}
		this.id = id;
	}

	/**
	 * Sets the OMTSOrderID of the request list.
	 * 
	 * @param OMTSOrderID
	 *            the OMTSOrderID to set.
	 * @throws FIFException
	 *             if the OMTSOrderID could not be set.
	 */
	public void setOMTSOrderID(String OMTSOrderID) throws FIFException {
		if ((OMTSOrderID == null) || (OMTSOrderID.trim().length() == 0)) {
			throw new FIFException(
					"Cannot set request list OMTSOrderID because the passed "
							+ "in name is null or empty");
		}
		this.OMTSOrderID = OMTSOrderID;
	}

	/**
	 * Sets the manualRollback of the request list.
	 * 
	 * @param manualRollback
	 *            the manualRollback to set.
	 */
	public void setManualRollback(String manualRollback) throws FIFException {
		this.manualRollback = manualRollback;
	}

	/**
	 * Sets the HeaderList of the request list.
	 * 
	 * @param headerList
	 *            the headerList to set.
	 * @throws FIFException
	 *             if the headerList could not be set.
	 */
	public void setHeaderList(List<SimpleParameter> headerList) throws FIFException {
		if ((headerList == null) || (headerList.size() == 0)) {
			throw new FIFException(
					"Cannot set headerList because the passed "
							+ "in list is null or empty");
		}
		this.headerList = headerList;
	}	
	
	
	
	/**
	 * Sets the action.
	 * 
	 * @param action
	 *            The action to set
	 */
	public void setAction(String action) throws FIFException {
		throw new FIFException("Cannot set action on a request list.");
	}

	/**
	 * Adds a request to the request list.
	 * 
	 * @param request
	 *            the FIF request to add.
	 * @throws FIFException
	 *             if the request could not be added.
	 */
	public void addRequest(FIFRequest request) throws FIFException {
		if (request == null) {
			throw new FIFException(
					"Cannot add request to list because the passed "
							+ "in request is null.");
		}
		requests.add(request);
	}

	/**
	 * Sets the requests on the list.
	 * 
	 * @param requests
	 *            the <code>List</code> of requests.
	 * @throws FIFException
	 *             if the requests could not be set.
	 */
	public void setRequests(List requests) throws FIFException {
		if (requests == null) {
			throw new FIFException(
					"Cannot set null request list on RequestList object.");
		}
		this.requests = requests;
	}

	/**
	 * Gets the list containing the bundled requests.
	 * 
	 * @return the <code>List</code> containing the bundled
	 *         <code>FIFRequest</code> objects.
	 */
	public List getRequests() {
		return requests;
	}

	public void sort() {
		ActionComparator actionComp = new ActionComparator();
		Collections.sort(requests, actionComp);
	}

	public static FIFRequestList createFIFRequestList() {
		return new FIFRequestList();
	}

	// looks for a FIF parameter in a FIF request, which can be a single request or a request list
	public String getParameterValue(List<String> searchParameters) {
		// loop through the list of header parameters, if exists 
		List<SimpleParameter> listParameters = getHeaderList();
		if (listParameters != null)
			for (SimpleParameter listParameter : listParameters)
				if (searchParameters.contains(listParameter.getName()))
					return listParameter.getValue();
		
		String value = null;  
		for (Object singleRequest : getRequests()) {
			if (singleRequest instanceof FIFRequest)
				value = ((FIFRequest) singleRequest).getParameterValue(searchParameters);
			if (value != null)
				break;
		}
		return value;
	}
}
