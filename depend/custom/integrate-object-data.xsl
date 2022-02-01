<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:import href="manage-dependencies.xsl"/>

    <xsl:param name="project-name"/>
    <xsl:param name="pathtoproject"/>
    <xsl:param name="pathtoserver"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:call-template name="clean-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="title[contains(@id, 'module-workitem')]">
        <xsl:variable name="folder" select="substring-after(@id, 'params=id=')"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>
        <xsl:element name="title">
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:call-template name="clean-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="document($document-path)/work-item/field[@id = 'title']"/>
        </xsl:element>
        <!--<xsl:element name="draft-comment">
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:call-template name="clean-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:element name="dl">
                <xsl:for-each select="document($document-path)/work-item/field">
                    <xsl:element name="dlentry">
                        <xsl:element name="dt">
                            <xsl:value-of select="@id"/>
                        </xsl:element>
                        <xsl:element name="dd">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>-->
    </xsl:template>

    <xsl:template match="span[contains(@id, 'polarion-comment:')]">
        <xsl:variable name="comment" select="substring-after(@id, 'polarion-comment:')"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/comment-', $comment, '.xml'))"/>
        <xsl:element name="draft-comment">
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:call-template name="clean-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:element name="dl">
                <xsl:for-each select="document($document-path)/module-comment/field">
                    <xsl:element name="dlentry">
                        <xsl:element name="dt">
                            <xsl:value-of select="@id"/>
                        </xsl:element>
                        <xsl:element name="dd">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="span">
        <xsl:variable name="count" select="count(@*)"/>
        <xsl:choose>
            <xsl:when
                test="contains(@class, 'polarion-rte-link') and contains(@data-type, 'crossReference')">
                <xsl:call-template name="create-xref"/>
            </xsl:when>
            <xsl:when
                test="contains(@class, 'polarion-rte-link') and contains(@data-type, 'workItem')">
                <xsl:call-template name="create-link"/>
                <!-- this will only create a dl if there is actually a workitem in place. Otherwise if forms an external link -->
            </xsl:when>
            <xsl:when test="contains(@class, 'polarion-rte-link')">
                <xsl:call-template name="create-dl"/>
            </xsl:when>
            <xsl:when test="@style and (number($count) = 1)">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="ancestor::p | ancestor::span">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="@id">
                        <xsl:attribute name="id">
                            <xsl:call-template name="clean-id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="section">
        <xsl:element name="section">
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when
                    test="child::title[contains(@id, 'polarion_wiki') and contains(@id, 'workitem')]">
                    <xsl:call-template name="create-section-id"/>
                </xsl:when>
                <xsl:when test="not(@id)">
                    <xsl:attribute name="id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="div">
        <xsl:choose>
            <xsl:when
                test="contains(@id, 'module-workitem') and contains(@id, 'polarion_wiki') and not(contains(@id, 'external=true')) and not(preceding-sibling::div[1][contains(@id, 'module-workitem') and contains(@id, 'polarion_wiki')])">
                <xsl:call-template name="process-wikidata"/>
            </xsl:when>
            <xsl:when
                test="contains(@id, 'module-workitem') and contains(@id, 'polarion_wiki') and contains(@id, 'external=true') and not(preceding-sibling::div[1][contains(@id, 'module-workitem') and contains(@id, 'polarion_wiki')])">

                <xsl:call-template name="create-div-xref"/>

            </xsl:when>
            <xsl:when test="contains(@id, 'module-workitem') and contains(@id, 'name=toc')"/>
            <xsl:when test="contains(@id, 'module-workitem') and contains(@id, 'level=')"/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="create-div-xref">
        <xsl:variable name="front-half" select="substring-after(@id, 'params=id=')"/>
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
        <xsl:element name="p">
            <xsl:element name="xref">
                <xsl:attribute name="href">
                    <xsl:value-of
                        select="concat($pathtoserver, $project-name, '/workitem?id=', $folder)"
                    />
                </xsl:attribute>
                <xsl:attribute name="scope">external</xsl:attribute>
                <xsl:value-of select="$folder"/>
                <xsl:text> </xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <xsl:template name="create-xref">
        <xsl:variable name="folder" select="@data-item-id"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>
        <xsl:element name="xref">
            <xsl:attribute name="href">
                <xsl:variable name="target">
                    <xsl:call-template name="generate-id">
                        <xsl:with-param name="content"
                            select="concat(document($document-path)/work-item/field[@id = 'title'], '-', $folder)"
                        />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat($target, '.xml')"/>
            </xsl:attribute>
            <xsl:attribute name="scope">local</xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="create-section-id">
        <xsl:variable name="folder" select="substring-after(child::title[1]/@id, 'params=id=')"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>
        <xsl:attribute name="id">
            <xsl:variable name="content">
                <xsl:value-of
                    select="concat(document($document-path)/work-item/field[@id = 'title'], '-', $folder)"
                />
            </xsl:variable>
            <xsl:call-template name="generate-id">
                <xsl:with-param name="content" select="$content"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="create-link ">
        <xsl:variable name="folder" select="@data-item-id"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>
        <xsl:variable name="content" select="document($document-path)/work-item/field[1]"/>
        <xsl:choose>
            <xsl:when test="string-length($content) &gt; 0">
                <xsl:choose>
                    <xsl:when test="parent::entry or parent::td">
                        <xsl:element name="p">
                            <xsl:element name="xref">
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://polarion.microchip.com/polarion/#/project/', $project-name, '/workitem?id=', $folder)"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="scope">external</xsl:attribute>
                                <xsl:value-of select="$folder"/>
                                <xsl:variable name="content"
                                    select="document($document-path)/work-item/field[@id = 'description']"/>
                                <xsl:choose>
                                    <xsl:when test="contains($content, 'span&gt;')">
                                        <xsl:text> </xsl:text>-<xsl:text> </xsl:text><xsl:value-of
                                            select="substring-before(substring-after($content, '&gt;'), '&lt;')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="string-length($content) &gt; 0"
                                            ><xsl:text> </xsl:text>-<xsl:text> </xsl:text><xsl:value-of
                                            select="$content"/></xsl:when>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="xref">
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('https://polarion.microchip.com/polarion/#/project/', $project-name, '/workitem?id=', $folder)"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="scope">external</xsl:attribute>
                            <xsl:value-of select="$folder"/>
                            <xsl:variable name="content"
                                select="document($document-path)/work-item/field[@id = 'description']"/>
                            <xsl:choose>
                                <xsl:when test="contains($content, 'span&gt;')">
                                    <xsl:text> </xsl:text>-<xsl:text> </xsl:text><xsl:value-of
                                        select="substring-before(substring-after($content, '&gt;'), '&lt;')"
                                    />
                                </xsl:when>
                                <xsl:when test="string-length($content) &gt; 0"
                                        ><xsl:text> </xsl:text>-<xsl:text> </xsl:text><xsl:value-of
                                        select="$content"/></xsl:when>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::entry or parent::td">
                        <xsl:element name="p">
                            <xsl:element name="xref">
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://polarion.microchip.com/polarion/#/project/', $project-name, '/workitem?id=', $folder)"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="scope">external</xsl:attribute>
                                <xsl:value-of select="$folder"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="xref">
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('https://polarion.microchip.com/polarion/#/project/', $project-name, '/workitem?id=', $folder)"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="scope">external</xsl:attribute>
                            <xsl:value-of select="$folder"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="create-dl">
        <xsl:variable name="folder" select="@data-item-id"/>
        <xsl:variable name="document-path"
            select="concat(translate($pathtoproject, '\', '/'), concat('/workitems/', concat($folder, '/workitem.xml')))"/>
        <xsl:variable name="content" select="document($document-path)/work-item/field[1]"/>
        <xsl:choose>
            <xsl:when test="string-length($content) &gt; 0">
                <xsl:element name="dl">
                    <xsl:for-each select="document($document-path)/work-item/field">
                        <xsl:element name="dlentry">
                            <xsl:element name="dt">
                                <xsl:value-of select="@id"/>
                            </xsl:element>
                            <xsl:element name="dd">
                                <xsl:value-of select="."/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@data-item-name and @data-space-name">
                <xsl:element name="xref">
                    <xsl:variable name="data-item-name" select="replace(@data-item-name, ' ', '%20')"></xsl:variable>
                    <xsl:variable name="data-space-name" select="replace(@data-space-name, ' ', '%20')"></xsl:variable>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat($pathtoserver, $project-name, '/wiki/', $data-space-name, '/', $data-item-name)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:value-of select="@data-item-name"/>
                </xsl:element>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="xref">
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat($pathtoserver, $project-name, '/workitem?id=', $folder)"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="scope">external</xsl:attribute>
                    <xsl:value-of select="$folder"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

    <xsl:template name="clean-id">
        <xsl:value-of
            select="translate(@id, '!@#$%^=*(){}[]:;/?~ |,.…', '________________________')"/>
    </xsl:template>

    <xsl:template name="generate-id">
        <xsl:param name="content"/>
        <xsl:value-of
            select="translate($content, '!@#$%^=*(){}[]:;/?~ |,.…', '_________________________')"/>
    </xsl:template>

</xsl:stylesheet>
