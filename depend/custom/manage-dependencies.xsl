<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template name="process-wikidata">
        <table outputclass=" nocolor compact " border="0" bordercolor="ffffff">
            <tgroup cols="20">
                <colspec colname="1" colwidth=".75cm"/>
                <colspec colname="2" colwidth=".75cm"/>
                <colspec colname="3" colwidth=".75cm"/>
                <colspec colname="4" colwidth=".75cm"/>
                <colspec colname="5" colwidth=".75cm"/>
                <colspec colname="6" colwidth=".75cm"/>
                <colspec colname="7" colwidth=".75cm"/>
                <colspec colname="8" colwidth=".75cm"/>
                <colspec colname="9" colwidth=".75cm"/>
                <colspec colname="10" colwidth=".75cm"/>
                <colspec colname="11" colwidth=".75cm"/>
                <colspec colname="12" colwidth=".75cm"/>
                <colspec colname="13" colwidth=".75cm"/>
                <colspec colname="14" colwidth=".75cm"/>
                <colspec colname="15" colwidth=".75cm"/>
                <colspec colname="16" colwidth=".75cm"/>
                <colspec colname="17" colwidth=".75cm"/>
                <colspec colname="18" colwidth="1cm"/>
                <colspec colname="19" colwidth="2cm"/>
                <colspec colname="20" colwidth="1cm"/>
                <tbody>

                    <xsl:call-template name="create-dependencies">
                        <xsl:with-param name="content" select="self::*"/>
                    </xsl:call-template>

                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <xsl:template name="create-dependencies">
        <xsl:param name="level" select="0"/>
        <xsl:param name="layout" select="0"/>
        <xsl:param name="content"/>

        <xsl:variable name="front-half" select="substring-after($content/@id, 'params=id=')"/>
        <xsl:variable name="folder">
            <xsl:choose>
                <xsl:when test="contains($front-half, '|layout=')">
                    <xsl:value-of select="substring-before($front-half, '|layout=')"/>
                </xsl:when>
                <xsl:when test="contains($front-half, '|level=')">
                    <xsl:value-of select="substring-before($front-half, '|level=')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$front-half"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>

        <xsl:element name="row">
            <xsl:call-template name="fill-cells">
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
            <xsl:element name="entry">
                <xsl:attribute name="nameend">20</xsl:attribute>
                <xsl:attribute name="namest">
                    <xsl:value-of select="$level + 1"/>
                </xsl:attribute>
                <xsl:element name="p">
                    <xsl:element name="b">
                    <xsl:element name="xref">
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('https://polarion.microchip.com/polarion/#/project/', $project-name, '/workitem?id=', $folder)"
                            />
                        </xsl:attribute>
                        <xsl:attribute name="scope">external</xsl:attribute>
                        <xsl:value-of select="$folder"/>
                        <xsl:text> </xsl:text>
                    </xsl:element>

                    <xsl:if
                        test="document($document-path)/work-item/field[contains(@id, 'requirement_type')]">
                        <xsl:value-of
                            select="upper-case(concat(' -  ', translate(document($document-path)/work-item/field[contains(@id, 'requirement_type')], '_', ' ')))"
                        />
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="document($document-path)/work-item/field[@id = 'title']">
                            <xsl:choose>
                                <xsl:when
                                    test="contains(document($document-path)/work-item/field[@id = 'title'], '&lt;/span')">
                                    <xsl:value-of
                                        select="concat('- ', substring-after(substring-before(document($document-path)/work-item/field[@id = 'title'], '&lt;/span'), '&gt;'))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="concat('- ', document($document-path)/work-item/field[@id = 'title'])"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="contains(document($document-path)/work-item/field[@id = 'description'], '&lt;/span')">
                                    <xsl:value-of
                                        select="concat('- ', substring-after(substring-before(document($document-path)/work-item/field[@id = 'description'], '&lt;/span'), '&gt;'))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="concat('- ', document($document-path)/work-item/field[@id = 'description'])"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:element>
                    <xsl:text> </xsl:text>
                    <xsl:text>(</xsl:text>
                    
                    <xsl:if
                        test="document($document-path)/work-item/field[contains(@id, 'bulding_block_asil')]"
                        > ASIL<xsl:text> </xsl:text><xsl:value-of
                            select="upper-case(translate(document($document-path)/work-item/field[@id = 'bulding_block_asil'], '_', ' '))"
                        />  <xsl:text> / </xsl:text>
                    </xsl:if>
                    
                    <xsl:text> </xsl:text>
                    
                    <xsl:if test="document($document-path)/work-item/field[@id = 'asil']">
                        <xsl:value-of
                            select="upper-case(concat(' ASIL ', document($document-path)/work-item/field[@id = 'asil']))"
                        />  <xsl:text> / </xsl:text>
                    </xsl:if>        
                    
                    <xsl:choose>
                        <xsl:when test="document($document-path)/work-item/field[@id = 'severity']">
                            <xsl:call-template name="initial-cap">
                                <xsl:with-param name="content" ><xsl:value-of select="translate(document($document-path)/work-item/field[@id = 'severity'], '_', ' ')"/></xsl:with-param>
                            </xsl:call-template>   <xsl:text> / </xsl:text>
                        </xsl:when>
                    </xsl:choose>    
                    
                    <xsl:if test="document($document-path)/work-item/field[@id = 'status']">
                        <xsl:call-template name="initial-cap">
                            <xsl:with-param name="content"
                                select="document($document-path)/work-item/field[@id = 'status']"/>
                        </xsl:call-template> 
                    </xsl:if>
                    
                    <xsl:text>)</xsl:text>
                </xsl:element>
                <xsl:if
                    test="document($document-path)/work-item/field[@id = 'description'] and document($document-path)/work-item/field[@id = 'title']">
                    <xsl:element name="p">                        
                        <xsl:choose>
                            <xsl:when
                                test="contains(document($document-path)/work-item/field[@id = 'description'], '&lt;/span')">
                                <xsl:value-of
                                    select="substring-after(substring-before(document($document-path)/work-item/field[@id = 'description'], '&lt;/span'), '&gt;')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="document($document-path)/work-item/field[@id = 'description']"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
           
        </xsl:element>

        <!-- We do a for-each on a single node here to advance the current context node, one, which greatly simplifies processing going forward.  -->
        <xsl:for-each
            select="following-sibling::div[1][contains(@id, 'module-workitem') and contains(@id, 'polarion_wiki')]">
            <xsl:variable name="level">
                <xsl:choose>
                    <xsl:when test="contains(@id, 'level=')">
                        <xsl:value-of select="number(substring-after(@id, 'level='))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="layout">
                <xsl:choose>
                    <xsl:when test="contains(@id, '|level=') and contains(@id, 'layout=')">
                        <xsl:value-of
                            select="number(substring-before(substring-after(@id, 'layout='), '|level='))"
                        />
                    </xsl:when>
                    <xsl:when test="contains(@id, 'layout=')">
                        <xsl:value-of select="number(substring-after(@id, 'layout='))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="create-dependencies">
                <xsl:with-param name="level" select="$level"/>
                <xsl:with-param name="layout" select="$layout"/>
                <xsl:with-param name="content" select="self::*"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="fill-cells">
        <xsl:param name="level"/>
        <xsl:if test="$level &gt; 0">
            <xsl:element name="entry">
                <xsl:attribute name="name" select="number($level)"/>
            </xsl:element>
            <xsl:call-template name="fill-cells">
                <xsl:with-param name="level" select="$level - 1"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="initial-cap">
        <xsl:param name="content"/>
        <xsl:variable name="token" select="tokenize($content, ' ')"/>
        <xsl:for-each select="$token">
            <xsl:sequence
                select="concat(upper-case(substring(., 1, 1)), lower-case(substring(., 2)))"/>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
