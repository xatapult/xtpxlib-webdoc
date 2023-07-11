<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:local="#local.k4s_cdm_5jb" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
      Merges several sources for parameters into a single parameter file:
      * Local & global parameter files
      * component-info.xml
      * Some additional data
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/xtpxlib-webdoc.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="href-parameters" as="xs:string?" required="yes"/>
  <xsl:param name="href-global-parameters" as="xs:string?" required="yes"/>
  <xsl:param name="component-name" as="xs:string" required="yes"/>
  <xsl:param name="component-display-name" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="parameters-document" as="document-node()">
    <xsl:choose>
      <xsl:when test="normalize-space($href-parameters) ne ''">
        <xsl:if test="not(doc-available($href-parameters))">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Parameters document for merge with version information not found: ', xtlc:q($href-parameters))"
            />
          </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="doc($href-parameters)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:document>
          <parameters>
            <xsl:comment> == Generated parameters document by {static-base-uri()} - {current-dateTime()} == </xsl:comment>
          </parameters>
        </xsl:document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="global-parameters-document" as="document-node()?">
    <xsl:choose>
      <xsl:when test="normalize-space($href-global-parameters) ne ''">
        <xsl:if test="not(doc-available($href-global-parameters))">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Global parameters document not found: ', xtlc:q($href-global-parameters))"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:sequence select="doc($href-global-parameters)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($component-name)"/>
  <xsl:variable name="href-component-information" as="xs:string" select="string(base-uri($component-information))"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates select="$parameters-document/*"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*:parameters">
    <xsl:copy copy-namespaces="false">
      <xsl:copy-of select="@* | node()"/>
      
      <!-- Component info: -->
      <xsl:call-template name="generate-component-information-parameters"/>

      <!-- Global parameters: -->
      <xsl:variable name="global-parameters" as="element()*" select="$global-parameters-document//*:parameters/*:parameter"/>
      <xsl:if test="exists($global-parameters)">
        <xsl:comment> == Global parameters from {$href-global-parameters}: == </xsl:comment>
        <xsl:copy-of select="$global-parameters"/>
      </xsl:if>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="generate-component-information-parameters" as="element(parameter)*">
    <xsl:for-each select="$component-information">

      <!-- Basic information: -->
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-name'"/>
        <xsl:with-param name="value" select="@name"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-display-name'"/>
        <xsl:with-param name="value" select="$component-display-name"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-title'"/>
        <xsl:with-param name="value" select="xwebdoc:title"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-documentation-uri'"/>
        <xsl:with-param name="value" select="xwebdoc:documentation-uri"/>
        <xsl:with-param name="value-must-exist" select="false()"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-git-uri'"/>
        <xsl:with-param name="value" select="xwebdoc:git-uri"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-git-site-uri'"/>
        <xsl:with-param name="value" select="xwebdoc:git-site-uri"/>
      </xsl:call-template>

      <!-- Release info: -->
      <xsl:variable name="current-release" as="element(xwebdoc:release)?" select="(xwebdoc:releases/xwebdoc:release)[1]"/>
      <xsl:if test="empty($current-release)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Missing release information in component information: ', xtlc:q($href-component-information))"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-current-release-version'"/>
        <xsl:with-param name="value" select="$current-release/@version"/>
      </xsl:call-template>
      <xsl:call-template name="create-parameter">
        <xsl:with-param name="name" select="'component-current-release-date'"/>
        <xsl:with-param name="value" select="$current-release/@date"/>
      </xsl:call-template>

    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-parameter" as="element(parameter)?">
    <xsl:param name="name" as="xs:string" required="yes"/>
    <xsl:param name="value" as="xs:string?" required="yes"/>
    <xsl:param name="value-must-exist" as="xs:boolean" required="false" select="true()"/>

    <xsl:variable name="value-is-empty" as="xs:boolean" select="normalize-space($value) eq ''"/>
    <xsl:if test="$value-must-exist and $value-is-empty">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Information for parameter ', xtlc:q($name), ' is missing from component information: ', xtlc:q($href-component-information))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not($value-is-empty)">
      <parameter name="{$name}">
        <value>{ $value }</value>
      </parameter>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
