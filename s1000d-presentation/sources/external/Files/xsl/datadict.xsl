<?xml version="1.0" encoding="utf-8"?>
<!--
Copyright:
	Copyright © 2023 by each of the following organizations:
	1.  Aerospace, Security and Defence Industries Association of Europe - ASD.
	2.  Ministries of Defence of the member countries of ASD.

	Limitations of Liability:

	1.  This material is provided "As Is" and neither ASD nor any person who has contributed to the creation, revision or maintenance of the material makes any representations or warranties, express or implied, including but not limited to, warranties of merchantability or fitness for any particular purpose.
	2.  Neither ASD nor any person who has contributed to the creation, revision or maintenance of this material shall be liable for any direct, indirect, special or consequential damages or any other liability arising from any use of this material.
	3.  Revisions to this document may occur after its issuance.  The user is responsible for determining if revisions to the material contained in this document have occurred and are applicable. 
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:import href="xmlverbatim.xsl"/>
	<xsl:include href="parameter.xsl"/>
	<xsl:output method="html"/>
	<xsl:variable name="masterSchemaPath" select="'../xml_schema_master'"/>
	<xsl:variable name="flatSchemaPath" select="'../xml_schema_flat'"/>
	<xsl:variable name="lomSchemaPath" select="'../lom_schemas'"/>

	<!--all schema base files from masterSchemaPath (except xml and xlink)-->
	<xsl:variable name="attributeGroupsFile"
		select="concat($masterSchemaPath, '/attributeGroups.xsd')"/>
	<xsl:variable name="attributesFile" select="concat($masterSchemaPath, '/attributes.xsd')"/>
	<xsl:variable name="complexElementsFile"
		select="concat($masterSchemaPath, '/complexElements.xsd')"/>
	<xsl:variable name="complexTypesFile" select="concat($masterSchemaPath, '/complexTypes.xsd')"/>
	<xsl:variable name="simpleElementsFile"
		select="concat($masterSchemaPath, '/simpleElements.xsd')"/>
	<xsl:variable name="simpleTypesFile" select="concat($masterSchemaPath, '/simpleTypes.xsd')"/>

	<xsl:variable name="attributeGroups" select="document($attributeGroupsFile, .)"/>
	<xsl:variable name="attributes" select="document($attributesFile, .)"/>
	<xsl:variable name="complexElements" select="document($complexElementsFile, .)"/>
	<xsl:variable name="complexTypes" select="document($complexTypesFile, .)"/>
	<xsl:variable name="simpleElements" select="document($simpleElementsFile, .)"/>
	<xsl:variable name="simpleTypes" select="document($simpleTypesFile, .)"/>

	<xsl:variable name="complexElementsSchemaFile" select="concat($masterSchemaPath,'/complexElements.xsd')"/>
	<xsl:variable name="complexTypesSchemaFile" select="concat($masterSchemaPath,'/complexTypes.xsd')"/>
	<xsl:variable name="simpleElementsSchemaFile" select="concat($masterSchemaPath,'/simpleElements.xsd')"/>
	<xsl:variable name="simpleTypesSchemaFile" select="concat($masterSchemaPath,'/simpleTypes.xsd')"/>
	<xsl:variable name="attributeGroupsSchemaFile" select="concat($masterSchemaPath,'/attributeGroups.xsd')"/>	

	<!--all module schemas from masterSchemaPath (except xml and xlink)-->
	<xsl:variable name="appliccrossreftableSchemaFile"
		select="concat($masterSchemaPath, '/appliccrossreftableSchema.xsd')"/>
	<xsl:variable name="brdocSchemaFile" select="concat($masterSchemaPath, '/brdocSchema.xsd')"/>
	<xsl:variable name="brexSchemaFile" select="concat($masterSchemaPath, '/brexSchema.xsd')"/>
	<xsl:variable name="checklistSchemaFile"
		select="concat($masterSchemaPath, '/checklistSchema.xsd')"/>
	<xsl:variable name="commentSchemaFile" select="concat($masterSchemaPath, '/commentSchema.xsd')"/>
	<xsl:variable name="comrepSchemaFile" select="concat($masterSchemaPath, '/comrepSchema.xsd')"/>
	<xsl:variable name="condcrossreftableSchemaFile"
		select="concat($masterSchemaPath, '/condcrossreftableSchema.xsd')"/>
	<xsl:variable name="containerSchemaFile"
		select="concat($masterSchemaPath, '/containerSchema.xsd')"/>
	<xsl:variable name="crewSchemaFile" select="concat($masterSchemaPath, '/crewSchema.xsd')"/>
	<xsl:variable name="dcFile" select="concat($masterSchemaPath, '/dc.xsd')"/>
	<xsl:variable name="ddnSchemaFile" select="concat($masterSchemaPath, '/ddnSchema.xsd')"/>
	<xsl:variable name="descriptSchemaFile"
		select="concat($masterSchemaPath, '/descriptSchema.xsd')"/>
	<xsl:variable name="dmlSchemaFile" select="concat($masterSchemaPath, '/dmlSchema.xsd')"/>
	<xsl:variable name="faultSchemaFile" select="concat($masterSchemaPath, '/faultSchema.xsd')"/>
	<xsl:variable name="frontmatterSchemaFile"
		select="concat($masterSchemaPath, '/frontmatterSchema.xsd')"/>
	<xsl:variable name="icnmetadataSchemaFile"
		select="concat($masterSchemaPath, '/icnmetadataSchema.xsd')"/>
	<xsl:variable name="ipdSchemaFile" select="concat($masterSchemaPath, '/ipdSchema.xsd')"/>
	<xsl:variable name="learningSchemaFile"
		select="concat($masterSchemaPath, '/learningSchema.xsd')"/>
	<xsl:variable name="notationsFile" select="concat($masterSchemaPath, '/notations.xsd')"/>
	<xsl:variable name="pmSchemaFile" select="concat($masterSchemaPath, '/pmSchema.xsd')"/>
	<xsl:variable name="prdcrossreftableSchemaFile"
		select="concat($masterSchemaPath, '/prdcrossreftableSchema.xsd')"/>
	<xsl:variable name="procedSchemaFile" select="concat($masterSchemaPath, '/procedSchema.xsd')"/>
	<xsl:variable name="processSchemaFile" select="concat($masterSchemaPath, '/processSchema.xsd')"/>
	<xsl:variable name="rdfFile" select="concat($masterSchemaPath, '/rdf.xsd')"/>
	<xsl:variable name="sbSchemaFile" select="concat($masterSchemaPath, '/sbSchema.xsd')"/>
	<xsl:variable name="schedulSchemaFile" select="concat($masterSchemaPath, '/schedulSchema.xsd')"/>
	<xsl:variable name="scocontentSchemaFile"
		select="concat($masterSchemaPath, '/scocontentSchema.xsd')"/>
	<xsl:variable name="scormcontentpackageSchemaFile"
		select="concat($masterSchemaPath, '/scormcontentpackageSchema.xsd')"/>
	<xsl:variable name="updateSchemaFile" select="concat($masterSchemaPath, '/updateSchema.xsd')"/>
	<xsl:variable name="wrngdataSchemaFile"
		select="concat($masterSchemaPath, '/wrngdataSchema.xsd')"/>
	<xsl:variable name="wrngfldsSchemaFile"
		select="concat($masterSchemaPath, '/wrngfldsSchema.xsd')"/>

	<xsl:variable name="appliccrossreftableSchema"
		select="document($appliccrossreftableSchemaFile, .)"/>
	<xsl:variable name="brdocSchema" select="document($brdocSchemaFile, .)"/>
	<xsl:variable name="brexSchema" select="document($brexSchemaFile, .)"/>
	<xsl:variable name="checklistSchema" select="document($checklistSchemaFile, .)"/>
	<xsl:variable name="commentSchema" select="document($commentSchemaFile, .)"/>
	<xsl:variable name="comrepSchema" select="document($comrepSchemaFile, .)"/>
	<xsl:variable name="condcrossreftableSchema" select="document($condcrossreftableSchemaFile, .)"/>
	<xsl:variable name="containerSchema" select="document($containerSchemaFile, .)"/>
	<xsl:variable name="crewSchema" select="document($crewSchemaFile, .)"/>
	<xsl:variable name="dc" select="document($dcFile, .)"/>
	<xsl:variable name="ddnSchema" select="document($ddnSchemaFile, .)"/>
	<xsl:variable name="descriptSchema" select="document($descriptSchemaFile, .)"/>
	<xsl:variable name="dmlSchema" select="document($dmlSchemaFile, .)"/>
	<xsl:variable name="faultSchema" select="document($faultSchemaFile, .)"/>
	<xsl:variable name="frontmatterSchema" select="document($frontmatterSchemaFile, .)"/>
	<xsl:variable name="icnmetadataSchema" select="document($icnmetadataSchemaFile, .)"/>
	<xsl:variable name="ipdSchema" select="document($ipdSchemaFile, .)"/>
	<xsl:variable name="learningSchema" select="document($learningSchemaFile, .)"/>
	<xsl:variable name="notations" select="document($notationsFile, .)"/>
	<xsl:variable name="pmSchema" select="document($pmSchemaFile, .)"/>
	<xsl:variable name="prdcrossreftableSchema" select="document($prdcrossreftableSchemaFile, .)"/>
	<xsl:variable name="procedSchema" select="document($procedSchemaFile, .)"/>
	<xsl:variable name="processSchema" select="document($processSchemaFile, .)"/>
	<xsl:variable name="rdf" select="document($rdfFile, .)"/>
	<xsl:variable name="sbSchema" select="document($sbSchemaFile, .)"/>
	<xsl:variable name="schedulSchema" select="document($schedulSchemaFile, .)"/>
	<xsl:variable name="scocontentSchema" select="document($scocontentSchemaFile, .)"/>
	<xsl:variable name="scormcontentpackageSchema"
		select="document($scormcontentpackageSchemaFile, .)"/>
	<xsl:variable name="updateSchema" select="document($updateSchemaFile, .)"/>
	<xsl:variable name="wrngdataSchema" select="document($wrngdataSchemaFile, .)"/>
	<xsl:variable name="wrngfldsSchema" select="document($wrngfldsSchemaFile, .)"/>

	<!--all flat schemas from flatSchemaPath (except xml and xlink)-->
	<xsl:variable name="appliccrossreftableSchemaFileFlat"
		select="concat($flatSchemaPath, '/appliccrossreftable.xsd')"/>
	<xsl:variable name="brdocSchemaFileFlat" select="concat($flatSchemaPath, '/brdoc.xsd')"/>
	<xsl:variable name="brexSchemaFileFlat" select="concat($flatSchemaPath, '/brex.xsd')"/>
	<xsl:variable name="checklistSchemaFileFlat"
		select="concat($flatSchemaPath, '/checklist.xsd')"/>
	<xsl:variable name="commentSchemaFileFlat" select="concat($flatSchemaPath, '/comment.xsd')"/>
	<xsl:variable name="comrepSchemaFileFlat" select="concat($flatSchemaPath, '/comrep.xsd')"/>
	<xsl:variable name="condcrossreftableSchemaFileFlat"
		select="concat($flatSchemaPath, '/condcrossreftable.xsd')"/>
	<xsl:variable name="containerSchemaFileFlat"
		select="concat($flatSchemaPath, '/container.xsd')"/>
	<xsl:variable name="crewSchemaFileFlat" select="concat($flatSchemaPath, '/crew.xsd')"/>
	<xsl:variable name="ddnSchemaFileFlat" select="concat($flatSchemaPath, '/ddn.xsd')"/>
	<xsl:variable name="descriptSchemaFileFlat"
		select="concat($flatSchemaPath, '/descript.xsd')"/>
	<xsl:variable name="dmlSchemaFileFlat" select="concat($flatSchemaPath, '/dml.xsd')"/>
	<xsl:variable name="faultSchemaFileFlat" select="concat($flatSchemaPath, '/fault.xsd')"/>
	<xsl:variable name="frontmatterSchemaFileFlat"
		select="concat($flatSchemaPath, '/frontmatter.xsd')"/>
	<xsl:variable name="icnmetadataSchemaFileFlat"
		select="concat($flatSchemaPath, '/icnmetadata.xsd')"/>
	<xsl:variable name="ipdSchemaFileFlat" select="concat($flatSchemaPath, '/ipd.xsd')"/>
	<xsl:variable name="learningSchemaFileFlat"
		select="concat($flatSchemaPath, '/learning.xsd')"/>
	<xsl:variable name="pmSchemaFileFlat" select="concat($flatSchemaPath, '/pm.xsd')"/>
	<xsl:variable name="prdcrossreftableSchemaFileFlat"
		select="concat($flatSchemaPath, '/prdcrossreftable.xsd')"/>
	<xsl:variable name="procedSchemaFileFlat" select="concat($flatSchemaPath, '/proced.xsd')"/>
	<xsl:variable name="processSchemaFileFlat" select="concat($flatSchemaPath, '/process.xsd')"/>
	<xsl:variable name="sbSchemaFileFlat" select="concat($flatSchemaPath, '/sb.xsd')"/>
	<xsl:variable name="schedulSchemaFileFlat" select="concat($flatSchemaPath, '/schedul.xsd')"/>
	<xsl:variable name="scocontentSchemaFileFlat"
		select="concat($flatSchemaPath, '/scocontent.xsd')"/>
	<xsl:variable name="scormcontentpackageSchemaFileFlat"
		select="concat($flatSchemaPath, '/scormcontentpackage.xsd')"/>
	<xsl:variable name="updateSchemaFileFlat" select="concat($flatSchemaPath, '/update.xsd')"/>
	<xsl:variable name="wrngdataSchemaFileFlat"
		select="concat($flatSchemaPath, '/wrngdata.xsd')"/>
	<xsl:variable name="wrngfldsSchemaFileFlat"
		select="concat($flatSchemaPath, '/wrngflds.xsd')"/>
	
	<xsl:variable name="appliccrossreftableSchemaFlat"
		select="document($appliccrossreftableSchemaFileFlat, .)"/>
	<xsl:variable name="brdocSchemaFlat" select="document($brdocSchemaFileFlat, .)"/>
	<xsl:variable name="brexSchemaFlat" select="document($brexSchemaFileFlat, .)"/>
	<xsl:variable name="checklistSchemaFlat" select="document($checklistSchemaFileFlat, .)"/>
	<xsl:variable name="commentSchemaFlat" select="document($commentSchemaFileFlat, .)"/>
	<xsl:variable name="comrepSchemaFlat" select="document($comrepSchemaFileFlat, .)"/>
	<xsl:variable name="condcrossreftableSchemaFlat" select="document($condcrossreftableSchemaFileFlat, .)"/>
	<xsl:variable name="containerSchemaFlat" select="document($containerSchemaFileFlat, .)"/>
	<xsl:variable name="crewSchemaFlat" select="document($crewSchemaFileFlat, .)"/>
	<xsl:variable name="ddnSchemaFlat" select="document($ddnSchemaFileFlat, .)"/>
	<xsl:variable name="descriptSchemaFlat" select="document($descriptSchemaFileFlat, .)"/>
	<xsl:variable name="dmlSchemaFlat" select="document($dmlSchemaFileFlat, .)"/>
	<xsl:variable name="faultSchemaFlat" select="document($faultSchemaFileFlat, .)"/>
	<xsl:variable name="frontmatterSchemaFlat" select="document($frontmatterSchemaFileFlat, .)"/>
	<xsl:variable name="icnmetadataSchemaFlat" select="document($icnmetadataSchemaFileFlat, .)"/>
	<xsl:variable name="ipdSchemaFlat" select="document($ipdSchemaFileFlat, .)"/>
	<xsl:variable name="learningSchemaFlat" select="document($learningSchemaFileFlat, .)"/>
	<xsl:variable name="pmSchemaFlat" select="document($pmSchemaFileFlat, .)"/>
	<xsl:variable name="prdcrossreftableSchemaFlat" select="document($prdcrossreftableSchemaFileFlat, .)"/>
	<xsl:variable name="procedSchemaFlat" select="document($procedSchemaFileFlat, .)"/>
	<xsl:variable name="processSchemaFlat" select="document($processSchemaFileFlat, .)"/>
	<xsl:variable name="sbSchemaFlat" select="document($sbSchemaFileFlat, .)"/>
	<xsl:variable name="schedulSchemaFlat" select="document($schedulSchemaFileFlat, .)"/>
	<xsl:variable name="scocontentSchemaFlat" select="document($scocontentSchemaFileFlat, .)"/>
	<xsl:variable name="scormcontentpackageSchemaFlat"
		select="document($scormcontentpackageSchemaFileFlat, .)"/>
	<xsl:variable name="updateSchemaFlat" select="document($updateSchemaFileFlat, .)"/>
	<xsl:variable name="wrngdataSchemaFlat" select="document($wrngdataSchemaFileFlat, .)"/>
	<xsl:variable name="wrngfldsSchemaFlat" select="document($wrngfldsSchemaFileFlat, .)"/>
	
	<!--all files from elements and definitions (except placeholder)-->
	<xsl:variable name="elementList" select="document('../elements/elementList.xml', .)"/>
	<xsl:variable name="attributeList" select="document('../attributes/attributeList.xml', .)"/>
	<xsl:variable name="elementsDefinition"
		select="document('../definitions/elementsDefinition.xml', .)"/>
	<xsl:variable name="attributesDefinition"
		select="document('../definitions/attributesDefinition.xml', .)"/>
	<xsl:variable name="schemasDefinition"
		select="document('../definitions/schemasDefinition.xml', .)"/>

	<xsl:variable name="elementName" select="/dataDictionary/element/@name"/>
	<xsl:variable name="attributeName" select="/dataDictionary/attribute/@name"/>
	<xsl:include href="xsd_graphic_generator.xsl"/>
	<xsl:include href="xsd_graphic_flat_generator.xsl"/>

	<xsl:template match="dataDictionary">
		<html lang="en">
			<link rel="STYLESHEET" type="text/css" href="../css/styles.css"/>
			<link rel="STYLESHEET" type="text/css" href="../css/xmlverbatim.css"/>
			<link rel="STYLESHEET" type="text/css" href="../xml_schema_viewer/xsd_graphic.css"/>

			<script language="javascript" src="../js/functions.js"/>
			<script language="javascript" src="../xml_schema_viewer/functions.js"/>
			<head>
				<meta charset="UTF-8"/>
				<title>
					<xsl:text>S1000D - Data Dictionary</xsl:text>
				</title>
			</head>
			<body onload="javascript:init('{$elementName}');">
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="element">
		<xsl:variable name="elementName" select="@name"/>
		<xsl:variable name="elementType" select="@type"/>

		<xsl:for-each select="$elementList//element[@name = $elementName]">
			<xsl:variable name="anchor" select="@name"/>
			<xsl:variable name="blockId" select="concat('elem_', @name)"/>
			<p>
				<p>
					<i>
						<a href="javascript:returnToList('elem');">
							<img src="../img/bluearrow_right.png" border="0"/>
							<xsl:text>&#160; Return to Element List</xsl:text>
						</a>
						<!--<xsl:value-of select="@name"/>-->
					</i>
				</p>
				<div>
					<table border="0"
						width="100%" cellpadding="2" cellspacing="1">
						<colgroup>
							<col width="20%"/>
							<col width="80%"/>
						</colgroup>
						<xsl:call-template name="elementDefinitionInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>

						<tr>
							<td class="label">
								<xsl:text>Element Located in Schema</xsl:text>
							</td>
							<td>
								<xsl:call-template name="schemaLocation">
									<xsl:with-param name="elemName" select="@name" />
								</xsl:call-template>
							</td>
						</tr>
						<tr>
							<td class="label">
								<xsl:text>Element Definition</xsl:text>
							</td>
							<td>
								<div>
									<xsl:text>&lt;xs:element </xsl:text>
									<xsl:text>name="</xsl:text>
									<xsl:value-of select="@name"/>
									<xsl:text>" type="</xsl:text>
									<xsl:value-of select="@type"/>
									<xsl:text>"/&gt;</xsl:text>
								</div>
							</td>
						</tr>
						<xsl:call-template name="checkConstraintUnique">
							<xsl:with-param name="elemName" select="@name" />
						</xsl:call-template>
						<tr>
							<td class="label">
								<xsl:text>Element Type</xsl:text>
							</td>
							<td>
								<xsl:variable name="typeBlockId" select="concat('type_', @name)"/>
								<xsl:choose>
									<xsl:when test="contains(@type, 'xs:')">
										<xsl:value-of select="@type"/>
									</xsl:when>
									<xsl:otherwise>
										<a href="javascript:showHideBlock('{$typeBlockId}');">
											<xsl:value-of select="@type"/>
										</a>
										<div id="{$typeBlockId}" class="elementType" style="display:none;">
											<xsl:call-template name="xsdSourceDefinitionInclude">
												<xsl:with-param name="type" select="@type"/>
											</xsl:call-template>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<tr>
							<td class="label">
								<xsl:text>Element Type Redefined in Schema</xsl:text>
							</td>
							<td>
								<xsl:call-template name="xsdSourceRedefinitionInclude">
									<xsl:with-param name="type" select="@type"/>
								</xsl:call-template>
							</td>
						</tr>
						<!--display the definition-->
						<xsl:call-template name="xsdDefinitionInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
						<!--display BREX rules-->
						<xsl:call-template name="BREXrulesInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
						<!--display SPEC sample -->
						<xsl:call-template name="sampleInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
					</table>
					<br/>
					<br/>
					<hr/>
				</div>
			</p>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute">
		<xsl:variable name="attributeName" select="@name"/>

		<xsl:for-each select="$attributeList//attribute[@name = $attributeName]">
			<xsl:variable name="anchor" select="@name"/>
			<xsl:variable name="blockId" select="concat('att_', @name)"/>
			<p>
				<p>

					<i>
						<a href="javascript:returnToList('att');">
							<img src="../img/bluearrow_right.png" border="0"/>
							<xsl:text>&#160; Return to Attribute List</xsl:text>
						</a>
					</i>
				</p>
				<xsl:variable name="sourceBlockId" select="concat('source_', @name)"/>
				<i>
					<div id="{$sourceBlockId}" style="display:none;margin-left:10px;">
						<xsl:text>&lt;xs:attribute </xsl:text>
						<xsl:text>name="</xsl:text>
						<xsl:value-of select="@name"/>
						<xsl:text>" type="</xsl:text>
						<xsl:value-of select="@type"/>
						<xsl:text>"</xsl:text>
						<xsl:if test="@default">
							<xsl:text> default="</xsl:text>
							<xsl:value-of select="@default"/>
							<xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>/&gt;</xsl:text>
					</div>
				</i>
				<div>
					<table border="0" class="details"
						width="100%" cellpadding="2" cellspacing="1">
						<colgroup>
							<col width="20%"/>
							<col width="80%"/>
						</colgroup>
						<xsl:call-template name="attributeDefinitionInclude">
							<xsl:with-param name="name" select="@name"/>
						</xsl:call-template>
						<tr>
							<td class="label">
								<xsl:text>Type</xsl:text>
							</td>
							<td>
								<xsl:variable name="typeBlockId"
									select="concat('type_', @name)"/>
								<xsl:choose>
									<xsl:when test="contains(@type, 'xs:')">
										<xsl:value-of select="@type"/>
									</xsl:when>
									<xsl:otherwise>
										<a
										href="javascript:showHideBlock('{$typeBlockId}');">
										<xsl:value-of select="@type"/>
										</a>
										<div id="{$typeBlockId}"
										style="display:none;font-family:Courier New;margin-left:10px;">
										<xsl:call-template
										name="xsdSourceDefinitionInclude">
										<xsl:with-param name="type" select="@type"/>
										</xsl:call-template>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<xsl:if test="@default">
							<tr>
								<td class="label">
									<xsl:text>Default value</xsl:text>
								</td>
								<td>
									<xsl:value-of select="@default"/>
								</td>
							</tr>
						</xsl:if>
						<!--display the definition-->
						<xsl:call-template name="xsdAttributeDefinitionInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
						<!--display BREX rules-->
						<xsl:call-template name="BREXattributeRulesInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
						<!--display SPEC sample -->
						<xsl:call-template name="sampleInclude">
							<xsl:with-param name="name" select="@name"/>
							<xsl:with-param name="type" select="@type"/>
						</xsl:call-template>
					</table>
					<br/>
					<br/>
					<hr/>
				</div>
			</p>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="elementDefinitionInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>

		<xsl:for-each select="$elementsDefinition//element[name = $name]">				
			<tr>
				<td class="label">
					<xsl:text>Element Details</xsl:text>
				</td>
				<td class="label">
					<span class="elementName"><xsl:value-of select="$name"/></span>
					<xsl:if test="@relatedCPFs!='' and $DEBUG='true'">
						<span class="relatedCPFs"><xsl:value-of select="@relatedCPFs"/></span>
					</xsl:if>
				</td>
			</tr>
			<tr>
				<td class="label">Graphic View</td>
				<td>
					<table width="100%">
						<tr>
							<td>
								<i>
									<xsl:text>Levels: </xsl:text>
									<input type="button" id="levelminus" value=" - "
										onClick="changeLevel(-1)"/>
									<xsl:text>&#160;</xsl:text>
									<i id="graphicLevel"/>
									<xsl:text>&#160;</xsl:text>
									<input type="button" id="levelplus" value=" + "
										onClick="changeLevel(1)"/>
									<xsl:text>&#160; (</xsl:text>
									<a href="javascript:displayXSDGraphic('{$name}',null);">
										<xsl:text>Master Graphic</xsl:text>
									</a>
									<xsl:text>)</xsl:text>
								</i>
							</td>
							<td align="right">
								<i id="graphicContext" style="text-align: right;"/>
							</td>
						</tr>
					</table>
					<br/>
					<i id="graphicRedefinition">
						<xsl:call-template name="graphicRedefinition">
							<xsl:with-param name="name" select="$name"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:call-template>
					</i>
					<br/>
					<div id="XSDGraphic">
						<xsl:call-template name="generateMasterDiagram">
							<xsl:with-param name="startElement" select="$elementName"/>
						</xsl:call-template>
						<xsl:call-template name="generateRedefinitionDiagram">
							<xsl:with-param name="name" select="$elementName"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:call-template>
					</div>
				</td>
			</tr>

			<tr>
				<td class="label">
					<xsl:text>Title</xsl:text>
				</td>
				<td>
					<xsl:value-of select="title"/>
				</td>
			</tr>
			<tr>
				<td class="label">
					<xsl:text>Definition</xsl:text>
				</td>
				<td>
					<xsl:apply-templates select="definition"/>
				</td>
			</tr>
			<tr>
				<td class="label">
					<xsl:text>Spec Location</xsl:text>
				</td>
				<td>
					<xsl:text>Chapter: </xsl:text>
					<xsl:value-of select="chapter"/>
					<xsl:if test="para != ''">
						<xsl:text> (Para: </xsl:text>
						<xsl:value-of select="para"/>
						<xsl:text>)</xsl:text>
					</xsl:if>
				</td>
			</tr>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="definition">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="br">
		<br/>
	</xsl:template>

	<xsl:template match="dot">
		<xsl:text>&#x2022;</xsl:text>
	</xsl:template>

	<xsl:template match="linkelement">
		<xsl:param name="blockId" select="."/>
		<a href="../elements/{$blockId}.xml">
			<xsl:value-of select="."/>
		</a>
	</xsl:template>

	<xsl:template name="attributeDefinitionInclude">
		<xsl:param name="name"/>

		<xsl:for-each select="document('../definitions/attributesDefinition.xml', .)">
			<xsl:for-each select="//attribute">
				<xsl:if test="name = $name">
					<tr>
						<td class="label">Attribute Details</td>
						<td class="label">
							<span class="elementName"><xsl:value-of select="$name"/></span>
							<xsl:if test="@relatedCPFs!='' and $DEBUG='true'">
								<span class="relatedCPFs"><xsl:value-of select="@relatedCPFs"/></span>
							</xsl:if>
						</td>
					</tr>
					<tr>
						<td class="label">
							<xsl:text>Name</xsl:text>
						</td>
						<td>
							<xsl:value-of select="name"/>
						</td>
					</tr>
					<tr>
						<td class="label">
							<xsl:text>Definition</xsl:text>
						</td>
						<td>
							<xsl:apply-templates select="definition"/>
						</td>
					</tr>
					<tr>
						<td class="label">
							<xsl:text>Spec Location</xsl:text>
						</td>
						<td>
							<xsl:variable name="specLink">
								<xsl:value-of
									select="substring-before(substring-after(DMC, '-'), '_')"/>
							</xsl:variable>

							<!--<a href="../../../spec/pdf/{$specLink}.pdf" target="content">-->
							<xsl:text>Chapter: </xsl:text>
							<xsl:value-of select="chapter"/>
							<!--</a>-->
							<xsl:text> (Para: </xsl:text>
							<xsl:value-of select="para"/>
							<xsl:text>)</xsl:text>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdDefinitionInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>

		<xsl:for-each select="document('../xml_schema_master/complexTypes.xsd', .)">
			<!--<xsl:for-each select="//xs:complexType">
				<xsl:if test="@name = $type">
					<tr>
					<td class="label"><xsl:text>Content</xsl:text></td>
					<td><xsl:text>Complex</xsl:text></td>
					</tr>
				</xsl:if>
			</xsl:for-each>-->
			<tr>
				<td class="label">
					<xsl:text>Parent</xsl:text>
				</td>
				<td>
					<xsl:for-each select="//xs:element/@ref | //xs:attribute/@ref">
						<xsl:if test=". = $name">
							<xsl:choose>
								<xsl:when test="ancestor::xs:complexType">
									<xsl:variable name="complexTypeName"
										select="ancestor::xs:complexType/@name"/>
									<xsl:choose>
										<xsl:when
											test="contains($complexTypeName, 'GenericElemType')">
											<xsl:call-template name="xsdGenericTypeParser">
												<xsl:with-param name="complexTypeName"
												select="$complexTypeName"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:variable name="blockId">
												<xsl:value-of
												select="substring-before($complexTypeName, 'ElemType')"
												/>
											</xsl:variable>
											<a href="../elements/{$blockId}.xml">
												<xsl:value-of select="$blockId"/>
											</a>
											<xsl:text>, </xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="ancestor::xs:group">
									<xsl:call-template name="xsdGroupResolver">
										<xsl:with-param name="groupName"
											select="ancestor::xs:group/@name"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="xsdGroupResolver">
										<xsl:with-param name="groupName"
											select="ancestor::xs:attributeGroup/@name"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			<xsl:for-each select="//xs:complexType">
				<xsl:if test="@name = $type">
					<tr>
						<td class="label">
							<xsl:text>Children</xsl:text>
						</td>
						<td>

							<xsl:for-each select=".//xs:element">
								<xsl:choose>
									<xsl:when test="contains(@ref, ':')">
										<xsl:if
											test="./@ref[not(preceding-sibling::*/@ref = ./@ref)]">
											<xsl:value-of select="@ref"/>
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if
											test="./@ref[not(preceding-sibling::*/@ref = ./@ref)]">
											<xsl:variable name="blockId" select="@ref"/>
											<a href="../elements/{$blockId}.xml">
												<xsl:value-of select="@ref"/>
											</a>
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							<xsl:for-each select=".//xs:group">
								<xsl:call-template name="xsdGroupDefinition">
									<xsl:with-param name="groupName" select="@ref"/>
								</xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="//xs:complexType">
				<xsl:if test="@name = $type">
					<tr>
						<td class="label" valign="top">
							<br/>
							<xsl:text>Attribute</xsl:text>
						</td>
						<td>
							<br/>
							<xsl:if test=".//xs:attribute | .//xs:attributeGroup">
								<table border="1" class="details">
									<tr>
										<th>Attribute Name</th>
										<th>Use</th>
										<th>Attribute Definition</th>
									</tr>
									<xsl:for-each select=".//xs:attribute">
										<xsl:variable name="attV" select="@ref"/>
										<tr>
											<td>
												<a href="../attributes/{$attV}.xml">
												<xsl:value-of select="@ref"/>
												</a>
												<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
											</td>
											<td>
												<xsl:choose>
												<xsl:when test="@use = 'required'">
												<xsl:text>required</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:text>optional</xsl:text>
												</xsl:otherwise>
												</xsl:choose>
											</td>
											<td>
												<xsl:for-each
												select="document('../definitions/attributesDefinition.xml', .)">
												<xsl:for-each select="//attribute">
												<xsl:if test="name = $attV">
												<xsl:apply-templates select="definition"/>
												</xsl:if>
												</xsl:for-each>
												</xsl:for-each>
												<xsl:text>&#160;</xsl:text>
											</td>
										</tr>
									</xsl:for-each>
									<xsl:for-each select=".//xs:attributeGroup">
										<xsl:call-template name="xsdAttGroupDefinition">
											<xsl:with-param name="groupName" select="@ref"/>
										</xsl:call-template>
									</xsl:for-each>
								</table>
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdGenericTypeParser">
		<xsl:param name="complexTypeName"/>
		<xsl:for-each select="document('../xml_schema_master/complexElements.xsd', .)">
			<xsl:for-each select="//xs:element">
				<xsl:if test="@type = $complexTypeName">
					<a href="../elements/{@name}.xml">
						<xsl:value-of select="@name"/>
					</a>
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdAttributeDefinitionInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>

		<tr>
			<td class="label">
				<xsl:text>Parent</xsl:text>
			</td>
			<td>
				<xsl:for-each select="$complexTypes//xs:attribute[@ref=$name]">						
					<xsl:choose>
						<xsl:when test="ancestor::xs:complexType">
							<xsl:variable name="complexTypeName"
								select="ancestor::xs:complexType/@name"/>
							<xsl:choose>
								<xsl:when
									test="contains($complexTypeName, 'GenericElemType')">
									<xsl:call-template name="xsdGenericTypeParser">
										<xsl:with-param name="complexTypeName"
										select="$complexTypeName"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="blockId">
										<xsl:value-of
										select="substring-before($complexTypeName, 'ElemType')"
										/>
									</xsl:variable>
									<a href="../elements/{$blockId}.xml">
										<xsl:value-of select="$blockId"/>
									</a>
									<xsl:text>, </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="ancestor::xs:group">
							<xsl:call-template name="xsdGroupResolver">
								<xsl:with-param name="groupName"
									select="ancestor::xs:group/@name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="xsdGroupResolver">
								<xsl:with-param name="groupName"
									select="ancestor::xs:attributeGroup/@name"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:for-each select="$attributeGroups//xs:attribute[@ref=$name]">
					<xsl:variable name="attributeGroupName" select="ancestor::xs:attributeGroup/@name"/>
					<xsl:call-template name="xsdGroupResolver">
						<xsl:with-param name="groupName" select="$attributeGroupName"/>
					</xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="xsdSourceDefinitionInclude">
		<xsl:param name="type"/>

		<xsl:for-each select="$complexTypes//xs:complexType[@name = $type]">
			<div class="xmlverb-default">
				<xsl:apply-templates select="." mode="xmlverb">
					<xsl:with-param name="indent-elements" select="true()"/>
				</xsl:apply-templates>
			</div>
		</xsl:for-each>

		<xsl:for-each select="$simpleTypes//xs:simpleType[@name = $type]">
			<div class="xmlverb-default">
				<xsl:apply-templates select="." mode="xmlverb">
					<xsl:with-param name="indent-elements" select="true()"/>
				</xsl:apply-templates>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdSourceRedefinitionInclude">
		<xsl:param name="type"/>
		<xsl:for-each select="$appliccrossreftableSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">appliccrossreftable</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$brexSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">brex</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$checklistSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">checklist</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$commentSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">comment</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$comrepSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">comrep</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$condcrossreftableSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">condcrossreftable</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$containerSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">container</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$crewSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">crew</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$ddnSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">ddn</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$descriptSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">descript</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$dmlSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">dml</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$faultSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">fault</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$frontmatterSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">frontmatter</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$ipdSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">ipd</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$learningSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">learning</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$pmSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">pm</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$prdcrossreftableSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">prdcrossreftable</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$procedSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">proced</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$processSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">process</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$sbSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">sb</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$schedulSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">schedul</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$scocontentSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">scocontent</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$scormcontentpackageSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">scormcontentpackage</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$updateSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">update</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$wrngdataSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">wrngdata</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$wrngfldsSchema//xs:complexType[@name = $type]">
			<xsl:call-template name="xsdSourceRedefinitionSpecific">
				<xsl:with-param name="schemaName">wrngflds</xsl:with-param>
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="xsdSourceRedefinitionSpecific">
		<xsl:param name="schemaName" />
		<xsl:param name="type"></xsl:param>
		<xsl:variable name="typeBlockId" select="concat($schemaName,'_refdeftype_', $type)"/>
		<a href="javascript:showHideBlock('{$typeBlockId}');">
			<xsl:value-of select="concat($schemaName,', ')" />
		</a>		
		<div id="{$typeBlockId}" class="elementType"  style="display:none;">
				<xsl:apply-templates select="." mode="xmlverb">
					<xsl:with-param name="indent-elements" select="true()"/>
					<xsl:with-param name="show-comments" select="true()" />
				</xsl:apply-templates>
			<br/>
			<br/>
		</div>
	</xsl:template>

	
	<xsl:template name="graphicRedefinition">
		<xsl:param name="name"/>
		<xsl:param name="type"/>
			<xsl:for-each select="$appliccrossreftableSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a
						href="javascript:displayXSDGraphicFlat('{$name}', 'appliccrossreftable.xsd');">
						<xsl:text>appliccrossreftable, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$brexSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'brex.xsd');">
						<xsl:text>brex, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$checklistSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'checklist.xsd');">
						<xsl:text>checklist, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$commentSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'comment.xsd');">
						<xsl:text>comment, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$comrepSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'comrep.xsd');">
						<xsl:text>comrep, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$condcrossreftableSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'condcrossreftable.xsd');">
						<xsl:text>condcrossreftable, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$containerSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'container.xsd');">
						<xsl:text>container, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$crewSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'crew.xsd');">
						<xsl:text>crew, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$ddnSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'ddn.xsd');">
						<xsl:text>ddn, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$descriptSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'descript.xsd');">
						<xsl:text>descript, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$dmlSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'dml.xsd');">
						<xsl:text>dml, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$frontmatterSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'frontmatter.xsd');">
						<xsl:text>frontmatter, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$faultSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'fault.xsd');">
						<xsl:text>fault, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$ipdSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'ipd.xsd');">
						<xsl:text>ipd, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$learningSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'learning.xsd');">
						<xsl:text>learning, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$pmSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'pm.xsd');">
						<xsl:text>pm, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$prdcrossreftableSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'prdcrossreftable.xsd');">
						<xsl:text>prdcrossreftable, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$procedSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'proced.xsd');">
						<xsl:text>proced, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$processSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'process.xsd');">
						<xsl:text>process, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$sbSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'sb.xsd');">
						<xsl:text>sb, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$schedulSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'schedul.xsd');">
						<xsl:text>schedul, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$scocontentSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'scocontent.xsd');">
						<xsl:text>scocontent, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$scormcontentpackageSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a
						href="javascript:displayXSDGraphicFlat('{$name}', 'scormcontentpackage.xsd');">
						<xsl:text>scormcontentpackage, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$updateSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'update.xsd');">
						<xsl:text>update, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$wrngdataSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'wrngdata.xsd');">
						<xsl:text>wrngdata, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>		
			<xsl:for-each select="$wrngfldsSchema//xs:complexType">
				<xsl:if test="@name = $type">
					<a href="javascript:displayXSDGraphicFlat('{$name}', 'wrngflds.xsd');">
						<xsl:text>wrngflds, </xsl:text>
					</a>
				</xsl:if>
			</xsl:for-each>
	</xsl:template>

	
	<xsl:template name="generateRedefinitionDiagram">
		<xsl:param name="name"/>
		<xsl:param name="type"/>
		
		<xsl:for-each select="$appliccrossreftableSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$appliccrossreftableSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'appliccrossreftable'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$brexSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$brexSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'brex'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$checklistSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$checklistSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'checklist'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$commentSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$commentSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'comment'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$comrepSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$comrepSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'comrep'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$condcrossreftableSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$condcrossreftableSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'condcrossreftable'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$containerSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$containerSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'container'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$crewSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$crewSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'crew'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$ddnSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$ddnSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'ddn'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$descriptSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$descriptSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'descript'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$dmlSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$dmlSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'dml'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$frontmatterSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$frontmatterSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'frontmatter'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$faultSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$faultSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'fault'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$ipdSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$ipdSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'ipd'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$learningSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$learningSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'learning'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$pmSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$pmSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'pm'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$prdcrossreftableSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$prdcrossreftableSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'prdcrossreftable'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$procedSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$procedSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'proced'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$processSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$processSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'process'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$sbSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$sbSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'sb'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$schedulSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$schedulSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'schedul'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$scocontentSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$scocontentSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'scocontent'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$scormcontentpackageSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$scormcontentpackageSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'scormcontentpackage'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$updateSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$updateSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'update'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$wrngdataSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$wrngdataSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'wrngdata'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$wrngfldsSchema//xs:complexType">
			<xsl:if test="@name = $type">
				<xsl:call-template name="generateFlatDiagramDiv">
					<xsl:with-param name="flatSchema" select="$wrngfldsSchemaFlat"/>
					<xsl:with-param name="flatSchemaName" select="'wrngflds'"/>
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template name="xsdGroupDefinition">
		<xsl:param name="groupName"/>
		<xsl:for-each select="document('../xml_schema_master/complexTypes.xsd', .)">
			<xsl:for-each select="//xs:group">
				<xsl:if test="@name = $groupName">
					<xsl:for-each select=".//xs:element">
						<xsl:variable name="blockId" select="@ref"/>
						<a href="../elements/{$blockId}.xml">
							<xsl:value-of select="@ref"/>
						</a>
						<xsl:text>, </xsl:text>
					</xsl:for-each>
					<xsl:for-each select=".//xs:group">
						<xsl:call-template name="xsdGroupDefinition">
							<xsl:with-param name="groupName" select="@ref"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdGroupResolver">
		<xsl:param name="groupName"/>
		<xsl:for-each select="document('../xml_schema_master/complexTypes.xsd', .)">
			<xsl:for-each select="//xs:group/@ref | //xs:attributeGroup/@ref">
				<xsl:if test=". = $groupName">
					<xsl:choose>
						<xsl:when test="ancestor::xs:complexType">
							<xsl:variable name="blockId"
								select="substring(ancestor::xs:complexType/@name, 0, string-length(ancestor::xs:complexType/@name) - 7)"/>
							<a href="../elements/{$blockId}.xml">
								<xsl:value-of
									select="substring(ancestor::xs:complexType/@name, 0, string-length(ancestor::xs:complexType/@name) - 7)"
								/>
							</a>
							<xsl:text>, </xsl:text>
						</xsl:when>
						<xsl:when test="ancestor::xs:group">
							<xsl:call-template name="xsdGroupResolver">
								<xsl:with-param name="groupName" select="ancestor::xs:group/@name"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="ancestor::xs:attributeGroup">
							<xsl:call-template name="xsdGroupResolver">
								<xsl:with-param name="groupName"
									select="ancestor::xs:attributeGroup/@name"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="xsdAttGroupDefinition">
		<xsl:param name="groupName"/>

		<xsl:for-each select="document('../xml_schema_master/attributeGroups.xsd', .)">
			<xsl:for-each select="//xs:attributeGroup">
				<xsl:if test="@name = $groupName">
					<xsl:for-each select="xs:attribute">
						<xsl:variable name="attV" select="@ref"/>
						<tr>
							<td>
								<a href="../attributes/{$attV}.xml">
									<xsl:value-of select="@ref"/>
								</a>
								<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
							</td>
							<td>
								<xsl:choose>
									<xsl:when test="@use = 'required'">
										<xsl:text>required</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>optional </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:for-each
									select="document('../definitions/attributesDefinition.xml', .)">
									<xsl:for-each select="//attribute">
										<xsl:if test="name = $attV">
											<xsl:apply-templates select="definition"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:for-each>
								<xsl:text>&#160;</xsl:text>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="xs:attributeGroup">
						<xsl:call-template name="xsdAttGroupDefinition">
							<xsl:with-param name="groupName" select="@ref"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="schemaLocationMaster">
		<xsl:param name="elemName"/>
		<xsl:param name="inSchema">
			<xsl:if test="$appliccrossreftableSchema//xs:element[@name = $elemName]">
				<xsl:text>appliccrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$brexSchema//xs:element[@name = $elemName]">
				<xsl:text>brex, </xsl:text>
			</xsl:if>
			<xsl:if test="$checklistSchema//xs:element[@name = $elemName]">
				<xsl:text>checklist, </xsl:text>
			</xsl:if>
			<xsl:if test="$commentSchema//xs:element[@name = $elemName]">
				<xsl:text>comment, </xsl:text>
			</xsl:if>
			<xsl:if test="$comrepSchema//xs:element[@name = $elemName]">
				<xsl:text>comrep, </xsl:text>
			</xsl:if>
			<xsl:if test="$condcrossreftableSchema//xs:element[@name = $elemName]">
				<xsl:text>condcrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$containerSchema//xs:element[@name = $elemName]">
				<xsl:text>container, </xsl:text>
			</xsl:if>
			<xsl:if test="$crewSchema//xs:element[@name = $elemName]">
				<xsl:text>crew, </xsl:text>
			</xsl:if>
			<xsl:if test="$ddnSchema//xs:element[@name = $elemName]">
				<xsl:text>ddn, </xsl:text>
			</xsl:if>
			<xsl:if test="$descriptSchema//xs:element[@name = $elemName]">
				<xsl:text>descript, </xsl:text>
			</xsl:if>
			<xsl:if test="$dmlSchema//xs:element[@name = $elemName]">
				<xsl:text>dml, </xsl:text>
			</xsl:if>
			<xsl:if test="$faultSchema//xs:element[@name = $elemName]">
				<xsl:text>fault, </xsl:text>
			</xsl:if>
			<xsl:if test="$frontmatterSchema//xs:element[@name = $elemName]">
				<xsl:text>frontmatter, </xsl:text>
			</xsl:if>
			<xsl:if test="$ipdSchema//xs:element[@name = $elemName]">
				<xsl:text>ipd, </xsl:text>
			</xsl:if>
			<xsl:if test="$learningSchema//xs:element[@name = $elemName]">
				<xsl:text>learning, </xsl:text>
			</xsl:if>
			<xsl:if test="$pmSchema//xs:element[@name = $elemName]">
				<xsl:text>pm, </xsl:text>
			</xsl:if>
			<xsl:if test="$prdcrossreftableSchema//xs:element[@name = $elemName]">
				<xsl:text>prdcrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$procedSchema//xs:element[@name = $elemName]">
				<xsl:text>proced, </xsl:text>
			</xsl:if>
			<xsl:if test="$processSchema//xs:element[@name = $elemName]">
				<xsl:text>process, </xsl:text>
			</xsl:if>
			<xsl:if test="$sbSchema//xs:element[@name = $elemName]">
				<xsl:text>sb, </xsl:text>
			</xsl:if>
			<xsl:if test="$schedulSchema//xs:element[@name = $elemName]">
				<xsl:text>schedul, </xsl:text>
			</xsl:if>
			<xsl:if test="$scocontentSchema//xs:element[@name = $elemName]">
				<xsl:text>scocontent, </xsl:text>
			</xsl:if>
			<xsl:if test="$scormcontentpackageSchema//xs:element[@name = $elemName]">
				<xsl:text>scormcontentpackage, </xsl:text>
			</xsl:if>
			<xsl:if test="$updateSchema//xs:element[@name = $elemName]">
				<xsl:text>update, </xsl:text>
			</xsl:if>
			<xsl:if test="$wrngdataSchema//xs:element[@name = $elemName]">
				<xsl:text>wrngdata, </xsl:text>
			</xsl:if>
			<xsl:if test="$wrngfldsSchema//xs:element[@name = $elemName]">
				<xsl:text>wrngflds, </xsl:text>
			</xsl:if>
			<xsl:text>END</xsl:text>
		</xsl:param>
		<!--final comma removed-->
		<xsl:value-of select="substring-before($inSchema, ', END')"/>
		<!--<xsl:for-each select="document('../xml_schema_flat/xcf.xsd',.)">
			<xsl:for-each select="//xs:element">
				<xsl:if test="@name = $elemName">
					<xsl:text>xcf, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>-->
	</xsl:template>
	
	<xsl:template name="schemaLocation">
		<xsl:param name="elemName"/>
		<xsl:param name="inSchema">
			<xsl:if test="$appliccrossreftableSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>appliccrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$brexSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>brex, </xsl:text>
			</xsl:if>
			<xsl:if test="$checklistSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>checklist, </xsl:text>
			</xsl:if>
			<xsl:if test="$commentSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>comment, </xsl:text>
			</xsl:if>
			<xsl:if test="$comrepSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>comrep, </xsl:text>
			</xsl:if>
			<xsl:if test="$condcrossreftableSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>condcrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$containerSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>container, </xsl:text>
			</xsl:if>
			<xsl:if test="$crewSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>crew, </xsl:text>
			</xsl:if>
			<xsl:if test="$ddnSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>ddn, </xsl:text>
			</xsl:if>
			<xsl:if test="$descriptSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>descript, </xsl:text>
			</xsl:if>
			<xsl:if test="$dmlSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>dml, </xsl:text>
			</xsl:if>
			<xsl:if test="$faultSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>fault, </xsl:text>
			</xsl:if>
			<xsl:if test="$frontmatterSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>frontmatter, </xsl:text>
			</xsl:if>
			<xsl:if test="$ipdSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>ipd, </xsl:text>
			</xsl:if>
			<xsl:if test="$learningSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>learning, </xsl:text>
			</xsl:if>
			<xsl:if test="$pmSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>pm, </xsl:text>
			</xsl:if>
			<xsl:if test="$prdcrossreftableSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>prdcrossreftable, </xsl:text>
			</xsl:if>
			<xsl:if test="$procedSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>proced, </xsl:text>
			</xsl:if>
			<xsl:if test="$processSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>process, </xsl:text>
			</xsl:if>
			<xsl:if test="$sbSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>sb, </xsl:text>
			</xsl:if>
			<xsl:if test="$schedulSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>schedul, </xsl:text>
			</xsl:if>
			<xsl:if test="$scocontentSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>scocontent, </xsl:text>
			</xsl:if>
			<xsl:if test="$scormcontentpackageSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>scormcontentpackage, </xsl:text>
			</xsl:if>
			<xsl:if test="$updateSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>update, </xsl:text>
			</xsl:if>
			<xsl:if test="$wrngdataSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>wrngdata, </xsl:text>
			</xsl:if>
			<xsl:if test="$wrngfldsSchemaFlat//xs:element[@name = $elemName]">
				<xsl:text>wrngflds, </xsl:text>
			</xsl:if>
			<xsl:text>END</xsl:text>
		</xsl:param>
		<!--final comma removed-->
		<xsl:value-of select="substring-before($inSchema, ', END')"/>
		<!--<xsl:for-each select="document('../xml_schema_flat/xcf.xsd',.)">
			<xsl:for-each select="//xs:element">
				<xsl:if test="@name = $elemName">
					<xsl:text>xcf, </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>-->
	</xsl:template>
	
	<!--new for bundeswehr-->
	<xsl:template name="BREXrulesInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>
		<xsl:for-each select="document(concat('../brex/', $defaultBREX), .)">
			<xsl:variable name="rulesFound">
				<xsl:for-each select="//structureObjectRule">
					<xsl:if
						test="starts-with(objectPath, $name) or starts-with(objectPath, concat('//', $name, '/')) or starts-with(objectPath, concat('//', $name, '[')) or substring(objectPath, string-length(objectPath) - string-length(concat($name, '[')) + 1) = concat($name, '[')">
						<xsl:text>X</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="contains($rulesFound, 'X')">
				<tr id="BREX">
					<td class="label">
						<xsl:text>Default BREX Rules</xsl:text>
					</td>
					<td>
						<a href="javascript:showHideBlock('brexInclude');" class="discrete">
							<xsl:text>show/hide</xsl:text>
						</a>
						<div id="brexInclude" style="display:none;">
							<xsl:for-each select="//structureObjectRule">
								<xsl:if
									test="starts-with(objectPath, $name) or starts-with(objectPath, concat('//', $name, '/')) or starts-with(objectPath, concat('//', $name, '[')) or substring(objectPath, string-length(objectPath) - string-length(concat($name, '[')) + 1) = concat($name, '[')">
									<xsl:apply-templates select="."/>
								</xsl:if>
							</xsl:for-each>
						</div>
					</td>
				</tr>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="BREXattributeRulesInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>
		<xsl:for-each select="document(concat('../brex/', $defaultBREX), .)">
			<xsl:variable name="rulesFound">
				<xsl:for-each select="//structureObjectRule">
					<xsl:if
						test="starts-with(objectPath, concat('@', $name)) or starts-with(objectPath, concat('//@', $name)) or starts-with(objectPath, concat('attribute::', $name)) or starts-with(objectPath, concat('//attribute::', $name)) or substring(objectPath, string-length(objectPath) - string-length(concat('@', $name)) + 1) = concat('@', $name)">
						<xsl:text>X</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="contains($rulesFound, 'X')">
				<tr class="BREXrulesInclude">
					<td class="label">
						<xsl:text>Default BREX Rules</xsl:text>
					</td>
					<td>
						<xsl:for-each select="//structureObjectRule">
							<xsl:if
								test="starts-with(objectPath, concat('@', $name)) or starts-with(objectPath, concat('//@', $name)) or starts-with(objectPath, concat('attribute::', $name)) or starts-with(objectPath, concat('//attribute::', $name)) or substring(objectPath, string-length(objectPath) - string-length(concat('@', $name)) + 1) = concat('@', $name)">
								<xsl:apply-templates select="."/>
							</xsl:if>
						</xsl:for-each>
					</td>
				</tr>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="structureObjectRule">
		<div class="structureObjectRule">
			<div class="structureSubObjectRule">
				<b>Rule <xsl:value-of select="brDecisionRef/@brDecisionIdentNumber"/>: </b>
				<xsl:apply-templates select="objectUse"/>
			</div>
			<div class="structureSubObjectRule">
				<b>Schema object: </b>
				<xsl:apply-templates select="objectPath"/>
			</div>
			<div class="structureSubObjectRule">
				<b>Schema object usage: </b>
				<xsl:apply-templates select="objectPath/@allowedObjectFlag"/>
			</div>
			<xsl:if test="objectValue">
				<div class="structureSubObjectRule">
					<table cellpadding="2" cellspacing="1">
						<thead>
							<tr>
								<th style="width:200px;">Allowable Value</th>
								<th style="width:100px;">Tailoring</th>
								<th>Interpretation</th>
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates select="objectValue"/>
						</tbody>
					</table>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="objectValue">
		<tr>
			<td>
				<xsl:value-of select="@valueAllowed"/>
			</td>
			<td>
				<xsl:value-of select="@valueTailoring"/>
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="@allowedObjectFlag">
		<xsl:choose>
			<xsl:when test=". = '0'">
				<b style="font-weight:normal;color:red;">Not allowed</b>
			</xsl:when>
			<xsl:when test=". = '1'">
				<b style="font-weight:normal;color:blue;">mandatory</b>
			</xsl:when>
			<xsl:when test=". = '2'">
				<b style="font-weight:normal;color:green;">As defined in S1000D</b>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--	SFU addition SPEC sample display-->
	<xsl:template name="sampleInclude">
		<xsl:param name="name"/>
		<xsl:param name="type"/>
		<xsl:for-each select="document('../samples/sampleList.xml', .)">
			<xsl:variable name="sampleFile">
				<xsl:value-of select="//sample[@sample = $name]/@file"/>
			</xsl:variable>
			<xsl:if test="$sampleFile != ''">
				<tr>
					<td class="label">
						<xsl:text>Sample</xsl:text>
					</td>
					<td>
						<a href="javascript:showHideBlock('sampleInclude');" class="discrete">
							<xsl:text>show/hide</xsl:text>
						</a>
						<xsl:for-each select="document(concat('../samples/', $sampleFile), .)">
							<div id="sampleInclude" class="elementType" style="display:none;">
								<xsl:apply-templates select="." mode="xmlverb">
									<xsl:with-param name="indent-elements" select="true()"/>
									<xsl:with-param name="show-comments" select="true()" />
								</xsl:apply-templates>
							</div>
						</xsl:for-each>
					</td>
				</tr>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="checkConstraintUnique" >
		<xsl:param name="elemName"/>
		<xsl:for-each select="$complexElements//xs:element[@name=$elemName]">
			<xsl:for-each select="xs:unique">
			<xsl:variable name="uniqueBlockId" select="concat('unique_', @name)"/>
				<tr>
					<td class="label"><xsl:text>Constraints</xsl:text></td>
					<td>
						<a href="javascript:showHideBlock('{$uniqueBlockId}');">
							<xsl:value-of select="@name" />
						</a>
						<div id="{$uniqueBlockId}" class="elementType" style="display:none;">
							<div class="xmlverb-default">
								<xsl:apply-templates select="." mode="xmlverb">
									<xsl:with-param name="indent-elements" select="true()"/>
								</xsl:apply-templates>
							</div>
						</div>
					</td>
				</tr>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
