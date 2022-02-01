<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:dbx="http://sourceforge.net/projects/docbook/defguide/schema/extra-markup"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xsl db xlink svg mml dbx xi html">
    
    <xsl:param name="AtmelOutput" select="true()"/>
    
   <xsl:include href="generate_structures.xsl"/>
    
      <xsl:output method="xml" media-type="text/xml" indent="no" encoding="UTF-8"
        doctype-public="-//Atmel//DTD DITA Mathml Topic//EN" doctype-system="AtmelTopic.dtd"/> 
    
    <!-- <xsl:output method="xml" media-type="text/xml" indent="no" encoding="UTF-8"
        doctype-public="-//OASIS//DTD DITA 1.2 Topic//EN" doctype-system="topic.dtd"/>  -->
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Remove processing instructions -->
    
    <xsl:template match="processing-instruction()"/>
    
    <xsl:template match="section[not(contains(@outputclass, 'requirement-layout'))]">
        <xsl:variable name="IDValue">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
            </xsl:choose>           
        </xsl:variable>      
        <xsl:variable name="fileName">
            <xsl:value-of select="concat($IDValue, '.xml')"/>
        </xsl:variable>          
        <xsl:result-document href="{$fileName}">
            <topic id="{$IDValue}">               
                <xsl:element name="title"><xsl:value-of select="title"/></xsl:element>
                <xsl:element name="body">                   
                    <xsl:apply-templates/>
                </xsl:element>
            </topic>
        </xsl:result-document>
        
        <xsl:message>Document created: <xsl:value-of select="$fileName"/></xsl:message>
        
    </xsl:template>    
   
    
</xsl:stylesheet>
