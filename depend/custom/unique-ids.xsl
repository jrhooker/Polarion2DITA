<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:deltaxml="http://www.deltaxml.com/ns/well-formed-delta-v1"
    xmlns:dxx="http://www.deltaxml.com/ns/xml-namespaced-attribute"
    xmlns:dxa="http://www.deltaxml.com/ns/non-namespaced-attribute"
    xmlns:pi="http://www.deltaxml.com/ns/processing-instructions" version="2.0">

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>

    <xsl:template name="object.id">
        <xsl:param name="object" select="."/>
        <xsl:variable name="id" select="@id"/>
        <!-- Changed "preceding:: to  preceding::*|ancestor::* because it was failing to filter out ids that had been assigned to both the section and the sections title-->
        <xsl:variable name="preceding.id" select="count((preceding::* | ancestor::*)[@id = $id])"/>
        <xsl:choose>
            <xsl:when test="$object/@id and $preceding.id != 0">
                <xsl:value-of select="concat($object/@id, $preceding.id)"/>
            </xsl:when>
            <xsl:when test="$object/@id">
                <xsl:value-of select="$object/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($object)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:call-template name="object.id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
