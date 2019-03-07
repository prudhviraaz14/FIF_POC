<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  Creates product subscription groups and adds / removes items

  @author banania
-->
<xsl:stylesheet exclude-result-prefixes="dateutils" version="1.0"
  xmlns:dateutils="http://xml.apache.org/xalan/java/net.arcor.fif.common.DateUtils" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
  <xsl:template match="/">
    <xsl:element name="CcmFifCommandList">
      <xsl:apply-templates select="request/request-params"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="request-params">
    <!-- Copy over transaction ID and action name -->
    <xsl:element name="transaction_id">
      <xsl:value-of select="request-param[@name='transactionID']"/>
    </xsl:element>
    <xsl:element name="client_name">SLS</xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
        <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    <xsl:element name="Command_List">
    
      <xsl:variable name="Today" select="dateutils:getCurrentDate()"/>

      <xsl:variable name="DesiredDate">
        <xsl:choose>
            <xsl:when test="request-param[@name='desiredDate'] = ''">
            <xsl:value-of select="$Today"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="request-param[@name='desiredDate']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="Action">
        <xsl:value-of select="request-param[@name='action']"/>
      </xsl:variable>		
      <xsl:variable name="ProductSubscriptionId">
        <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
      </xsl:variable>		
      <xsl:variable name="ProductSubscriptionGroupId">
        <xsl:value-of select="request-param[@name='productSubscriptionGroupId']"/>
      </xsl:variable>
      <xsl:variable name="CreateProductSubscriptionGroup">
        <xsl:value-of select="request-param[@name='createProductSubscriptionGroup']"/>
      </xsl:variable>		

      <!--  Validate parameter "ACTION_TYPE"  --> 
      <xsl:if test="$Action != ''
        and $Action != 'ADD'
        and $Action != 'REMOVE'">
        <xsl:element name="CcmFifRaiseErrorCmd">
          <xsl:element name="command_id">raise_error_1</xsl:element> 
          <xsl:element name="CcmFifRaiseErrorInCont">
            <xsl:element name="error_text">Allowed values for parameter "action": 'ADD' and 'REMOVE'.</xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      
     <!--  Validate parameters action & createProductSubscriptionGroup --> 
     <xsl:if test="$Action = ''
         and count(request-param-list[@name='productSubscriptionList']/request-param-list-item) = 0
         and $CreateProductSubscriptionGroup != 'Y'">
        <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">raise_error_2</xsl:element> 
            <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">The parameter createProductSubscriptionGroup can not be set to 'N' if action is empty.</xsl:element>
            </xsl:element>
        </xsl:element>
     </xsl:if>
        
    <!--  Validate parameters action, productSubscriptionGroupId & createProductSubscriptionGroup --> 
        <xsl:if test="($Action != '' or count(request-param-list[@name='productSubscriptionList']/request-param-list-item) != 0)
        and $CreateProductSubscriptionGroup != 'Y'
        and $ProductSubscriptionGroupId = ''">
        <xsl:element name="CcmFifRaiseErrorCmd">
            <xsl:element name="command_id">raise_error_3</xsl:element> 
            <xsl:element name="CcmFifRaiseErrorInCont">
                <xsl:element name="error_text">The parameter productSubscriptionGroupId can not be empty if createProductSubscriptionGroup is set to 'N' and action is not empty .</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:if>
        
      <xsl:variable name="ContactActionType">  
        <xsl:choose>
          <xsl:when test ="$Action = 'ADD'">
            <xsl:text>erstellt </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>deaktiviert </xsl:text>
          </xsl:otherwise>
        </xsl:choose>                      
      </xsl:variable>
      
      <xsl:if test="$CreateProductSubscriptionGroup = 'Y'">	
           <!-- Create product subscription Group --> 
          <xsl:element name="CcmFifCreateProdSubsGroupCmd">
            <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
            <xsl:element name="CcmFifCreateProdSubsGroupInCont">
              <xsl:element name="customer_number">
                <xsl:value-of select="request-param[@name='customerNumber']"/>
              </xsl:element>
              <xsl:element name="product_sub_group_name">
                <xsl:value-of select="request-param[@name='name']"/>
              </xsl:element>
              <xsl:element name="product_sub_group_description">
                <xsl:value-of select="request-param[@name='description']"/>
              </xsl:element>
              <xsl:element name="effective_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
      </xsl:if>  

      <xsl:if test="count(request-param-list[@name='productSubscriptionList']/request-param-list-item) != 0">
        
         <xsl:for-each select="request-param-list[@name='productSubscriptionList']/request-param-list-item">
           <xsl:variable name="NodePosition" select="position()"/> 
          <xsl:element name="CcmFifAddRemoveProdSubscrProdSubscrGroupCmd">
            <xsl:element name="command_id">
              <xsl:value-of select="concat('create_pspsg_', $NodePosition)"/>
            </xsl:element>
            <xsl:element name="CcmFifAddRemoveProdSubscrProdSubscrGroupInCont">
              <xsl:element name="product_subscription_id">
                <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
              </xsl:element>
              <xsl:if test="$CreateProductSubscriptionGroup = 'Y'">	
                <xsl:element name="product_subs_group_ref">
                  <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
                  <xsl:element name="field_name">product_subs_group_id</xsl:element>
                </xsl:element>
              </xsl:if>
              <xsl:if test="$CreateProductSubscriptionGroup != 'Y'">	
                <xsl:element name="product_subs_group_id">
                    <xsl:value-of select="$ProductSubscriptionGroupId"/>
                </xsl:element>
              </xsl:if>
              <xsl:element name="desired_date">
                <xsl:value-of select="$DesiredDate"/>
              </xsl:element>
              <xsl:element name="action_type">
                  <xsl:value-of select="request-param[@name='action']"/>
              </xsl:element>
            </xsl:element>
          </xsl:element> 
         </xsl:for-each> 
      </xsl:if>  
      
      <xsl:if test="$Action != '' 
        and count(request-param-list[@name='productSubscriptionList']/request-param-list-item) = 0">	
        <!-- Create product subscription Group --> 
        <xsl:element name="CcmFifAddRemoveProdSubscrProdSubscrGroupCmd">
          <xsl:element name="command_id">create_pspsg_1</xsl:element>
          <xsl:element name="CcmFifAddRemoveProdSubscrProdSubscrGroupInCont">
            <xsl:element name="product_subscription_id">
              <xsl:value-of select="$ProductSubscriptionId"/>
            </xsl:element>
            <xsl:if test="$CreateProductSubscriptionGroup = 'Y'">	
              <xsl:element name="product_subs_group_ref">
                <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
                <xsl:element name="field_name">product_subs_group_id</xsl:element>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$CreateProductSubscriptionGroup != 'Y'">	
              <xsl:element name="product_subs_group_id">
                <xsl:value-of select="$ProductSubscriptionGroupId"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="desired_date">
              <xsl:value-of select="$DesiredDate"/>
            </xsl:element>
            <xsl:element name="action_type">
              <xsl:value-of select="$Action"/>
            </xsl:element>
          </xsl:element>
        </xsl:element> 
      </xsl:if>
      
      <xsl:if test="request-param[@name='createContact'] != 'N'">
      <!-- Create Contact -->
        <xsl:element name="CcmFifCreateContactCmd">
          <xsl:element name="command_id">create_contact</xsl:element>
          <xsl:element name="CcmFifCreateContactInCont">
            <xsl:element name="customer_number">
              <xsl:value-of select="request-param[@name='customerNumber']"/>
            </xsl:element>
            <xsl:element name="contact_type_rd">
            <xsl:choose>
              <xsl:when test="request-param[@name='contactType'] != ''">
                <xsl:value-of select="request-param[@name='contactType']"/>
              </xsl:when>
              <xsl:otherwise>PROD_SUBS</xsl:otherwise>
            </xsl:choose>
            </xsl:element>
            <xsl:element name="short_description">
              <xsl:choose>
                <xsl:when test="request-param[@name='shortDescription'] != ''">
                  <xsl:value-of select="request-param[@name='shortDescription']"/>
                </xsl:when>
                <xsl:otherwise>Änderung Prod. Gruppe</xsl:otherwise>
              </xsl:choose>
            </xsl:element>            
            <xsl:element name="description_text_list">
              <xsl:choose>
                <xsl:when test="request-param[@name='longDescriptionText'] != ''">
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="contact_text">  
                  <xsl:value-of select="request-param[@name='longDescriptionText']"/>
                  <xsl:text>&#xA;</xsl:text>
                    </xsl:element>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="count(request-param-list[@name='productSubscriptionList']/request-param-list-item) != 0">
                      <xsl:if test="$CreateProductSubscriptionGroup != 'Y'">
                        <xsl:element name="CcmFifPassingValueCont">
                          <xsl:element name="contact_text">  
                            <xsl:text>&#xA;Die Verknüpfung zwischen der Produktgruppe: </xsl:text>
                            <xsl:value-of select="$ProductSubscriptionGroupId"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:if>
                      <xsl:if test="$CreateProductSubscriptionGroup = 'Y'">	
                        <xsl:element name="CcmFifPassingValueCont">
                          <xsl:element name="contact_text">
                            <xsl:text>&#xA;Die Verknüpfung zwischen der Produktgruppe: </xsl:text>
                          </xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifCommandRefCont">
                          <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
                          <xsl:element name="field_name">product_subs_group_id</xsl:element>
                        </xsl:element>
                      </xsl:if>
                      <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text">  
                          <xsl:text>&#xA; und der Produktnutzung(en)wurde erstellt/deaktiviert. </xsl:text>
                        </xsl:element>
                      </xsl:element>
                      <xsl:for-each select="request-param-list[@name='productSubscriptionList']/request-param-list-item">
                      <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text">  
                            <xsl:text>&#xA;Produktnutzung:</xsl:text>
                            <xsl:value-of select="request-param[@name='productSubscriptionId']"/>
                            <xsl:text>&#xA;Action:</xsl:text>
                            <xsl:value-of select="request-param[@name='action']"/>
                            <xsl:text>&#xA;</xsl:text>
                        </xsl:element>
                      </xsl:element>
                      </xsl:for-each>	
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:if test="$CreateProductSubscriptionGroup != 'Y'">	
                        <xsl:element name="CcmFifPassingValueCont">
                          <xsl:element name="contact_text"> 
                              <xsl:text>&#xA;Die Verknüpfung zwischen der Produktgruppe: </xsl:text>
                                <xsl:value-of select="$ProductSubscriptionGroupId"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:if>
                        <xsl:if test="$CreateProductSubscriptionGroup = 'Y'">	
                          <xsl:element name="CcmFifPassingValueCont">
                            <xsl:element name="contact_text">
                              <xsl:text>&#xA;Die Verknüpfung zwischen der Produktgruppe: </xsl:text>
                            </xsl:element>
                          </xsl:element>
                          <xsl:element name="CcmFifCommandRefCont">
                            <xsl:element name="command_id">create_prod_subs_group_1</xsl:element>
                            <xsl:element name="field_name">product_subs_group_id</xsl:element>
                          </xsl:element>
                        </xsl:if>
                      <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="contact_text"> 
                          <xsl:text>&#xA; und der Produktnutzung: </xsl:text>
                            <xsl:value-of select="$ProductSubscriptionId"/>
                          <xsl:text>&#xA; wurde </xsl:text>
                          <xsl:value-of select="$ContactActionType"/>
                        </xsl:element>
                      </xsl:element>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:element name="CcmFifPassingValueCont">
                    <xsl:element name="contact_text"> 
                      <xsl:text>&#xA; Desired date: </xsl:text>
                      <xsl:value-of select="$DesiredDate"/>
                      <xsl:text>&#xA; FIF Client Name: </xsl:text>
                      <xsl:value-of select="request-param[@name='clientName']"/>
                      <xsl:text>&#xA; TransactionID: </xsl:text>
                      <xsl:value-of select="request-param[@name='transactionID']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:otherwise>
             </xsl:choose>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        </xsl:if>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
