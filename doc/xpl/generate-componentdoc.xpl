<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:local="#local" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Pipeline to create the documentation for this component.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>A report XML about the component documentation generation</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../../xpl/xdoc-to-componentdoc-website.xpl"/>

  <!-- ================================================================== -->
  <!-- SUBPIPELINE TO CREATE SEPARATE PDFs -->

  <p:declare-step type="local:create-pdf" name="local-create-pdf">

    <!-- Pass through: -->
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true">
      <p:pipe port="source" step="local-create-pdf"/>
    </p:output>

    <p:option name="href-source" required="true"/>
    <p:option name="base-output-directory" required="true"/>
    <p:import href="../../../xtpxlib-xdoc/xpl/xdoc-to-pdf.xpl"/>

    <!-- Get the filename of the input, without extension, and create an output filename from this: -->
    <p:variable name="filename-noext" select="substring-before(tokenize($href-source, '/')[last()], '.xml')"/>
    <p:variable name="href-output" select="concat($base-output-directory, '/additional/', $filename-noext, '.pdf')"/>

    <p:load dtd-validate="false">
      <p:with-option name="href" select="$href-source"/>
    </p:load>
    <xdoc:xdoc-to-pdf>
      <p:with-option name="href-pdf" select="$href-output"/>
    </xdoc:xdoc-to-pdf>
    <p:sink/>

  </p:declare-step>

  <!-- ================================================================== -->

  <p:variable name="href-parameters" select="resolve-uri('../data/xtpxlib-componentdoc-parameters.xml', static-base-uri())"/>
  <p:variable name="output-directory" select="resolve-uri('../../docs/', static-base-uri())"/>
  <p:variable name="href-readme" select="resolve-uri('../../README.md', static-base-uri())"/>

  <!-- Generate the website: -->
  <xwebdoc:xdoc-to-componentdoc-website>
    <p:input port="source">
      <p:document href="../source/xtpxlib-webdoc-componentdoc.xml"/>
    </p:input>
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
