<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:param name="pathtoproject"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="homePageContent">
        <xsl:element name="homePageContent">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="h3">        
        <xsl:variable name="heading-count"
            select="count(preceding-sibling::h3) + 1"/>
        <xsl:element name="section">
            <xsl:element name="title">
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:element>
            <xsl:for-each select="following-sibling::element()">
                <xsl:call-template name="process-siblings">
                    <xsl:with-param name="heading-node" select="$heading-count"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="process-siblings">
        <xsl:param name="heading-node"/>
        <xsl:choose>
            <xsl:when test="self::h3"></xsl:when>
            <xsl:when
                test="count(preceding-sibling::h3) = number($heading-node)">               
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template
        match="*[preceding-sibling::h3 and not(self::h3)]"/>

    <!--<xsl:template match="h1">
        <xsl:variable name="title-location" select="substring-after(@id, 'id=')"/>
        <xsl:variable name="full-path"
            select="concat($pathtoproject, 'workitems/MCU32APPS-8314/workitem.xml')"/>
        <xsl:variable name="workitem" select="document('C:/Projects/Polarion/Polarion2DITA/Source/Functional_Safety-r48676/Configuration_Management_Plan/workitems/MCU32APPS-8314/workitem.xml')"/>
        <xsl:element name="h1">
            Made it: <xsl:value-of select="$workitem/work-item/field[@id = 'author']"/>
        </xsl:element>
    </xsl:template>-->

</xsl:stylesheet>
