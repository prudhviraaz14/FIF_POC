

<!-- give current time in the som format -->
<xsl:template name="currentTime" xmlns:cal="xalan://java.util.GregorianCalendar">
    <xsl:variable name="rightNow" select="cal:getInstance()" />      
    <xsl:variable name="month" select="cal:get($rightNow, 2) + 1" />
    <xsl:variable name="day" select="cal:get($rightNow, 5) " />
    <xsl:variable name="year" select="cal:get($rightNow, 1)" />
    <xsl:variable name="hour" select="cal:get($rightNow, 11) " />
    <xsl:variable name="minutes" select="cal:get($rightNow, 12) " />
    <xsl:variable name="seconds" select="cal:get($rightNow, 13)" />
    <xsl:value-of select="$year" />
    <xsl:text>-</xsl:text>
    <xsl:if test="string-length($month)=1">0</xsl:if>
    <xsl:value-of select="$month"/>
    <xsl:text>-</xsl:text>
    <xsl:if test="string-length($day)=1">0</xsl:if>
    <xsl:value-of select="$day"/>
    <xsl:text>T</xsl:text>
    <xsl:if test="string-length($hour)=1">0</xsl:if>
    <xsl:value-of select="$hour"/>
    <xsl:text>:</xsl:text>
    <xsl:if test="string-length($minutes)=1">0</xsl:if>
    <xsl:value-of select="$minutes"/>
    <xsl:text>:</xsl:text>
    <xsl:if test="string-length($seconds)=1">0</xsl:if>
    <xsl:value-of select="$seconds"/>
</xsl:template>


<!-- node printing -->
<xsl:template name="output-tokens">
    <xsl:param name="list"/>
    <xsl:variable name="first" select="substring-before($list, ';')"/>
    <xsl:variable name="remaining" select="substring-after($list, ';')"/>
    <xsl:variable name="second" select="substring-before($remaining, ';')"/>
    <xsl:variable name="remaining" select="substring-after($remaining, ';')"/>
    <xsl:element name="{$first}">
        <xsl:element name="configured">
            <xsl:choose>
                <xsl:when test="contains($first , 'accessNumber') or 
                               contains($first , 'lineOwner') or 
                               contains($first , 'msisdn')">
                    <xsl:call-template name="output-tokens-access">
                        <xsl:with-param name="list" select="$second"/>
                    </xsl:call-template>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$second"/>
                </xsl:otherwise>
            </xsl:choose>
           
           
        </xsl:element>
    </xsl:element>
    <xsl:if test="$remaining">
        <xsl:call-template name="output-tokens">
            <xsl:with-param name="list" select="$remaining"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>


<xsl:template name="output-tokens-access">
    <xsl:param name="list"/>
    <xsl:variable name="first" select="substring-before($list, '$')"/>
    <xsl:variable name="remaining" select="substring-after($list, '$')"/>
    <xsl:variable name="second" select="substring-before($remaining, '$')"/>
    <xsl:variable name="remaining" select="substring-after($remaining, '$')"/>
    <xsl:element name="{$first}">       
        <xsl:value-of select="$second"/>        
     </xsl:element>
    <xsl:if test="$remaining">
        <xsl:call-template name="output-tokens-access">
            <xsl:with-param name="list" select="$remaining"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="output-tokens-adr">
    <xsl:param name="list"/>
    <xsl:variable name="first" select="substring-before($list, ';')"/>
    <xsl:variable name="remaining" select="substring-after($list, ';')"/>
    <xsl:variable name="second" select="substring-before($remaining, ';')"/>
    <xsl:variable name="remaining" select="substring-after($remaining, ';')"/>
    <xsl:element name="{$first}">   
        <xsl:choose>
            <xsl:when test="contains($first , 'conditionService') or
                contains($first , 'tariffOption') or
                contains($first , 'tvCenterOption')">
                <xsl:call-template name="output-tokens-access">
                    <xsl:with-param name="list" select="$second"/>
                </xsl:call-template>                    
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$second"/>
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:element>
    <xsl:if test="$remaining">
        <xsl:call-template name="output-tokens-adr">
            <xsl:with-param name="list" select="$remaining"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="PrintComplxNode">
    <xsl:param name="complxName"/>
    <xsl:param name="complxValue"/>    
    <xsl:element name="{$complxName}">        
        <xsl:call-template name="output-tokens">
            <xsl:with-param name="list" select="$complxValue"/>
        </xsl:call-template>
    </xsl:element>
</xsl:template>

<xsl:template name="PrintComplxAdrNode">
    <xsl:param name="complxName"/>
    <xsl:param name="complxValue"/>    
    <xsl:element name="{$complxName}">
        <xsl:element name="configured">
            <xsl:call-template name="output-tokens-adr">
                <xsl:with-param name="list" select="$complxValue"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:element>
</xsl:template>



<xsl:template name="ChooseNodeAdr">
    <xsl:param name="nodeName"/>
    <xsl:param name="functionList"/>
    <xsl:for-each select="/*/*/request-param-list[@name=$functionList]/request-param-list-item">
        <xsl:variable name="name">
            <xsl:value-of
                select="request-param[@name='PARAM_NAME']"/>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:value-of
                select="request-param[@name='PARAM_VALUE']"/>
        </xsl:variable>
               
        <xsl:if test="$nodeName = $name">
                     <xsl:call-template name="PrintComplxAdrNode">
                        <xsl:with-param name="complxName">
                            <xsl:value-of select="$name"/>
                        </xsl:with-param>
                        <xsl:with-param name="complxValue">
                            <xsl:value-of select="$value"/>
                        </xsl:with-param>
                    </xsl:call-template>
         </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template name="ChooseNodeClx">
    <xsl:param name="nodeName"/>
    <xsl:param name="functionList"/>
    <xsl:for-each select="/*/*/request-param-list[@name=$functionList]/request-param-list-item">
        <xsl:variable name="name">
            <xsl:value-of
                select="request-param[@name='PARAM_NAME']"/>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:value-of
                select="request-param[@name='PARAM_VALUE']"/>
        </xsl:variable>
        
        <xsl:if test="$nodeName = $name">
            <xsl:call-template name="PrintComplxNode">
                <xsl:with-param name="complxName">
                    <xsl:value-of select="$name"/>
                </xsl:with-param>
                <xsl:with-param name="complxValue">
                    <xsl:value-of select="$value"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="ChooseNode">
    <xsl:param name="nodeName"/>
    <xsl:param name="functionList"/>
    <xsl:for-each select="/*/*/request-param-list[@name=$functionList]/request-param-list-item">
        <xsl:variable name="name">
            <xsl:value-of select="request-param[@name='PARAM_NAME']"/>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:value-of select="request-param[@name='PARAM_VALUE']"/>
        </xsl:variable>
        
        <xsl:if test="$nodeName = $name">
                <xsl:element name="{$name}">
                    <xsl:element name="configured">
                        <xsl:value-of select="$value"/>
                    </xsl:element>
                </xsl:element>
         </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- print contact role node -->
<xsl:template name="PrintContactRole">   
    <xsl:for-each select="/*/*/request-param">
        <xsl:if test="@name = 'contactRole' and . != ''">            
            <contactRoleRefIdList>
                <contactRoleRef>
                    <configured>CR-INST</configured>
                </contactRoleRef>
            </contactRoleRefIdList>              
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- print skeleton contract node -->
<xsl:template name="PrintSkeletonContract">   
    <xsl:for-each select="/*/*/request-param">        
        <xsl:if test="@name='skeletonContract' and . != ''">
            <skeletonContractCcbId>
                <xsl:element name="existing">
                    <xsl:value-of select="."/>
                </xsl:element>
            </skeletonContractCcbId>
        </xsl:if>
     </xsl:for-each>
</xsl:template>

<!-- print serviceDeliveryContract node -->
<xsl:template name="PrintServiceDeliveryContract">   
    <xsl:for-each select="/*/*/request-param">        
        <xsl:if test="@name='serviceDeliveryContract' and . != ''">
            <serviceDeliveryContractCcbId>
                <xsl:element name="existing">
                    <xsl:value-of select="."/>
                </xsl:element>
            </serviceDeliveryContractCcbId>
        </xsl:if>
    </xsl:for-each>
</xsl:template>




<!-- main printing tmplate -->

<xsl:template name="PrintFunctionNode">
    <xsl:param name="functionName"/>
    <xsl:param name="functionConfig"/>
    <xsl:param name="functionList"/>
    <xsl:param name="AccessRef"/>
    <xsl:param name="FunctionNumber"/>
   
 <xsl:for-each select="/*/*/request-param"> 
        
        <xsl:if test="@name=$functionName">
            <xsl:variable name="funcID">
                <xsl:choose>
                    <xsl:when test=". = 'isdn' or . = 'ngn' or . = 'ipBitstream'">
                        <xsl:value-of select="concat('access-',.)"/>
                    </xsl:when>
                    <xsl:when test=". = 'internet' or . = 'voice'">
                        <xsl:value-of select="concat('func-',.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('func-',substring(.,1,3),'-',$FunctionNumber)"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:variable>
            <xsl:variable name="functionName"><xsl:value-of select="."/></xsl:variable>
            <xsl:element name="{.}">
                <xsl:attribute name="ID">
                    <xsl:value-of select="$funcID"/>
                </xsl:attribute>
            
                <xsl:choose>
                    <xsl:when test=". = 'voice' or . = 'internet' or . = 'tvCenter'">
                        <xsl:attribute name="refAccessID">
                            <xsl:value-of select="$AccessRef"/>
                        </xsl:attribute>
                        <processingType>ADD</processingType>
                    </xsl:when>                  
                    <xsl:when test=". = 'safetyPackage'">                    
                        <processingType>ADD</processingType>
                    </xsl:when>
                    <xsl:when test="$AccessRef = 'access-ngn' and (. = 'hardware' or .='installationSvc')">                    
                        <processingType>ADD</processingType>
                        <refFunctionID>
                            <configured>func-internet</configured>
                        </refFunctionID>   
                    </xsl:when>
					 <xsl:when test="$AccessRef = 'access-ipBitstream' and (. = 'hardware' or .='installationSvc')">                    
                        <processingType>ADD</processingType>
                        <refFunctionID>
                            <configured>func-internet</configured>
                        </refFunctionID>   
                    </xsl:when>
                    <xsl:when test="$AccessRef = 'access-isdn' and (. = 'hardware' or .='installationSvc')">                    
                        <processingType>ADD</processingType>
                        <refFunctionID>
                            <configured>func-voice</configured>
                        </refFunctionID>   
                    </xsl:when>
                    <xsl:when test=". = 'directoryEntry'">                    
                        <processingType>ADD</processingType>
                        <refFunctionID>
                            <configured>func-voice</configured>
                        </refFunctionID>   
                    </xsl:when>
                    
                </xsl:choose>
             
                <xsl:choose>
                    <!-- contact role node -->
                    <xsl:when test=". = 'isdn' or . = 'ngn' or . = 'ipBitstream'">    
                        <xsl:call-template name="PrintContactRole"/>   
                       
                    </xsl:when>      
                    <!-- skeletonContract and serviceDeliveryContract nodes -->
                    <xsl:when test=". = 'voice' or . = 'internet'">                        
                        <xsl:call-template name="PrintServiceDeliveryContract"/>
                        <xsl:call-template name="PrintSkeletonContract"/>
                    </xsl:when>            
                </xsl:choose>
                
                <xsl:for-each select="/*/*/request-param">
                    <xsl:if test="@name=$functionConfig">
                        
                        <xsl:variable name="functionConfigName">
                            <xsl:value-of select="."/>
                        </xsl:variable>
                 
                        <xsl:element name="{$functionConfigName}">
                            <xsl:choose>
                                <xsl:when test="$functionConfigName = 'isdnConfiguration'">
                                    <xsl:call-template name="isdnConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$functionConfigName = 'adslInternetConfiguration'">
                                    <xsl:call-template name="adslInternetConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'voicePremiumConfiguration'">
                                    <xsl:call-template name="voicePremiumConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'directoryEntryConfiguration'">
                                    <xsl:call-template name="directoryEntryConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'hardwareConfiguration'">
                                    <xsl:call-template name="hardwareConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>                                   
                                <xsl:when test="$functionConfigName = 'installationSvcConfiguration'">
                                    <xsl:call-template name="installationSvcConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'safetyPackageConfiguration'">
                                    <xsl:call-template name="safetyPackageConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'tvCenterBundledConfiguration'">
                                    <xsl:call-template name="tvCenterBundledConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'ngnConfiguration'">
                                    <xsl:call-template name="ngnConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'voiceBasisConfiguration'">
                                    <xsl:call-template name="voiceBasisConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                <xsl:when test="$functionConfigName = 'ipBitstreamConfiguration'">
                                    <xsl:call-template name="ipBitstreamConfiguration">                                      
                                        <xsl:with-param name="functionList" select="$functionList"/>
                                    </xsl:call-template>
                                </xsl:when>   
                                
                            </xsl:choose>                                                     
                        </xsl:element>
                        
                    </xsl:if>
                </xsl:for-each>
                
            </xsl:element>
        </xsl:if>
 </xsl:for-each> 
</xsl:template>
