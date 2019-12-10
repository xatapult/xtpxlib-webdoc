<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:local="#local.rff_3dl_wjb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Generates a CNAME file for the GitHub pages for this component
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
  <xsl:variable name="cname" as="xs:string" select="string($component-information/xwebdoc:documentation-uri) => xtlc:href-protocol-remove()"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <CNAME>{$cname}</CNAME>
  </xsl:template>

</xsl:stylesheet>
