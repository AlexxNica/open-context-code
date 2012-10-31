<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet  [
	<!ENTITY nbsp   "&#160;">
	<!ENTITY copy   "&#169;">
	<!ENTITY reg    "&#174;">
	<!ENTITY trade  "&#8482;">
	<!ENTITY mdash  "&#8212;">
	<!ENTITY ldquo  "&#8220;">
	<!ENTITY rdquo  "&#8221;"> 
	<!ENTITY pound  "&#163;">
	<!ENTITY yen    "&#165;">
	<!ENTITY euro   "&#8364;">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					 xmlns:ocsem="http://opencontext.org/about/concepts#"
					 xmlns:gml="http://www.opengis.net/gml"
					 xmlns:atom="http://www.w3.org/2005/Atom"
					 xmlns:georss="http://www.georss.org/georss"
					 xmlns:oc="http://opencontext.org/schema/property_schema_v1.xsd"
					 xmlns:arch="http://ochre.lib.uchicago.edu/schema/Project/Variable.xsd"
					 xmlns:xhtml="http://www.w3.org/1999/xhtml"
					 xmlns:dc="http://purl.org/dc/elements/1.1/"
					 xmlns:bibo="http://purl.org/ontology/bibo/"
						xmlns:cc="http://creativecommons.org/ns#"
						xmlns:dcmitype="http://purl.org/dc/dcmitype/"
						xmlns:dcterms="http://purl.org/dc/terms/"
						xmlns:foaf="http://xmlns.com/foaf/0.1/"
						xmlns:owl="http://www.w3.org/2002/07/owl#"
						xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
						xmlns:rdfa="http://www.w3.org/ns/rdfa#"
						xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
						xmlns:skos="http://www.w3.org/2004/02/skos/core#">
<xsl:output method="xml" indent="yes" encoding="utf-8" doctype-public="-//W3C//DTD XHTML+RDFa 1.0//EN" doctype-system="http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"/>



<xsl:template name="string-replace">
		<xsl:param name="arg"/>
		<xsl:param name="toReplace"/>
		<xsl:param name="replaceWith"/>
		<xsl:choose>
			<xsl:when test="contains($arg, $toReplace)">
				<xsl:variable name="prefix" select="substring-before($arg, $toReplace)"/>
				<xsl:variable name="postfix" select="substring($arg, string-length($prefix)+string-length($toReplace)+1)"/>
				<xsl:value-of select="concat($prefix, $replaceWith)"/>
				<xsl:call-template name="string-replace">
					<xsl:with-param name="arg" select="$postfix"/>
					<xsl:with-param name="toReplace" select="$toReplace"/>
					<xsl:with-param name="replaceWith" select="$replaceWith"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$arg"/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>



<xsl:template match="/">

<xsl:variable name="allCreators">
<xsl:for-each select="//arch:property/oc:metadata/dc:creator">&amp;rft.creator=<xsl:value-of select="."/>
</xsl:for-each>
&amp;rft_id=http%3A%2F%2Fopencontext.org%2Fprojects%2F<xsl:value-of select="//arch:property/@UUID"/>
</xsl:variable>






<xsl:variable name="badCOINS"><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:coins"/>
</xsl:variable>
<xsl:variable name="toReplace">Open%20Context</xsl:variable>
<xsl:variable name="replaceWith">Open%20Context&amp;rft.rights=</xsl:variable>
<xsl:variable name="toReplaceB">&amp;rft.type=dataset</xsl:variable>
<xsl:variable name="replaceWithB">&amp;rft.type=dataset<xsl:value-of select="$allCreators"/></xsl:variable>

<xsl:variable name="fixedCOINSpre">
	<xsl:choose>
			<xsl:when test="contains($badCOINS, $toReplace)">
				<xsl:variable name="prefix" select="substring-before($badCOINS, $toReplace)"/>
				<xsl:variable name="postfix" select="substring($badCOINS, string-length($prefix)+string-length($toReplace)+1)"/>
				<xsl:value-of select="concat($prefix, $replaceWith, $postfix)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$badCOINS"/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:variable>


<xsl:variable name="fixedCOINS">
	<xsl:choose>
			<xsl:when test="contains($fixedCOINSpre, $toReplaceB)">
				<xsl:variable name="prefix" select="substring-before($fixedCOINSpre, $toReplaceB)"/>
				<xsl:variable name="postfix" select="substring($fixedCOINSpre, string-length($prefix)+string-length($toReplaceB)+1)"/>
				<xsl:value-of select="concat($prefix, $replaceWithB, $postfix)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$fixedCOINSpre"/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:variable>


<xsl:variable name="num_Summaries">
		<xsl:value-of select="count(//oc:propStats)"/>
</xsl:variable>

<xsl:variable name="num_editors">
	<xsl:value-of select="count(//arch:property/oc:metadata/oc:metadata/dc:creator)"/>
</xsl:variable>

<xsl:variable name="num_contribs">
	<xsl:value-of select="count(//arch:property/oc:metadata/dc:contributor)"/>
</xsl:variable>

<xsl:variable name="citation">
	<xsl:for-each select="//arch:property/oc:metadata/dc:contributor">
		<xsl:value-of select="."/>
		<xsl:if test="position() != last()">, </xsl:if>
		<xsl:if test="position() = last()">. </xsl:if>
	</xsl:for-each>
	<xsl:if test="$num_contribs = 0"> 
		<xsl:for-each select="//arch:property/oc:metadata/dc:creator">
			<xsl:value-of select="."/>
		<xsl:if test="position() != last()">, </xsl:if>
		<xsl:if test="position() = last()">. </xsl:if>
		</xsl:for-each>
	</xsl:if>&quot;<xsl:value-of select="//arch:property/oc:metadata/dc:title"/>&quot; (Released <xsl:value-of select="//arch:property/oc:metadata/dc:date"/>). <xsl:for-each select="//arch:property/oc:metadata/dc:creator"> <xsl:value-of select="."/><xsl:if test="position() != last()">, </xsl:if><xsl:if test="position() = last()"><xsl:if test="$num_editors = 1"> (Ed.) </xsl:if><xsl:if test="$num_editors != 1"> (Eds.) </xsl:if></xsl:if></xsl:for-each> <em>Open Context. </em> &lt;http://opencontext.org/projects/<xsl:value-of select="//arch:property/@UUID"/>&gt; 
</xsl:variable>

<xsl:variable name="citationView">
		<xsl:value-of select="$citation"/>
</xsl:variable>



<div id="main">

		<xsl:comment>
		BEGIN Container for gDIV of general item information
		</xsl:comment>
		
		<div id="item_top"> 
				<xsl:comment>
				This is where the item name is displayed
				</xsl:comment>
				<div id="item_top_tab">
						<div id="item_top_row">
								<div id="item_top_icon_cell">
										<img width='40' height='40'><xsl:attribute name="src">/images/item_view/project_icon.jpg</xsl:attribute><xsl:attribute name="alt">Project or Organization</xsl:attribute></img>
								</div>
								<div id="item_top_name_cell">
										<h1>Property: <xsl:value-of select="//arch:property/arch:name/arch:string"/></h1>
										<h2>Project: <a><xsl:attribute name="href">../projects/<xsl:if test="//arch:property/@ownedBy !=0"><xsl:value-of select="//arch:property/@ownedBy"/></xsl:if></xsl:attribute><xsl:value-of select="//arch:property/oc:metadata/oc:project_name"/></a>
										</h2>
								</div>       
								
								<div id="item_top_view_cell">Number of Views: 
								</div>
						</div>
				</div>
		</div>
		
		<xsl:comment>
		END code for General Item info DIV
		</xsl:comment>
			 
			 
		
		<xsl:comment>
		Code for showing the main description content
		</xsl:comment>
		
		<div id="main_description">
				<div id="main_description_tab">
						<div id="main_description_row">
								<div id="left_des">
				
				
										<div id="proj-all-des">
											<h5>Description</h5>
											
												<div id="abstract">
														
														<div>
																<xsl:choose>
																		<xsl:when test="$num_Summaries &gt; 1">
																				<xsl:attribute name="class">item-multi-obs</xsl:attribute>
																				<ul class="nav nav-tabs">
																						<xsl:for-each select="//oc:propStats">
																								<li>
																										<xsl:choose>
																												<xsl:when test="@observeType = 'spatialUnit'">
																														Locations and Objects
																												</xsl:when>
																												<xsl:when test="@observeType = 'resource'">
																														Media
																												</xsl:when>
																												<xsl:when test="@observeType = 'person'">
																														People and Organizations
																												</xsl:when>
																												<xsl:when test="@observeType = 'project'">
																														Projects and Collections
																												</xsl:when>
																												<xsl:when test="@observeType = 'diary'">
																														Documents
																												</xsl:when>
																												<xsl:otherwise></xsl:otherwise>
																										</xsl:choose>
																								</li>
																						</xsl:for-each>
																				</ul>
																				<div class="tab-content">
																						<xsl:for-each select="//oc:propStats">
																								<div>
																										<xsl:if test="position() != 1">
																												<xsl:attribute name="class">tab-pane fade in active</xsl:attribute>
																										</xsl:if>
																										<xsl:if test="position() != 1">
																												<xsl:attribute name="class">tab-pane fade</xsl:attribute>
																										</xsl:if>
																										<h5>Property Summary: 
																												<xsl:choose>
																														<xsl:when test="@observeType = 'spatialUnit'">
																																Locations and Objects
																														</xsl:when>
																														<xsl:when test="@observeType = 'resource'">
																																Media
																														</xsl:when>
																														<xsl:when test="@observeType = 'person'">
																																People and Organizations
																														</xsl:when>
																														<xsl:when test="@observeType = 'project'">
																																Projects and Collections
																														</xsl:when>
																														<xsl:when test="@observeType = 'diary'">
																																Documents
																														</xsl:when>
																														<xsl:otherwise></xsl:otherwise>
																												</xsl:choose>
																										</h5>
																								</div>
																						</xsl:for-each>
																				</div>
																		</xsl:when>
																		<xsl:otherwise>
																				<h5>Property Summary: 
																						<xsl:choose>
																								<xsl:when test="//oc:propStats/@observeType = 'spatialUnit'">
																										Locations and Objects
																								</xsl:when>
																								<xsl:when test="//oc:propStats/@observeType = 'resource'">
																										Media
																								</xsl:when>
																								<xsl:when test="//oc:propStats/@observeType = 'person'">
																										People and Organizations
																								</xsl:when>
																								<xsl:when test="//oc:propStats/@observeType = 'project'">
																										Projects and Collections
																								</xsl:when>
																								<xsl:when test="//oc:propStats/@observeType = 'diary'">
																										Documents
																								</xsl:when>
																								<xsl:otherwise></xsl:otherwise>
																						</xsl:choose>
																				</h5>
																		</xsl:otherwise>
																</xsl:choose>
																
																
																
																
																
																
														</div>
														
														
														
														
														
														
														
														
														
														
														
														
														<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:notes/arch:note) = 0" >
															<p id="no-notes" class="bodyText">(This item has no additional notes)</p>
														</xsl:if>
														
														<xsl:for-each select="atom:feed/atom:entry/arch:person/arch:notes/arch:note">
															<div class="bodyText"><xsl:value-of select="arch:string" disable-output-escaping="yes" /></div><br/>
														</xsl:for-each>
														
														<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/oc:metadata/oc:links/oc:link) != 0" >
																<div id="person-links">
																		<xsl:for-each select="atom:feed/atom:entry/arch:person/oc:metadata/oc:links/oc:link">
																			<h5>Linked Data:
																				<a>
																						<xsl:attribute name="class">person-link</xsl:attribute>
																						<xsl:attribute name="id">plink-<xsl:value-of select="position()"/></xsl:attribute>
																						<xsl:attribute name="rel"><xsl:value-of select="@rel"/></xsl:attribute>
																						<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
																						<xsl:value-of select="."/>
																				</a>
																			</h5>
																			<div>
																				<xsl:attribute name="id">plink-data-<xsl:value-of select="position()"/></xsl:attribute>
																				<br/>
																			</div>
																		</xsl:for-each>
																</div>
														</xsl:if>
														
												</div>
												
										</div>
									
										<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:observations/arch:observation/arch:links/oc:space_links/oc:link) != 0" >
											<div id="all_links">
												<p class="subHeader">Linked Items (<xsl:value-of select="count(descendant::atom:feed/atom:entry/arch:person/arch:observations/arch:observation/arch:links/oc:space_links/oc:link)"/> items)</p>
													<xsl:for-each select="atom:feed/atom:entry/arch:person/arch:observations/arch:observation/arch:links/oc:space_links/oc:link">
															<xsl:choose>
																<xsl:when test="position() mod 2 = 1">
																	<div class="container_a">
																	<div class="container">	
																	<a><xsl:attribute name="href"><xsl:value-of select="oc:id"/></xsl:attribute><img> 
																		<xsl:attribute name="src">http://www.opencontext.org/database/ui_images/oc_icons/<xsl:value-of select="oc:item_class/oc:iconURI"/></xsl:attribute>
																		<xsl:attribute name="alt"><xsl:value-of select="oc:item_class/oc:name"/></xsl:attribute>
																	</img></a></div>
																	<div class="container"><span class="bodyText"><a>
																	<xsl:attribute name="href"><xsl:value-of select="oc:id"/></xsl:attribute><xsl:value-of select="oc:name"/>
																	</a> ( <xsl:value-of select="oc:relation"/> )</span></div>
															</div> 
																</xsl:when>
																<xsl:otherwise>
																	<div class="clear_container">
																	<div class="container">	
																	<a><xsl:attribute name="href"><xsl:value-of select="oc:id"/></xsl:attribute><img> 
																		<xsl:attribute name="src">http://www.opencontext.org/database/ui_images/oc_icons/<xsl:value-of select="oc:item_class/oc:iconURI"/></xsl:attribute>
																		<xsl:attribute name="alt"><xsl:value-of select="oc:item_class/oc:name"/></xsl:attribute>
																	</img></a></div>
																	<div class="container"><span class="bodyText"><a>
																	<xsl:attribute name="href"><xsl:value-of select="oc:id"/></xsl:attribute><xsl:value-of select="oc:name"/>
																	</a> ( <xsl:value-of select="oc:relation"/> )</span></div>
															</div> 
																</xsl:otherwise>
															</xsl:choose>
														</xsl:for-each>
														<br/>
														<br/>
												</div>
										</xsl:if>
										
										
										<div id="preview">
												<h5>Content Associated with this Person or Organization</h5>
												
												<xsl:if test="atom:feed/atom:entry/atom:category/@term ='category' ">
														<p class="bodyText">Items in these categories have been viewed: <strong><xsl:value-of select="//oc:social_usage/oc:item_views[@type='spatialCount']/oc:count"/></strong> times. (Ranked: <xsl:value-of select="//oc:social_usage/oc:item_views[@type='spatialCount']/oc:count/@rank"/> of  <xsl:value-of select="//oc:social_usage/oc:item_views[@type='spatialCount']/oc:count/@pop"/>)</p>
														<div class="list_tab" style="width:100%;">
																<xsl:for-each select="atom:feed/atom:entry">
																		<xsl:if test="./atom:category/@term ='category' ">
																				<div class="list_tab_row">
																						<div class="list_tab_cell_icon"><a><xsl:attribute name="href"><xsl:for-each select="./atom:link[@rel='alternate']"><xsl:value-of select=".//@href"/></xsl:for-each></xsl:attribute><img><xsl:attribute name="src"><xsl:value-of select="oc:item_class/oc:iconURI"/></xsl:attribute><xsl:attribute name="alt"><xsl:value-of select="oc:item_class/oc:name"/></xsl:attribute></img></a></div>
																						<div class="list_tab_cell"><strong><a><xsl:attribute name="href"><xsl:for-each select="./atom:link[@rel='alternate']"><xsl:value-of select=".//@href"/></xsl:for-each></xsl:attribute><xsl:value-of select="./atom:title"/></a></strong></div>
																						<div class="list_tab_cell"><xsl:value-of select="./atom:content"/></div>
																				</div>
																		</xsl:if>
																</xsl:for-each>
														</div>
												</xsl:if>
												
												<xsl:if test="//oc:metadata/oc:project_name/@editStatus = 0">
														Project dataset is forthcoming, and not yet available.
												</xsl:if>
										</div>
										
										
										<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:properties/arch:property[oc:show_val/text()]) !=0 ">
												<div class="properties">
														<h5>Description (<xsl:value-of select="count(descendant::atom:feed/atom:entry/arch:person/arch:properties/arch:property[oc:show_val/text()])"/> properties)</h5>
														<table class="table table-striped table-condensed table-hover table-bordered prop-tab">
																<thead>
																		<tr>
																				<th>Variable</th>
																				<th>Value</th>
																		</tr>
																</thead>
																<tbody> 
																		<xsl:for-each select="atom:feed/atom:entry/arch:person/arch:properties/arch:property[oc:show_val/text()]">
																				<tr>
																						<td>
																								<xsl:value-of select="oc:var_label"/>
																						</td>
																						<td>
																								<a><xsl:attribute name="href">../properties/<xsl:value-of select="oc:propid"/></xsl:attribute><xsl:value-of select="oc:show_val"/></a>
																						</td>
																				</tr>
																		 </xsl:for-each>
																</tbody>
														</table>
												</div>
										</xsl:if>
										
										
										<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:links/oc:person_links/oc:link) != 0">
												<div id="all_people" >
													<h5>Associated People (<xsl:value-of select="count(descendant::atom:feed/atom:entry/arch:person/arch:links/oc:person_links/oc:link)"/> people)</h5>
													<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:links/oc:person_links/oc:link[oc:name/text() !='']) != 0" >	
														<p class="bodyText">
															<xsl:for-each select="atom:feed/atom:entry/arch:person/arch:links/oc:person_links/oc:link[oc:name/text() !='']">
																<a><xsl:attribute name="href">../persons/<xsl:value-of select="oc:id"/></xsl:attribute><xsl:value-of select="oc:name"/></a><xsl:if test="position() != last()">, </xsl:if>
															</xsl:for-each>
														</p>
													</xsl:if>
													<br/>
													<br/>	
												</div>
										</xsl:if>
					
								</div> <!-- end left_des cell -->
								<div id="right_des">
										<div id="ed-spacer"><br/></div>
										<div id="editorial">
												<h5>Project Rreview Status</h5>
												<div id="project-edit-status">
														  <span id="project-edit-stars">
																  <xsl:attribute name="title"><xsl:value-of select="//oc:metadata/oc:project_name/@statusDes"/> (Click for more)</xsl:attribute>
																  <a href="../about/publishing#editorial-status">
																		<xsl:choose>
																				<xsl:when test="//oc:metadata/oc:project_name/@editStatus = 1">
																						&#9733;&#9734;&#9734;&#9734;&#9734;
																				</xsl:when>
																				<xsl:when test="//oc:metadata/oc:project_name/@editStatus = 2">
																						&#9733;&#9733;&#9734;&#9734;&#9734;
																				</xsl:when>
																				<xsl:when test="//oc:metadata/oc:project_name/@editStatus = 3">
																						&#9733;&#9733;&#9733;&#9734;&#9734;
																				</xsl:when>
																				<xsl:when test="//oc:metadata/oc:project_name/@editStatus = 4">
																						&#9733;&#9733;&#9733;&#9733;&#9734;
																				</xsl:when>
																				<xsl:when test="//oc:metadata/oc:project_name/@editStatus = 5">
																						&#9733;&#9733;&#9733;&#9733;&#9733;
																				</xsl:when>
																				<xsl:otherwise>
																						Forthcomming
																				</xsl:otherwise>
																		</xsl:choose>
																  </a>
																  
														  </span>
														  <xsl:value-of select="//oc:metadata/oc:project_name/@statusLabel"/>
												  </div>
												<br/>
												<br/>
												<h5>Suggested Citation</h5>
												<div id="citation">
														<xsl:value-of select="$citationView"/>
												</div>
										</div>
								
										<div id="all_media" >
												<h5>Linked Media  (<xsl:value-of select="count(descendant::atom:feed/atom:entry/arch:person/arch:links/oc:media_links/oc:link)"/> files)</h5>
												<xsl:if test="count(descendant::atom:feed/atom:entry/arch:person/arch:links/oc:media_links/oc:link) != 0" >
														<div class="list_tab">
																<xsl:for-each select="atom:feed/atom:entry/arch:person/arch:links/oc:media_links/oc:link">
																		<div class="list_tab_row">
																				<xsl:choose>
																				<xsl:when test="oc:type = 'csv'">	
																				<div  class="list_tab_cell">
																					<a>
																						<xsl:attribute name="href">../tables/<xsl:value-of select="oc:id"/></xsl:attribute>
																						<xsl:attribute name="title">Downloadable table: <xsl:value-of select="oc:name"/></xsl:attribute>
																						<img>
																							<xsl:attribute name="alt"><xsl:value-of select="oc:name"/></xsl:attribute>
																							<xsl:attribute name="src"><xsl:value-of select="oc:thumbnailURI"/></xsl:attribute>
																						</img>
																					</a>
																				</div>
																				<div  class="list_tab_cell">
																					<a>
																						<xsl:attribute name="href">../tables/<xsl:value-of select="oc:id"/></xsl:attribute>
																						<xsl:attribute name="title">Downloadable table: <xsl:value-of select="oc:name"/></xsl:attribute>
																						<xsl:value-of select="oc:name"/></a>
																				</div>
																				</xsl:when>
																				<xsl:when test="oc:type = 'acrobat pdf'">	
																				<div  class="list_tab_cell">
																					<a>
																						<xsl:attribute name="href">../media/<xsl:value-of select="oc:id"/></xsl:attribute>
																						<xsl:attribute name="title">Acrobat Document: <xsl:value-of select="oc:name"/></xsl:attribute>
																						<img>
																							<xsl:attribute name="alt"><xsl:value-of select="oc:name"/></xsl:attribute>
																							<xsl:attribute name="src"><xsl:value-of select="oc:thumbnailURI"/></xsl:attribute>
																						</img>
																					</a>
																				</div>
																				<div  class="list_tab_cell">
																					<a>
																						<xsl:attribute name="href">../media/<xsl:value-of select="oc:id"/></xsl:attribute>
																						<xsl:attribute name="title">Acrobat Document: <xsl:value-of select="oc:name"/></xsl:attribute>
																						<xsl:value-of select="oc:name"/></a>
																				</div>
																				</xsl:when>
																				<xsl:otherwise>	
																				<div class="list_tab_cell">
																					<a>
																						<xsl:attribute name="href">../media/<xsl:value-of select="oc:id"/></xsl:attribute>
																						<xsl:attribute name="title"><xsl:value-of select="oc:name"/></xsl:attribute>
																						<img>
																							<xsl:attribute name="alt"><xsl:value-of select="oc:name"/></xsl:attribute>
																							<xsl:attribute name="src"><xsl:value-of select="oc:thumbnailURI"/></xsl:attribute>
																						</img>
																					</a>
																				</div>
																				</xsl:otherwise>
																				</xsl:choose>
																		</div>
																</xsl:for-each>
														</div>
												</xsl:if>
										</div>
								
										<div id="all_keywords">
												<h5>Project Keywords</h5>
													<em><xsl:for-each select="//arch:property/oc:metadata/dc:subject">
														<xsl:value-of select="." /><xsl:if test="position() != last()">, </xsl:if>
														</xsl:for-each>
													</em>
												<br/>	
										</div>
								
										<div id="item-license" >
													 <h5>Copyright Licensing</h5>
													 <div class="list_tab">
														  <div class="list_tab_row">
																<div id="license-icon">
																	 <xsl:choose>
																		  <xsl:when test="//oc:metadata/oc:copyright_lic/oc:lic_URI">
																				<a>
																					 <xsl:attribute name="href"><xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_URI"/></xsl:attribute>
																					 <img> 
																						<xsl:attribute name="src"><xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_icon_URI"/></xsl:attribute>
																						<xsl:attribute name="alt"><xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_name"/></xsl:attribute>
																					 </img>
																				</a>
																		  </xsl:when>
																		  <xsl:otherwise>
																				<a href="http://creativecommons.org/licenses/by/3.0/">
																					 <img src="http://i.creativecommons.org/l/by/3.0/88x31.png" alt="Creative Commons Attribution 3.0 License" />
																				</a>
																		  </xsl:otherwise>
																	 </xsl:choose>
																</div>
																<div id="license-text">
																	 To the extent to which copyright applies, this content is licensed with:
																	 <a>
																		  <xsl:attribute name="rel">license</xsl:attribute>
																		  <xsl:choose>
																				<xsl:when test="//oc:metadata/oc:copyright_lic/oc:lic_URI">
																					 <xsl:attribute name="href"><xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_URI"/></xsl:attribute>
																				</xsl:when>
																				<xsl:otherwise>
																						<xsl:attribute name="href">http://creativecommons.org/licenses/by/3.0/</xsl:attribute>
																				</xsl:otherwise>
																		  </xsl:choose>
																		  <xsl:choose>
																				<xsl:when test="//oc:metadata/oc:copyright_lic/oc:lic_URI">
																					 Creative Commons <xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_name"/>&#32;<xsl:value-of select="//oc:metadata/oc:copyright_lic/oc:lic_vers"/>&#32;License
																				</xsl:when>
																				<xsl:otherwise>
																						Creative Commons Attribution 3.0&#32;License
																				</xsl:otherwise>
																		  </xsl:choose>
																	 </a>
																	 Attribution Required: Citation, and hyperlinks for online uses.
																	 <div style="display:none; width:0px; overflow:hidden;">
																		 <abbr class="unapi-id"><xsl:attribute name="title"><xsl:value-of select="//oc:metadata/dc:identifier"/></xsl:attribute><xsl:value-of select="//oc:metadata/dc:identifier"/></abbr>
																		 <a xmlns:cc="http://creativecommons.org/ns#">
																			 <xsl:attribute name="href"><xsl:value-of select="//oc:metadata/dc:identifier"/></xsl:attribute>
																			 <xsl:attribute name="property">cc:attributionName</xsl:attribute>
																			 <xsl:attribute name="rel">cc:attributionURL</xsl:attribute>
																			 <xsl:value-of select="$citation"/>
																		 </a>
																	 </div>
																</div>
														  </div>
													 </div>
												</div>
												<!-- end div for license div -->
								
								
								</div>
								<!-- end right des row -->
								
								
								
						
						</div> <!-- end main des row -->
						<div id="main_description_bottom">
						</div> <!-- end main des bottom row -->
				</div> <!-- end main des tab -->
		</div> <!-- end main des -->
		
				<xsl:comment>
				BEGIN COINS metadata (for Zotero)
				</xsl:comment>
				
				<span class="Z3988">
					<xsl:attribute name="title"><xsl:value-of select="$fixedCOINS"/></xsl:attribute>
				</span>
				
				<xsl:comment>
				END COINS metadata (for Zotero)
				</xsl:comment>
		
		
		<!--
		<div id="footer">
		
		<div id="w3c_val_logo">
		<a href="http://validator.w3.org/check?uri=referer"><img
				  src="http://www.w3.org/Icons/valid-xhtml-rdfa"
				  alt="Valid XHTML + RDFa" height="31" width="88" /></a>
		</div>
		
		
		<xsl:comment>
		Code for licensing information
		</xsl:comment>
		
		<div id="all_lic">
		<div id="lic_pict">
		<a>
			<xsl:attribute name="href"><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_URI"/></xsl:attribute>
			<img width='88' height='31' style='border:none;'> 
			  <xsl:attribute name="src"><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_icon_URI"/></xsl:attribute>
			  <xsl:attribute name="alt"><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_name"/></xsl:attribute>
			</img>
		</a>
		</div>
		
		<div class="tinyText" id="licarea"> 
		To the extent to which copyright applies, this content is licensed with:<a>
				<xsl:attribute name="rel">license</xsl:attribute>
				<xsl:attribute name="href"><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_URI"/></xsl:attribute><xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_name"/>
						<xsl:value-of select="atom:feed/atom:entry/arch:person/oc:metadata/oc:copyright_lic/oc:lic_vers"/>&#32;License
			</a> Attribution Required: <a href='javascript:showCite()'>Citation</a>, and hyperlinks for online uses.
			<div style="width:0px; overflow:hidden;">
				<a xmlns:cc="http://creativecommons.org/ns#">
					<xsl:attribute name="href"><xsl:value-of select="atom:feed/atom:entry/arch:persont/oc:metadata/dc:identifier"/></xsl:attribute>
					<xsl:attribute name="property">cc:attributionName</xsl:attribute>
					<xsl:attribute name="rel">cc:attributionURL</xsl:attribute>
					<xsl:value-of select="$citation"/>
				</a>
			</div>
		</div>
		
		<div style="display:none;">
				<div property="dc:title"><xsl:value-of select="//oc:metadata/dc:title"/></div>
				<div property="dc:date"><xsl:value-of select="//oc:metadata/dc:date"/></div>
				
				<xsl:for-each select="//oc:metadata/dc:creator">
				<div rel="dc:creator"><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute></div>
				<div property="rdfs:label"><xsl:attribute name="about"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="."/></div>
				</xsl:for-each>
				
				<xsl:for-each select="//oc:metadata/dc:contributor">
				<div rel="dc:contributor"><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute></div>
				<div property="rdfs:label"><xsl:attribute name="about"><xsl:value-of select="@href"/></xsl:attribute>
				<xsl:value-of select="."/></div>
				</xsl:for-each>
				
				<div rel="dc:publisher"><xsl:attribute name="href">http://opencontext.org</xsl:attribute></div>
				<div property="rdfs:label"><xsl:attribute name="about">http://opencontext.org</xsl:attribute>Open Context</div>
				
		</div>
		
		
		
		
		
		</div>
		<xsl:comment>
		END Code for licensing information
		</xsl:comment>
		
		
		
		</div>
		-->
		
</div>

</xsl:template>
</xsl:stylesheet>
