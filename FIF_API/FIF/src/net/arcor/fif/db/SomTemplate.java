/**
 ***************************************************************************
 *     $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/SomTemplate.java-arc   1.0   Dec 03 2013 06:33:40   schwarje  $
 *    $Revision:   1.0  $
 *    $Workfile:   SomTemplate.java  $
 *      $Author:   schwarje  $
 *        $Date:   Dec 03 2013 06:33:40  $
 *
 *  
 *  Copyright (C) Vodafone
 *
 ***************************************************************************
 *  History
 *  $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/db/SomTemplate.java-arc  $
 * 
 *    Rev 1.0   Dec 03 2013 06:33:40   schwarje
 * Initial revision.
 * 
 * 
 ***************************************************************************  
 */
package net.arcor.fif.db;


public class SomTemplate {
	public String getSomTemplateID() {
		return somTemplateID;
	}
	public void setSomTemplateID(String somTemplateID) {
		this.somTemplateID = somTemplateID;
	}
	public String getDescriptionText() {
		return descriptionText;
	}
	public void setDescriptionText(String descriptionText) {
		this.descriptionText = descriptionText;
	}
	public String getSomTemplate() {
		return somTemplate;
	}
	public void setSomTemplate(String somTemplate) {
		this.somTemplate = somTemplate;
	}
	public boolean isSubTemplate() {
		return isSubTemplate;
	}
	public void setSubTemplate(boolean isSubTemplate) {
		this.isSubTemplate = isSubTemplate;
	}
	private String somTemplateID = null;
	private String descriptionText = null;
	private String somTemplate = null;
	private boolean isSubTemplate = false;
	
}
