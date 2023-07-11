<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.gcj_h3w_byb"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc"
  xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0" exclude-inline-prefixes="#all" type="xwebdoc:xdoc-to-componentdoc-website"
  name="xdoc-to-componentdoc-website">

  <p:documentation>
     Creates a documentation website for a component from an xdoc book style document.
     Relative names are resolved against the base URI of the *source document*.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <!-- From xtpxlib-common: -->
  <p:import href="../../xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>

  <!-- From xtpxlib-xdoc: -->
  <p:import href="../../xtpxlib-xdoc/xpl3/xdoc-to-docbook.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl3/docbook-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl3/docbook-to-pdf.xpl"/>

  <!-- From xtpxlib-container: -->
  <p:import href="../../xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:document href="../doc/source/xtpxlib-webdoc-componentdoc.xml" use-when="$develop"/>
    <p:documentation>The DocBook source with xdoc extensions to create the website from</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small XML report about the website generation.</p:documentation>
    <p:pipe port="result" step="end-result"/>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="component-name" as="xs:string" required="true" use-when="not($develop)">
    <p:documentation>The name of the component (e.g. `xtpxlib-xdoc`) for which the documentation is generated.</p:documentation>
  </p:option>
  <p:option name="component-name" as="xs:string" required="false" select="'xtpxlib-webdoc'" use-when="$develop"/>

  <p:option name="component-display-name" as="xs:string?" required="false" select="()">
    <p:documentation>The name of the component (e.g. `xtpxlib`) under which name the documentation is generated. 
      If empty `$component-name` is used.</p:documentation>
  </p:option>

  <p:option name="href-parameters" as="xs:string?" required="false" select="()">
    <p:documentation>Reference to an optional document with parameter settings. See the `xtpxlib-common` `parameters.mod.xsl` module for details
      about its format.</p:documentation>
  </p:option>

  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="not($develop)">
    <p:documentation>Optional filter settings for processing the parameters.</p:documentation>
  </p:option>
  <p:option name="parameter-filters-map" as="map(xs:string, xs:string)" required="false" select="map{}" use-when="$develop"/>

  <p:option name="href-readme" as="xs:string?" required="false" select="()">
    <p:documentation>The name of the README file to generate (if any).</p:documentation>
  </p:option>

  <p:option name="output-directory" as="xs:string" required="true" use-when="not($develop)">
    <p:documentation>The name of the output directory for the generated website.</p:documentation>
  </p:option>
  <p:option name="output-directory" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())" use-when="$develop"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- The following options all get sensible defaults which are, in most cases, OK: -->
  <!-- REMARK: In the 1.0 version, a bug in Calabash (?) returned the wrong value for static-base-uri() in p:option/@select (the URI of the importing
       document, not this one). Therefore we postpone the calculation of the actual defaults for these parameters to later on. This workaround was not (yet?) 
       removed in the 3.0 version.
  -->

  <p:option name="resources-target-subdirectory" as="xs:string" required="false" select="'resources'">
    <p:documentation>The *relative* name of the subdirectory that contains specific resources (like CSS, images, etc.) for this component.</p:documentation>
  </p:option>

  <p:option name="href-global-parameters" as="xs:string?" required="false" select="()">
    <p:documentation>Reference to the global parameters file.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" as="xs:string?" required="false" select="()">
    <p:documentation>The name of the subdirectory that contains global resources (resources used for documenting a group of components).</p:documentation>
  </p:option>

  <p:option name="href-template" as="xs:string?" required="false" select="()">
    <p:documentation>Reference to the HTML template used for generating the website pages.</p:documentation>
  </p:option>

  <!-- ================================================================== -->

  <p:declare-step type="local:merge-parameters-and-version-information" name="merge-parameters-and-version-information">

    <p:documentation>
      Merges information from the `component-info.xml` document, the local and global parameters and some other stuff into a single
      parameter file. Writes this to disk.
      
      Acts like a `p:identity` step in the pipeline.
    </p:documentation>

    <p:option name="component-name" as="xs:string" required="true"/>
    <p:option name="component-display-name" as="xs:string" required="true"/>
    <p:option name="href-parameters" as="xs:string?" required="false" select="()"/>
    <p:option name="href-global-parameters" as="xs:string?" required="false" select="()"/>
    <p:option name="href-result" as="xs:string" required="true"/>

    <p:input port="source" primary="true" sequence="true" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@merge-parameters-and-version-information"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:xslt>
      <p:with-input port="source">
        <null/>
      </p:with-input>
      <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/merge-parameters-and-version-information.xsl"/>
      <p:with-option name="parameters" select="map{
        'href-parameters': $href-parameters,  
        'href-global-parameters': $href-global-parameters,
        'component-name': $component-name,
        'component-display-name': $component-display-name
      }"/>
    </p:xslt>
    <p:store href="{$href-result}" serialization="map{'method': 'xml', 'indent': true()}"/>

  </p:declare-step>

  <!-- ================================================================== -->

  <p:declare-step type="local:generate-readme" name="generate-readme">

    <p:documentation>
      Generates a standard `xtpxlib` `README.md` file.
      
      Acts like a `p:identity` step in the pipeline.
    </p:documentation>

    <p:option name="href-readme" required="true"/>
    <p:option name="component-name" required="true"/>
    <p:option name="href-global-parameters" required="true"/>

    <p:input port="source" primary="true" sequence="true" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@generate-readme"/>


    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:if test="normalize-space($href-readme) ne ''">
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/generate-readme.xsl"/>
        <p:with-option name="parameters" select="map{
            'component-name': $component-name,
            'href-global-parameters': $href-global-parameters
          }"/>
      </p:xslt>
      <p:store href="{$href-readme}" serialization="map{'method': 'text'}"/>
    </p:if>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="start-timestamp" as="xs:dateTime" select="current-dateTime()"/>

  <!-- Make sure all relative directory and file names are resolved against the directory of the source document: -->
  <p:variable name="base-uri-source-document" as="xs:string" select="base-uri(/)"/>
  <p:variable name="full-href-parameters" as="xs:string?"
    select="if (normalize-space($href-parameters) eq '') then () else resolve-uri($href-parameters, $base-uri-source-document)"/>
  <p:variable name="full-resources-source-directory" as="xs:string" select="resolve-uri($resources-target-subdirectory, $base-uri-source-document)"/>
  <p:variable name="full-output-directory" as="xs:string" select="resolve-uri($output-directory, $base-uri-source-document)"/>
  <p:variable name="full-resources-target-directory" as="xs:string"
    select="string-join(($full-output-directory, $resources-target-subdirectory), '/')"/>
  <p:variable name="href-parameters-merged-temp" as="xs:string" select="string-join(($full-output-directory, 'merged-parameters-temp.xml'), '/')"/>

  <!-- Provide sensible defaults for some global files/directories. This done here due to a 1.0  Calabash bug (?) in the
    static-base-uri() handling of which the workaround is not yet removed.. -->
  <p:variable name="full-href-global-parameters" as="xs:string" select="if (normalize-space($href-global-parameters) eq '') 
    then resolve-uri('../global/data/componentdoc-global-parameters.xml', static-base-uri()) 
    else resolve-uri($href-global-parameters, $base-uri-source-document)"/>
  <p:variable name="full-global-resources-directory" as="xs:string" select="if (normalize-space($global-resources-directory) eq '') 
    then resolve-uri('../global/resources/', static-base-uri())
    else resolve-uri($global-resources-directory, $base-uri-source-document)"/>
  <p:variable name="full-href-template" as="xs:string" select="if (normalize-space($href-template) eq '') 
    then resolve-uri('../global/data/componentdoc-website-template.html', static-base-uri()) 
    else resolve-uri($href-template, $base-uri-source-document)"/>

  <!-- Get the correct component display name: -->
  <p:variable name="component-display-name-to-use" as="xs:string"
    select="if (normalize-space($component-display-name) eq '') then $component-name else $component-display-name"/>

  <!-- Definitions for the PDF version: -->
  <p:variable name="pdf-filename" as="xs:string"
    select="concat(replace($component-display-name-to-use, '[^A-Za-z0-9\-.]', '_'), '-documentation.pdf')"/>
  <p:variable name="pdf-relative-href" as="xs:string" select="string-join(($resources-target-subdirectory, $pdf-filename), '/')"/>
  <p:variable name="pdf-absolute-href" as="xs:string" select="string-join(($full-output-directory, $pdf-relative-href), '/')"/>

  <!-- Remove the output directory first: -->
  <xtlc:create-clear-directory href-dir="{$output-directory}"/>

  <!-- We're going to write a temporary new parameters document to the output directory 
    (it is deleted later when the output directory is overwritten): -->
  <local:merge-parameters-and-version-information>
    <p:with-option name="component-name" select="$component-name"/>
    <p:with-option name="component-display-name" select="$component-display-name-to-use"/>
    <p:with-option name="href-parameters" select="$full-href-parameters"/>
    <p:with-option name="href-global-parameters" select="$full-href-global-parameters"/>
    <p:with-option name="href-result" select="$href-parameters-merged-temp"/>
  </local:merge-parameters-and-version-information>

  <!-- Turn the xdoc source into Docbook (we're going to use this later on to create the PDF also): -->
  <xdoc:xdoc-to-docbook name="docbook-contents">
    <p:with-option name="href-parameters" select="$href-parameters-merged-temp"/>
    <p:with-option name="parameter-filters-map" select="$parameter-filters-map"/>
  </xdoc:xdoc-to-docbook>

  <!-- Now create the XHTML version: -->
  <xdoc:docbook-to-xhtml/>

  <!-- Create an xtpxlib-container structure for writing the XHTML results:. -->
  <!-- WARNING: This assumes there are no double titles. Normally this won't be the case because all prefaces/chapters/appendices 
    are numbered. But... decisions about naming and numbering might influence that. We'll pas that bridge when we stumble upon it.
  -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/create-basic-container.xsl"/>
    <p:with-option name="parameters" select="map{
      'component-name': $component-name,
      'href-target-path': $full-output-directory,
      'href-componentdoc-website-template': $full-href-template
    }"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/fix-internal-links.xsl"/>
  </p:xslt>

  <!-- Add internal linking between the pages (TOC, etc.): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/add-additional-links.xsl"/>
    <p:with-option name="parameters" select="map{
      'pdf-href':  $pdf-relative-href
    }"/>
  </p:xslt>

  <!-- Adapt things a little (more bootstrap style): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/adapt-html.xsl"/>
    <p:with-option name="parameters" select="map{
      'component-display-name': $component-display-name-to-use
    }"/>
  </p:xslt>

  <!-- Insert directory information for the resources and re-work this to the right container external document entries: -->
  <!-- Remark: the global list is inserted before the specific one, so you can override files from it with ones from the specific directory. -->
  <p:insert match="/*" position="first-child">
    <p:with-input port="insertion" pipe="result@resources-directory-list"/>
  </p:insert>
  <p:insert match="/*" position="first-child">
    <p:with-input port="insertion" pipe="result@global-resources-directory-list"/>
  </p:insert>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-xdoc-to-componentdoc-website/rework-resources-directory-list.xsl"/>
    <p:with-option name="parameters" select="map{
      'resources-target-directory': $full-resources-target-directory
    }"/>
  </p:xslt>


  <p:store href="file:///C:/xdata/container-test/container.xml"/>

  <!-- Write the result out to disk: -->
  <xtlcon:container-to-disk remove-target="false"/>

  <!-- Create the PDF version of the documentation also: -->
  <xdoc:docbook-to-pdf>
    <p:with-input port="source" pipe="@docbook-contents"/>
    <p:with-option name="href-pdf" select="$pdf-absolute-href"/>
    <p:with-option name="global-resources-directory" select="$full-global-resources-directory"/>
  </xdoc:docbook-to-pdf>

  <!-- Generate a little report: -->
  <p:identity>
    <p:with-input port="source">
      <xdoc-to-componentdoc-website/>
    </p:with-input>
  </p:identity>
  <p:add-attribute attribute-name="timestamp" match="/*">
    <p:with-option name="attribute-value" select="string($start-timestamp)"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="duration" match="/*">
    <p:with-option name="attribute-value" select="string(current-dateTime() - $start-timestamp)"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="source" match="/*">
    <p:with-option name="attribute-value" select="$base-uri-source-document"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="output-directory" match="/*">
    <p:with-option name="attribute-value" select="$full-output-directory"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="pdf" match="/*">
    <p:with-option name="attribute-value" select="$pdf-absolute-href"/>
  </p:add-attribute>

  <!-- Generate a readme file (if any): -->
  <local:generate-readme>
    <p:with-option name="href-readme" select="$href-readme"/>
    <p:with-option name="component-name" select="$component-name"/>
    <p:with-option name="href-global-parameters" select="$full-href-global-parameters"/>
  </local:generate-readme>

  <!-- Remove the temporary parameters file: -->
  <p:file-delete href="{$href-parameters-merged-temp}" fail-on-error="true"/>

  <!-- Done: -->
  <p:identity name="end-result"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the specific resources directory: -->

  <xtlc:recursive-directory-list name="resources-directory-list">
    <p:with-option name="path" select="$full-resources-source-directory"/>
    <p:with-option name="flatten" select="true()"/>
  </xtlc:recursive-directory-list>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the global resources directory: -->

  <xtlc:recursive-directory-list name="global-resources-directory-list">
    <p:with-option name="path" select="$full-global-resources-directory"/>
    <p:with-option name="flatten" select="true()"/>
  </xtlc:recursive-directory-list>

</p:declare-step>
