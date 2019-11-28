<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:local="#local.rff_3dl_wjb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       TBD
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../xslmod/xtpxlib-webdoc.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="component-name" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($component-name)"/>
  <xsl:variable name="current-release" as="element(xwebdoc:release)" select="($component-information/xwebdoc:releases/xwebdoc:release)[1]"/>

  <xsl:variable name="documentation-uri" as="xs:string?" select="$component-information/xwebdoc:documentation-uri"/>
  <xsl:variable name="documentation-ref" as="xs:string"
    select="if (normalize-space($documentation-uri) ne '') then ('Documentation: ' || local:siteref($documentation-uri)) else ''"/>

  <xsl:variable name="dependent-component-information" as="map(xs:string, element(xwebdoc:component-info))"
    select="xwebdoc:get-dependent-component-information($component-name)"/>
  <xsl:variable name="component-dependency-lines" as="xs:string*">
    <xsl:if test="map:size($dependent-component-information) gt 0">
      <xsl:sequence select="'This component depends on:'"/>
      <xsl:for-each select="map:keys($dependent-component-information)">
        <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="$dependent-component-information(.)"/>
        <xsl:variable name="documentation-uri" as="xs:string?" select="$component-information/xwebdoc:documentation-uri"/>
        <xsl:variable name="component-link" as="xs:string"
          select="if (normalize-space($documentation-uri) ne '') then local:siteref(., $documentation-uri) else local:code(.)"/>
        <xsl:sequence select="'- ' || $component-link || ' (' || $component-information/xwebdoc:title || ')'"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="component-dependency-part" as="xs:string" select="string-join($component-dependency-lines, '&#x0a;')"/>

  <xsl:variable name="line" as="xs:string" select="'----------'"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">


    <README xml:space="preserve"># {local:code($component-name)}: {$component-information/xwebdoc:title}

**{$xwebdoc:owner-company-name} - {local:siteref($xwebdoc:owner-website-uri)}**

{$line} 

{$component-information/xwebdoc:summary}

{$line}

Component version: {$current-release/@version} - {$current-release/@date}

{$documentation-ref}

Git URI: {local:code($component-information/xwebdoc:git-uri)}

Git site: {local:siteref($component-information/xwebdoc:git-site-uri)}
      
Dependent components: {string-join(xwebdoc:get-dependent-component-names($component-name), '; ')}

{$component-dependency-part}
</README>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:code" as="xs:string">
    <xsl:param name="in" as="xs:string"/>
    <xsl:sequence select="'`' || $in || '`'"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:siteref" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="local:siteref($uri, $uri)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:siteref" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="'[' || local:code($name) || '](' || $uri || ')'"/>
  </xsl:function>
  
</xsl:stylesheet>
