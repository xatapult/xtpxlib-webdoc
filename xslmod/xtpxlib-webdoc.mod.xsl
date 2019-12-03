<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:local="#local.h1l_l4k_wjb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--	
       Internal XSLT library for use in this module only.
	-->
  <!-- ================================================================== -->
  <!-- COMMON SETUP: -->

  <xsl:include href="../../xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="../../xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:variable name="xwebdoc:component-name" as="xs:string" select="'xtpxlib-webdoc'"/>

  <!-- ================================================================== -->
  <!-- COMPONENT INFO INFORMATION: -->

  <xsl:variable name="xwebdoc:component-info-file-name" as="xs:string" select="'component-info.xml'"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xwebdoc:get-component-info" as="element(xwebdoc:component-info)">
    <!--~ 
      Returns the root element of a component's information file. 
    -->
    <xsl:param name="component-name" as="xs:string?">
      <!--~ 
        Name of the component to get the information for. If empty get it for this component.  
      -->
    </xsl:param>

    <!-- Find out what to get and where to get it: -->
    <xsl:variable name="component-name-to-get" as="xs:string" select="($component-name, $xwebdoc:component-name)[1]"/>
    <xsl:variable name="href-component-root-directory" as="xs:string"
      select="replace(static-base-uri(), '/' || $xwebdoc:component-name || '/.*$', '')"/>
    <xsl:variable name="href-component-info" as="xs:string"
      select="xtlc:href-concat(($href-component-root-directory, $component-name, $xwebdoc:component-info-file-name))"/>

    <!-- Get it and check some things on the way: -->
    <xsl:if test="not(doc-available($href-component-info))">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Component information file not found or not well-formed: ', xtlc:q($href-component-info))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="component-info-document" as="document-node()" select="doc($href-component-info)"/>
    <xsl:if test="empty($component-info-document/*/self::xwebdoc:component-info)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Component information file is invalid (incorrect root element): ', xtlc:q($href-component-info))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="component-name-from-document" as="xs:string" select="string($component-info-document/*/@name)"/>
    <xsl:if test="$component-name ne $component-name-from-document">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Component information file is not for the requested component (request was for ', xtlc:q($component-name), 
          ', found ', xtlc:q($component-name-from-document), '): ', xtlc:q($href-component-info))"
        />
      </xsl:call-template>
    </xsl:if>
    <xsl:sequence select="$component-info-document/*"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xwebdoc:get-dependent-component-information" as="map(xs:string, element(xwebdoc:component-info))">
    <!--~ TBD  -->
    <xsl:param name="component-name" as="xs:string"/>

    <xsl:variable name="component-names" as="xs:string*" select="xwebdoc:get-dependent-component-names($component-name)"/>
    <xsl:map>
      <xsl:for-each select="$component-names">
        <xsl:map-entry key="." select="xwebdoc:get-component-info(.)"/>
      </xsl:for-each>
    </xsl:map>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xwebdoc:get-dependent-component-names" as="xs:string*">
    <!--~ TBD  -->
    <xsl:param name="component-name" as="xs:string"/>
    <xsl:sequence select="local:get-dependent-component-names-recursive($component-name, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-dependent-component-names-recursive" as="xs:string*">
    <xsl:param name="component-name" as="xs:string"/>
    <xsl:param name="exclude-names" as="xs:string*"/>

    <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($component-name)"/>
    <xsl:variable name="dependent-components" as="xs:string*"
      select="distinct-values($component-information/xwebdoc:dependencies/xwebdoc:component/@name/normalize-space())"/>
    <xsl:variable name="dependent-components-filtered" as="xs:string*" select="$dependent-components[not(. = $exclude-names)][. ne $component-name]"/>

    <xsl:variable name="gathered-dependent-components" as="xs:string*">
      <xsl:sequence select="$dependent-components-filtered"/>
      <xsl:for-each select="$dependent-components-filtered">
        <xsl:sequence select="local:get-dependent-component-names-recursive(., ($component-name, $exclude-names))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="distinct-values($gathered-dependent-components)"/>

  </xsl:function>

</xsl:stylesheet>
