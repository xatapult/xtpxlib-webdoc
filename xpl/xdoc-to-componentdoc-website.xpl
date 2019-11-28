<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:local="#local" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xwebdoc="http://www.xtpxlib.nl/ns/webdoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all"
  type="xwebdoc:xdoc-to-componentdoc-website">

  <p:documentation>
     Creates a documentation website for a component from an xdoc book style document.
     Relative names are resolved against the base URI of the *source document*.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook source with xdoc extensions to create the website from</p:documentation>
  </p:input>

  <p:option name="href-parameters" required="false" select="()">
    <p:documentation>Reference to an optional document with parameter settings. See the xtpxlib-common parameters.mod.xsl module for details.</p:documentation>
  </p:option>

  <p:option name="parameter-filters" required="false" select="()">
    <p:documentation>Filter settings for processing the parameters. Format: "name=value|name=value|..."</p:documentation>
  </p:option>

  <p:option name="href-global-parameters" required="false" select="()">
    <p:documentation>Optional global parameters file. The parameters from this file will be merged in as well.</p:documentation>
  </p:option>

  <p:option name="resources-subdirectory" required="false" select="()">
    <p:documentation>The *relative* name of the subdirectory that contains specific resources (like CSS, images, etc.) for this component.</p:documentation>
  </p:option>

  <p:option name="global-resources-directory" required="false" select="()">
    <p:documentation>The name of the subdirectory that contains global resources (resources used for documenting a group of components).</p:documentation>
  </p:option>

  <p:option name="output-directory" required="true">
    <p:documentation>The name of the output directory for the generated website.</p:documentation>
  </p:option>

  <p:option name="href-template" required="true">
    <p:documentation>TBD html template to use</p:documentation>
  </p:option>

  <p:option name="component-name" required="true">
    <p:documentation>The name of the component (e.g. `xtpxlib-xdoc`) for which the documentation is generated.</p:documentation>
  </p:option>

  <p:option name="component-display-name" required="false" select="()">
    <p:documentation>The name of the component (e.g. `xtpxlib`) under which name the documentation is generated. If empty `$component-name` is used.</p:documentation>
  </p:option>

  <p:option name="href-readme" required="false" select="()">
    <p:documentation>The name of the readme file to generate (if any).</p:documentation>
  </p:option>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>TBD???</p:documentation>
    <p:pipe port="result" step="end-result"/>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../../xtpxlib-xdoc/xpl/xdoc-to-docbook.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl/docbook-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl/docbook-to-pdf.xpl"/>
  <p:import href="../../xtpxlib-common/xplmod/common.mod/common.mod.xpl"/>
  <p:import href="../../xtpxlib-container/xplmod/container.mod/container.mod.xpl"/>

  <!-- ================================================================== -->
  <!-- TBD -->

  <p:declare-step type="local:merge-parameters-and-version-information" name="merge-parameters-and-version-information">

    <p:documentation>
      Merges a set of parameters with information from a standard `xtpxlib` component information file. Writes this file to disk.
      Acts like a p:identity step, primary input is passed unchanged.
      
      Turns the component information into the following parameters:
      * `component-name`
      * `component-display-name`
      * `component-title`
      * `component-documentation-uri`
      * `component-git-uri`
      * `component-git-site-uri`
      * `component-current-release-version`
      * `component-current-release-date`
    </p:documentation>

    <p:option name="component-name" required="true"/>
    <p:option name="component-display-name" required="true"/>
    <p:option name="href-parameters" required="false" select="()"/>
    <p:option name="href-global-parameters" required="false" select="()"/>
    <p:option name="href-result" required="true"/>

    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true">
      <p:pipe port="source" step="merge-parameters-and-version-information"/>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:xslt>
      <p:input port="source">
        <p:inline>
          <null/>
        </p:inline>
      </p:input>
      <p:input port="stylesheet">
        <p:document href="xsl-xdoc-to-componentdoc-website/merge-parameters-and-version-information.xsl"/>
      </p:input>
      <p:with-param name="href-parameters" select="$href-parameters"/>
      <p:with-param name="href-global-parameters" select="$href-global-parameters"/>
      <p:with-param name="component-name" select="$component-name"/>
      <p:with-param name="component-display-name" select="$component-display-name"/>
    </p:xslt>
    <p:store method="xml" indent="true" encoding="UTF-8" omit-xml-declaration="false">
      <p:with-option name="href" select="$href-result"/>
    </p:store>

  </p:declare-step>

  <!-- ================================================================== -->

  <p:declare-step type="xwebdoc:delete-file" name="delete-file" xmlns:pxf="http://exproc.org/proposed/steps/file">

    <p:documentation>
      Deletes a single file. Acts like a `p:identity` step.
      
      Isolated in a separate substep because we had difficulties in timing the deletion right. Now its part of the flow ans will be 
      deleted when we intend it to (at the end of all processing).
    </p:documentation>

    <p:option name="href" required="true"/>

    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true">
      <p:pipe port="source" step="delete-file"/>
    </p:output>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <pxf:delete recursive="false" fail-on-error="true">
      <p:with-option name="href" select="$href"/>
    </pxf:delete>

  </p:declare-step>

  <!-- ================================================================== -->

  <p:declare-step type="xwebdoc:generate-readme" name="generate-readme">

    <p:documentation>
    TBD
    </p:documentation>

    <p:option name="href-readme" required="true"/>
    <p:option name="component-name" required="true"/>
    
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true">
      <p:pipe port="source" step="generate-readme"/>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:choose>
      <p:when test="normalize-space($href-readme) ne ''">
        <p:xslt>
          <p:input port="stylesheet">
            <p:document href="xsl-xdoc-to-componentdoc-website/generate-readme.xsl"/>
          </p:input>
          <p:with-param name="component-name" select="$component-name"/>
        </p:xslt>
        <p:store method="text" encoding="UTF-8">
          <p:with-option name="href" select="$href-readme"/>
        </p:store>
      </p:when>
      <p:otherwise>
        <p:sink/>
      </p:otherwise>
    </p:choose>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- MAIN PIPELINE: -->

  <p:variable name="start-timestamp" select="current-dateTime()"/>

  <!-- Make sure all relative directory and file names are resolved against the directory of the source document: -->
  <p:variable name="base-uri-source-document" select="base-uri(/)"/>
  <p:variable name="full-href-parameters"
    select="if (normalize-space($href-parameters) eq '') then () else resolve-uri($href-parameters, $base-uri-source-document)"/>
  <p:variable name="full-href-global-parameters"
    select="if (normalize-space($href-global-parameters) eq '') then () else resolve-uri($href-global-parameters, $base-uri-source-document)"/>
  <p:variable name="full-resources-source-directory" select="resolve-uri($resources-subdirectory, $base-uri-source-document)"/>
  <p:variable name="full-global-resources-directory" select="resolve-uri($global-resources-directory, $base-uri-source-document)"/>
  <p:variable name="full-output-directory" select="resolve-uri($output-directory, $base-uri-source-document)"/>
  <p:variable name="full-resources-target-directory" select="string-join(($full-output-directory, $resources-subdirectory), '/')"/>
  <p:variable name="full-href-template" select="resolve-uri($href-template, $base-uri-source-document)"/>

  <!-- Get the correct component display name: -->
  <p:variable name="component-display-name-to-use"
    select="if (normalize-space($component-display-name) eq '') then $component-name else $component-display-name"/>

  <!-- Definitions for the PDF version: -->
  <p:variable name="pdf-filename" select="concat(replace($component-display-name-to-use, '[^A-Za-z0-9\-.]', '_'), '-documentation.pdf')"/>
  <p:variable name="pdf-relative-href" select="string-join(($resources-subdirectory, $pdf-filename), '/')"/>
  <p:variable name="pdf-absolute-href" select="string-join(($full-output-directory, $pdf-relative-href), '/')"/>

  <!-- Remove the output directory first: -->
  <xtlc:remove-dir>
    <p:with-option name="href-dir" select="$output-directory"/>
  </xtlc:remove-dir>

  <!-- We're going to write a temporary new parameters document to the output directory 
    (it is deleted later when the output directory is overwritten): -->
  <p:variable name="href-parameters-merged-temp" select="string-join(($full-output-directory, 'merged-parameters-temp.xml'), '/')"/>
  <local:merge-parameters-and-version-information>
    <p:with-option name="component-name" select="$component-name"/>
    <p:with-option name="component-display-name" select="$component-display-name-to-use"/>
    <p:with-option name="href-parameters" select="$full-href-parameters"/>
    <p:with-option name="href-global-parameters" select="$full-href-global-parameters"/>
    <p:with-option name="href-result" select="$href-parameters-merged-temp"/>
  </local:merge-parameters-and-version-information>

  <!-- Turn the xdoc source into Docbook: -->
  <xdoc:xdoc-to-docbook>
    <p:with-option name="href-parameters" select="$href-parameters-merged-temp"/>
    <p:with-option name="parameter-filters" select="$parameter-filters"/>
  </xdoc:xdoc-to-docbook>
  <p:identity name="docbook-contents"/>

  <!-- Now create the XHTML version: -->
  <xdoc:docbook-to-xhtml>
    <p:with-option name="create-header" select="true()"/>
  </xdoc:docbook-to-xhtml>

  <!-- Create an xtpxlib-container structure for writing the XHTML results:. -->
  <!-- WARNING: This assumes there are no double titles. Normally this won't be the case because all prefaces/chapters/appendices 
    are numbered. But... decisions about naming and numbering might influence that. We'll pas that bridge when we stumble upon it.
  -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/create-basic-container.xsl"/>
    </p:input>
    <p:with-param name="href-target-path" select="$full-output-directory"/>
    <p:with-param name="href-componentdoc-website-template" select="$full-href-template"/>
  </p:xslt>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/fix-internal-links.xsl"/>
    </p:input>
    <p:with-param name="null" select="()"/>
  </p:xslt>

  <!-- Add internal linking between the pages (TOC, etc.): -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/add-additional-links.xsl"/>
    </p:input>
    <p:with-param name="pdf-href" select="$pdf-relative-href"/>
  </p:xslt>

  <!-- Adapt things a little (more bootstrap style): -->
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/adapt-html.xsl"/>
    </p:input>
    <p:with-param name="component-display-name" select="$component-display-name-to-use"/>
  </p:xslt>

  <!-- Insert directory information for the resources and re-work this to the right container external document entries: -->
  <!-- Remark: the global list is inserted before the specific one, so you can override files from it with ones from the specific directory. -->
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="resources-directory-list"/>
    </p:input>
  </p:insert>
  <p:insert match="/*" position="first-child">
    <p:input port="insertion">
      <p:pipe port="result" step="global-resources-directory-list"/>
    </p:input>
  </p:insert>
  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="xsl-xdoc-to-componentdoc-website/rework-resources-directory-list.xsl"/>
    </p:input>
    <p:with-param name="resources-target-directory" select="$full-resources-target-directory"/>
  </p:xslt>

  <!-- Write the result out to disk: -->
  <xtlcon:container-to-disk name="step-container-to-disk">
    <p:with-option name="remove-target" select="false()"/>
  </xtlcon:container-to-disk>
  <p:sink/>

  <!-- Create the PDF version of the documentation also: -->
  <xdoc:docbook-to-pdf>
    <p:input port="source">
      <p:pipe port="result" step="docbook-contents"/>
    </p:input>
    <p:with-option name="dref-pdf" select="$pdf-absolute-href"/>
    <p:with-option name="global-resources-directory" select="$full-global-resources-directory"/>
  </xdoc:docbook-to-pdf>
  <p:sink/>

  <!-- Generate a little report: -->
  <p:identity>
    <p:input port="source">
      <p:inline>
        <xdoc-to-componentdoc-website/>
      </p:inline>
    </p:input>
  </p:identity>
  <p:add-attribute attribute-name="timestamp" match="/*">
    <p:with-option name="attribute-value" select="$start-timestamp"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="duration" match="/*">
    <p:with-option name="attribute-value" select="current-dateTime() - xs:dateTime($start-timestamp)"/>
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
  <xwebdoc:generate-readme>
    <p:with-option name="href-readme" select="$href-readme"/> 
    <p:with-option name="component-name" select="$component-name"/> 
  </xwebdoc:generate-readme>

  <!-- Final cleanup: -->
  <xwebdoc:delete-file>
    <p:with-option name="href" select="$href-parameters-merged-temp"/>
  </xwebdoc:delete-file>

  <!-- Done: -->
  <p:identity name="end-result"/>
  <p:sink/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the specific resources directory: -->

  <p:choose>
    <p:when test="normalize-space($resources-subdirectory) ne ''">
      <xtlc:recursive-directory-list>
        <p:with-option name="path" select="$full-resources-source-directory"/>
        <p:with-option name="flatten" select="true()"/>
      </xtlc:recursive-directory-list>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:inline>
            <c:directory/>
          </p:inline>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  <p:identity name="resources-directory-list"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Subpipeline to get the contents of the global resources directory: -->

  <p:choose>
    <p:when test="normalize-space($global-resources-directory) ne ''">
      <xtlc:recursive-directory-list>
        <p:with-option name="path" select="$full-global-resources-directory"/>
        <p:with-option name="flatten" select="true()"/>
      </xtlc:recursive-directory-list>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:inline>
            <c:directory/>
          </p:inline>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  <p:identity name="global-resources-directory-list"/>

</p:declare-step>
