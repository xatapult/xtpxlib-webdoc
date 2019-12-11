<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Creates the basic xtpxlib container structure from the documentation's HTML
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../xslmod/xtpxlib-webdoc.mod.xsl"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-create-contents" on-no-match="shallow-copy"/>
  <xsl:mode name="mode-remove-comments" on-no-match="shallow-copy"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-target-path" as="xs:string" required="yes"/>
  <xsl:param name="href-componentdoc-website-template" as="xs:string" required="yes"/>
  <xsl:param name="component-name" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="template" as="document-node()">
    <xsl:choose>
      <xsl:when test="doc-available($href-componentdoc-website-template)">
        <xsl:apply-templates select="doc($href-componentdoc-website-template)" mode="mode-remove-comments"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Module documentation website template ', xtlc:q($href-componentdoc-website-template), ' not found')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Stuff we need from the component-info: -->
  <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($component-name)"/>
  <xsl:variable name="cname" as="xs:string" select="string($component-information/xwebdoc:documentation-uri) => xtlc:href-protocol-remove()"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <!-- Generate a title for this site: -->
    <xsl:variable name="title" as="xs:string" select="(/*/xhtml:div[@class eq 'header']/xhtml:*[@class eq 'title'])[1]"/>
    <xsl:variable name="subtitle" as="xs:string?" select="(/*/xhtml:div[@class eq 'header']/xhtml:*[@class eq 'subtitle'])[1]"/>
    <xsl:variable name="full-title" as="xs:string" select="string-join(($title, $subtitle), ' - ')"/>

    <!-- Create the container: -->
    <xtlcon:document-container timestamp="{current-dateTime()}" href-target-path="{$href-target-path}"
      moduledoc-website-template="{$href-componentdoc-website-template}" title="{$full-title}">

      <!-- Create some entries for the GitHub pages: -->
      <xsl:call-template name="create-github-pages-documents"/>

      <!-- Create the html pages: -->
      <xsl:for-each select="/*/xhtml:div[@class = ('preface', 'chapter', 'appendix')]">
        <xsl:variable name="is-preface" as="xs:boolean" select="@class eq 'preface'"/>
        <!-- Create a container document entry: -->
        <xsl:variable name="title" as="xs:string" select="local:get-title(.)"/>
        <xtlcon:document title="{$title}" index="{$is-preface}" is-page="true">
          <xsl:choose>
            <xsl:when test="$is-preface">
              <xsl:attribute name="href-target" select="'index.html'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="href-target" select="local:title-to-id($title) || '.html'"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- Add the contents, wrapped in the template: -->
          <xsl:apply-templates select="$template" mode="mode-create-contents">
            <xsl:with-param name="title" as="xs:string" select="$title" tunnel="true"/>
            <xsl:with-param name="body" as="element()" select="." tunnel="true"/>
          </xsl:apply-templates>
        </xtlcon:document>
      </xsl:for-each>
    </xtlcon:document-container>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- GITHUB PAGES STUFF: -->

  <xsl:template name="create-github-pages-documents" as="element(xtlcon:document)+">

    <!-- It seems that GitHub pages needs this setting even when we don't use it. Not sure whether it is actually needed 
      but it doesn't harm (?): -->
    <xtlcon:document href-target="_config.yml" mime-type="text/plain">
      <dummy-root>
        <xsl:text>theme: jekyll-theme-minimal</xsl:text>
      </dummy-root>
    </xtlcon:document>
    
    <!-- The CNAME file that takes care of making the site accessible through a clean URL: -->
    <xtlcon:document href-target="CNAME" mime-type="text/plain">
      <dummy-root>
        <xsl:value-of select="$cname"/>
      </dummy-root>
    </xtlcon:document>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- TEMPLATE HANDLING: -->

  <xsl:template match="xhtml:title" mode="mode-create-contents">
    <xsl:param name="title" as="xs:string" required="yes" tunnel="true"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="$title"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:body" mode="mode-create-contents">
    <xsl:param name="body" as="element()" required="yes" tunnel="true"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="$body"/>
      <!-- Also copy anything that was already in the body: -->
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- REMOVE COMMENTS: -->

  <xsl:template match="comment()[normalize-space(.) ne '']" mode="mode-remove-comments">
    <!-- Remove non-empty comments. Empty comments might be there to keep <script> start/end tags apart... -->
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:get-title" as="xs:string">
    <xsl:param name="root" as="element()"/>

    <xsl:variable name="title-h1" as="element(xhtml:h1)?" select="($root//xhtml:h1)[1]"/>
    <xsl:variable name="id" as="xs:string?" select="$root/@id"/>

    <xsl:choose>
      <xsl:when test="exists($title-h1)">
        <xsl:sequence select="string($title-h1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="($id, generate-id($root))"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:title-to-id" as="xs:string">
    <xsl:param name="title" as="xs:string"/>
    <xsl:sequence select="replace($title, '[^A-Za-z0-9.\-]', '_')"/>
  </xsl:function>

</xsl:stylesheet>
