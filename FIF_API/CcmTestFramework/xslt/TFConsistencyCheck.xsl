<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  XSLT file for creating a FIF request for consistency check

  @author Wlazlo
-->
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
      <xsl:element name="action_name">
         <xsl:value-of select="//request/action-name"/>
      </xsl:element>
      <xsl:element name="override_system_date">
         <xsl:value-of select="request-param[@name='OVERRIDE_SYSTEM_DATE']"/>
      </xsl:element>
      <xsl:element name="Command_List">
         <!-- Consistency Check-->
         <xsl:element name="CcmFifConsistencyCheckCmd">
            <xsl:element name="command_id">consistency_check_1</xsl:element>
            <xsl:element name="CcmFifConsistencyCheckInCont">
               <xsl:element name="table_name">
                  <xsl:value-of select="request-param[@name='TABLE_NAME']"/>
               </xsl:element>
               <xsl:element name="column_name_list">
                  <xsl:for-each select="request-param-list[@name='COLUMNs']/request-param-list-item">
                     <xsl:element name="CcmFifPassingValueCont">
                        <xsl:element name="column">
                           <xsl:value-of select="request-param[@name='COLUMN']"/>
                        </xsl:element>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
               <xsl:element name="sql_where">
                  <xsl:value-of select="request-param[@name='SQL_WHERE']"/>
               </xsl:element>
               <xsl:element name="parameter_name_list">
                  <xsl:for-each select="request-param-list[@name='PARAMs']/request-param-list-item">
                     <xsl:element name="CcmFifParameterValueCont">
                        <xsl:for-each select="./child::node()">
                           <xsl:if test="string(.)">
                              <xsl:element name="parameter_name">
                                 <xsl:value-of select="@name"/>
                              </xsl:element>
                              <xsl:element name="parameter_value">
                                 <xsl:value-of select="."/>
                              </xsl:element>
                           </xsl:if>
                        </xsl:for-each>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:element>
               <xsl:element name="row_number_check">
                  <xsl:value-of select="request-param[@name='ROW_NUMBER_CHECK']"/>
               </xsl:element>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
