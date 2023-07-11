<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.err_mjf_wjb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://docbook.org/ns/docbook"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~ 
       Generates a suitable top sidebar with basic component and version information
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../xslmod/xtpxlib-webdoc.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- INFORMATION FROM THE <xdoc:transform> root element: -->

  <xsl:variable name="component-name" as="xs:string" select="/*/@component-name"/>
  <xsl:variable name="is-xtpxlib-generic" as="xs:boolean" select="(xs:boolean(/*/@xtpxlib-generic), false())[1]"/>

  <!-- ================================================================== -->

  <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($component-name)"/>
  <xsl:variable name="current-release" as="element(xwebdoc:release)" select="($component-information/xwebdoc:releases/xwebdoc:release)[1]"/>
  
  <!-- Do not show more than this number of release entries: -->
  <xsl:variable name="release-entries-max" as="xs:integer" select="5"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xdoc:GROUP>

      <!-- Sidebar with some overview info and logo: -->
      <sidebar>
        <figure role="global nonumber">
          <title/>
          <mediaobject>
            <imageobject>
              <!--<imagedata fileref="resources/logo-xatapult.jpg" width="15%"/>-->
              <imagedata fileref="resources/logo-xtpxlib.png"/>
            </imageobject>
          </mediaobject>
        </figure>
        <para role="halfbreak"/>
        <xsl:if test="not($is-xtpxlib-generic)">
          <para><emphasis role="bold"><code>xtpxlib</code></emphasis> library - component <emphasis role="bold"
              ><code>{$component-name}</code></emphasis> - <emphasis role="bold">v{$current-release/@version}</emphasis>
            ({$current-release/@date})</para>
        </xsl:if>
        <para xsl:expand-text="false">{$owner-company-name} - <link role="newpage" xlink:href="{{$owner-company-website}}"/> -
          {$owner-company-phone}</para>
        <para xsl:expand-text="false">{$author-name} - <link xlink:href="mailto:{{$author-email-address}}">{$author-email-address}</link></para>
      </sidebar>
      <para role="halfbreak"/>

      <!-- Generic info: -->
      <xsl:if test="not($is-xtpxlib-generic)">

        <para><emphasis role="bold"><code>{$component-name}</code></emphasis> is part of the <emphasis role="bold"><code>xtpxlib</code></emphasis>
          library. <emphasis role="bold"><code>xtpxlib</code></emphasis> contains software for processing XML, using languages like XSLT and XProc. It
          consists of several separate components, all named <code>xtpxlib-*</code>. Everything can be found on GitHub (<link role="newpage"
            xlink:href="{{$owner-company-git-site-uri}}"/>).</para>
        <xdoc:MARKDOWN>{$component-information/xwebdoc:summary}</xdoc:MARKDOWN>

        <xsl:variable name="main-component-info" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($xwebdoc:component-name)"/>
        <xsl:variable name="main-documentation-uri" as="xs:string?" select="$main-component-info/xwebdoc:documentation-uri"/>
        <xsl:if test="exists($main-documentation-uri)">
          <para>Installation and usage information can be found on <emphasis role="bold"><code>xtpxlib</code></emphasis>'s main website <link
              xlink:href="{$main-documentation-uri}"/>.</para>
        </xsl:if>

        <!-- Technical information: -->
        <bridgehead>Technical information:</bridgehead>
        <xsl:variable name="documentation-uri" as="xs:string?" select="$component-information/xwebdoc:documentation-uri"/>
        <xsl:if test="exists($documentation-uri)">
          <para>Component documentation: <link xlink:href="{$documentation-uri}"/></para>
        </xsl:if>
        <para xsl:expand-text="false">License: {$license}</para>
        <para>Git URI: <code>{$component-information/xwebdoc:git-uri}</code></para>
        <para>Git site: <link role="newpage" xlink:href="{$component-information/xwebdoc:git-site-uri}"/></para>
        <xsl:call-template name="generate-dependency-info"/>

        <!-- Release information: -->
        <bridgehead>Release information:</bridgehead>
      <xsl:variable name="releases" as="element(xwebdoc:release)*" select="$component-information/xwebdoc:releases/xwebdoc:release"/>
        <variablelist>
          <xsl:for-each select="$releases[position() le $release-entries-max]">
            <varlistentry>
              <term>v{@version} - {@date} {if (position() eq 1) then '(current)' else ()}</term>
              <listitem>
                <xdoc:MARKDOWN>{.}</xdoc:MARKDOWN>
              </listitem>
            </varlistentry>
          </xsl:for-each>
        </variablelist>
        
        <xsl:if test="count($releases) gt $release-entries-max">
          <para>(Abbreviated. Full release information in <code>README.md</code>)</para>
        </xsl:if>
        
      </xsl:if>

    </xdoc:GROUP>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="generate-dependency-info">

    <xsl:variable name="dependent-component-information" as="map(xs:string, element(xwebdoc:component-info))"
      select="xwebdoc:get-dependent-component-information($component-name)"/>
    <xsl:if test="map:size($dependent-component-information) gt 0">
      <para>This component depends on:</para>
      <itemizedlist>
        <xsl:for-each select="map:keys($dependent-component-information)">
          <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="$dependent-component-information(.)"/>
          <xsl:variable name="documentation-uri" as="xs:string?" select="$component-information/xwebdoc:documentation-uri"/>
          <listitem>
            <para>
              <xsl:choose>
                <xsl:when test="normalize-space($documentation-uri) ne ''">
                  <link xlink:href="{$documentation-uri}">{.}</link>
                </xsl:when>
                <xsl:otherwise>
                  <code>{.}</code>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text> (</xsl:text>
              <xsl:value-of select="$component-information/xwebdoc:title"/>
              <xsl:text>)</xsl:text>
            </para>
          </listitem>
        </xsl:for-each>
      </itemizedlist>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-main-website-uri" as="xs:string?">
    <xsl:variable name="main-component-info" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info($xwebdoc:component-name)"/>
    <xsl:sequence select="$main-component-info/xwebdoc:documentation-uri"/>
  </xsl:function>

</xsl:stylesheet>
