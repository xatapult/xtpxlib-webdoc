<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all">

  <p:documentation>
    TBD
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>A report XML about the component documentation generation</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../../xpl/xdoc-to-componentdoc-website.xpl"/>

  <!-- ================================================================== -->

  <p:variable name="href-parameters" select="resolve-uri('../data/xtpxlib-webdoc-componentdoc-parameters.xml', static-base-uri())"/>
  
  <p:variable name="href-global-parameters" select="resolve-uri('../data/componentdoc-global-parameters.xml', static-base-uri())"/>
  <p:variable name="global-resources-dir" select="resolve-uri('../global-resources/', static-base-uri())"/>
  <p:variable name="href-template" select="resolve-uri('../data/componentdoc-website-template.html', static-base-uri())"/>
  <p:variable name="output-directory" select="resolve-uri('../../docs/', static-base-uri())"/>
  <p:variable name="href-readme" select="resolve-uri('../../README.md', static-base-uri())"/>

  <!-- Generate the website: -->
  <xwebdoc:xdoc-to-componentdoc-website>
    <p:input port="source">
      <p:document href="../source/xtpxlib-webdoc-componentdoc.xml"/>
    </p:input>
    <p:with-option name="component-name" select="'xtpxlib-webdoc'"/>
    <p:with-option name="component-display-name" select="'xtpxlib'"/>
    <p:with-option name="href-parameters" select="$href-parameters"/>
    <p:with-option name="parameter-filters" select="()"/>
    <p:with-option name="href-global-parameters" select="$href-global-parameters"/>
    <p:with-option name="resources-subdirectory" select="'resources/'"/>
    <p:with-option name="global-resources-directory" select="$global-resources-dir"/>
    <p:with-option name="href-template" select="$href-template"/>
    <p:with-option name="output-directory" select="$output-directory"/>
    <p:with-option name="href-readme" select="$href-readme"/> 
  </xwebdoc:xdoc-to-componentdoc-website>

</p:declare-step>
