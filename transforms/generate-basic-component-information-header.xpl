<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc"
  xmlns:db="http://docbook.org/ns/docbook" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
     xdoc transform. Creates a standard component header, suitable for inclusion on the home page of a component documentation website.
     
     Attributes on the xdoc:transform element:
     * `component-name`: (mandatory) Name of the component
     * `xtpxlib-generic`: (boolean, default `false`) If true a limited set is generated, suitable for the `xtpxlib` main website.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The document containing the XML description, wrapped in an `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>The resulting DocBook output, containing the element's description.</p:documentation>
  </p:output>
  
  <p:import href="../../xtpxlib-xdoc/xplmod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ================================================================== -->

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-generate-basic-component-information-header/generate-basic-component-information-header.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>
  
  <xdoc:markdown-to-docbook/>

</p:declare-step>
