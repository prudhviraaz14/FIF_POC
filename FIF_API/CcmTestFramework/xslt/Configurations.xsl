<!-- isdnConfiguration -->
<xsl:template name="isdnConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'locationAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'salesSegment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dtagFreeText'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'locationTAE'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'asb'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'localAreaCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'carrier'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'serviceProvider'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'oldAccess'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'lineType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'multimediaPort'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'acsIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleRegion'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleDepartment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'inboundPortingSourceAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'witaUsage'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
</xsl:template>

<!-- adslInternetConfiguration -->
<xsl:template name="adslInternetConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'pricingStructureCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'minimumDurationPeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'autoExtension'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'noticePeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTerminationRight'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'DSLBandwidth'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'upstreamBandwidth'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'allowBandwidthDowngrade'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'desiredBandwidth'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'fixedIPAddressChangeType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'userAccountName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
<!--    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTimeWindow'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'projectOrderIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'fixedOrderDateIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template> -->
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'automaticMailingIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
     <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'featuresList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'chargesAndCreditsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tariffOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'remarks'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dialInAccountName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dialInAccountNameStatic'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>            
</xsl:template>

<!-- voicePremiumConfiguration -->
<xsl:template name="voicePremiumConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'pricingStructureCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'minimumDurationPeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'autoExtension'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'noticePeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTerminationRight'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'automaticMailingIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
<!--    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'projectOrderIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template> -->
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'activationType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'customerCallBackNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'featuresList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'chargesAndCreditsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'blockingList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tariffOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'remarks'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'mailboxAlias'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'portingAccessNumbers'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'desiredCountriesList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'connectionType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'allowDifferentConnectionType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
</xsl:template>    




<!-- directoryEntryConfiguration -->
<xsl:template name="directoryEntryConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'directoryEntryType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'inverseSearchIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'titleDescription'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'forename'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'nobilityPrefixDescription'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'surnamePrefix'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'name'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'profession'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'industrialSectorRd'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'listedAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'listedPhoneNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'name2'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'forename2'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'publicationMedia'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'information'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'keyword'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dtagId'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>   
</xsl:template>      

<!-- hardwareConfiguration -->
<xsl:template name="hardwareConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'hardwareServiceCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'articleNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'articleName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'serialNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'orderReason'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'subventionCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'zeroChargeIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'shippingCosts'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'salutationDescription'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'forename'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'name'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'hardwareRecipient'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'hardwareMailingAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'remarks'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'imei'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'sapActionCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'sapOrderId'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'deliveryNoteNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'deliveryDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
   <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'deliveryCompany'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'defectCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template> 
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'defectText'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>     
</xsl:template>

<!-- installationSvcConfiguration -->
<xsl:template name="installationSvcConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'installationPackage'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'quantity'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'signatureRequiredIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'desiredDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'contactPhoneNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'sundayServiceIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
</xsl:template>

<!-- safetyPackageConfiguration -->
<xsl:template name="safetyPackageConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'pricingStructureCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'visTrackingPosition'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'minimumDurationPeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'autoExtension'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'noticePeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTerminationRight'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'remarks'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'activationKey'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tariffOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>  
</xsl:template>

<!-- ngnConfiguration -->
<xsl:template name="ngnConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'locationAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
   <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'salesSegment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dtagFreeText'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'locationTAE'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'asb'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'localAreaCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'carrier'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'serviceProvider'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'oldAccess'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'lineType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'multimediaPort'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'acsIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'iadPin'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'lineID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleRegion'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleDepartment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'inboundPortingSourceAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>   
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'witaUsage'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'accessTechnology'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>     
</xsl:template>    

<!-- voiceBasisConfiguration -->
<xsl:template name="voiceBasisConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'pricingStructureCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'minimumDurationPeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'autoExtension'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'noticePeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTerminationRight'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'discountID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'automaticMailingIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
<!--    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'projectOrderIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template> -->
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'activationType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'customerCallBackNumber'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
     <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'featuresList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'chargesAndCreditsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'blockingList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tariffOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
     <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'portingAccessNumbers'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'desiredCountriesList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'allowDifferentConnectionType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
</xsl:template>      

<!-- tvCenterBundledConfiguration -->
<xsl:template name="tvCenterBundledConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'pricingStructureCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'boardSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignName'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'primaryCustSignDate'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'minimumDurationPeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'autoExtension'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'noticePeriod'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'specialTerminationRight'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'fskLevel'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'allowPartialCancel'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'initialOrderType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'featuresList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'chargesAndCreditsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'conditionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tariffOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'tvCenterOptionsList'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'setTopBoxPinChange'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'tvPinChange'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeClx">
        <xsl:with-param name="nodeName" select="'adultPinChange'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
</xsl:template>  

<!-- ipBitstreamConfiguration -->
<xsl:template name="ipBitstreamConfiguration">
    <xsl:param name="functionList"/>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'locationAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
   <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'salesSegment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'dtagFreeText'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'locationTAE'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'asb'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'localAreaCode'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'carrier'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'serviceProvider'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'oldAccess'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'lineType'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'multimediaPort'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'acsIndicator'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'iadPin'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'lineID'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleRegion'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'responsibleDepartment'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>
    <xsl:call-template name="ChooseNodeAdr">
        <xsl:with-param name="nodeName" select="'inboundPortingSourceAddress'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>   
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'witaUsage'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>    
    <xsl:call-template name="ChooseNode">
        <xsl:with-param name="nodeName" select="'accessTechnology'"/>
        <xsl:with-param name="functionList" select="$functionList"/>
    </xsl:call-template>     
</xsl:template>    
