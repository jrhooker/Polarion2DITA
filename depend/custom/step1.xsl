<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="/">
        <root>
            <xsl:apply-templates/>
        </root>
    </xsl:template>

    <xsl:template match="*" >
        <xsl:copy>            
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="field[@id = 'homePageContent']">   
        <xsl:variable name="content"><xsl:value-of select="." disable-output-escaping="yes"/></xsl:variable>
        <xsl:element name="homePageContent">                
                <xsl:value-of select="$content" disable-output-escaping="yes"/>
            </xsl:element>        
    </xsl:template>
    
    <xsl:template match="field[@id = 'crossReferenceMappingData']">
        <xsl:variable name="content" select="tokenize(self::*, ',')"/>
        <xsl:element name="crossReferenceMapping">
        <xsl:for-each select="$content">
            <xsl:element name="node">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
        </xsl:element>    
    </xsl:template>

</xsl:stylesheet>
