<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local-xdoc-to-moduledoc-website" xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Adapts the generated HTML so it becomes suitable for the Bootstrap environment.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="component-display-name" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <!-- We need some weird adjustments for margins to prevent content disappearing behind the menu... Its probably I don't understand something
    right, but this seems to work... -->
  <xsl:variable name="margin-adjustment" as="xs:string" select="'65px'"/>
  <xsl:variable name="header-style" as="xs:string" select="'padding-top: ' || $margin-adjustment || '; margin-top: -' || $margin-adjustment || ';'"/>

  <!-- ================================================================== -->
  <!-- GNERERIC ADJUSTMENTS: -->

  <xsl:template match="xhtml:body">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="style" select="'padding-top: ' || $margin-adjustment || ';'"/>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:div[@class = ('chapter', 'preface', 'appendix')]">
    <div class="container">
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:h1" priority="10">
    <div class="page-header" style="{$header-style}">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:h2 | xhtml:h3 | xhtml:h4  | xhtml:h5 | xhtml:h6 | xhtml:h7 | xhtml:h8 | xhtml:h9">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="style" select="$header-style"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:span['bold' = xtlc:str2seq(@class)]">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- MENU: -->

  <xsl:template match="xhtml:div[@class eq 'toc']">

    <xsl:variable name="toc-level-0" as="element(xhtml:ul)?" select="xhtml:ul[@class eq 'toc-level-0']"/>
    <xsl:variable name="first-link" as="element(xhtml:a)" select="$toc-level-0/xhtml:li[1]/xhtml:a"/>


    <!-- Rework TOC to bootstrap style -->
    <nav class="navbar fixed-top navbar-expand-sm navbar-dark bg-dark">

      <!-- Brand = Name of the component: -->
      <a class="navbar-brand" href="{$first-link/@href}" title="home">{ $component-display-name }</a>

      <!-- Button, I think this when resized on small display? -->
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
        aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"/>
      </button>

      <div id="navbarSupportedContent" class="collapse navbar-collapse">
        <ul class="navbar-nav mr-auto">
          <xsl:for-each select="$toc-level-0/xhtml:li[position() gt 1]">
            <xsl:variable name="toc-level-1" as="element(xhtml:ul)?" select="xhtml:ul[@class eq 'toc-level-1']"/>
            <li class="nav-item">
              <xsl:choose>

                <!-- Dropdown menu entry: -->
                <xsl:when test="exists($toc-level-1)">
                  <xsl:attribute name="class" select="'nav-item dropdown'"/>
                  <xsl:variable name="entry-main-title" as="xs:string" select="string(xhtml:a)"/>
                  <xsl:variable name="entry-main-href" as="xs:string" select="xhtml:a/@href"/>
                  <a href="{$entry-main-href}" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true"
                    aria-expanded="false">
                    <xsl:value-of select="local:title-no-numbers($entry-main-title)"/>
                    <xsl:text> </xsl:text>
                    <span class="caret"/>
                  </a>
                  <div class="dropdown-menu">
                    <xsl:for-each select="$toc-level-1">

                      <a href="{$entry-main-href}" class="dropdown-item">
                        <xsl:value-of select="local:title-no-numbers($entry-main-title)"/>
                      </a>
                      <div class="dropdown-divider">
                        <xsl:comment/>
                      </div>
                      <xsl:for-each select="xhtml:li">
                        <a class="dropdown-item">
                          <xsl:copy-of select="xhtml:a/@* except xhtml:a/@class"/>
                          <xsl:value-of select="local:title-no-numbers(string(xhtml:a))"/>
                        </a>
                      </xsl:for-each>
                    </xsl:for-each>
                  </div>
                </xsl:when>

                <!-- Normal single menu entry: -->
                <xsl:otherwise>
                  <a class="nav-link">
                    <xsl:copy-of select="xhtml:a/@* except xhtml:a/@class"/>
                    <xsl:value-of select="local:title-no-numbers(string(xhtml:a))"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>

            </li>
          </xsl:for-each>
        </ul>
      </div>

    </nav>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- TABLE ADJUSTMENTS: -->

  <xsl:template match="xhtml:table">
    <xsl:copy>
      <xsl:copy-of select="@* except @class"/>
      <xsl:attribute name="class" select="'table table-sm table-bordered'"/>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:thead">
    <xsl:copy>
      <xsl:copy-of select="@* except @class"/>
      <xsl:attribute name="class" select="'thead-light'"/>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xhtml:td/xhtml:p | xhtml:th/xhtml:p">
    <!-- Remove surrounding p elements: -->
    <xsl:apply-templates/>
    <xsl:if test="exists(following-sibling::xhtml:*)">
      <br/>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:title-no-numbers" as="xs:string">
    <xsl:param name="title" as="xs:string"/>
    <xsl:sequence select="replace($title, '^[0-9.]+\s+', '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:annoying-warning-suppression-template"/>

</xsl:stylesheet>
