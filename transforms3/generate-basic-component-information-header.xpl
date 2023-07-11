<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xsk_trw_byb"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" name="this">

  <p:documentation>
     xdoc transform. Creates a standard component header, suitable for inclusion on the home page of a component documentation website.
     
     Attributes on the xdoc:transform element:
     * `component-name`: (mandatory) Name of the component
     * `xtpxlib-generic`: (boolean, default `false`) If true a limited set is generated, suitable for the `xtpxlib` main website.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-xdoc/xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The document containing the XML description, wrapped in an `xdoc:transform` element.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml">
    <p:documentation>The resulting DocBook output, containing the element's description.</p:documentation>
  </p:output>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-generate-basic-component-information-header/generate-basic-component-information-header.xsl"/>
  </p:xslt>

  <xdoc:markdown-to-docbook/>

</p:declare-step>
