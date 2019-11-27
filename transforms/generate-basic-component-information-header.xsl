<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.err_mjf_wjb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all" expand-text="false">
  <!-- ================================================================== -->
  <!--~ 
       Generates a suitable top sidebar with basic component and version information
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:variable name="is-xtpxlib-generic" as="xs:boolean" select="(xs:boolean(/*/@xtpxlib-generic), false())[1]"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xdoc:GROUP>
      <sidebar>
        <figure role="nonumber">
          <title/>
          <mediaobject>
            <imageobject>
              <imagedata fileref="resources/logo-xatapult.jpg" width="15%"/>
            </imageobject>
          </mediaobject>
        </figure>
        <para role="halfbreak"/>
        <xsl:if test="not($is-xtpxlib-generic)">
          <para>Component <emphasis role="bold"><code>{$component-name}</code></emphasis> version {$current-release-version} -
            {$current-release-date}</para>
        </xsl:if>
        <para>{$owner-company-name} - <link xlink:href="{{$owner-company-website}}"/> - {$owner-company-phone}</para>
        <para>{$author-name} - <link xlink:href="mailto:{{$author-email-address}}">{$author-email-address}</link></para>
      </sidebar>
      <para role="halfbreak"/>
    </xdoc:GROUP>
  </xsl:template>

</xsl:stylesheet>
