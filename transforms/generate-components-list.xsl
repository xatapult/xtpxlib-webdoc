<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.err_mjf_wjb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://docbook.org/ns/docbook"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~ 
    This xdoc transform looks at the global parameters file, parameter `active-components`. Creates a table with the active components overview.
    
    The (relative) URI of the global parameters file must be present as `@global-parameters-uri` on the `xdoc:transform` element.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../xslmod/xtpxlib-webdoc.mod.xsl"/>
  <xsl:include href="../../xtpxlib-common/xslmod/parameters.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- INFORMATION FROM THE <xdoc:transform> root element: -->

  <xsl:variable name="global-parameters-uri" as="xs:string" select="/*/@global-parameters-uri"/>

  <!-- ================================================================== -->

  <xsl:variable name="full-global-parameters-uri" as="xs:string" select="string(resolve-uri($global-parameters-uri, base-uri(/)))"/>
  <xsl:variable name="global-parameters" as="map(xs:string, xs:string*)" select="xtlc:parameters-get($full-global-parameters-uri, ())"/>
  <xsl:variable name="active-components" as="xs:string*" select="$global-parameters('active-components')"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xdoc:GROUP>
      <xsl:choose>
        <xsl:when test="exists($active-components)">
          <table role="nonumber">
            <title/>
            <tgroup cols="2">
              <colspec role="code-width-cm:3-6"/>
              <colspec/>
              <thead>
                <row>
                  <entry>Component</entry>
                  <entry>Description</entry>
                </row>
              </thead>
              <tbody>
                <xsl:for-each select="$active-components">
                  <xsl:variable name="component-information" as="element(xwebdoc:component-info)" select="xwebdoc:get-component-info(.)"/>
                  <xsl:variable name="documentation-uri" as="xs:string?" select="$component-information/xwebdoc:documentation-uri"/>
                  <row>
                    <entry>
                      <para>
                        <code role="code-width-limited">
                          <xsl:choose>
                            <xsl:when test="normalize-space($documentation-uri) ne ''">
                              <link xlink:href="{$documentation-uri}">{.}</link>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="."/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </code>
                      </para>
                    </entry>
                    <entry>
                      <para>{$component-information/xwebdoc:title}</para>
                    </entry>
                  </row>
                </xsl:for-each>
              </tbody>
            </tgroup>
          </table>
        </xsl:when>
        <xsl:when test="not(doc-available($full-global-parameters-uri))">
          <para>*** Global parameter file not found: "{$full-global-parameters-uri}"</para>
        </xsl:when>
        <xsl:otherwise>
          <para>*** Missing active-components parameter in global parameter file "{$full-global-parameters-uri}"</para>
        </xsl:otherwise>  
      </xsl:choose>
    </xdoc:GROUP>
  </xsl:template>

</xsl:stylesheet>
