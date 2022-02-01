<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="not(name() = 'style')">
                    <xsl:copy/>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[contains(@id, 'polarion_wiki') and contains(@id, 'module-workitem')]">
        <xsl:choose>
            <xsl:when test="contains(@id, 'level=')"/>
            <xsl:otherwise>
                <xsl:element name="div">
                    <xsl:copy-of select="@*"/>
                    <xsl:call-template name="nest-dependencies">
                        <xsl:with-param name="count" select="1"/>
                        <xsl:with-param name="level" select="1"/>
                    </xsl:call-template>                     
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="nest-dependencies">
        <xsl:param name="count"/>
        <xsl:param name="level"/>
        <xsl:variable name="full-level" select="concat('level=', $level)"/>
        <xsl:choose>
            <xsl:when test="following-sibling::div[$count][contains(@id, $full-level)]">
                <xsl:element name="div">
                    <xsl:copy-of select="following-sibling::div[$count][contains(@id, $full-level)]/@*"/>
                </xsl:element>             
                <xsl:call-template name="nest-dependencies">
                    <xsl:with-param name="count" select="$count + 1"/>
                    <xsl:with-param name="level" select="1"></xsl:with-param>
                </xsl:call-template> 
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>