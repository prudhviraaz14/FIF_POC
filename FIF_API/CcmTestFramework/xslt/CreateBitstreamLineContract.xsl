<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
    XSLT file for creating bitstream line
    
    @author wlazlow
-->

<!DOCTYPE XSL [
<!ENTITY CreateSom SYSTEM "CreateSom.xsl">
<!ENTITY Configurations SYSTEM "Configurations.xsl">
]>

<xsl:stylesheet  version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="ISO-8859-1" doctype-system="fif_transaction.dtd"/>
    
    <xsl:template match="/">
        <xsl:element name="CcmFifCommandList">
            <xsl:apply-templates select="//request/request-params"/>
        </xsl:element>       
    </xsl:template>
    
    <!-- som deifinition templates -->       
    &Configurations; 
    <!-- helper templates -->     
    &CreateSom; 
    
    
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
            <!-- variables -->
            <xsl:variable name="orderID">
                <xsl:value-of select="request-param[@name='orderID']"/>              
            </xsl:variable>
            
            <xsl:variable name="somVersion">
                <xsl:value-of select="request-param[@name='somVersion']"/>              
            </xsl:variable>
            
            <xsl:variable name="now">
                <xsl:call-template name="currentTime">
                </xsl:call-template>
            </xsl:variable>        
            
            <xsl:variable name="somOrder"><xsl:text disable-output-escaping="yes">&lt;?xml version="1.0" encoding="UTF-8"?>
            </xsl:text>
                <xsl:text disable-output-escaping="yes">&lt;order somVersion="</xsl:text><xsl:value-of select="$somVersion"/><xsl:text disable-output-escaping="yes">" xmlns="http://www.arcor.net/orderSchema" orderID="</xsl:text><xsl:value-of select="$orderID"/><xsl:text disable-output-escaping="yes">"></xsl:text>
                
                
                <sendingSystem>CCM</sendingSystem>
                <entryUser>CCM</entryUser>
                <entrySystem>CCM</entrySystem>
                
                <entryDateTime><xsl:value-of select="$now"/></entryDateTime>
                <customerContactPoint>KSC</customerContactPoint>
                
                <!-- sales org number -->
                <salesOrganisation>
                    <salesOrganisationNumber type="A">
                        <xsl:value-of select="request-param[@name='salesOrganisationNumber']"/>
                    </salesOrganisationNumber>
                </salesOrganisation>
                
                <!-- customer data -->
                <customerData role="default">
                    <customer ID="CUST-001">
                        <ccbId type="C">
                            <xsl:element name="existing">
                                <xsl:value-of select="request-param[@name='customer']"/>
                            </xsl:element>
                        </ccbId>
                    </customer>
                    <billingAccount ID="ACCT-001">
                        <ccbId type="A">
                            <xsl:element name="existing">
                                <xsl:value-of select="request-param[@name='billingAccount']"/>
                            </xsl:element>
                        </ccbId>
                    </billingAccount>
                    <xsl:if test="request-param[@name='contactRole'] != ''">
                        <contactRole ID="CR-INST" ownerNodeRefID="CUST-001">
                            <changeType>IGNORE</changeType>
                            <ccbId type="R">
                                <xsl:element name="existing">
                                    <xsl:value-of select="request-param[@name='contactRole']"/>
                                </xsl:element>
                            </ccbId>
                        </contactRole>
                    </xsl:if>
                    <xsl:if test="request-param[@name='skeletonContract'] != ''">
                        <skeletonContract ID="SKC-001">
                            <ccbId type="K">
                                <xsl:element name="existing">
                                    <xsl:value-of select="request-param[@name='skeletonContract']"/>
                                </xsl:element>
                            </ccbId>
                        </skeletonContract>
                    </xsl:if>
                    <xsl:if test="request-param[@name='serviceDeliveryContract'] != ''">
                        <serviceDeliveryContract ID="SDC-001">
                            <ccbId type="D">
                                <xsl:element name="existing">
                                    <xsl:value-of select="request-param[@name='serviceDeliveryContract']"/>
                                </xsl:element>
                            </ccbId>
                        </serviceDeliveryContract>
                    </xsl:if>
                </customerData>
                
              
                
                
                <!-- line creation -->
                <lineCreation orderPositionNumber="1">
                    <customerIntention>LineCreation</customerIntention>
                    <xsl:element name="desiredDate">
                        <xsl:value-of select="request-param[@name='desiredDate']"/>
                    </xsl:element>
                    <orderReceivedDate><xsl:value-of select="$now"/></orderReceivedDate>
                    <orderVariant>Echte Neuanschaltung</orderVariant>
                    <beneficiary ID="BEN-001" role="default">
                        <customerNodeRefID>CUST-001</customerNodeRefID>
                    </beneficiary>
                    <payerAllCharges ID="PAY-001">
                        <billingAccountNodeRefID>ACCT-001</billingAccountNodeRefID>
                    </payerAllCharges>
                    <!-- access -->
                    <accesses>
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'ACCESS_NAME_01'"/>
                            <xsl:with-param name="functionConfig" select="'ACCESS_CONFIG_01'"/>
                            <xsl:with-param name="functionList" select="'ACCESS_LIST_01'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                        </xsl:call-template>
                    </accesses>
                    <!-- functions -->
                    <functions>
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_01'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_01'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_01'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'1'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_02'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_02'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_02'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'2'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_03'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_03'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_03'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'3'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_04'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_04'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_04'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'4'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_05'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_05'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_05'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'5'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_06'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_06'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_06'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'6'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_07'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_07'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_07'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'7'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_08'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_08'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_08'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'8'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_09'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_09'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_09'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'9'"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="PrintFunctionNode">
                            <xsl:with-param name="functionName" select="'FUNCTION_NAME_10'"/>
                            <xsl:with-param name="functionConfig" select="'FUNCTION_CONFIG_10'"/>
                            <xsl:with-param name="functionList" select="'FUNCTION_LIST_10'"/>
                            <xsl:with-param name="AccessRef" select="'access-ipBitstream'"/>
                            <xsl:with-param name="FunctionNumber" select="'10'"/>
                        </xsl:call-template>
                    </functions>
                </lineCreation>
                <xsl:text disable-output-escaping="yes">&lt;/order></xsl:text>
            </xsl:variable>
            
            
            
            <!-- call the bus for master data update request -->
            <xsl:element name="CcmFifProcessServiceBusRequestCmd">
                <xsl:element name="command_id">send_servicebuss_request_1</xsl:element>
                <xsl:element name="CcmFifProcessServiceBusRequestInCont">
                    <xsl:element name="package_name">net.arcor.com.epsm_com_001</xsl:element>
                    <xsl:element name="service_name">StartPreclearedFixedLineOrder</xsl:element>
                    <xsl:element name="synch_ind">N</xsl:element>
                    <xsl:element name="external_system_id">
                        <xsl:value-of select="$orderID"/>
                    </xsl:element>
                    <xsl:element name="parameter_value_list">
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">Barcode</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:value-of select="$orderID"/>
                            </xsl:element>                                                                    
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">SendingSystem</xsl:element>
                            <xsl:element name="parameter_value">CCM</xsl:element>
                        </xsl:element>
                        <xsl:element name="CcmFifParameterValueCont">
                            <xsl:element name="parameter_name">SomString</xsl:element>
                            <xsl:element name="parameter_value">
                                <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text><xsl:copy-of select="$somOrder"/><xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>                             
                            </xsl:element>
                        </xsl:element>                       
                    </xsl:element>                   
                </xsl:element>
            </xsl:element>
            
            <!-- create contact  -->
            <xsl:element name="CcmFifCreateContactCmd">
                <xsl:element name="command_id">create_contact</xsl:element>
                <xsl:element name="CcmFifCreateContactInCont">
                    <xsl:element name="customer_number">                       
                        <xsl:value-of select="request-param[@name='customer']"/>
                    </xsl:element>
                    <xsl:element name="contact_type_rd">COM</xsl:element>
                    <xsl:element name="short_description">ipBitstream-Neuanlage über COM</xsl:element>
                    <xsl:element name="long_description_text">
                        <xsl:text>Auftrag  </xsl:text>
                        <xsl:value-of select="$orderID"/>
                        <xsl:text> für ipBitstream-Neuanschaltung wurde an COM gesendet.</xsl:text>                      
                        <xsl:text>&#xA;TransactionID: </xsl:text>
                        <xsl:value-of select="request-param[@name='transactionID']"/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="request-param[@name='clientName']"/>
                        <xsl:text>)</xsl:text>
                    </xsl:element>                    
                </xsl:element>
            </xsl:element>
            
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
