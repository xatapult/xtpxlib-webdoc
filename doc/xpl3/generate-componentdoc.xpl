<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.vsb_j3x_byb"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="this">

  <p:documentation>
    Pipeline to create the documentation for this component.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xpl3/xdoc-to-componentdoc-website.xpl"/>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A report XML about the component documentation generation</p:documentation>
  </p:output>

  <!-- ================================================================== -->
  <!-- SUBPIPELINE TO CREATE SEPARATE PDFs -->

  <p:declare-step type="local:create-pdf" name="local-create-pdf">

    <p:import href="../../../xtpxlib-xdoc/xpl3/xdoc-to-pdf.xpl"/>

    <!-- Pass through: -->
    <p:input port="source" primary="true" sequence="false" content-types="xml"/>
    <p:output port="result" primary="true" sequence="false" content-types="xml" pipe="source@local-create-pdf"/>

    <p:option name="href-source" required="true"/>
    <p:option name="base-output-directory" required="true"/>

    <!-- Get the filename of the input, without extension, and create an output filename from this: -->
    <p:variable name="filename-noext" select="substring-before(tokenize($href-source, '/')[last()], '.xml')"/>
    <p:variable name="href-output" select="concat($base-output-directory, '/additional/', $filename-noext, '.pdf')"/>

    <xdoc:xdoc-to-pdf>
      <p:with-input port="source" href="{$href-source}"/>
      <p:with-option name="href-pdf" select="$href-output"/>
      <p:with-option name="href-xsl-fo" select="resolve-uri('../../tmp/webdoc-xsl-fo.xml', static-base-uri())"/>
      <p:with-option name="href-docbook" select="resolve-uri('../../tmp/webdoc-docbook.xml', static-base-uri())"/>
    </xdoc:xdoc-to-pdf>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="href-parameters" select="resolve-uri('../data/xtpxlib-componentdoc-parameters.xml', static-base-uri())"/>
  <p:variable name="output-directory" select="resolve-uri('../../docs/', static-base-uri())"/>
  <p:variable name="href-readme" select="resolve-uri('../../README.md', static-base-uri())"/>

  <!-- Generate the website: -->
  <xwebdoc:xdoc-to-componentdoc-website>
    <p:with-input port="source" href="../source/xtpxlib-webdoc-componentdoc.xml"/>
    <p:with-option name="component-name" select="(doc('../../component-info.xml')/*/@name, '?COMPONENTNAME?')[1]"/>
    <p:with-option name="component-display-name" select="'xtpxlib'"/>
    <p:with-option name="href-parameters" select="$href-parameters"/>
    <p:with-option name="output-directory" select="$output-directory"/>
    <p:with-option name="href-readme" select="$href-readme"/>
  </xwebdoc:xdoc-to-componentdoc-website>
  
  <local:create-pdf>
    <p:with-option name="href-source" select="resolve-uri('../source/howto-release.xml', static-base-uri())"/>
    <p:with-option name="base-output-directory" select="$output-directory"/>
  </local:create-pdf>

</p:declare-step>
