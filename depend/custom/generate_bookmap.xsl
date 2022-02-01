<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:dbx="http://sourceforge.net/projects/docbook/defguide/schema/extra-markup"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xsl db xlink svg mml dbx xi html">

    <!-- This stylesheet takes a PMC article and flips it into a DITA bookmap. The next stylesheet will take the content of the article and generate topics that connect to the bookmap -->

    <xsl:variable name="quot">"</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>

     <xsl:output method="xml" media-type="text/xml" indent="yes" encoding="UTF-8"
        doctype-public="-//Atmel//DTD DITA Map//EN" doctype-system="map.dtd"/>   
    
    <!--  <xsl:output method="xml" media-type="text/xml" indent="yes" encoding="UTF-8"
        doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="map.dtd"/>-->
   
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Remove processing instructions -->

    <xsl:template match="processing-instruction()"/>
    
    <xsl:template match="draft-comment">
        <xsl:element name="draft-comment">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Turn the info element into pmc_iso elements -->
    <xsl:template name="info_element">
      
    </xsl:template>

    <xsl:template match="field | crossReferenceMapping"></xsl:template>

    <!-- The following templates are in place to populate the pmc_iso element when the docbook file has its source in Confluence, which pushes the ISO info into a simpletable element immediately following the info element. -->

    <xsl:template match="homePageContent">
        <xsl:element name="map">
            <xsl:element name="title">
                <xsl:value-of select="section[1]/title[1]"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Eliminate the info element that is already being processed inside the article element -->
    
    <xsl:template match="section[not(contains(@outputclass, 'requirement-layout'))]">
        <xsl:variable name="IDValue">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
            </xsl:choose>           
        </xsl:variable>       
        <xsl:element name="topicref">
            <xsl:attribute name="id"><xsl:value-of select="$IDValue"/></xsl:attribute>             
            <xsl:attribute name="href"><xsl:value-of select="concat($IDValue, '.xml')"/></xsl:attribute>
            <xsl:apply-templates select="section[not(contains(@outputclass, 'requirement-layout'))]"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Get rid of the first level section; it's really the map title. -->
    <xsl:template match="root/module/homePageContent/section[1]">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="root/module/homePageContent/section[1]/title">
    </xsl:template>  
    

</xsl:stylesheet>
