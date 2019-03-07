<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
  XSLT file for allocating a cid

  @author schwarje
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
    <xsl:element name="client_name">
      <xsl:value-of select="request-param[@name='clientName']"/>
    </xsl:element>
    <xsl:element name="action_name">
      <xsl:value-of select="//request/action-name"/>
    </xsl:element>
    <xsl:element name="override_system_date">
      <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
    </xsl:element>
    
    <xsl:element name="Command_List">

      <!-- if relocation
        if reconfigure 001x
        if !reconfigure 002x, 003x
        
        if !, as before
        
      -->
      <xsl:if test="request-param[@name='isIpCentrex'] = 'Y'">
        <xsl:if test="request-param[@name='orderPositionType'] = 'relocation'">
          <xsl:element name="CcmFifCreateExternalNotificationCmd">
            <xsl:element name="command_id">create_notification</xsl:element>
            <xsl:element name="CcmFifCreateExternalNotificationInCont">
              <xsl:element name="effective_date">
                <xsl:value-of select="dateutils:getCurrentDate()"/>
              </xsl:element>
              <xsl:element name="transaction_id">
                <xsl:value-of select="request-param[@name='requestListId']"/>
              </xsl:element>
              <xsl:element name="processed_indicator">Y</xsl:element>
              <xsl:element name="notification_action_name">
                <xsl:value-of select="//request/action-name"/>
              </xsl:element>
              <xsl:element name="target_system">FIF</xsl:element>
              <xsl:element name="parameter_value_list">    
                <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
                  <xsl:variable name="ptnSuffix">
                    <xsl:if test="request-param[@name='functionName'] = 'internet'">
                      <xsl:text>i</xsl:text>
                    </xsl:if>          
                    <xsl:if test="request-param[@name='functionName'] = 'directoryEntry'">
                      <xsl:text>t</xsl:text>
                    </xsl:if>          
                    
                    <xsl:if test="request-param[@name='functionName'] = 'seat'">
                      <xsl:text>v</xsl:text>
                      <xsl:if test="position() &lt; 100">0</xsl:if>                  
                      <xsl:if test="position() &lt; 10">0</xsl:if>                  
                      <xsl:value-of select="position()"/>
                    </xsl:if>                  
                  </xsl:variable>
                                  
                  <xsl:choose>
                    <xsl:when test="request-param[@name='processingType'] = 'CHANGE'">
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:text>default</xsl:text>
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:text>001</xsl:text>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	                                  
                    </xsl:when>
                    <xsl:when test="request-param[@name='processingType'] = 'TERM'">
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:text>default</xsl:text>
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:text>002</xsl:text>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	                                  
                    </xsl:when>
                    <xsl:when test="request-param[@name='processingType'] = 'ADD'">
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:text>target</xsl:text>
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:text>003</xsl:text>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	                                  
                    </xsl:when>
                    <xsl:when test="request-param[@name='processingType'] = 'ADDTERM'">
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:text>default</xsl:text>
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:text>002</xsl:text>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	                                  
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:text>target</xsl:text>
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:text>003</xsl:text>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	                                  
                    </xsl:when>
                  </xsl:choose>                      
                </xsl:for-each>
              </xsl:element>          
            </xsl:element>
          </xsl:element>  
          
  
        </xsl:if>
        
        <xsl:if test="request-param[@name='orderPositionType'] != 'relocation'">
          <xsl:variable name="voiceOrder">
            <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
              <xsl:if test="request-param[@name='functionName'] = 'voice'">
                <xsl:text>Y</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
  
          <xsl:variable name="isHardwareOnlyOrder">
            <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
              <xsl:if test="request-param[@name='functionName'] != 'hardware'">
                <xsl:text>N</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>        
                          
          <xsl:choose>
            <xsl:when test="$isHardwareOnlyOrder != ''">
              <xsl:variable name="ptnPrefix">
                <xsl:if test="number(request-param[@name='orderPositionNumber']) &lt; 100">0</xsl:if>                  
                <xsl:if test="number(request-param[@name='orderPositionNumber']) &lt; 10">0</xsl:if>                  
                <xsl:value-of select="request-param[@name='orderPositionNumber']"/>
              </xsl:variable>
              
              <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_notification</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                  <xsl:element name="effective_date">
                    <xsl:value-of select="dateutils:getCurrentDate()"/>
                  </xsl:element>
                  <xsl:element name="transaction_id">
                    <xsl:value-of select="request-param[@name='requestListId']"/>
                  </xsl:element>
                  <xsl:element name="processed_indicator">Y</xsl:element>
                  <xsl:element name="notification_action_name">
                    <xsl:value-of select="//request/action-name"/>
                  </xsl:element>
                  <xsl:element name="target_system">FIF</xsl:element>
                  <xsl:element name="parameter_value_list">            
                    <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
                      <xsl:variable name="ptnSuffix">
                        <xsl:if test="request-param[@name='functionName'] = 'internet'">
                          <xsl:if test="request-param[@name='accessName'] = 'businessDSL'
                            and $voiceOrder != ''">
                            <xsl:text>i</xsl:text>
                          </xsl:if>
                        </xsl:if>          
                        
                        <xsl:if test="request-param[@name='functionName'] = 'voice'">
                          <xsl:if test="request-param[@name='accessName'] != 'ipCentrex' and
                            request-param[@name='accessName'] != 'sipTrunk'">
                            <xsl:text>v</xsl:text>
                          </xsl:if>
                        </xsl:if>                            
                        
                        <xsl:if test="request-param[@name='functionName'] = 'seat'">
                          <xsl:text>v</xsl:text>
                          <xsl:if test="position() &lt; 100">0</xsl:if>                  
                          <xsl:if test="position() &lt; 10">0</xsl:if>                  
                          <xsl:value-of select="position()"/>
                        </xsl:if>          
                        
                        <xsl:if test="request-param[@name='functionName'] = 'safetyPackage'">
                          <xsl:text>f</xsl:text>
                        </xsl:if>          
                        
                        <xsl:if test="request-param[@name='functionName'] = 'directoryEntry'">
                          <xsl:if test="request-param[@name='accessName'] != 'ipCentrex' and
                            request-param[@name='accessName'] != 'sipTrunk'">v</xsl:if>
                          <xsl:text>t</xsl:text>
                        </xsl:if>          
                        
                        <xsl:if test="request-param[@name='functionName'] = 'installationSvc'">
                          <xsl:variable name="parentFunctionID">
                            <xsl:value-of select="request-param[@name='parentFunctionID']"/>
                          </xsl:variable>
                          <xsl:for-each select="../../request-param-list[@name='functionList']/request-param-list-item">
                            <xsl:if test="$parentFunctionID = request-param[@name='functionID']">
                              <xsl:if test="request-param[@name='functionName'] = 'internet'
                                and $voiceOrder != ''">
                                <xsl:text>i</xsl:text>
                              </xsl:if>          
                              <xsl:if test="request-param[@name='functionName'] = 'seat'">
                                <xsl:text>v</xsl:text>
                                <xsl:if test="position() &lt; 100">0</xsl:if>                  
                                <xsl:if test="position() &lt; 10">0</xsl:if>                  
                                <xsl:value-of select="position()"/>
                              </xsl:if>          
                            </xsl:if>                  
                          </xsl:for-each>
                          <xsl:text>is</xsl:text>
                        </xsl:if>                                    
                      </xsl:variable>
                      
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:value-of select="$ptnPrefix"/>
                          <xsl:value-of select="$ptnSuffix"/>
                        </xsl:element>
                      </xsl:element>	              
                    </xsl:for-each>
                  </xsl:element>          
                </xsl:element>
              </xsl:element>              
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="CcmFifCreateExternalNotificationCmd">
                <xsl:element name="command_id">create_notification</xsl:element>
                <xsl:element name="CcmFifCreateExternalNotificationInCont">
                  <xsl:element name="effective_date">
                    <xsl:value-of select="dateutils:getCurrentDate()"/>
                  </xsl:element>
                  <xsl:element name="transaction_id">
                    <xsl:value-of select="request-param[@name='requestListId']"/>
                  </xsl:element>
                  <xsl:element name="processed_indicator">Y</xsl:element>
                  <xsl:element name="notification_action_name">
                    <xsl:value-of select="//request/action-name"/>
                  </xsl:element>
                  <xsl:element name="target_system">FIF</xsl:element>
                  <xsl:element name="parameter_value_list">            
                    <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
                      <xsl:element name="CcmFifParameterValueCont">
                        <xsl:element name="parameter_name">
                          <xsl:value-of select="request-param[@name='functionID']"/>
                          <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                        </xsl:element>
                        <xsl:element name="parameter_value">
                          <xsl:if test="position() &lt; 100">0</xsl:if>                  
                          <xsl:if test="position() &lt; 10">0</xsl:if>                  
                          <xsl:value-of select="position()"/>
                        </xsl:element>
                      </xsl:element>	              
                    </xsl:for-each>
                  </xsl:element>          
                </xsl:element>
              </xsl:element>           
            </xsl:otherwise>
          </xsl:choose>
                          
        </xsl:if>
      </xsl:if>
 
      <xsl:if test="request-param[@name='isIpCentrex'] != 'Y'">
        <xsl:element name="CcmFifCreateExternalNotificationCmd">
          <xsl:element name="command_id">create_notification</xsl:element>
          <xsl:element name="CcmFifCreateExternalNotificationInCont">
            <xsl:element name="effective_date">
              <xsl:value-of select="dateutils:getCurrentDate()"/>
            </xsl:element>
            <xsl:element name="transaction_id">
              <xsl:value-of select="request-param[@name='requestListId']"/>
            </xsl:element>
            <xsl:element name="processed_indicator">Y</xsl:element>
            <xsl:element name="notification_action_name">
              <xsl:value-of select="//request/action-name"/>
            </xsl:element>
            <xsl:element name="target_system">FIF</xsl:element>
            <xsl:element name="parameter_value_list">    
              <xsl:for-each select="request-param-list[@name='functionList']/request-param-list-item">
                <xsl:variable name="ptnSuffix">
                  <xsl:if test="request-param[@name='functionName'] = 'internet' 
                    and request-param[@name='accessName'] = 'isdn'">
                    <xsl:text>i</xsl:text>
                  </xsl:if>          
                  <xsl:if test="request-param[@name='functionName'] = 'voice' 
                    and request-param[@name='accessName'] != 'isdn'">
                    <xsl:text>v</xsl:text>
                    <xsl:if test="request-param[@name='changePreviousOrderPositionIndicator'] = 'Y'">
                      <xsl:text>c</xsl:text>
                    </xsl:if>
                  </xsl:if>          
                  <xsl:if test="request-param[@name='functionName'] = 'safetyPackage'">
                    <xsl:text>f</xsl:text>
                  </xsl:if>          
                  <xsl:if test="request-param[@name='functionName'] = 'tvCenter'">
                    <xsl:text>h</xsl:text>
                  </xsl:if>          
                  <xsl:if test="request-param[@name='functionName'] = 'directoryEntry'">
                    <xsl:text>t</xsl:text>
                  </xsl:if>          
                  <xsl:if test="request-param[@name='functionName'] = 'hardware'">
                    <xsl:text>w</xsl:text>
                    <xsl:if test="position() &lt; 100">0</xsl:if>                  
                    <xsl:if test="position() &lt; 10">0</xsl:if>                  
                    <xsl:value-of select="position()"/>
                  </xsl:if>  
                  <xsl:if test="request-param[@name='functionName'] = 'installationSvc'">
                    <xsl:text>is</xsl:text>
                  </xsl:if>
                </xsl:variable>
                
                <xsl:choose>
                  <xsl:when test="request-param[@name='processingType'] = 'CHANGE'">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">
                        <xsl:text>default</xsl:text>
                        <xsl:value-of select="request-param[@name='functionID']"/>
                        <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                      </xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:text>001</xsl:text>
                        <xsl:value-of select="$ptnSuffix"/>
                      </xsl:element>
                    </xsl:element>	                                  
                  </xsl:when>
                  <xsl:when test="request-param[@name='processingType'] = 'TERM'">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">
                        <xsl:text>default</xsl:text>
                        <xsl:value-of select="request-param[@name='functionID']"/>
                        <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                      </xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:text>002</xsl:text>
                        <xsl:value-of select="$ptnSuffix"/>
                      </xsl:element>
                    </xsl:element>	                                  
                  </xsl:when>
                  <xsl:when test="request-param[@name='processingType'] = 'ADD'">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">
                        <xsl:text>target</xsl:text>
                        <xsl:value-of select="request-param[@name='functionID']"/>
                        <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                      </xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:text>003</xsl:text>
                        <xsl:value-of select="$ptnSuffix"/>
                      </xsl:element>
                    </xsl:element>	                                  
                  </xsl:when>
                  <xsl:when test="request-param[@name='processingType'] = 'ADDTERM'">
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">
                        <xsl:text>default</xsl:text>
                        <xsl:value-of select="request-param[@name='functionID']"/>
                        <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                      </xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:text>002</xsl:text>
                        <xsl:value-of select="$ptnSuffix"/>
                      </xsl:element>
                    </xsl:element>	                                  
                    <xsl:element name="CcmFifParameterValueCont">
                      <xsl:element name="parameter_name">
                        <xsl:text>target</xsl:text>
                        <xsl:value-of select="request-param[@name='functionID']"/>
                        <xsl:text>_PROVIDER_TRACKING_NUMBER</xsl:text>
                      </xsl:element>
                      <xsl:element name="parameter_value">
                        <xsl:text>003</xsl:text>
                        <xsl:value-of select="$ptnSuffix"/>
                      </xsl:element>
                    </xsl:element>	                                  
                  </xsl:when>
                </xsl:choose>                      
              </xsl:for-each>
            </xsl:element>          
          </xsl:element>
        </xsl:element> 
      </xsl:if>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
