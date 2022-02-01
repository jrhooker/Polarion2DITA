<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:dbx="http://sourceforge.net/projects/docbook/defguide/schema/extra-markup"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xsl db xlink svg mml dbx xi html">

    <xsl:template match="processing-instruction()"/>

    <xsl:template match="draft-comment">
        <xsl:element name="draft-comment">
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pre">
        <xsl:element name="codeblock">
            <xsl:copy-of select="@id"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="topic_title">
        <xsl:for-each select="title">
            <xsl:choose>
                <xsl:when test="string-length(.) = 0"/>
                <xsl:when
                    test="parent::table | parent::fig | parent::example | parent::procedure | parent::preface">
                    <xsl:element name="title">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="title">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="caption_title">
        <xsl:choose>
            <xsl:when
                test="following-sibling::p[1][contains(@class, 'polarion-rte-caption-paragraph')]">
                <xsl:variable name="content">
                    <xsl:value-of
                        select="following-sibling::p[1][contains(@class, 'polarion-rte-caption-paragraph')]"
                    />
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains(normalize-space($content), 'Table #')">
                        <xsl:value-of select="substring-after(normalize-space($content), 'Table #')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="self::img">
                <xsl:variable name="content">
                    <xsl:value-of
                        select="parent::p/following-sibling::p[1][contains(@class, 'polarion-rte-caption-paragraph')]"
                    />
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains(normalize-space($content), 'Figure #')">
                        <xsl:value-of
                            select="substring-after(normalize-space($content), 'Figure #')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get_topic_title">
        <xsl:for-each select="title">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="get_index_topic_title">
        <xsl:for-each select="title">
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>

    <!-- There are lots of instances in the docbook files where paragraph elements have been embedded, which is not allowed in either docbook or dita. 
    This template has rules that straighten out the known issues and will grow as more issues are found. -->

    <xsl:template match="p">
        <xsl:variable name="content">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:choose>

            <!-- <xsl:when test="number(string-length(normalize-space($content))) &lt; 1"/> -->
            <!-- there is not a single case in any of the samples where a para that has a formalpara as a child is not spurious -->
            <xsl:when test="child::formalpara">
                <xsl:apply-templates/>
            </xsl:when>

            <xsl:when test="parent::p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="img">
        <xsl:choose>
            <xsl:when
                test="parent::p/following-sibling::p[1][contains(@class, 'polarion-rte-caption-paragraph')]">
                <xsl:element name="fig">
                    <xsl:copy-of select="@id"/>
                    <xsl:variable name="img_title">
                        <xsl:call-template name="caption_title"/>
                    </xsl:variable>
                    <xsl:if test="string-length(normalize-space($img_title)) &gt; 1">
                        <xsl:element name="title">
                            <xsl:call-template name="caption_title"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="image">
                        <xsl:attribute name="placement">break</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('attachments/', substring-after(@src, 'attachment:'))"
                            />
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="image">
                    <xsl:attribute name="placement">break</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat('attachments/', substring-after(@src, 'attachment:'))"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="table">
        <xsl:choose>
            <xsl:when test="ancestor::table">
                <xsl:element name="p">
                    <xsl:element name="table">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:call-template name="topic_title"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="table">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:variable name="table_title">
                        <xsl:call-template name="topic_title"/>
                    </xsl:variable>
                    <xsl:variable name="caption_table_title">
                        <xsl:call-template name="caption_title"/>
                    </xsl:variable>
                    <xsl:if
                        test="string-length(normalize-space($caption_table_title)) &gt; 1 or string-length(normalize-space($table_title))">
                        <xsl:element name="title">
                            <xsl:choose>
                                <xsl:when test="string-length(normalize-space($table_title)) &gt; 0">
                                    <xsl:value-of select="$table_title"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$caption_table_title"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="child::tgroup">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="tgroup">
                                <xsl:attribute name="cols">
                                    <xsl:choose>
                                        <xsl:when test="colgroup/col">
                                            <xsl:value-of select="count(colgroup/col)"/>
                                        </xsl:when>
                                        <xsl:when test="tbody[1]/tr[1]/td">
                                            <xsl:value-of select="count(tbody[1]/tr[1]/td)"/>
                                        </xsl:when>
                                        <xsl:when test="tbody[1]/tr[1]/th">
                                            <xsl:value-of select="count(tbody[1]/tr[1]/th)"/>
                                        </xsl:when>
                                        <xsl:otherwise>no_count</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="p[contains(@class, 'polarion-rte-caption-paragraph')]">
        <xsl:choose>
            <xsl:when test="preceding-sibling::table[1]"></xsl:when>
            <xsl:when test="preceding-sibling::p[1]/img[1]"></xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="entrytbl">
        <xsl:choose>
            <xsl:when test="ancestor::table">
                <xsl:element name="p">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:element name="table">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:element name="title"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="table">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:element name="title"/>
                    <xsl:apply-templates/>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="informaltable">
        <xsl:variable name="content">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:variable name="figure-content">
            <xsl:apply-templates select="descendant::fig"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(normalize-space($content))"/>
            <!-- Informal tables are being used as containers for figures for some reason; if the string length in figures is the same as the string length in the 
            whole construct, then clearly all of the content is in the figures, therefore, we just skip right to processing the figures -->
            <xsl:when
                test="string-length(normalize-space($content)) = string-length(normalize-space($figure-content))">
                <xsl:for-each select="descendant::fig">
                    <xsl:element name="fig">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:call-template name="topic_title"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::table">
                <xsl:element name="p">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:element name="simpletable">
                        <xsl:call-template name="attribute_manager"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="simpletable">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
                <xsl:call-template name="externalize-tfooters"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tgroup">
        <xsl:choose>
            <xsl:when test="parent::informaltable">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="tgroup">
                    <xsl:attribute name="cols">
                        <xsl:value-of select="@cols"/>
                    </xsl:attribute>
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tbody">
        <xsl:choose>
            <xsl:when test="parent::tgroup/parent::informaltable">
                <xsl:apply-templates mode="simpletable"/>
            </xsl:when>
            <xsl:when test="tr/th">
                <xsl:element name="thead">
                    <xsl:apply-templates select="tr[child::th]"></xsl:apply-templates>
                </xsl:element>
                <xsl:element name="tbody">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates select="tr[child::td] | row[child::entry]"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="tbody">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates select="tr[child::td] | row[child::entry]"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="thead">
        <xsl:choose>
            <xsl:when test="parent::tgroup/parent::informaltable">
                <xsl:apply-templates mode="simpletable"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="thead">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="row" mode="simpletable">
        <xsl:choose>
            <xsl:when test="parent::thead">
                <xsl:element name="sthead">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates mode="simpletable"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="strow">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates mode="simpletable"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="entry" mode="simpletable">
        <xsl:element name="stentry">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="row | tr">
        <xsl:choose>
            <xsl:when test="(ancestor::table) and (ancestor::thead)">
                <xsl:element name="row">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="(ancestor::table) and (ancestor::tbody)">
                <xsl:element name="row">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="(ancestor::entrytbl) and (ancestor::thead)">
                <xsl:element name="row">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="(ancestor::entrytbl) and (ancestor::tbody)">
                <xsl:element name="row">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="row">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                    <xsl:element name="entry">
                        <!--Missing options in the row
                        template -->
                        <xsl:call-template name="attribute_manager"/>
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="entry | td | th">
        <xsl:choose>
            <xsl:when test="(ancestor::node() = simpletable)">
                <xsl:element name="entry">
                    <xsl:if test="@nameend">
                        <xsl:copy-of select="@nameend"/>
                    </xsl:if>
                    <xsl:if test="@namest">
                        <xsl:copy-of select="@namest"/>
                    </xsl:if>
                    <xsl:if test="@morerows">
                        <xsl:copy-of select="@morerows"/>
                    </xsl:if>
                    <xsl:if test="@rowspan">
                        <xsl:attribute name="morerows"><xsl:value-of select="number(@rowspan) - 1"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="attribute_manager"/>                   
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="(ancestor::node() = table)">
                <xsl:element name="entry">
                    <xsl:if test="@nameend">
                        <xsl:copy-of select="@nameend"/>
                    </xsl:if>
                    <xsl:if test="@namest">
                        <xsl:copy-of select="@namest"/>
                    </xsl:if>
                    <xsl:if test="@morerows">
                        <xsl:copy-of select="@morerows"/>
                    </xsl:if>
                    <xsl:if test="@rowspan">
                        <xsl:attribute name="morerows"><xsl:value-of select="number(@rowspan) - 1"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="entry">
                    <xsl:if test="@nameend">
                        <xsl:copy-of select="@nameend"/>
                    </xsl:if>
                    <xsl:if test="@namest">
                        <xsl:copy-of select="@namest"/>
                    </xsl:if>
                    <xsl:if test="@morerows">
                        <xsl:copy-of select="@morerows"/>
                    </xsl:if>
                    <xsl:if test="@spanname">
                        <xsl:copy-of select="@spanname"/>
                    </xsl:if>
                    <xsl:if test="@rowspan">
                        <xsl:attribute name="morerows"><xsl:value-of select="number(@rowspan) - 1"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>       
    </xsl:template>

    <xsl:template match="colspec">
        <xsl:if test="not(ancestor::informaltable)">
            <xsl:element name="colspec">
                <xsl:for-each select="@*">
                    <xsl:choose>
                        <xsl:when test="name() = 'id'">
                            <xsl:attribute name="id">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:if test="@colwidth">
                    <xsl:choose>
                        <xsl:when test="contains(@colwidth, 'in')">
                            <xsl:attribute name="colwidth">
                                <xsl:value-of select="@colwidth"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@colwidth, 'cm')">
                            <xsl:attribute name="colwidth">
                                <xsl:value-of select="@colwidth"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@colwidth, 'mm')">
                            <xsl:attribute name="colwidth">
                                <xsl:value-of select="@colwidth"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@colwidth, 'px')">
                            <xsl:attribute name="colwidth">
                                <xsl:value-of select="@colwidth"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:call-template name="attribute_manager"/>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="spanspec">
        <xsl:element name="spanspec">
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="caution | warning | note | tip | important">
        <xsl:element name="note">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="code | command | filename">
        <xsl:element name="codeph">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="example">
        <xsl:element name="example">
            <xsl:call-template name="attribute_manager"/>
            <xsl:call-template name="topic_title"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="footnote">
        <xsl:element name="fn">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="footnoteref">
        <xsl:element name="xref">
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="fig">
        <xsl:choose>
            <!-- For some odd reason someone embedded a bunch of tables in figures -->
            <xsl:when test="descendant::table or descendant::informaltable">
                <xsl:for-each select="descendant::table | descendant::informaltable">
                    <xsl:element name="table">
                        <xsl:for-each select="@*">
                            <xsl:if test="name() = 'id'">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="not(name() = 'id')">
                                <xsl:copy/>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="parent::fig/@*">
                            <xsl:if test="name() = 'id'">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="not(name() = 'id')">
                                <xsl:copy/>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="@id">
                            <xsl:attribute name="id">
                                <xsl:call-template name="id_processing"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:element name="title">
                            <xsl:apply-templates select="parent::figure/title"/>
                        </xsl:element>
                        <xsl:apply-templates select="./*"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="fig">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:call-template name="topic_title"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="mediaobject | imageobject">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="index | indexdiv"/>

    <xsl:template match="indexentry">
        <!--  <xsl:apply-templates/> -->
    </xsl:template>

    <xsl:template match="primary">
        <!-- <xsl:element name="indexterm">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element> -->
    </xsl:template>

    <xsl:template match="secondary">
        <!--  <xsl:element name="indexterm">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element> -->
    </xsl:template>

    <xsl:template match="tertiary">
        <!--  <xsl:element name="indexterm">

            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element> -->
    </xsl:template>

    <xsl:template match="inlinemediaobject">
        <xsl:for-each select="imageobject/imagedata">
            <xsl:element name="image">

                <xsl:attribute name="placement">inline</xsl:attribute>
                <xsl:attribute name="href" select="@fileref"/>

                <xsl:call-template name="attribute_manager"/>
                <xsl:if test="@width or @depth">
                    <xsl:choose>
                        <xsl:when test="contains(@width, 'in')">
                            <xsl:attribute name="width"><xsl:value-of
                                    select="number(substring-before(@width, 'in')) * 200"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@width, 'cm')">
                            <xsl:attribute name="width"><xsl:value-of
                                    select="number(substring-before(@width, 'cm')) * 70"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@width, 'mm')">
                            <xsl:attribute name="width"><xsl:value-of
                                    select="number(substring-before(@width, 'mm')) * 7"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@width">
                            <xsl:attribute name="width"><xsl:value-of
                                    select="number(substring-before(@width, 'px'))"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@depth, 'in')">
                            <xsl:attribute name="height"><xsl:value-of
                                    select="number(substring-before(@width, 'in')) * 200"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@depth, 'cm')">
                            <xsl:attribute name="height"><xsl:value-of
                                    select="number(substring-before(@width, 'cm')) * 70"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="contains(@depth, 'mm')">
                            <xsl:attribute name="height"><xsl:value-of
                                    select="number(substring-before(@width, 'mm')) * 7"
                                />px</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@depth">
                            <xsl:attribute name="height"><xsl:value-of
                                    select="number(substring-before(@width, 'px'))"
                                />px</xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- The XMLmind paste-from-word feature seems to turn bulleted lists in  a whole bunch of lists 
     with a single bullet each. The following templates or itemizedlist and orderedlist re-create 
     the original list. -->

    <xsl:template match="itemizedlist">
        <xsl:choose>
            <xsl:when test="count(child::listitem) &gt; 1">
                <xsl:element name="ul">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="preceding-sibling::itemizedlist[count(child::listitem) = 1]"/>
            <xsl:otherwise>
                <xsl:element name="ul">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:call-template name="itemizedlist-master-processor"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="orderedlist">
        <xsl:choose>
            <xsl:when test="count(child::listitem) &gt; 1">
                <xsl:if test="title">
                    <xsl:element name="p">

                        <xsl:call-template name="attribute_manager"/>
                        <xsl:value-of select="title"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="ol">

                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="preceding-sibling::orderlist[count(child::listitem) = 1]"/>
            <xsl:otherwise>
                <xsl:if test="title">
                    <xsl:element name="p">

                        <xsl:call-template name="attribute_manager"/>
                        <xsl:value-of select="title"/>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="ol">

                    <xsl:call-template name="attribute_manager"/>
                    <xsl:call-template name="orderedlist-master-processor"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="substeps">
        <xsl:if test="title">
            <xsl:element name="p">
                <xsl:call-template name="attribute_manager"/>
                <xsl:value-of select="title"/>
            </xsl:element>
        </xsl:if>
        <xsl:element name="ol">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="orderedlist/title | substeps/title"/>

    <xsl:template match="procedure">
        <xsl:element name="p">
            <xsl:call-template name="attribute_manager"/>
            <xsl:element name="b">
                <xsl:value-of select="title"/>
            </xsl:element>
        </xsl:element>
        <xsl:element name="ol">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="listitem | step | member">
        <xsl:choose>
            <xsl:when test="parent::simplelist">
                <xsl:element name="sli">

                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="li">

                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ul | ol">
        <xsl:choose>
            <xsl:when test="parent::ol or parent::ul">
                <xsl:element name="li">
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

    <xsl:template match="li">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="emphasis">
        <xsl:choose>
            <xsl:when test="ancestor::thead">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains(@role, 'bold') or contains(@role, 'strong')">
                <xsl:element name="b">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains(@role, 'color:')">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="i">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="remark">
        <xsl:element name="draft-comment">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="simplelist">
        <xsl:element name="sl">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="subscript">
        <xsl:element name="sub">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="superscript">
        <xsl:element name="sup">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="subtitle"/>

    <xsl:template match="symbol">
        <xsl:element name="ph">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="variablelist">
        <xsl:element name="parml">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="varlistentry">
        <xsl:element name="plentry">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="varlistentry/term">
        <xsl:element name="pt">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="varlistentry/listitem">
        <xsl:element name="pd">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="trademark">
        <xsl:element name="tm">
            <xsl:call-template name="attribute_manager"/>
            <xsl:attribute name="tmtype">tm</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="generate_tablefigureexample_indexentry">
        <xsl:variable name="temp_id">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:element name="p">

            <xsl:element name="indexterm">

                <xsl:call-template name="attribute_manager"/>
                <xsl:choose>
                    <xsl:when test="//procedure[@id = $temp_id]">Procedures</xsl:when>
                    <xsl:when test="//table[@id = $temp_id]">Tables</xsl:when>
                    <xsl:when test="//figure[@id = $temp_id]">Figures</xsl:when>
                    <xsl:when test="//example[@id = $temp_id]">Examples</xsl:when>
                </xsl:choose>
                <xsl:element name="indexterm">

                    <xsl:call-template name="attribute_manager"/>
                    <xsl:value-of select="//info/title"/>
                    <xsl:element name="indexterm">

                        <xsl:call-template name="attribute_manager"/>
                        <xsl:choose>
                            <xsl:when test="//procedure[@id = $temp_id]">Procedure <xsl:number
                                    select="//procedure[@id = $temp_id]" format="001" level="any"
                                    count="procedure"/>: <xsl:call-template
                                    name="get_index_topic_title"/></xsl:when>
                            <xsl:when test="//table[@id = $temp_id]">Table <xsl:number
                                    select="//table[@id = $temp_id]" format="001" level="any"
                                    count="table"/>: <xsl:call-template name="get_index_topic_title"
                                /></xsl:when>
                            <xsl:when test="//figure[@id = $temp_id]">Figure <xsl:number
                                    select="//figure[@id = $temp_id]" format="001" level="any"
                                    count="figure"/>: <xsl:call-template
                                    name="get_index_topic_title"/></xsl:when>
                            <xsl:when test="//example[@id = $temp_id]">Example <xsl:number
                                    select="//example[@id = $temp_id]" format="001" level="any"
                                    count="example"/>: <xsl:call-template
                                    name="get_index_topic_title"/></xsl:when>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="procedure/title"/>

    <!-- INFO element -->

    <xsl:template match="info/title">
        <xsl:element name="title">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="info_element">
        <table>
            <tgroup cols="4">
                <colspec colname="_1"/>
                <colspec colname="_2" colnum="2"/>
                <colspec colname="_3"/>
                <colspec colname="_4"/>
                <tbody>
                    <row>
                        <entry>Title:</entry>
                        <entry nameend="_4" namest="_2">
                            <xsl:value-of select="//info/title"/>
                        </entry>
                    </row>
                    <row>
                        <entry>Abstract:</entry>
                        <entry nameend="_4" namest="_2">
                            <xsl:for-each select="abstract/para">
                                <xsl:element name="p">

                                    <xsl:apply-templates/>
                                </xsl:element>
                            </xsl:for-each>
                        </entry>
                    </row>
                    <row>
                        <entry>Document Type:</entry>
                        <entry nameend="_4" namest="_2">
                            <xsl:value-of select="//info/pmc_doc_type"/>
                        </entry>
                    </row>
                    <row>
                        <entry>Marketing No:</entry>
                        <entry>
                            <xsl:value-of select="//info/pmc_productnumber"/>
                        </entry>
                        <entry>Doc Issue: </entry>
                        <entry>
                            <xsl:value-of select="issuenum"/>
                        </entry>
                    </row>
                    <row>
                        <entry>Document No:</entry>
                        <entry>
                            <xsl:value-of select="//info/pmc_document_id"/>
                        </entry>
                        <entry>Issue Date:</entry>
                        <entry>
                            <xsl:value-of select="//info/pubdate"/>
                        </entry>
                    </row>
                    <row>
                        <entry>Keywords</entry>
                        <entry nameend="_4" namest="_2">
                            <xsl:element name="p">

                                <xsl:for-each select="//info/keywords/keywords"><xsl:value-of
                                        select="."/>, </xsl:for-each>
                            </xsl:element>
                        </entry>
                    </row>
                    <row>
                        <entry>Patents</entry>
                        <entry nameend="_4" namest="_2">
                            <xsl:for-each select="//info/pmc_patents/para">
                                <xsl:element name="p">

                                    <xsl:apply-templates/>
                                </xsl:element>
                            </xsl:for-each>
                        </entry>
                    </row>
                </tbody>
            </tgroup>
        </table>
    </xsl:template>

    <xsl:template match="@colwidth">
        <xsl:attribute name="colwidth">
            <xsl:value-of select="number(substring-before(@colwidth, 'in')) * 92"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate_prolog">
        <!-- <xsl:if test="@id">
            <xsl:element name="prolog">               
                <xsl:element name="data">                    
                    <xsl:attribute name="type">pdf_name</xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:if> -->
    </xsl:template>

    <!-- Manage attributes -->

    <xsl:template name="attribute_manager">
        <xsl:for-each select="@*">
            <xsl:choose>
                <xsl:when test="name() = 'id'">
                    <xsl:attribute name="id">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="topic_attribute_manager"> </xsl:template>


    <!-- manage tfooters, which are not allowed in the DITA version of CALS tables. Call this template immediately after processing the table itself -->

    <xsl:template name="externalize-tfooters">
        <xsl:for-each select="descendant::tfoot/row/entry">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="id_processing">
        <xsl:param name="link">default</xsl:param>
        <xsl:variable name="link_2">
            <xsl:choose>
                <xsl:when test="$link = 'default'">
                    <xsl:value-of select="@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains($link_2, 'section_')">
                <xsl:value-of select="substring-after($link_2, 'section_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'table_')">
                <xsl:value-of select="substring-after($link_2, 'table_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'figure_')">
                <xsl:value-of select="substring-after($link_2, 'figure_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'informaltable_')">
                <xsl:value-of select="substring-after($link_2, 'informaltable_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'listitem_')">
                <xsl:value-of select="substring-after($link_2, 'listitem_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'itemizedlist_')">
                <xsl:value-of select="substring-after($link_2, 'itemizedlist_')"/>
            </xsl:when>
            <xsl:when test="contains($link_2, 'orderedlist_')">
                <xsl:value-of select="substring-after($link_2, 'orderedlist_')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$link_2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Process itemized listed to remove the sheer volume of single-item lists found in projects converted from Word -->
    <!-- The following template should grab any following siblings of the current itemizedlist  and process them as a part of the curret list. -->

    <xsl:template name="itemizedlist-master-processor">
        <xsl:variable name="itemizedlists"
            select="listitem | following-sibling::itemizedlist[count(child::listitem) = 1]/listitem"/>
        <xsl:apply-templates select="$itemizedlists"/>
    </xsl:template>

    <xsl:template name="orderedlist-master-processor">
        <xsl:variable name="orderedlists"
            select="listitem | following-sibling::orderedlist[count(child::listitem) = 1]/listitem"/>
        <xsl:apply-templates select="$orderedlists"/>
    </xsl:template>


    <xsl:template name="project-converter"> </xsl:template>

    <xsl:template match="xref">
        <xsl:choose>
            <!-- prevent xref elements from being the immediate child elements of the body element. -->
            <xsl:when test="parent::section">
                <xsl:element name="p">
                    <xsl:element name="xref">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="xref">
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="anchor">
        <xsl:choose>
            <xsl:when
                test="parent::section or parent::simplesect or parent::chapter or parent::appendix">
                <xsl:element name="p">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ancestor::programlisting">
                <xsl:element name="ph">
                    <xsl:call-template name="attribute_manager"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="literallayout">
        <xsl:variable name="content">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="number(string-length(normalize-space($content))) &lt; 2"/>
            <xsl:otherwise>
                <xsl:element name="codeblock">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:apply-templates mode="literallayout"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="literallayout">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="programlisting | screen">
        <xsl:element name="codeblock">
            <xsl:call-template name="attribute_manager"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="section | simplesect">
        <xsl:element name="section">
            <xsl:call-template name="attribute_manager"/>
            <xsl:call-template name="topic_title"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="title"/>

    <xsl:template match="formalpara">
        <xsl:choose>
            <!-- If this is the only child of a para element, then the para element has already been removed -->
            <xsl:when
                test="parent::para and (count(preceding-sibling::element()) = 0) and (count(following-sibling::element()) = 0)">
                <xsl:element name="section">
                    <xsl:element name="b">
                        <xsl:value-of select="title"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="table">
                    <xsl:call-template name="attribute_manager"/>
                    <xsl:element name="title">
                        <xsl:value-of select="title"/>
                    </xsl:element>
                    <xsl:element name="tgroup">
                        <xsl:attribute name="cols">1</xsl:attribute>
                        <xsl:element name="tbody">
                            <xsl:element name="row">
                                <xsl:element name="entry">
                                    <xsl:apply-templates select="*[not(title)]"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when
                test="parent::section | parent::simplesect | parent::chapter | parent::appendix and string-length(normalize-space(.)) &gt; 4">
                <xsl:element name="p">
                    <xsl:copy/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="b">
       <xsl:element name="b">
           <xsl:copy-of select="@*"/>
           <xsl:apply-templates/>
       </xsl:element>
    </xsl:template>

    <xsl:template match="a">
        <xsl:element name="xref">
            <xsl:attribute name="scope">external</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="@href"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:if test="draft-comment">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dl | dt | dd | dlentry">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
