<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:arco-core="https://w3id.org/arco/core/" xmlns:arco-fn="http://w3id.org/arco/saxon-extension"
	xmlns:arco-catalogue="https://w3id.org/arco/catalogue/" xmlns:cis="http://dati.beniculturali.it/cis/"
	xmlns:clvapit="https://w3id.org/italia/onto/CLV/" xmlns:smapit="https://w3id.org/italia/onto/SM/"
	xmlns:arco-dd="https://w3id.org/arco/denotative-description/"
	xmlns:arco-cd="https://w3id.org/arco/context-description/"
	xmlns:arco-ce="https://w3id.org/arco/cultural-event/"
	xmlns:dcterms="http://purl.org/dc/terms/creator" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:frbr="http://purl.org/vocab/frbr/core#"
	xmlns:l0="https://w3id.org/italia/onto/l0/"
	xmlns:arco-location="https://w3id.org/arco/location/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:php="http://php.net/xsl" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:roapit="https://w3id.org/italia/onto/RO/"
	xmlns:tiapit="https://w3id.org/italia/onto/TI/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:mu="https://w3id.org/italia/onto/MU/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	version="1.0" exclude-result-prefixes="xsl php">
	<xsl:output method="xml" encoding="utf-8" indent="yes" />
	<xsl:param name="item" />

	<!-- xsl:import href="test.xsl"/ -->

	<xsl:template match="/">
		<xsl:variable name="NS" select="'https://w3id.org/arco/resource/'" />
		<!-- xsl:variable name="itemURI" select="arco-fn:urify($item)"></xsl:variable -->
		<!-- This cannot be valid as schede/*/CD/NCT/NCTR and schede/*/CD/NCT/NCTN 
			are not unique xsl:variable name="itemURI" select="concat(schede/*/CD/NCT/NCTR, 
			schede/*/CD/NCT/NCTN, schede/*/CD/NCT/NCTS)"></xsl:variable -->
		<xsl:variable name="itemURI">
			<xsl:choose>
				<xsl:when test="schede/*/RV/RVE/RVEL">
					<xsl:value-of
						select="concat(schede/*/CD/NCT/NCTR, schede/*/CD/NCT/NCTN, schede/*/CD/NCT/NCTS, '-', arco-fn:urify(normalize-space(schede/*/RV/RVE/RVEL)))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="concat(schede/*/CD/NCT/NCTR, schede/*/CD/NCT/NCTN, schede/*/CD/NCT/NCTS)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- xsl:variable name="sheetType" select="schede/*/CD/TSK/text()"></xsl:variable -->
		<xsl:variable name="sheetVersion" select="schede/*/@version" />
		<xsl:variable name="sheetType" select="name(schede/*)" />
		<xsl:variable name="cp-name" select="''" />

		<rdf:RDF>
			<!-- We firstly introduce the sheet. -->
			<rdf:Description>
				<xsl:attribute name="rdf:about">
                    <xsl:value-of
					select="concat($NS, 'CatalogueRecord', $sheetType, '/', $itemURI)" />
                </xsl:attribute>

				<rdf:type>
					<xsl:attribute name="rdf:resource">
                        <xsl:value-of
						select="concat('https://w3id.org/arco/catalogue/', 'CatalogueRecord', $sheetType)" />
                    </xsl:attribute>
				</rdf:type>
				<rdfs:label xml:lang="en">
					<xsl:value-of select="concat('Catalogue Record n: ', $itemURI)" />
				</rdfs:label>
				<rdfs:label xml:lang="it">
					<xsl:value-of select="concat('Scheda catalografica n: ', $itemURI)" />
				</rdfs:label>
				
				<!-- hasCataloguingLevel (schede/*/CD/LIR) -->
				<xsl:for-each select="schede/*/CD/LIR">
					<arco-catalogue:hasCataloguingLevel>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat('https://w3id.org/arco/catalogue/', upper-case(arco-fn:urify(.)))" />
                        </xsl:attribute>
					</arco-catalogue:hasCataloguingLevel>
				</xsl:for-each>
				<!-- identifier:sheetIdentifier - concat of NCTR + NCTN + NCTS + - +RVEL. 
					NCTR+NCTN+NCTS comes from schede/*/CD/NCT RVEL comes from schede/*/RV/RVE/RVEL 
					(optional) -->
				<xsl:if test="schede/*/CD/NCT">
					<arco-catalogue:catalogueRecordIdentifier>
						<xsl:choose>
							<xsl:when test="schede/*/RV/RVE/RVEL">
								<xsl:value-of
									select="concat(schede/*/CD/NCT/NCTR, schede/*/CD/NCT/NCTN, schede/*/CD/NCT/NCTS, '-', schede/*/RV/RVE/RVEL)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat(schede/*/CD/NCT/NCTR, schede/*/CD/NCT/NCTN, schede/*/CD/NCT/NCTS)" />
							</xsl:otherwise>
						</xsl:choose>
					</arco-catalogue:catalogueRecordIdentifier>
				</xsl:if>
				<!-- proprietà per avere sempre un collegamento col nome del file xml 
					"ICCD..." -->
				<arco-catalogue:systemRecordCode>
					<xsl:value-of select="$item" />
				</arco-catalogue:systemRecordCode>
				<xsl:for-each select="schede/*/RV/RSP">
					<arco-catalogue:deletedICCDIdentifier>
						<xsl:value-of select="." />
					</arco-catalogue:deletedICCDIdentifier>
				</xsl:for-each>
				<xsl:for-each select="schede/*/RVE/RVES">
					<arco-catalogue:deletedICCDIdentifier>
						<xsl:value-of select="." />
					</arco-catalogue:deletedICCDIdentifier>
				</xsl:for-each>
				<!-- alternative identifier (AC/ACC) -->
				<xsl:if test="schede/*/AC/ACC">
					<xsl:for-each select="schede/*/AC/ACC">
						<arco-catalogue:hasAlternativeIdentifier>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'AlternativeIdentifier/', $itemURI, '-', position())" />
	                			</xsl:attribute>
						</arco-catalogue:hasAlternativeIdentifier>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="schede/*/CM/CMP">
					<arco-catalogue:hasCatalogueRecordVersion>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-compilation')" />
                        </xsl:attribute>
					</arco-catalogue:hasCatalogueRecordVersion>
				</xsl:if>
				<xsl:if test="schede/*/CM/RVM">
					<arco-catalogue:hasCatalogueRecordVersion>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-rvm')" />
                        </xsl:attribute>
					</arco-catalogue:hasCatalogueRecordVersion>
				</xsl:if>
				<xsl:for-each select="schede/*/CM/AGG">
					<arco-catalogue:hasCatalogueRecordVersion>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-agg-', position())" />
                        </xsl:attribute>
					</arco-catalogue:hasCatalogueRecordVersion>
				</xsl:for-each>
				<xsl:if test="schede/*/AN/OSS">
					<arco-core:note>
						<xsl:value-of select="normalize-space(schede/*/AN/OSS)" />
					</arco-core:note>
				</xsl:if>
				<xsl:if test="schede/*/AN/RDP">
					<arco-catalogue:recoveredData>
						<xsl:value-of select="normalize-space(schede/*/AN/RDP)" />
					</arco-catalogue:recoveredData>
				</xsl:if>
			</rdf:Description>
			<!-- This block introduces the triples about the sheet versions. I.e. 
				sub-elements of schede/*/CM -->
			<xsl:if test="schede/*/CM/CMP">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-compilation')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/catalogue/CatalogueRecordVersion'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of
							select="concat(schede/*/CM/CMP/@hint, ' - ', normalize-space(schede/*/CM/CMP))" />
					</rdfs:label>
					<arco-catalogue:isCatalogueRecordVersionOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecord', $sheetType, '/', $itemURI)" />
                        </xsl:attribute>
					</arco-catalogue:isCatalogueRecordVersionOf>
					<xsl:if test="schede/*/CM/CMP/CMPN and (not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'n.r')))">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-compilation-', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasResponsibleResearchAndCompilation>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasResponsibleResearchAndCompilation>
					</xsl:if>
					<xsl:if test="schede/*/CM/CMP/CMPD and (not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPD)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPD)), 'n.r')))">
						<arco-catalogue:editedAtTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPD)))" />
                            </xsl:attribute>
						</arco-catalogue:editedAtTime>
					</xsl:if>
					<!-- Referente verifica scientifica -->
					<xsl:if test="schede/*/CM/RSR and (not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'n.r')))">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/RSR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasScientificDirector>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasScientificDirector>
					</xsl:if>
					<!-- Funzionario responsabile -->
					<xsl:if
						test="schede/*/CM/FUR and (not(starts-with(lower-case(normalize-space(schede/*/CM/FUR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/FUR)), 'n.r')))">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/FUR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasOfficialInCharge>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasOfficialInCharge>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- This block introduces the triples about the sheet versions for RVM. 
				I.e. sub-elements of schede/*/RVM -->
			<xsl:if test="schede/*/CM/RVM">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-rvm')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/catalogue/CatalogueRecordVersion'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of
							select="concat(schede/*/CM/RVM/@hint, ' - ', normalize-space(schede/*/CM/RVM))" />
					</rdfs:label>
					<arco-catalogue:isCatalogueRecordVersionOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecord', $sheetType, '/', $itemURI)" />
                        </xsl:attribute>
					</arco-catalogue:isCatalogueRecordVersionOf>
					<xsl:if test="schede/*/CM/RVM/RVMN">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-rvm-', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasDigitalTranscriptionOperator>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasDigitalTranscriptionOperator>
					</xsl:if>
					<xsl:if test="schede/*/CM/RVM/RVME">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-rvm-', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVME)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasDigitalTranscriptionResponsibleAgent>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVME)))" />
                            </xsl:attribute>
						</arco-catalogue:hasDigitalTranscriptionResponsibleAgent>
					</xsl:if>
					<xsl:if test="schede/*/CM/RVM/RVMD and (not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMD)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMD)), 'n.r')))">
						<arco-catalogue:editedAtTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMD)))" />
                            </xsl:attribute>
						</arco-catalogue:editedAtTime>
					</xsl:if>
					<!-- Referente verifica scientifica -->
					<xsl:if test="schede/*/CM/RSR and (not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'n.r')))">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/RSR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
					</xsl:if>
					<!-- Funzionario responsabile -->
					<xsl:if
						test="schede/*/CM/FUR and (not(starts-with(lower-case(normalize-space(schede/*/CM/FUR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/FUR)), 'n.r')))">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/FUR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasOfficialInCharge>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasOfficialInCharge>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- This block introduces the triples about the sheet versions for AGG. 
				I.e. sub-elements of schede/*/AGG -->
			<xsl:for-each select="schede/*/CM/AGG">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'CatalogueRecordVersion/', $itemURI, '-agg-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/catalogue/CatalogueRecordVersion'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="concat(./@hint, ' - ', normalize-space(.))" />
					</rdfs:label>
					<arco-catalogue:isCatalogueRecordVersionOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'CatalogueRecord', $sheetType, '/', $itemURI)" />
                        </xsl:attribute>
					</arco-catalogue:isCatalogueRecordVersionOf>
					<xsl:if test="./AGGN">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasUpdateResponsibleResearchAndCompilation>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGN)))" />
                            </xsl:attribute>
						</arco-catalogue:hasUpdateResponsibleResearchAndCompilation>
					</xsl:if>
					<xsl:if test="./AGGR">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasUpdateScientificRevisor>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGR)))" />
                            </xsl:attribute>
						</arco-catalogue:hasUpdateScientificRevisor>
					</xsl:if>
					<xsl:if test="./AGGE">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGE)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasUpdateResponsibleAgent>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGE)))" />
                            </xsl:attribute>
						</arco-catalogue:hasUpdateResponsibleAgent>
					</xsl:if>
					<xsl:if test="./AGGD and not(lower-case(normalize-space(./AGGD))='nr' or lower-case(normalize-space(./AGGD))='n.r.' or lower-case(normalize-space(./AGGD))='nr (recupero pregresso)')">
						<arco-catalogue:editedAtTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./AGGD)))" />
                            </xsl:attribute>
						</arco-catalogue:editedAtTime>
					</xsl:if>
					<!-- Funzionario responsabile -->
					<xsl:if
						test="./AGGF and not(lower-case(normalize-space(./AGGF))='nr' or lower-case(normalize-space(./AGGF))='n.r.' or lower-case(normalize-space(./AGGF))='nr (recupero pregresso)')">
						<arco-catalogue:hasCatalogueRecordVersionRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(./AGGF/@hint)), '-', arco-fn:urify(normalize-space(./AGGF)))" />
                            </xsl:attribute>
						</arco-catalogue:hasCatalogueRecordVersionRiT>
						<arco-catalogue:hasUpdateOfficialInCharge>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGF)))" />
                            </xsl:attribute>
						</arco-catalogue:hasUpdateOfficialInCharge>
					</xsl:if>
				</rdf:Description>
				<!-- Time interval -->
				<xsl:if test="./AGGD and not(lower-case(normalize-space(./AGGD))='nr' or lower-case(normalize-space(./AGGD))='n.r.' or lower-case(normalize-space(./AGGD))='nr (recupero pregresso)')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./AGGD)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./AGGD)" />
						</rdfs:label>
						<tiapit:time>
							<xsl:value-of select="normalize-space(./AGGD)" />
						</tiapit:time>
					</rdf:Description>
				</xsl:if>
				<!-- Participant role AGGN -->
				<xsl:if test="./AGGN">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGN)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="concat(./@hint, ' da ', normalize-space(./AGGN))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="concat('Update', ' by ', normalize-space(./AGGN))" />
						</rdfs:label>
						<roapit:withRole>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Role/UpdateResponsibleCompilation')" />
                            </xsl:attribute>
						</roapit:withRole>
						<roapit:isRoleInTimeOf>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGN)))" />
                            </xsl:attribute>
						</roapit:isRoleInTimeOf>
					</rdf:Description>
					<!-- Role -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Role/UpdateResponsibleCompilation')" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Update responsible research and compilation'" />
						</rdfs:label>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="'Responsabile di ricerca e redazione di aggiornamento'" />
						</rdfs:label>
					</rdf:Description>
					<!-- Agent -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGN)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./AGGN)" />
						</rdfs:label>
					</rdf:Description>
				</xsl:if>
				<!-- Participant role - AGGE -->
				<xsl:if test="./AGGE">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGE)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="concat(./@hint, ' da ', normalize-space(./AGGE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="concat('Update', ' by ', normalize-space(./AGGE))" />
						</rdfs:label>
						<roapit:withRole>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Role/UpdateResponsible')" />
                            </xsl:attribute>
						</roapit:withRole>
						<roapit:isRoleInTimeOf>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGE)))" />
                            </xsl:attribute>
						</roapit:isRoleInTimeOf>
					</rdf:Description>
					<!-- Role -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Role/UpdateResponsible')" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Update responsible'" />
						</rdfs:label>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Responsabile di aggiornamento'" />
						</rdfs:label>
					</rdf:Description>
					<!-- Agent -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGE)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./AGGE)" />
						</rdfs:label>
					</rdf:Description>
				</xsl:if>
				<!-- Participant role - AGGR -->
				<xsl:if test="./AGGR">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeIndexedRole/', $itemURI, '-agg-', position(), '-', arco-fn:urify(normalize-space(./AGGR)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="concat(./@hint, ' da ', normalize-space(./AGGR))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="concat('Update', ' by ', normalize-space(./AGGR))" />
						</rdfs:label>
						<roapit:withRole>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Role/UpdateScientificRevisor')" />
                            </xsl:attribute>
						</roapit:withRole>
						<roapit:isRoleInTimeOf>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGR)))" />
                            </xsl:attribute>
						</roapit:isRoleInTimeOf>
					</rdf:Description>
					<!-- Role -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Role/UpdateScientificRevisor')" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Update scientific revisor'" />
						</rdfs:label>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Referente verifica scientifica'" />
						</rdfs:label>
					</rdf:Description>
					<!-- Agent -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGR)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./AGGR)" />
						</rdfs:label>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Referente verifica scientifica -->
			<xsl:if test="schede/*/CM/RSR and (not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RSR)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/RSR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat(schede/*/CM/RSR/@hint, ': ', normalize-space(schede/*/CM/RSR))" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Scientific director', ': ', normalize-space(schede/*/CM/RSR))" />
					</rdfs:label>
					<roapit:withRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/ScientificDirector')" />
                        </xsl:attribute>
					</roapit:withRole>
					<roapit:isRoleInTimeOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                        </xsl:attribute>
					</roapit:isRoleInTimeOf>
				</rdf:Description>
				<!-- Agent: Referente verifica scientifica -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RSR)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/RSR)" />
					</rdfs:label>
				</rdf:Description>
				<!-- Role: Referente verifica scientifica -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/ScientificDirector')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="normalize-space(schede/*/CM/RSR/@hint)" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Scientific Director'" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- Funzionario responsabile -->
			<xsl:if
				test="schede/*/CM/FUR and not(lower-case(normalize-space(schede/*/CM/FUR))='nr' or lower-case(normalize-space(schede/*/CM/FUR))='n.r.' or lower-case(normalize-space(schede/*/CM/FUR))='nr (recupero pregresso)')">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(schede/*/CM/FUR/@hint)), '-', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat(schede/*/CM/FUR/@hint, ': ', normalize-space(schede/*/CM/FUR))" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Official in charge', ': ', normalize-space(schede/*/CM/FUR))" />
					</rdfs:label>
					<roapit:withRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/OfficialInCharge')" />
                        </xsl:attribute>
					</roapit:withRole>
					<roapit:isRoleInTimeOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                        </xsl:attribute>
					</roapit:isRoleInTimeOf>
				</rdf:Description>
				<!-- Agent: Funzionario responsabile -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/FUR)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/FUR)" />
					</rdfs:label>
				</rdf:Description>
				<!-- Role: Funzionario responsabile -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/OfficialInCharge')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="normalize-space(schede/*/CM/FUR/@hint)" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Official in charge'" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- Funzionario responsabile - AGGF -->
			<xsl:if
				test="schede/*/CM/AGG/AGGF and not(lower-case(normalize-space(schede/*/CM/AGG/AGGF))='nr' or lower-case(normalize-space(schede/*/CM/AGG/AGGF))='n.r.' or lower-case(normalize-space(schede/*/CM/AGG/AGGF))='nr (recupero pregresso)')">
				<xsl:for-each select="schede/*/CM/AGG">
					<xsl:if test="./AGGF">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                        <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(./AGGF/@hint)), '-', arco-fn:urify(normalize-space(./AGGF)))" />
                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            <xsl:value-of
									select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat(./AGGF/@hint, ' di aggiornamento: ', normalize-space(./AGGF))" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Update official in charge', ': ', normalize-space(./AGGF))" />
							</rdfs:label>
							<roapit:withRole>
								<xsl:attribute name="rdf:resource">
                            <xsl:value-of
									select="concat($NS, 'Role/OfficialInCharge')" />
                        </xsl:attribute>
							</roapit:withRole>
							<roapit:isRoleInTimeOf>
								<xsl:attribute name="rdf:resource">
                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGF)))" />
                        </xsl:attribute>
							</roapit:isRoleInTimeOf>
						</rdf:Description>
						<!-- Agent: Funzionario responsabile AGGF -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AGGF)))" />
                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./AGGF)" />
							</rdfs:label>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
				<!-- Role funzionario responsabile -->
				<xsl:if test="./AGGF and (not(starts-with(lower-case(normalize-space(./AGGF)), 'nr')) and not(starts-with(lower-case(normalize-space(./AGGF)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                        <xsl:value-of
							select="concat($NS, 'Role/OfficialInCharge')" />
                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="normalize-space(schede/*/CM/AGG/@hint)" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Official in charge'" />
						</rdfs:label>
					</rdf:Description>
				</xsl:if>
			</xsl:if>
			<!-- Version time interval - CMD -->
			<xsl:if test="schede/*/CM/CMP/CMPD and (not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPD)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPD)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPD)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/CMP/CMPD)" />
					</rdfs:label>
					<tiapit:time>
						<xsl:value-of select="normalize-space(schede/*/CM/CMP/CMPD)" />
					</tiapit:time>
				</rdf:Description>
			</xsl:if>
			<!-- Version time interval - RVM -->
			<xsl:if test="schede/*/CM/RVM/RVMD and (not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMD)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMD)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMD)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/RVM/RVMD)" />
					</rdfs:label>
					<tiapit:time>
						<xsl:value-of select="normalize-space(schede/*/CM/RVM/RVMD)" />
					</tiapit:time>
				</rdf:Description>
			</xsl:if>
			<!-- Participant role - Compilation -->
			<xsl:if test="schede/*/CM/CMP/CMPN and (not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedRole/', $itemURI, '-compilation-', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPN)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Compilation by ', normalize-space(schede/*/CM/CMP/CMPN))" />
					</rdfs:label>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Compilazione da ', normalize-space(schede/*/CM/CMP/CMPN))" />
					</rdfs:label>
					<roapit:withRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/ResponsibleCompilation')" />
                        </xsl:attribute>
					</roapit:withRole>
					<roapit:isRoleInTimeOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPN)))" />
                        </xsl:attribute>
					</roapit:isRoleInTimeOf>
				</rdf:Description>
			</xsl:if>
			<!-- responsible research and compilation Agent -->
			<xsl:if test="schede/*/CM/CMP/CMPN and (not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/CMP/CMPN)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/CMP/CMPN)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/CMP/CMPN)" />
					</rdfs:label>
				</rdf:Description>
				<!-- responsible research and compilation role -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/ResponsibleCompilation')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Responsible research and compilation'" />
					</rdfs:label>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="'Responsabile ricerca e redazione'" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- Participant role - RVME -->
			<xsl:if test="schede/*/CM/RVM/RVME and (not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVME)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVME)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedRole/', $itemURI, '-rvm-', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVME)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat(schede/*/CM/RVM/@hint, ' da ', normalize-space(schede/*/CM/RVM/RVME))" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Digital transcription', ' by ', normalize-space(schede/*/CM/RVM/RVME))" />
					</rdfs:label>
					<roapit:withRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/DigitalTranscriptionResponsibleAgent')" />
                        </xsl:attribute>
					</roapit:withRole>
					<roapit:isRoleInTimeOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVME)))" />
                        </xsl:attribute>
					</roapit:isRoleInTimeOf>
				</rdf:Description>
				<!-- digital transcription responsible agent -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVME)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/RVM/RVME)" />
					</rdfs:label>
				</rdf:Description>
				<!-- digital transcription responsible agent role -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/DigitalTranscriptionResponsibleAgent')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Digital transcription responsible agent'" />
					</rdfs:label>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="'Responsabile della trascrizione per informatizzazione'" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- Participant role - RVMN -->
			<xsl:if test="schede/*/CM/RVM/RVMN and (not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMN)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CM/RVM/RVMN)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedRole/', $itemURI, '-rvm-', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMN)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat(schede/*/CM/RVM/@hint, ' da ', normalize-space(schede/*/CM/RVM/RVMN))" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Digital transcription', ' by ', normalize-space(schede/*/CM/RVM/RVMN))" />
					</rdfs:label>
					<roapit:withRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/DigitalTranscriptionOperator')" />
                        </xsl:attribute>
					</roapit:withRole>
					<roapit:isRoleInTimeOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMN)))" />
                        </xsl:attribute>
					</roapit:isRoleInTimeOf>
				</rdf:Description>
				<!-- digital transcription agent -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CM/RVM/RVMN)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/CM/RVM/RVMN)" />
					</rdfs:label>
				</rdf:Description>
				<!-- digital transciption operator role -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/DigitalTranscriptionOperator')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Digital transcription operator'" />
					</rdfs:label>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="'Operatore della trascrizione per informatizzazione'" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>



			<!-- We then introduce the cultural entity described by the sheet. -->
			<rdf:Description>
				<xsl:attribute name="rdf:about">
                    <xsl:value-of
					select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                </xsl:attribute>
				<rdf:type>
					<xsl:attribute name="rdf:resource">
                        <xsl:value-of
						select="arco-fn:getPropertyType($sheetType)" />
                    </xsl:attribute>
				</rdf:type>
				<!-- rdf:type of cultural property -->
				<rdf:type>
					<xsl:attribute name="rdf:resource">
                        <xsl:value-of
						select="arco-fn:getSpecificPropertyType($sheetType)" />
                    </xsl:attribute>
				</rdf:type>
				<!-- rdfs:comment of cultural property -->
				<rdfs:comment>
					<xsl:for-each select="schede/*/OG/OGT/*">
						<xsl:choose>
							<xsl:when test="position() = 1">
								<xsl:value-of select="./text()" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(', ', ./text())" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<!-- comment for BDI 3.00 and 3.01 -->
					<xsl:for-each select="schede/*/DB/*">
						<xsl:choose>
							<xsl:when test="position() = 1">
								<xsl:value-of select="./text()" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(', ', ./text())" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:if test="schede/*/SGT/SGTI">
						<xsl:value-of select="concat(' ', schede/*/SGT/SGTI)" />
					</xsl:if>
				</rdfs:comment>
				<xsl:for-each select="schede/*/OG/OGT">
					<arco-dd:hasCulturalPropertyType>
						<xsl:attribute name="rdf:resource">
                            <xsl:choose>
                                <xsl:when test="./OGTT">
                                    <xsl:value-of
							select="concat($NS, 'CulturalPropertyType/', arco-fn:urify(normalize-space(./OGTD)), '-', arco-fn:urify(normalize-space(./OGTT)))" />
                                </xsl:when>
                                <xsl:when test="./OGTD">
                                    <xsl:value-of
							select="concat($NS, 'CulturalPropertyType/', arco-fn:urify(normalize-space(./OGTD)))" />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
					</arco-dd:hasCulturalPropertyType>
				</xsl:for-each>
			</rdf:Description>
			<!-- Subject as an individual (sgti) -->
			<xsl:for-each select="schede/*/*/SGT/SGTI">
				<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(.)))" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                          <xsl:value-of
								select="'https://w3id.org/arco/context-description/Subject'" />
                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
						<arco-cd:isSubjectOf>
							<xsl:attribute name="rdf:resource">
                    		<xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                    	</xsl:attribute>
						</arco-cd:isSubjectOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Subject as an individual (aidi) -->
			<xsl:for-each select="schede/*/DA/AID/AIDI">
				<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(.)))" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                          <xsl:value-of
								select="'https://w3id.org/arco/context-description/Subject'" />
                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
						<arco-cd:isSubjectOf>
							<xsl:attribute name="rdf:resource">
                    		<xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                    	</xsl:attribute>
						</arco-cd:isSubjectOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for SG/SGL/SGLL -->
			<xsl:if
				test="not(lower-case(normalize-space(schede/*/SG/SGL/SGLL))='nr' or lower-case(normalize-space(schede/*/SG/SGL/SGLL))='n.r.' or lower-case(normalize-space(schede/*/SG/SGL/SGLL))='nr (recupero pregresso)')">
				<xsl:for-each select="schede/*/SG/SGL/SGLL">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
						<arco-cd:hasTitleType>
							<xsl:attribute name="rdf:resource">
            			<xsl:value-of
								select="'https://w3id.org/arco/context-description/Parallel'" />
            		</xsl:attribute>
						</arco-cd:hasTitleType>
						<xsl:if test="../SGLS">
							<arco-core:specifications>
								<xsl:value-of select="normalize-space(../SGLS)" />
							</arco-core:specifications>
						</xsl:if>
					</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- Title as an individual for SG/SGT/SGTT -->
			<xsl:for-each select="schede/*/OG/SGT/SGTT">
			<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            				<xsl:value-of
						select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
					<xsl:if test="../SGTL and (not(starts-with(lower-case(normalize-space(../SGTL)), 'nr')) and not(starts-with(lower-case(normalize-space(../SGTL)), 'n.r')))">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
	            				</xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- Title source as an individual -->
				<xsl:if test="../SGTL">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                				<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
                			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                        		</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for DA/AID/AIDT -->
			<xsl:for-each select="schede/*/DA/AID/AIDT">
			<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            				<xsl:value-of
						select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
				</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for DA/AID/AIDN -->
			<xsl:for-each select="schede/*/DA/AID/AIDN">
			<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            				<xsl:value-of
						select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
					<arco-cd:hasTitleType>
						<xsl:attribute name="rdf:resource">
            			<xsl:value-of
							select="'https://w3id.org/arco/context-description/Alternative'" />
            		</xsl:attribute>
					</arco-cd:hasTitleType>
				</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for SG/SGT/SGTP -->
			<xsl:for-each select="schede/*/SG/SGT/SGTP">
			<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            				<xsl:value-of
						select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
					<arco-cd:hasTitleType>
						<xsl:attribute name="rdf:resource">
            			<xsl:value-of
							select="'https://w3id.org/arco/context-description/Proper'" />
            		</xsl:attribute>
					</arco-cd:hasTitleType>
					<xsl:if test="../SGTL and (not(starts-with(lower-case(normalize-space(../SGTL)), 'nr')) and not(starts-with(lower-case(normalize-space(../SGTL)), 'n.r')))">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
	            				</xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- Title source as an individual -->
				<xsl:if test="../SGTL">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                				<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
                			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                        		</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for SG/SGL/SGLT -->
			<xsl:if
				test="not(lower-case(normalize-space(schede/*/SG/SGL/SGLT))='nr' or lower-case(normalize-space(schede/*/SG/SGL/SGLT))='n.r.' or lower-case(normalize-space(schede/*/SG/SGL/SGLT))='nr (recupero pregresso)')">
				<xsl:for-each select="schede/*/SG/SGL/SGLT">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
						<arco-cd:hasTitleType>
							<xsl:attribute name="rdf:resource">
            			<xsl:value-of
								select="'https://w3id.org/arco/context-description/Proper'" />
            		</xsl:attribute>
						</arco-cd:hasTitleType>
						<xsl:if test="../SGLS">
							<arco-core:specifications>
								<xsl:value-of select="normalize-space(../SGLS)" />
							</arco-core:specifications>
						</xsl:if>
					</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- Title as an individual for SG/SGT/SGTR -->
			<xsl:for-each select="schede/*/SG/SGT/SGTR">
			<xsl:if
					test="not(starts-with(lower-case(normalize-space(.)), 'nr')) and not(starts-with(lower-case(normalize-space(.)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            				<xsl:value-of
						select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
					<arco-cd:hasTitleType>
						<xsl:attribute name="rdf:resource">
            			<xsl:value-of
							select="'https://w3id.org/arco/context-description/Parallel'" />
            		</xsl:attribute>
					</arco-cd:hasTitleType>
					<xsl:if test="../SGTL and (not(starts-with(lower-case(normalize-space(../SGTL)), 'nr')) and not(starts-with(lower-case(normalize-space(../SGTL)), 'n.r')))">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
	            				</xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- Title source as an individual -->
				<xsl:if test="../SGTL">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                				<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../SGTL)))" />
                			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                        		</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(../SGTL)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- Title as an individual for SG/SGL/SGLA -->
			<xsl:if
				test="not(lower-case(normalize-space(schede/*/SG/SGL/SGLA))='nr' or lower-case(normalize-space(schede/*/SG/SGL/SGLA))='n.r.' or lower-case(normalize-space(schede/*/SG/SGL/SGLA))='nr (recupero pregresso)')">
				<xsl:for-each select="schede/*/SG/SGL/SGLA">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Title/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
						<arco-cd:hasTitleType>
							<xsl:attribute name="rdf:resource">
            			<xsl:value-of
								select="'https://w3id.org/arco/context-description/Attributed'" />
            		</xsl:attribute>
						</arco-cd:hasTitleType>
						<xsl:if test="../SGLS">
							<arco-core:specifications>
								<xsl:value-of select="normalize-space(../SGLS)" />
							</arco-core:specifications>
						</xsl:if>
					</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with preparatory or final work (RO/ROF) -->
			<xsl:if test="schede/*/RO/ROF">
				<xsl:for-each select="schede/*/RO/ROF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-preparatory-final-work-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e opera originale o finale')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e opera originale o finale')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and preparatory or final work')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and preparatory or final work')" />
						</l0:name>
						<xsl:choose>
							<xsl:when
								test="lower-case(normalize-space(./ROFF))='calco' or lower-case(normalize-space(./ROFF))='calco parziale' or lower-case(normalize-space(./ROFF))='copia' or lower-case(normalize-space(./ROFF))='copia con varianti' or lower-case(normalize-space(./ROFF))='copia parziale' or lower-case(normalize-space(./ROFF))='derivazione' or lower-case(normalize-space(./ROFF))='derivazione con varianti' or lower-case(normalize-space(./ROFF))='derivazione parziale' or lower-case(normalize-space(./ROFF))='imitazione' or lower-case(normalize-space(./ROFF))='remake' or lower-case(normalize-space(./ROFF))='replica' or lower-case(normalize-space(./ROFF))='replica parziale' or lower-case(normalize-space(./ROFF))='replica con varianti' or lower-case(normalize-space(./ROFF))='positivo' or lower-case(normalize-space(./ROFF))='particolare' or lower-case(normalize-space(./ROFF))='fotomontaggio'">
								<arco-cd:hasRelatedWork>
									<xsl:attribute name="rdf:resource">
											<xsl:value-of
										select="concat($NS, 'PreparatoryWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
										</xsl:attribute>
								</arco-cd:hasRelatedWork>
							</xsl:when>
							<xsl:when
								test="lower-case(normalize-space(./ROFF))='bozzetto' or lower-case(normalize-space(./ROFF))='bozzetto parziale' or lower-case(normalize-space(./ROFF))='cartone' or lower-case(normalize-space(./ROFF))='cartone parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio' or lower-case(normalize-space(./ROFF))='matrice' or lower-case(normalize-space(./ROFF))='matrice parziale' or lower-case(normalize-space(./ROFF))='modellino' or lower-case(normalize-space(./ROFF))='modellino parziale' or lower-case(normalize-space(./ROFF))='modello' or lower-case(normalize-space(./ROFF))='modello parziale' or lower-case(normalize-space(./ROFF))='modello in cera' or lower-case(normalize-space(./ROFF))='progetto' or lower-case(normalize-space(./ROFF))='prototipo' or lower-case(normalize-space(./ROFF))='prova' or lower-case(normalize-space(./ROFF))='schizzo' or lower-case(normalize-space(./ROFF))='sinopia' or lower-case(normalize-space(./ROFF))='sinopia parziale' or lower-case(normalize-space(./ROFF))='negativo' or lower-case(normalize-space(./ROFF))='internegativo' or lower-case(normalize-space(./ROFF))='prova a contatto' or lower-case(normalize-space(./ROFF))='prova di stampa' or lower-case(normalize-space(./ROFF))='prova intermedia' or lower-case(normalize-space(./ROFF))='prova in controparte' or lower-case(normalize-space(./ROFF))='prova finale' or lower-case(normalize-space(./ROFF))='provino' or lower-case(normalize-space(./ROFF))='maquette'">
								<arco-cd:hasRelatedWork>
									<xsl:attribute name="rdf:resource">
											<xsl:value-of
										select="concat($NS, 'FinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
										</xsl:attribute>
								</arco-cd:hasRelatedWork>
							</xsl:when>
							<xsl:otherwise>
								<arco-cd:hasRelatedWork>
									<xsl:attribute name="rdf:resource">
											<xsl:value-of
										select="concat($NS, 'PreparatoryOrFinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
										</xsl:attribute>
								</arco-cd:hasRelatedWork>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="./ROFF and (not(starts-with(lower-case(normalize-space(./ROFF)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFF)), 'n.r')))">
							<arco-cd:hasCulturalPropertyStage>
								<xsl:attribute name="rdf:resource">
										<xsl:value-of
									select="concat($NS, 'CulturalPropertyStage/', arco-fn:urify(normalize-space(./ROFF)))" />
									</xsl:attribute>
							</arco-cd:hasCulturalPropertyStage>
						</xsl:if>
						<xsl:if test="./ROFP">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./ROFP)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- preparatory work, final work and preparatory or final work as individuals -->
					<xsl:choose>
						<!-- preparatory work as an individual -->
						<xsl:when
							test="lower-case(normalize-space(./ROFF))='calco' or lower-case(normalize-space(./ROFF))='calco parziale' or lower-case(normalize-space(./ROFF))='copia' or lower-case(normalize-space(./ROFF))='copia con varianti' or lower-case(normalize-space(./ROFF))='copia parziale' or lower-case(normalize-space(./ROFF))='derivazione' or lower-case(normalize-space(./ROFF))='derivazione con varianti' or lower-case(normalize-space(./ROFF))='derivazione parziale' or lower-case(normalize-space(./ROFF))='imitazione' or lower-case(normalize-space(./ROFF))='remake' or lower-case(normalize-space(./ROFF))='replica' or lower-case(normalize-space(./ROFF))='replica parziale' or lower-case(normalize-space(./ROFF))='replica con varianti'">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
										<xsl:value-of
									select="concat($NS, 'PreparatoryWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
									</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
		                          		<xsl:value-of
										select="'https://w3id.org/arco/context-description/PreparatoryWork'" />
		                       		</xsl:attribute>
								</rdf:type>
								<rdfs:label xml:lang="it">
									<xsl:value-of
										select="concat('Opera originale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="it">
									<xsl:value-of
										select="concat('Opera originale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<rdfs:label xml:lang="en">
									<xsl:value-of
										select="concat('Preparatory work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="en">
									<xsl:value-of
										select="concat('Preparatory work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<xsl:if test="./ROFS and (not(starts-with(lower-case(normalize-space(./ROFS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFS)), 'n.r')))">
									<arco-cd:hasSubject>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(./ROFS)))" />
										</xsl:attribute>
									</arco-cd:hasSubject>
								</xsl:if>
								<xsl:if test="./ROFR and (not(starts-with(lower-case(normalize-space(./ROFR)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFR)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkPreviousLocation>
										<xsl:value-of select="normalize-space(./ROFR)" />
									</arco-cd:preparatoryOrFinalWorkPreviousLocation>
								</xsl:if>
								<xsl:if test="./ROFC and (not(starts-with(lower-case(normalize-space(./ROFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFC)), 'n.r')))">
									<arco-cd:relatedWorkLocation>
										<xsl:value-of select="normalize-space(./ROFC)" />
									</arco-cd:relatedWorkLocation>
								</xsl:if>
								<xsl:if test="./ROFX and (not(starts-with(lower-case(normalize-space(./ROFX)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFX)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkRecordIdentifier>
										<xsl:value-of select="normalize-space(./ROFX)" />
									</arco-cd:preparatoryOrFinalWorkRecordIdentifier>
								</xsl:if>
								<xsl:if test="./ROFI and (not(starts-with(lower-case(normalize-space(./ROFI)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFI)), 'n.r')))">
									<arco-cd:hasInventory>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Inventory/', $itemURI, '-preparatory-final-work-inventory-', arco-fn:urify(normalize-space(./ROFI)))" />
										</xsl:attribute>
									</arco-cd:hasInventory>
								</xsl:if>
								<xsl:if test="./ROFT and (not(starts-with(lower-case(normalize-space(./ROFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFT)), 'n.r')))">
									<arco-cd:hasTitle>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Title/', $itemURI, '-preparatory-final-work-title-', arco-fn:urify(normalize-space(./ROFT)))" />
										</xsl:attribute>
									</arco-cd:hasTitle>
								</xsl:if>
								<xsl:if test="./ROFD and (not(starts-with(lower-case(normalize-space(./ROFD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFD)), 'n.r')))">
									<arco-cd:hasDating>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Dating/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />						
										</xsl:attribute>
									</arco-cd:hasDating>
								</xsl:if>
								<xsl:if test="./ROFA and (not(starts-with(lower-case(normalize-space(./ROFA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFA)), 'n.r')))">
									<arco-cd:hasAuthor>
										<xsl:attribute name="rdf:resource">
			            					<xsl:value-of
											select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ROFA)))" />
			            				</xsl:attribute>
									</arco-cd:hasAuthor>
								</xsl:if>
							</rdf:Description>
						</xsl:when>
						<!-- final work as an individual -->
						<xsl:when
							test="lower-case(normalize-space(./ROFF))='bozzetto' or lower-case(normalize-space(./ROFF))='bozzetto parziale' or lower-case(normalize-space(./ROFF))='cartone' or lower-case(normalize-space(./ROFF))='cartone parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio' or lower-case(normalize-space(./ROFF))='matrice' or lower-case(normalize-space(./ROFF))='matrice parziale' or lower-case(normalize-space(./ROFF))='modellino' or lower-case(normalize-space(./ROFF))='modellino parziale' or lower-case(normalize-space(./ROFF))='modello' or lower-case(normalize-space(./ROFF))='modello parziale' or lower-case(normalize-space(./ROFF))='modello in cera' or lower-case(normalize-space(./ROFF))='progetto' or lower-case(normalize-space(./ROFF))='prototipo' or lower-case(normalize-space(./ROFF))='prova' or lower-case(normalize-space(./ROFF))='schizzo' or lower-case(normalize-space(./ROFF))='sinopia' or lower-case(normalize-space(./ROFF))='sinopia parziale'">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
									<xsl:value-of
									select="concat($NS, 'FinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
								</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
										select="'https://w3id.org/arco/context-description/FinalWork'" />
	                       		</xsl:attribute>
								</rdf:type>
								<rdfs:label xml:lang="it">
									<xsl:value-of
										select="concat('Opera finale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="it">
									<xsl:value-of
										select="concat('Opera finale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<rdfs:label xml:lang="en">
									<xsl:value-of
										select="concat('Final work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="en">
									<xsl:value-of
										select="concat('Final work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<xsl:if test="./ROFS and (not(starts-with(lower-case(normalize-space(./ROFS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFS)), 'n.r')))">
									<arco-cd:hasSubject>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(./ROFS)))" />
										</xsl:attribute>
									</arco-cd:hasSubject>
								</xsl:if>
								<xsl:if test="./ROFR and (not(starts-with(lower-case(normalize-space(./ROFR)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFR)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkPreviousLocation>
										<xsl:value-of select="normalize-space(./ROFR)" />
									</arco-cd:preparatoryOrFinalWorkPreviousLocation>
								</xsl:if>
								<xsl:if test="./ROFC and (not(starts-with(lower-case(normalize-space(./ROFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFC)), 'n.r')))">
									<arco-cd:relatedWorkLocation>
										<xsl:value-of select="normalize-space(./ROFC)" />
									</arco-cd:relatedWorkLocation>
								</xsl:if>
								<xsl:if test="./ROFX and (not(starts-with(lower-case(normalize-space(./ROFX)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFX)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkRecordIdentifier>
										<xsl:value-of select="normalize-space(./ROFX)" />
									</arco-cd:preparatoryOrFinalWorkRecordIdentifier>
								</xsl:if>
								<xsl:if test="./ROFI and (not(starts-with(lower-case(normalize-space(./ROFI)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFI)), 'n.r')))">
									<arco-cd:hasInventory>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Inventory/', $itemURI, '-preparatory-final-work-inventory-', arco-fn:urify(normalize-space(./ROFI)))" />
										</xsl:attribute>
									</arco-cd:hasInventory>
								</xsl:if>
								<xsl:if test="./ROFT and (not(starts-with(lower-case(normalize-space(./ROFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFT)), 'n.r')))">
									<arco-cd:hasTitle>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Title/', $itemURI, '-preparatory-final-work-title-', arco-fn:urify(normalize-space(./ROFT)))" />
										</xsl:attribute>
									</arco-cd:hasTitle>
								</xsl:if>
								<xsl:if test="./ROFD and (not(starts-with(lower-case(normalize-space(./ROFD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFD)), 'n.r')))">
									<arco-cd:hasDating>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Dating/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />						
										</xsl:attribute>
									</arco-cd:hasDating>
								</xsl:if>
								<xsl:if test="./ROFA and (not(starts-with(lower-case(normalize-space(./ROFA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFA)), 'n.r')))">
									<arco-cd:hasAuthor>
										<xsl:attribute name="rdf:resource">
			            					<xsl:value-of
											select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ROFA)))" />
			            				</xsl:attribute>
									</arco-cd:hasAuthor>
								</xsl:if>
							</rdf:Description>
						</xsl:when>
						<!-- final or preparatory work as an individual -->
						<xsl:otherwise>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
										<xsl:value-of
									select="concat($NS, 'PreparatoryOrFinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
									</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
		                          		<xsl:value-of
										select="'https://w3id.org/arco/context-description/PreparatoryOrFinalWork'" />
		                       		</xsl:attribute>
								</rdf:type>
								<rdfs:label xml:lang="it">
									<xsl:value-of
										select="concat('Opera originale o finale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="it">
									<xsl:value-of
										select="concat('Opera originale o finale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<rdfs:label xml:lang="en">
									<xsl:value-of
										select="concat('Preparatory or final work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</rdfs:label>
								<l0:name xml:lang="en">
									<xsl:value-of
										select="concat('Preparatory or final work ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./ROFO))" />
								</l0:name>
								<xsl:if test="./ROFS and (not(starts-with(lower-case(normalize-space(./ROFS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFS)), 'n.r')))">
									<arco-cd:hasSubject>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(./ROFS)))" />
										</xsl:attribute>
									</arco-cd:hasSubject>
								</xsl:if>
								<xsl:if test="./ROFR and (not(starts-with(lower-case(normalize-space(./ROFR)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFR)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkPreviousLocation>
										<xsl:value-of select="normalize-space(./ROFR)" />
									</arco-cd:preparatoryOrFinalWorkPreviousLocation>
								</xsl:if>
								<xsl:if test="./ROFC and (not(starts-with(lower-case(normalize-space(./ROFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFC)), 'n.r')))">
									<arco-cd:relatedWorkLocation>
										<xsl:value-of select="normalize-space(./ROFC)" />
									</arco-cd:relatedWorkLocation>
								</xsl:if>
								<xsl:if test="./ROFX and (not(starts-with(lower-case(normalize-space(./ROFX)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFX)), 'n.r')))">
									<arco-cd:preparatoryOrFinalWorkRecordIdentifier>
										<xsl:value-of select="normalize-space(./ROFX)" />
									</arco-cd:preparatoryOrFinalWorkRecordIdentifier>
								</xsl:if>
								<xsl:if test="./ROFI and (not(starts-with(lower-case(normalize-space(./ROFI)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFI)), 'n.r')))">
									<arco-cd:hasInventory>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Inventory/', $itemURI, '-preparatory-final-work-inventory-', arco-fn:urify(normalize-space(./ROFI)))" />
										</xsl:attribute>
									</arco-cd:hasInventory>
								</xsl:if>
								<xsl:if test="./ROFT and (not(starts-with(lower-case(normalize-space(./ROFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFT)), 'n.r')))">
									<arco-cd:hasTitle>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Title/', $itemURI, '-preparatory-final-work-title-', arco-fn:urify(normalize-space(./ROFT)))" />
										</xsl:attribute>
									</arco-cd:hasTitle>
								</xsl:if>
								<xsl:if test="./ROFD and (not(starts-with(lower-case(normalize-space(./ROFD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFD)), 'n.r')))">
									<arco-cd:hasDating>
										<xsl:attribute name="rdf:resource">
											<xsl:value-of
											select="concat($NS, 'Dating/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />						
										</xsl:attribute>
									</arco-cd:hasDating>
								</xsl:if>
								<xsl:if test="./ROFA and (not(starts-with(lower-case(normalize-space(./ROFA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFA)), 'n.r')))">
									<arco-cd:hasAuthor>
										<xsl:attribute name="rdf:resource">
			            					<xsl:value-of
											select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ROFA)))" />
			            				</xsl:attribute>
									</arco-cd:hasAuthor>
								</xsl:if>
							</rdf:Description>
						</xsl:otherwise>
					</xsl:choose>
					<!-- cultural property stage as an individual -->
					<xsl:if test="./ROFF and (not(starts-with(lower-case(normalize-space(./ROFF)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFF)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'CulturalPropertyStage/', arco-fn:urify(normalize-space(./ROFF)))" />
									</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                          		<xsl:value-of
									select="'https://w3id.org/arco/context-description/CulturalPropertyStage'" />
			                       		</xsl:attribute>
							</rdf:type>
							<l0:name>
								<xsl:value-of select="normalize-space(./ROFF)" />
							</l0:name>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ROFF)" />
							</rdfs:label>
						</rdf:Description>
					</xsl:if>
					<!-- subject of preparatory or final work as an individual -->
					<xsl:if test="./ROFS and (not(starts-with(lower-case(normalize-space(./ROFS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFS)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            			<xsl:value-of
								select="concat($NS, 'Subject/', arco-fn:urify(normalize-space(./ROFS)))" />
				            		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                          <xsl:value-of
									select="'https://w3id.org/arco/context-description/Subject'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ROFS)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ROFS)" />
							</l0:name>
							<arco-cd:isSubjectOf>
								<xsl:attribute name="rdf:resource">
				                    		<xsl:choose>
				                    			<xsl:when
									test="lower-case(normalize-space(./ROFF))='calco' or lower-case(normalize-space(./ROFF))='calco parziale' or lower-case(normalize-space(./ROFF))='copia' or lower-case(normalize-space(./ROFF))='copia con varianti' or lower-case(normalize-space(./ROFF))='copia parziale' or lower-case(normalize-space(./ROFF))='derivazione' or lower-case(normalize-space(./ROFF))='derivazione con varianti' or lower-case(normalize-space(./ROFF))='derivazione parziale' or lower-case(normalize-space(./ROFF))='imitazione' or lower-case(normalize-space(./ROFF))='remake' or lower-case(normalize-space(./ROFF))='replica' or lower-case(normalize-space(./ROFF))='replica parziale' or lower-case(normalize-space(./ROFF))='replica con varianti'">
				                    				<xsl:value-of
									select="concat($NS, 'PreparatoryWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
				                    			</xsl:when>
				                    			<xsl:when
									test="lower-case(normalize-space(./ROFF))='bozzetto' or lower-case(normalize-space(./ROFF))='bozzetto parziale' or lower-case(normalize-space(./ROFF))='cartone' or lower-case(normalize-space(./ROFF))='cartone parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio parziale' or lower-case(normalize-space(./ROFF))='disegno preparatorio' or lower-case(normalize-space(./ROFF))='matrice' or lower-case(normalize-space(./ROFF))='matrice parziale' or lower-case(normalize-space(./ROFF))='modellino' or lower-case(normalize-space(./ROFF))='modellino parziale' or lower-case(normalize-space(./ROFF))='modello' or lower-case(normalize-space(./ROFF))='modello parziale' or lower-case(normalize-space(./ROFF))='modello in cera' or lower-case(normalize-space(./ROFF))='progetto' or lower-case(normalize-space(./ROFF))='prototipo' or lower-case(normalize-space(./ROFF))='prova' or lower-case(normalize-space(./ROFF))='schizzo' or lower-case(normalize-space(./ROFF))='sinopia' or lower-case(normalize-space(./ROFF))='sinopia parziale'">
				                    				<xsl:value-of
									select="concat($NS, 'FinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
				                    			</xsl:when>
				                    			<xsl:otherwise>
				                    				<xsl:value-of
									select="concat($NS, 'PreparatoryOrFinalWork/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
				                    			</xsl:otherwise>
				                    		</xsl:choose>
				                    	</xsl:attribute>
							</arco-cd:isSubjectOf>
						</rdf:Description>
					</xsl:if>
					<!-- inventory about preparatory or final work as an individual -->
					<xsl:if test="./ROFI and (not(starts-with(lower-case(normalize-space(./ROFI)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFI)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            			<xsl:value-of
								select="concat($NS, 'Inventory/', $itemURI, '-preparatory-final-work-inventory-', arco-fn:urify(normalize-space(./ROFI)))" />
				            		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                          <xsl:value-of
									select="'https://w3id.org/arco/context-description/Inventory'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Inventory ', normalize-space(./ROFI), ' of preparatory or final work of cultural property ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Inventory ', normalize-space(./ROFI), ' of preparatory or final work of cultural property ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Inventario ', normalize-space(./ROFI), ' dell''opera originale o finale del bene ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Inventario ', normalize-space(./ROFI), ' dell''opera originale o finale del bene ', $itemURI)" />
							</l0:name>
							<arco-cd:inventoryIdentifier>
								<xsl:value-of select="normalize-space(./ROFI)" />
							</arco-cd:inventoryIdentifier>
						</rdf:Description>
					</xsl:if>
					<!-- preparatory or final work title as an individual -->
					<xsl:if test="./ROFT and (not(starts-with(lower-case(normalize-space(./ROFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFT)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            						<xsl:value-of
								select="concat($NS, 'Title/', $itemURI, '-preparatory-final-work-title-', arco-fn:urify(normalize-space(./ROFT)))" />
	            					</xsl:attribute>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ROFT)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ROFT)" />
							</l0:name>
							<arco-cd:hasTitleType>
								<xsl:attribute name="rdf:resource">
					            			<xsl:value-of
									select="'https://w3id.org/arco/context-description/Proper'" />
					            		</xsl:attribute>
							</arco-cd:hasTitleType>
						</rdf:Description>
					</xsl:if>
					<!-- dating as an individual -->
					<xsl:if test="./ROFD and (not(starts-with(lower-case(normalize-space(./ROFD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFD)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				                        <xsl:value-of
								select="concat($NS, 'Dating/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)))" />
				                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="'https://w3id.org/arco/context-description/Dating'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Cronologia dell''opera originale o finale ', position(), ' del bene ', $itemURI)" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Dating of preparatory or final work ', position(), ' of cultural property ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Cronologia dell''opera originale o finale ', position(), ' del bene ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Dating of preparatory or final work ', position(), ' of cultural property ', $itemURI)" />
							</rdfs:label>
							<arco-cd:hasEvent>
								<xsl:attribute name="rdf:resource">
				                           <xsl:value-of
									select="concat($NS, 'Event/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)), '-creation')" />
				                        </xsl:attribute>
							</arco-cd:hasEvent>
							<!-- Source of dating -->
							<xsl:if
								test="./ROFM and (not(starts-with(lower-case(normalize-space(./ROFM)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFM)), 'n.r')))">
								<arco-cd:hasSource>
									<xsl:attribute name="rdf:resource">
				                              <xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./ROFM)))" />
				                         </xsl:attribute>
								</arco-cd:hasSource>
							</xsl:if>
						</rdf:Description>
						<!-- Source of dating as individual -->
						<xsl:if
							test="./ROFM and (not(starts-with(lower-case(normalize-space(./ROFM)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFM)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
				                             <xsl:value-of
									select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./ROFM)))" />
				                        </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
				                                <xsl:value-of
										select="'https://w3id.org/arco/context-description/Source'" />
				                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./ROFM)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./ROFM)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<!-- event of dating as individual -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				                        <xsl:value-of
								select="concat($NS, 'Event/', $itemURI, '-', arco-fn:urify(normalize-space(./ROFO)), '-creation')" />
				                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Event'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Realizzazione dell''opera originale o finale ', position(), ' del bene ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Realizzazione dell''opera originale o finale ', position(), ' del bene ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Creation of preparatory or final work ', position(), ' of cultural property ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Creation of preparatory or final work ', position(), ' of cultural property ', $itemURI)" />
							</l0:name>
							<tiapit:atTime>
								<xsl:attribute name="rdf:resource">
				                                <xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./ROFD)))" />
				                            </xsl:attribute>
							</tiapit:atTime>
						</rdf:Description>
						<!-- Time interval as an individual -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				                            <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./ROFD)))" />
				                        </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                                <xsl:value-of
									select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
				                            </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ROFD)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ROFD)" />
							</l0:name>
							<tiapit:time>
								<xsl:value-of select="normalize-space(./ROFD)" />
							</tiapit:time>
						</rdf:Description>
					</xsl:if>
					<xsl:if test="./ROFA and (not(starts-with(lower-case(normalize-space(./ROFA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ROFA)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ROFA)))" />
				            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				            					<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
				            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ROFA)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ROFA)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with copy (RO/COP) -->
			<xsl:if test="schede/*/RO/COP or schede/*/RO/CRF/CRFT='copia'">
				<xsl:for-each select="schede/*/RO/COP | schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-copy-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e copia')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e copia')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and copy')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and copy')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'Copy/', $itemURI, '-copy-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="../CRF/CRFS and (not(starts-with(lower-case(normalize-space(../CRF/CRFS)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFS)), 'n.r')))">
							<arco-core:note>
								<xsl:value-of select="normalize-space(../CRF/CRFS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- copy as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
										<xsl:value-of
							select="concat($NS, 'Copy/', $itemURI, '-copy-', position())" />
									</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
		                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Copy'" />
		                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Copia ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Copia ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Copy ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Copy ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="./COPR and (not(starts-with(lower-case(normalize-space(./COPR)), 'nr')) and not(starts-with(lower-case(normalize-space(./COPR)), 'n.r')))">
							<arco-cd:hasReferenceCatalogue>
								<xsl:attribute name="rdf:resource">
											<xsl:value-of
									select="concat($NS, 'ReferenceCatalogue/', $itemURI, '-reference-catalogue-', position())" />
										</xsl:attribute>
							</arco-cd:hasReferenceCatalogue>
						</xsl:if>
						<xsl:if test="./COPA and (not(starts-with(lower-case(normalize-space(./COPA)), 'nr')) and not(starts-with(lower-case(normalize-space(./COPA)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
			            					<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COPA)))" />
			            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="../CRF/CRFN or ../CRF/CRFB and (not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'n.r'))) and (not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
			            				<xsl:choose>
			            					<xsl:when test="../CRF/CRFN">
			            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFN)))" />
			            					</xsl:when>
			            					<xsl:otherwise>
			            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFB)))" />
			            					</xsl:otherwise>
			            				</xsl:choose>
			            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="../CRF/CRFC and (not(starts-with(lower-case(normalize-space(../CRF/CRFC)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFC)), 'n.r')))">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(../CRF/CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
					</rdf:Description>
					<!-- reference catalogue as an individual -->
					<xsl:if test="./COPR and (not(starts-with(lower-case(normalize-space(./COPR)), 'nr')) and not(starts-with(lower-case(normalize-space(./COPR)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
											<xsl:value-of
								select="concat($NS, 'ReferenceCatalogue/', $itemURI, '-reference-catalogue-', position())" />
										</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/ReferenceCatalogue'" />
				            				</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Repertorio della copia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./COPR))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Repertorio della copia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./COPR))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Reference catalogue of copy ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./COPR))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Reference catalogue of copy ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./COPR))" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- author of copy (RO/COP/COPA) as an individual -->
					<xsl:if test="./COPA and (not(starts-with(lower-case(normalize-space(./COPA)), 'nr')) and not(starts-with(lower-case(normalize-space(./COPA)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COPA)))" />
				            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				            					<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
				            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./COPA)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./COPA)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- author of copy (RO/CRF/CRFN or RO/CRF/CRFB) as an individual -->
					<xsl:if test="../CRF/CRFN or ../CRF/CRFB and (not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'n.r'))) and (not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            				<xsl:choose>
			            					<xsl:when test="../CRF/CRFN">
			            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFN)))" />
			            					</xsl:when>
			            					<xsl:otherwise>
			            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFB)))" />
			            					</xsl:otherwise>
			            				</xsl:choose>
				            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                                <xsl:choose>
				                                	<xsl:when
									test="lower-case(normalize-space(../CRF/CRFP))='p'">
                                        				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    				</xsl:when>
				                                    <xsl:when
									test="lower-case(normalize-space(../CRF/CRFP))='e'">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
				                                    </xsl:when>
				                                    <xsl:when test="../CRF/CRFN">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
				                                    </xsl:when>
				                                    <xsl:when test="../CRF/CRFB">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
				                                    </xsl:when>
				                                    <xsl:otherwise>
				                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
				                                    </xsl:otherwise>
				                                </xsl:choose>
                            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="../CRF/CRFN">
										<xsl:value-of select="normalize-space(../CRF/CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../CRF/CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="../CRF/CRFN">
										<xsl:value-of select="normalize-space(../CRF/CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../CRF/CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="../CRF/CRFH and (not(starts-with(lower-case(normalize-space(../CRF/CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="../CRF/CRFH" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a generic derivated work (if RO/CRF/CRFT != 'replica' 
				or 'contraffazione' or 'controtipo' or 'reimpiego' or 'copia') -->
			<xsl:if
				test="schede/*/RO/CRF and not(schede/*/RO/CRF/CRFT='copia' or schede/*/RO/CRF/CRFT='contraffazione' or schede/*/RO/CRF/CRFT='controtipo' or schede/*/RO/CRF/CRFT='replica' or schede/*/RO/CRF/CRFT='reimpiego')">
				<xsl:for-each select="schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-derivated-work-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e opera derivata')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e opera derivata')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and derivated work')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and derivated work')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'DerivatedWork/', $itemURI, '-derivated-work-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="./CRFS and (not(starts-with(lower-case(normalize-space(./CRFS)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFS)), 'n.r')))">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./CRFS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- derivated work as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
										<xsl:value-of
							select="concat($NS, 'DerivatedWork/', $itemURI, '-derivated-work-', position())" />
									</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
		                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/DerivatedWork'" />
		                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Opera derivata ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Opera derivata ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Derivated work ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Derivated work ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="./CRFT and (not(starts-with(lower-case(normalize-space(./CRFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFT)), 'n.r')))">
							<arco-cd:hasDerivatedWorkType>
								<xsl:attribute name="rdf:resource">
										<xsl:value-of
									select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./CRFT)))" />
									</xsl:attribute>
							</arco-cd:hasDerivatedWorkType>
						</xsl:if>
						<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
			            				<xsl:choose>
			            					<xsl:when test="./CRFN">
			            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
			            					</xsl:when>
			            					<xsl:otherwise>
			            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
			            					</xsl:otherwise>
			            				</xsl:choose>
			            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="./CRFC and (not(starts-with(lower-case(normalize-space(./CRFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFC)), 'n.r')))">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(./CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
					</rdf:Description>
					<!-- author of derivated work as an individual -->
					<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				            				<xsl:choose>
			            					<xsl:when test="./CRFN">
			            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
			            					</xsl:when>
			            					<xsl:otherwise>
			            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
			            					</xsl:otherwise>
			            				</xsl:choose>
				            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                                <xsl:choose>
				                                	<xsl:when
									test="lower-case(normalize-space(./CRFP))='p'">
                                        				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    				</xsl:when>
				                                    <xsl:when
									test="lower-case(normalize-space(./CRFP))='e'">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
				                                    </xsl:when>
				                                    <xsl:when test="./CRFN">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
				                                    </xsl:when>
				                                    <xsl:when test="./CRFB">
				                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
				                                    </xsl:when>
				                                    <xsl:otherwise>
				                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
				                                    </xsl:otherwise>
				                                </xsl:choose>
                            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="./CRFH and (not(starts-with(lower-case(normalize-space(./CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="normalize-space(./CRFH)" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
					<!-- derivated work type as an individual -->
					<xsl:if test="./CRFT and (not(starts-with(lower-case(normalize-space(./CRFT)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFT)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					            				<xsl:value-of
								select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./CRFT)))" />
					            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/DerivatedWorkType'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./CRFT)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./CRFT)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a particular type of derivated work: forgery -->
			<xsl:if test="schede/*/RO/CRF/CFRT='contraffazione'">
				<xsl:for-each select="schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-forgery-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e contraffazione')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e contraffazione')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and forgery')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and forgery')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'Forgery/', $itemURI, '-forgery-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="./CRFS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./CRFS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- forgery as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'Forgery/', $itemURI, '-forgery-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Forgery'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Contraffazione ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Contraffazione ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Forgery ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Forgery ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
		            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
		            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="./CRFC and (not(starts-with(lower-case(normalize-space(./CRFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFC)), 'n.r')))">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(./CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
					</rdf:Description>
					<!-- author of forgery as an individual -->
					<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
			            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                                <xsl:choose>
			                                	<xsl:when
									test="lower-case(normalize-space(./CRFP))='p'">
                                       				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                   				</xsl:when>
			                                    <xsl:when
									test="lower-case(normalize-space(./CRFP))='e'">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFN">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFB">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:otherwise>
			                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
			                                    </xsl:otherwise>
			                                </xsl:choose>
                           				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="./CRFH and (not(starts-with(lower-case(normalize-space(./CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="normalize-space(./CRFH)" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a particular type of derivated work: facsimile -->
			<xsl:if test="schede/*/RO/CRF/CFRT='controtipo'">
				<xsl:for-each select="schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-facsimile-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e controtipo')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e controtipo')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and facsimile')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and facsimile')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'Facsimile/', $itemURI, '-facsimile-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="./CRFS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./CRFS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- facsimile as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'Facsimile/', $itemURI, '-facsimile-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Facsimile'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Controtipo ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Controtipo ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Facsimile ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Facsimile ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
		            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
		            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="./CRFC">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(./CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
					</rdf:Description>
					<!-- author of facsimile as an individual -->
					<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
			            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                                <xsl:choose>
			                                	<xsl:when
									test="lower-case(normalize-space(./CRFP))='p'">
                                       				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                   				</xsl:when>
			                                    <xsl:when
									test="lower-case(normalize-space(./CRFP))='e'">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFN">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFB">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:otherwise>
			                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
			                                    </xsl:otherwise>
			                                </xsl:choose>
                           				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="./CRFH and (not(starts-with(lower-case(normalize-space(./CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="normalize-space(./CRFH)" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a particular type of derivated work: same author copy -->
			<xsl:if test="schede/*/RO/CRF/CFRT='replica'">
				<xsl:for-each select="schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-same-author-copy-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e replica')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e replica')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and copy by the same author')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and copy by the same author')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'SameAuthorCopy/', $itemURI, '-same-author-copy-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="./CRFS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./CRFS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- same author copy as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'SameAuthorCopy/', $itemURI, '-same-author-copy-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/SameAuthorCopy'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Replica ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Replica ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Copy ', position(), ' by the same author of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Copy ', position(), ' by the same author of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
		            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
		            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="./CRFC and (not(starts-with(lower-case(normalize-space(./CRFC)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFC)), 'n.r')))">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(./CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
					</rdf:Description>
					<!-- author of same author copy as an individual -->
					<xsl:if test="./CRFN or ./CRFB and (not(starts-with(lower-case(normalize-space(./CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
			            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                                <xsl:choose>
			                                	<xsl:when
									test="lower-case(normalize-space(./CRFP))='p'">
                                       				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                   				</xsl:when>
			                                    <xsl:when
									test="lower-case(normalize-space(./CRFP))='e'">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFN">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
			                                    </xsl:when>
			                                    <xsl:when test="./CRFB">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:otherwise>
			                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
			                                    </xsl:otherwise>
			                                </xsl:choose>
                           				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./CRFN">
										<xsl:value-of select="normalize-space(./CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="./CRFH and (not(starts-with(lower-case(normalize-space(./CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="normalize-space(./CRFH)" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a particular type of derivated work: reuse -->
			<xsl:if
				test="schede/*/RO/REI or schede/*/RO/RIU or schede/*/RO/CRF/CFRT='reimpiego'">
				<xsl:for-each select="schede/*/RO/REI | schede/*/RO/RIU | schede/*/RO/CRF">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-reuse-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e riuso')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra il bene culturale ', $itemURI, ' e riuso')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and reuse')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and reuse')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'Reuse/', $itemURI, '-reuse-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
						<xsl:if test="../CRF/CRFS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(../CRF/CRFS)" />
							</arco-core:note>
						</xsl:if>
						<xsl:if test="../REIS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./REIS)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<!-- reuse as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'Reuse/', $itemURI, '-reuse-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/Reuse'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Riuso ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Riuso ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Reuse ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Reuse ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<xsl:if test="../CRF/CRFN or ../CRF/CRFB and (not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
		            				<xsl:choose>
		            					<xsl:when test="./CRFN">
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
		            				</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="../CRF/CRFC and (not(starts-with(lower-case(normalize-space(../CRF/CRFC)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFC)), 'n.r')))">
							<arco-cd:relatedWorkLocation>
								<xsl:value-of select="normalize-space(../CRF/CRFC)" />
							</arco-cd:relatedWorkLocation>
						</xsl:if>
						<xsl:if test="./REID or ../RIU/RIUD">
							<tiapit:time>
								<xsl:choose>
									<xsl:when test="./REID">
										<xsl:value-of select="normalize-space(./REID)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../RIU/RIUD)" />
									</xsl:otherwise>
								</xsl:choose>
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./REIT or ../RIU/RIUT and (not(starts-with(lower-case(normalize-space(./REIT)), 'nr')) and not(starts-with(lower-case(normalize-space(./REIT)), 'n.r')) and not(starts-with(lower-case(normalize-space(../RIU/RIUT)), 'nr')) and not(starts-with(lower-case(normalize-space(../RIU/RIUT)), 'n.r')))">
							<arco-cd:hasDerivatedWorkType>
								<xsl:attribute name="rdf:resource">
									<xsl:choose>
										<xsl:when test="./REIT">
											<xsl:value-of
									select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./REIT)))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
									select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(../RIU/RIUT)))" />
										</xsl:otherwise>
									</xsl:choose>
									</xsl:attribute>
							</arco-cd:hasDerivatedWorkType>
						</xsl:if>
					</rdf:Description>
					<!-- derivated work type as an individual -->
					<xsl:if test="./REIT or ../RIU/RIUT and (not(starts-with(lower-case(normalize-space(./REIT)), 'nr')) and not(starts-with(lower-case(normalize-space(./REIT)), 'n.r')) and not(starts-with(lower-case(normalize-space(../RIU/RIUT)), 'nr')) and not(starts-with(lower-case(normalize-space(../RIU/RIUT)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					            				<xsl:choose>
													<xsl:when test="./REIT">
														<xsl:value-of
								select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./REIT)))" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of
								select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(../RIU/RIUT)))" />
													</xsl:otherwise>
												</xsl:choose>
					            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/DerivatedWorkType'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./REIT">
										<xsl:value-of select="normalize-space(./REIT)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../RIU/RIUD)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./REIT">
										<xsl:value-of select="normalize-space(./REIT)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../RIU/RIUD)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- author of reuse as an individual -->
					<xsl:if test="../CRF/CRFN or ../CRF/CRFB and (not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFN)), 'n.r')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			            				<xsl:choose>
		            					<xsl:when test="../CRF/CRFN">
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFN)))" />
		            					</xsl:when>
		            					<xsl:otherwise>
		            						<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../CRF/CRFB)))" />
		            					</xsl:otherwise>
		            				</xsl:choose>
			            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                                <xsl:choose>
			                                	<xsl:when
									test="lower-case(normalize-space(../CRF/CRFP))='p'">
                                       				<xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
                                   				</xsl:when>
			                                    <xsl:when
									test="lower-case(normalize-space(../CRF/CRFP))='e'">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:when test="../CRF/CRFN">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/CPV/Person'" />
			                                    </xsl:when>
			                                    <xsl:when test="../CRF/CRFB">
			                                        <xsl:value-of
									select="'https://w3id.org/italia/onto/COV/Organization'" />
			                                    </xsl:when>
			                                    <xsl:otherwise>
			                                    	<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
			                                    </xsl:otherwise>
			                                </xsl:choose>
                           				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="../CRF/CRFN">
										<xsl:value-of select="normalize-space(../CRF/CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../CRF/CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="../CRF/CRFN">
										<xsl:value-of select="normalize-space(../CRF/CRFN)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(../CRF/CRFB)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="../CRF/CRFH and (not(starts-with(lower-case(normalize-space(../CRF/CRFH)), 'nr')) and not(starts-with(lower-case(normalize-space(../CRF/CRFH)), 'n.r')))">
								<arco-cd:agentLocalIdentifier>
									<xsl:value-of select="../CRF/CRFH" />
								</arco-cd:agentLocalIdentifier>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- relation with a particular type of derivated work: print in publication (S) -->
				<xsl:if test="schede/*/RO/ADL">
					<xsl:for-each select="schede/*/RO/ADL">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                            <xsl:value-of
									select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-print-in-publication-', position())" />
			                        </xsl:attribute>
			                 <rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/RelatedWorkSituation'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra la stampa ', $itemURI, ' e pubblicazione contenente la stampa')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Rapporto ', position(), ' tra la stampa ', $itemURI, ' e pubblicazione contenente la stampa')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the print ', $itemURI, ' and publication with print')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the print ', $itemURI, ' and publication with print')" />
						</l0:name>
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
									<xsl:value-of
								select="concat($NS, 'PrintInPublication/', $itemURI, '-print-in-publication-', position())" />
								</xsl:attribute>
						</arco-cd:hasRelatedWork>
					</rdf:Description>
					<!-- print in publication as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
								<xsl:value-of
							select="concat($NS, 'PrintInPublication/', $itemURI, '-print-in-publication-', position())" />
							</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                          		<xsl:value-of
								select="'https://w3id.org/arco/context-description/PrintInPublication'" />
	                       		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Pubblicazione ', position(), ' contenente la stampa ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Pubblicazione ', position(), ' contenente la stampa ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Publication ', position(), ' with print ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Publication ', position(), ' with print ', $itemURI)" />
						</l0:name>
						<xsl:if test="./ADLA and (not(starts-with(lower-case(normalize-space(./ADLA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLA)), 'n.r')))">
							<arco-cd:hasAuthor>
								<xsl:attribute name="rdf:resource">
		            						<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ADLA)))" />
								</xsl:attribute>
							</arco-cd:hasAuthor>
						</xsl:if>
						<xsl:if test="./ADLL and (not(starts-with(lower-case(normalize-space(./ADLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLL)), 'n.r')))">
							<arco-cd:hasDerivatedWorkType>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./ADLL)))" />
									</xsl:attribute>
							</arco-cd:hasDerivatedWorkType>
						</xsl:if>
						<xsl:if test="./ADLT and (not(starts-with(lower-case(normalize-space(./ADLT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLT)), 'n.r')))">
							<arco-cd:hasTitle>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="concat($NS, 'Title/', $itemURI, '-publication-', arco-fn:urify(normalize-space(./ADLT)))" />
									</xsl:attribute>
							</arco-cd:hasTitle>
						</xsl:if>
						<xsl:if test="./ADLE and (not(starts-with(lower-case(normalize-space(./ADLE)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLE)), 'n.r')))">
							<arco-cd:hasEdition>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="concat($NS, 'Edition/', $itemURI, '-edition-', arco-fn:urify(normalize-space(./ADLE)))" />
									</xsl:attribute>
							</arco-cd:hasEdition>
						</xsl:if>
						<xsl:if test="./ADLP or ./ADLN">
							<arco-cd:hasReproduction>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="concat($NS, 'Reproduction/', $itemURI, '-reproduction')" />
									</xsl:attribute>
							</arco-cd:hasReproduction>
						</xsl:if>
						<xsl:if test="./ADLS and (not(starts-with(lower-case(normalize-space(./ADLS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLS)), 'n.r')))">
							<arco-cd:hasReproduction>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="concat($NS, 'NoLongerInPublication/', $itemURI, '-reproduction')" />
									</xsl:attribute>
							</arco-cd:hasReproduction>
						</xsl:if>
					</rdf:Description>
					<!-- derivated work type as an individual -->
					<xsl:if test="./ADLL and (not(starts-with(lower-case(normalize-space(./ADLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLL)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'DerivatedWorkType/', arco-fn:urify(normalize-space(./ADLL)))" />
					         </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/DerivatedWorkType'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ADLL)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ADLL)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- print in publication title as an individual -->
					<xsl:if test="./ADLT and (not(starts-with(lower-case(normalize-space(./ADLT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLT)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'Title/', $itemURI, '-publication-', arco-fn:urify(normalize-space(./ADLT)))" />
					         </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/Title'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ADLT)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ADLT)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- print in publication edition as an individual -->
					<xsl:if test="./ADLE and (not(starts-with(lower-case(normalize-space(./ADLE)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLE)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'Edition/', $itemURI, '-edition-', arco-fn:urify(normalize-space(./ADLE)))" />
					         </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/Edition'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="concat('Edizione della pubblicazione contenente la stampa ', $itemURI, ': ', normalize-space(./ADLE))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of select="concat('Edizione della pubblicazione contenente la stampa ', $itemURI, ': ', normalize-space(./ADLE))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="concat('Edition of publication with print ', $itemURI, ': ', normalize-space(./ADLE))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of select="concat('Edition of publication with print ', $itemURI, ': ', normalize-space(./ADLE))" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- print in publication reproduction as an individual -->
					<xsl:if test="./ADLP or ./ADLN">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'Reproduction/', $itemURI, '-reproduction')" />
					         </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/Reproduction'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="concat('Riproduzione in pubblicazione della stampa ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of select="concat('Riproduzione in pubblicazione della stampa ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="concat('Reproduction in publication of print ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of select="concat('Reproduction in publication of print ', $itemURI)" />
							</l0:name>
							<arco-cd:hasReproductionPosition>
								<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="concat($NS, 'ReproductionPosition/', $itemURI, '-', arco-fn:urify(normalize-space(./ADLP)))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($NS, 'ReproductionPosition/', $itemURI, '-reproduction-position')" />
									</xsl:otherwise>
								</xsl:choose>
								</xsl:attribute>
							</arco-cd:hasReproductionPosition>
						</rdf:Description>
						<!-- reproduction position as an individual -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="concat($NS, 'ReproductionPosition/', $itemURI, '-', arco-fn:urify(normalize-space(./ADLP)))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($NS, 'ReproductionPosition/', $itemURI, '-reproduction-position')" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="'https://w3id.org/arco/context-description/ReproductionPosition'" />
								</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="concat('Posizione della riproduzione della stampa ', $itemURI, ' nella pubblicazione: ', normalize-space(./ADLP))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('Posizione della riproduzione della stampa ', $itemURI, ' nella pubblicazione')" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="normalize-space(./ADLP)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('Posizione della riproduzione della stampa ', $itemURI, ' nella pubblicazione: ', normalize-space(./ADLP))" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="normalize-space(./ADLP)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('Print ', $itemURI, ' reproduction position in publication: ', normalize-space())" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:choose>
									<xsl:when test="./ADLP">
										<xsl:value-of select="concat('Print ', $itemURI, ' reproduction position in publication: ', normalize-space(./ADLP))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('Print ', $itemURI, ' reproduction position in publication')" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<xsl:if test="./ADLN and (not(starts-with(lower-case(normalize-space(./ADLN)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLN)), 'n.r')))">
								<arco-cd:pageOrTableNumber>
									<xsl:value-of select="normalize-space(./ADLN)" />
								</arco-cd:pageOrTableNumber>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
					<!-- no longer in publication as an individual -->
					<xsl:if test="./ADLS and (not(starts-with(lower-case(normalize-space(./ADLS)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLS)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
										<xsl:value-of
								select="concat($NS, 'NoLongerInPublication/', $itemURI, '-reproduction')" />
					         </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/NoLongerInPublication'" />
					            				</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="concat('Riproduzione in pubblicazione della stampa ', $itemURI, ' non più presente in pubblicazione')" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of select="concat('Riproduzione in pubblicazione della stampa ', $itemURI, ' non più presente in pubblicatione')" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="concat('Reproduction in publication of print ', $itemURI, ' no longer in publication')" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of select="concat('Reproduction in publication of print ', $itemURI, ' no longer in publication')" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- author of print in publication as an individual -->
					<xsl:if test="./ADLA and (not(starts-with(lower-case(normalize-space(./ADLA)), 'nr')) and not(starts-with(lower-case(normalize-space(./ADLA)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		            				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ADLA)))" />
			            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
			                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                           				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ADLA)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ADLA)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					</xsl:for-each>
				</xsl:if>
			<!-- Number of components as an individual -->
			<xsl:if
				test="schede/*/OG/QNT/QNTN or schede/*/OG/QNT/QNTI or schede/*/OG/QNT/QNTS">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'NumberOfComponents/', $itemURI, '-quantity')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                          <xsl:value-of
							select="'https://w3id.org/arco/core/NumberOfComponents'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:if test="schede/*/OG/QNT/QNTN">
							<xsl:value-of
								select="concat('Quantità degli esemplari del bene ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTN))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTI">
							<xsl:value-of
								select="concat('Quantità degli elementi del bene ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTI))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTS">
							<xsl:value-of
								select="concat('Quantità non rilevata: ', normalize-space(schede/*/OG/QNT/QNTS))" />
						</xsl:if>
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:if test="schede/*/OG/QNT/QNTN">
							<xsl:value-of
								select="concat('Quantità degli esemplari del bene ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTN))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTI">
							<xsl:value-of
								select="concat('Quantità degli elementi del bene ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTI))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTS">
							<xsl:value-of
								select="concat('Quantità non rilevata: ', normalize-space(schede/*/OG/QNT/QNTS))" />
						</xsl:if>
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:if test="schede/*/OG/QNT/QNTN">
							<xsl:value-of
								select="concat('Number of components of cultural property ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTN))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTI">
							<xsl:value-of
								select="concat('Number of components of cultural property ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTI))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTS">
							<xsl:value-of
								select="concat('Undetected quantity: ', normalize-space(schede/*/OG/QNT/QNTS))" />
						</xsl:if>
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:if test="schede/*/OG/QNT/QNTN">
							<xsl:value-of
								select="concat('Number of components of cultural property ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTN))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTI">
							<xsl:value-of
								select="concat('Number of components of cultural property ', $itemURI, ': ', normalize-space(schede/*/OG/QNT/QNTI))" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTS">
							<xsl:value-of
								select="concat('Undetected quantity: ', normalize-space(schede/*/OG/QNT/QNTS))" />
						</xsl:if>
					</l0:name>
					<arco-core:isNumberOfComponentsOf>
						<xsl:attribute name="rdf:resource">
                    		<xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                    	</xsl:attribute>
					</arco-core:isNumberOfComponentsOf>
					<arco-core:numberOfComponents>
						<xsl:if test="schede/*/OG/QNT/QNTN">
							<xsl:value-of select="normalize-space(schede/*/OG/QNT/QNTN)" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTI">
							<xsl:value-of select="normalize-space(schede/*/OG/QNT/QNTI)" />
						</xsl:if>
						<xsl:if test="schede/*/OG/QNT/QNTS">
							<xsl:value-of select="normalize-space(schede/*/OG/QNT/QNTS)" />
						</xsl:if>
					</arco-core:numberOfComponents>
					<xsl:if test="schede/*/OG/QNT/QNTE">
						<arco-core:note>
							<xsl:value-of select="normalize-space(schede/*/OG/QNT/QNTE)" />
						</arco-core:note>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- ERROR, this element has already been created in another section of 
				the sheet <xsl:for-each select="schede/*/OG/OGD"> <rdf:Description> <xsl:attribute 
				name="rdf:about"> <xsl:value-of select="concat('https://w3id.org/arco/resource/DesignationInTime/', 
				arco-fn:urify(normalize-space(./OGDN)))" /> </xsl:attribute> <rdfs:label> 
				<xsl:value-of select="normalize-space(./OGDN)" /> </rdfs:label> <l0:name> 
				<xsl:value-of select="normalize-space(./ODGN)" /> </l0:name> </rdf:Description> 
				</xsl:for-each> -->
			<xsl:for-each select="schede/*/AU/EDT">
				<xsl:if test="./EDTN and (not(starts-with(lower-case(normalize-space(./EDTN)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTN)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                                <xsl:when test="./EDTE and ./EDTL">
                                    <xsl:value-of
							select="concat($NS, 'Edition/', $itemURI, '-', arco-fn:urify(normalize-space(./EDTE)), '-', arco-fn:urify(normalize-space(./EDTL)))" />
                                </xsl:when>
                                <xsl:when test="./EDTE">
                                    <xsl:value-of
							select="concat($NS, 'Edition/', $itemURI, '-', arco-fn:urify(normalize-space(./EDTE)))" />
                                </xsl:when>
                                <xsl:when test="./EDTL">
                                    <xsl:value-of
							select="concat($NS, 'Edition/', $itemURI, '-', arco-fn:urify(normalize-space(./EDTL)))" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
							select="concat($NS, 'Edition/', $itemURI, '-', position())" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Edition'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:choose>
								<xsl:when test="./EDTE and ./EDTL">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTE), '-', normalize-space(./EDTL), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTE">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTE), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTL">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTL), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Edizione ', position(), ' del bene ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:choose>
								<xsl:when test="./EDTE and ./EDTL">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTE), '-', normalize-space(./EDTL), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTE">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTE), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTL">
									<xsl:value-of
										select="concat('Edizione ', normalize-space(./EDTL), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Edizione ', position(), ' del bene ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:choose>
								<xsl:when test="./EDTE and ./EDTL">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTE), '-', normalize-space(./EDTL), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTE">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTE), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTL">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTL), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Edition ', position(), ' of cultural property ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:choose>
								<xsl:when test="./EDTE and ./EDTL">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTE), '-', normalize-space(./EDTL), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTE">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTE), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:when test="./EDTL">
									<xsl:value-of
										select="concat('Edition ', normalize-space(./EDTL), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Edition ', position(), ' of cultural property ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./EDTE and (not(starts-with(lower-case(normalize-space(./EDTE)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTE)), 'n.r')))">
							<arco-cd:editionDate>
								<xsl:value-of select="normalize-space(./EDTE)" />
							</arco-cd:editionDate>
						</xsl:if>
						<xsl:if test="./EDTL and (not(starts-with(lower-case(normalize-space(./EDTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTL)), 'n.r')))">
							<arco-cd:editionLocation>
								<xsl:value-of select="normalize-space(./EDTL)" />
							</arco-cd:editionLocation>
						</xsl:if>
						<roapit:holdsRoleInTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-edition-', position())" />
                            </xsl:attribute>
						</roapit:holdsRoleInTime>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of
							select="concat($NS, 'TimeIndexedRole/', $itemURI, '-edition-', position())" />
                            </xsl:attribute>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/TimeIndexedRole'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:choose>
								<xsl:when test="./EDTR and (not(starts-with(lower-case(normalize-space(./EDTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTR)), 'n.r')))">
									<xsl:value-of
										select="concat(normalize-space(./EDTR), ' del bene ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('Ruolo nel tempo del bene ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:choose>
								<xsl:when test="./EDTR and (not(starts-with(lower-case(normalize-space(./EDTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTR)), 'n.r')))">
									<xsl:value-of
										select="concat(normalize-space(./EDTR), ' of cultural property ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Time indexed role of cultural property ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<xsl:if test="./EDTN">
							<roapit:forAgent>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./EDTN)))" />
                                </xsl:attribute>
							</roapit:forAgent>
						</xsl:if>
						<xsl:if test="./EDTR and (not(starts-with(lower-case(normalize-space(./EDTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTR)), 'n.r')))">
							<roapit:withRole>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Role/', arco-fn:urify(normalize-space(./EDTR)))" />
                                </xsl:attribute>
							</roapit:withRole>
						</xsl:if>
					</rdf:Description>
					<xsl:if test="./EDTR and (not(starts-with(lower-case(normalize-space(./EDTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTR)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'Role/', arco-fn:urify(normalize-space(./EDTR)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./EDTR)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./EDTR)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<xsl:if test="./EDTN">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./EDTN)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./EDTN)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./EDTN)" />
							</l0:name>
							<xsl:if test="./EDTD and (not(starts-with(lower-case(normalize-space(./EDTD)), 'nr')) and not(starts-with(lower-case(normalize-space(./EDTD)), 'n.r')))">
								<arco-cd:agentDate>
									<xsl:value-of select="normalize-space(./EDTD)" />
								</arco-cd:agentDate>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- dating of cultural property -->
			<xsl:for-each select="schede/*/DT">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Dating/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/Dating'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Cronologia ', position(), ' del bene ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Dating ', position(), ' of cultural property ', $itemURI)" />
					</l0:name>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Cronologia ', position(), ' del bene ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Dating ', position(), ' of cultural property ', $itemURI)" />
					</rdfs:label>
					<arco-cd:hasEvent>
						<xsl:choose>
							<xsl:when test="./DTN/DTNS and (not(starts-with(lower-case(normalize-space(./DTN/DTNS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DTN/DTNS)), 'n.r')))">
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Event/', arco-fn:urify(normalize-space(./DTN/DTNS)))" />
                                </xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Event/', $itemURI, '-creation-', position())" />
                                </xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</arco-cd:hasEvent>
					<!-- Source of dating -->
					<xsl:if
						test="./DTM and (not(starts-with(lower-case(normalize-space(./DTM)), 'nr')) and not(starts-with(lower-case(normalize-space(./DTM)), 'n.r')))">
						<arco-cd:hasSource>
							<xsl:choose>
								<xsl:when test="./DTM/DTMS">
									<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./DTM/DTMM)))" />
                                </xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./DTM)))" />
                                </xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- Source of dating as individual -->
				<xsl:if
					test="./DTM and (not(starts-with(lower-case(normalize-space(./DTM)), 'nr')) and not(starts-with(lower-case(normalize-space(./DTM)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                                <xsl:when test="./DTM/DTMS">
                                    <xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./DTM/DTMM)))" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./DTM)))" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./DTM/DTMS">
									<xsl:value-of select="normalize-space(./DTM/DTMM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./DTM)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./DTM/DTMS">
									<xsl:value-of select="normalize-space(./DTM/DTMM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./DTM)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./DTMS">
							<arco-core:specifications>
								<xsl:value-of select="normalize-space(./DTMS)" />
							</arco-core:specifications>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:choose>
                            <xsl:when test="./DTN/DTNS and (not(starts-with(lower-case(normalize-space(./DTN/DTNS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DTN/DTNS)), 'n.r')))">
                                <xsl:value-of
						select="concat($NS, 'Event/', arco-fn:urify(normalize-space(./DTNS)))" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
						select="concat($NS, 'Event/', $itemURI, '-creation-', position())" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Event'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:choose>
							<xsl:when test="./DTN/DTNS">
								<xsl:value-of select="normalize-space(./DTN/DTNS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Realizzazione del bene ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:choose>
							<xsl:when test="./DTN/DTNS">
								<xsl:value-of select="normalize-space(./DTN/DTNS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Realizzazione del bene ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:choose>
							<xsl:when test="./DTN/DTNS">
								<xsl:value-of select="normalize-space(./DTN/DTNS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Creation of cultural property ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:choose>
							<xsl:when test="./DTN/DTNS">
								<xsl:value-of select="normalize-space(./DTN/DTNS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Creation of cultural property ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<xsl:if test="./DTN/DTNN">
						<arco-core:description>
							<xsl:value-of select="normalize-space(./DTN/DTNN)" />
						</arco-core:description>
					</xsl:if>
					<xsl:if test="./DTZ">
						<tiapit:atTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when test="./DTZ/DTZS">
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./DTZ/DTZG)), '-',  arco-fn:urify(normalize-space(./DTZ/DTZS)))" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./DTZ/DTZG)))" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						</tiapit:atTime>
						<xsl:if test="./DTS">
							<xsl:if test="./DTS/DTSI or ./DTS/DTSF">
								<xsl:variable name="startDate">
									<xsl:choose>
										<xsl:when test="./DTS/DTSV">
											<xsl:value-of
												select="concat(normalize-space(./DTS/DTSV), ' ', normalize-space(./DTS/DTSI))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./DTS/DTSI)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="endDate">
									<xsl:choose>
										<xsl:when test="./DTS/DTSL">
											<xsl:value-of
												select="concat(normalize-space(./DTS/DTSL), ' ', normalize-space(./DTS/DTSF))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./DTS/DTSF)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<arco-cd:specificTime>
									<xsl:attribute name="rdf:resource">
		                            	<xsl:value-of
										select="concat($NS, 'TimeInterval/', arco-fn:urify(concat($startDate, '-',  $endDate)))" />
		                        	</xsl:attribute>
								</arco-cd:specificTime>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</rdf:Description>
				<xsl:if test="./DTZ">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                                <xsl:when test="./DTZ/DTZS">
                                    <xsl:value-of
							select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./DTZ/DTZG)), '-',  arco-fn:urify(normalize-space(./DTZ/DTZS)))" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
							select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./DTZ/DTZG)))" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./DTZ/DTZS">
									<xsl:value-of
										select="concat(normalize-space(./DTZ/DTZG), ' ', normalize-space(./DTZ/DTZS))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./DTZ/DTZG)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./DTZ/DTZS">
									<xsl:value-of
										select="concat(normalize-space(./DTZ/DTZG), ' ', normalize-space(./DTZ/DTZS))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./DTZ/DTZG)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<tiapit:time>
							<xsl:choose>
								<xsl:when test="./DTZ/DTZS">
									<xsl:value-of
										select="concat(normalize-space(./DTZ/DTZG), ' ', normalize-space(./DTZ/DTZS))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./DTZ/DTZG)" />
								</xsl:otherwise>
							</xsl:choose>
						</tiapit:time>
						<!-- xsl:if test="./DTS"> <arco-core:startTime> <xsl:choose> <xsl:when 
							test="./DTS/DTSV"> <xsl:value-of select="concat(normalize-space(./DTS/DTSV), 
							' ', normalize-space(./DTS/DTSI))" /> </xsl:when> <xsl:otherwise> <xsl:value-of 
							select="normalize-space(./DTS/DTSI)" /> </xsl:otherwise> </xsl:choose> </arco-core:startTime> 
							<arco-core:endTime> <xsl:choose> <xsl:when test="./DTS/DTSL"> <xsl:value-of 
							select="concat(normalize-space(./DTS/DTSL), ' ', normalize-space(./DTS/DTSF))" 
							/> </xsl:when> <xsl:otherwise> <xsl:value-of select="normalize-space(./DTS/DTSF)" 
							/> </xsl:otherwise> </xsl:choose> </arco-core:endTime> </xsl:if -->
					</rdf:Description>
					<!-- Time intervall with start time and end time -->
					<xsl:if test="./DTS">
						<xsl:if test="./DTS/DTSI or ./DTS/DTSF">
							<xsl:variable name="startDate">
								<xsl:choose>
									<xsl:when test="./DTS/DTSV">
										<xsl:value-of
											select="concat(normalize-space(./DTS/DTSV), ' ', normalize-space(./DTS/DTSI))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./DTS/DTSI)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="endDate">
								<xsl:choose>
									<xsl:when test="./DTS/DTSL">
										<xsl:value-of
											select="concat(normalize-space(./DTS/DTSL), ' ', normalize-space(./DTS/DTSF))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./DTS/DTSF)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
		                            <xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(concat($startDate, '-',  $endDate)))" />
		                        </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
		                                <xsl:value-of
										select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
		                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="concat($startDate, ' - ', $endDate)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="concat($startDate, ' - ', $endDate)" />
								</l0:name>
								<xsl:if test="./DTS">
									<arco-core:startTime>
										<xsl:value-of select="$startDate" />
									</arco-core:startTime>
									<arco-core:endTime>
										<xsl:value-of select="$endDate" />
									</arco-core:endTime>
								</xsl:if>
							</rdf:Description>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- dating of cultural property for A norm-->
			<xsl:for-each select="schede/A/RE">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Dating/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/Dating'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Cronologia ', position(), ' del bene ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Dating ', position(), ' of cultural property ', $itemURI)" />
					</l0:name>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Cronologia ', position(), ' del bene ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Dating ', position(), ' of cultural property ', $itemURI)" />
					</rdfs:label>
					<arco-cd:hasEvent>
						<xsl:choose>
							<xsl:when test="./REN/RENS and (not(starts-with(lower-case(normalize-space(./REN/RENS)), 'nr')) and not(starts-with(lower-case(normalize-space(./REN/RENS)), 'n.r')))">
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Event/', arco-fn:urify(normalize-space(./REN/RENS)))" />
                                </xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Event/', $itemURI, '-creation-', position())" />
                                </xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</arco-cd:hasEvent>
					<!-- Source of dating -->
					<xsl:if
						test="./REN/RENF and (not(starts-with(lower-case(normalize-space(./REN/RENF)), 'nr')) and not(starts-with(lower-case(normalize-space(./REN/RENF)), 'n.r')))">
						<arco-cd:hasSource>
									<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./REN/RENF)))" />
                                </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- Source of dating as individual -->
				<xsl:if
					test="./REN/RENF and (not(starts-with(lower-case(normalize-space(./REN/RENF)), 'nr')) and not(starts-with(lower-case(normalize-space(./REN/RENF)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./REN/RENF)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./REN/RENF)))" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of
										select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./REN/RENF)))" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- event of dating -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:choose>
                            <xsl:when test="./REN/RENS and (not(starts-with(lower-case(normalize-space(./REN/RENS)), 'nr')) and not(starts-with(lower-case(normalize-space(./REN/RENS)), 'n.r')))">
                                <xsl:value-of
						select="concat($NS, 'Event/', arco-fn:urify(normalize-space(./REN/RENS)))" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
						select="concat($NS, 'Event/', $itemURI, '-creation-', position())" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Event'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:choose>
							<xsl:when test="./REN/RENS">
								<xsl:value-of select="normalize-space(./REN/RENS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Realizzazione del bene ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:choose>
							<xsl:when test="./REN/RENS">
								<xsl:value-of select="normalize-space(./REN/RENS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Realizzazione del bene ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:choose>
							<xsl:when test="./REN/RENS">
								<xsl:value-of select="normalize-space(./REN/RENS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Creation of cultural property ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:choose>
							<xsl:when test="./REN/RENS">
								<xsl:value-of select="normalize-space(./REN/RENS)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Creation of cultural property ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<xsl:if test="./REN/RENN">
						<arco-core:description>
							<xsl:value-of select="normalize-space(./REN/RENN)" />
						</arco-core:description>
					</xsl:if>
					<!-- atTime -->
						<tiapit:atTime>
						<xsl:variable name="relv">
							<xsl:choose>
								<xsl:when test="./REL/RELV">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELV)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELW">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELW)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELF">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELF)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revv">
							<xsl:choose>
								<xsl:when test="./REV/REVV">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REV/REVV)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revw">
							<xsl:choose>
								<xsl:when test="./REV/REVW">
									<xsl:value-of
										select="normalize-space(./REV/REVW)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revf">
							<xsl:choose>
								<xsl:when test="./REV/REVF">
									<xsl:value-of
										select="normalize-space(./REV/REVF)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when test="./REV/REVW and ./REV/REVF">
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', $relv, arco-fn:urify(normalize-space(./REL/RELS)), '-', $relw, $revv, arco-fn:urify(normalize-space(./REV/REVS)), arco-fn:urify($revw), '-', arco-fn:urify($revf))" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', $relv, arco-fn:urify(normalize-space(./REL/RELS)), '-', $relw, $revv, arco-fn:urify(normalize-space(./REV/REVS)), arco-fn:urify($revw), arco-fn:urify($revf))" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						</tiapit:atTime>
						<!-- specific time -->
							<xsl:if test="./REV/REVI or ./REL/RELI">
							<xsl:variable name="startDate">
								<xsl:choose>
									<xsl:when test="./REL/RELX">
										<xsl:value-of
											select="concat(normalize-space(./REL/RELI), ' ', normalize-space(./REL/RELX))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./REL/RELI)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="endDate">
								<xsl:choose>
									<xsl:when test="./REV/REVX">
										<xsl:value-of
											select="concat(normalize-space(./REV/REVI), ' ', normalize-space(./REV/REVX))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./REV/REVI)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
								<arco-cd:specificTime>
									<xsl:attribute name="rdf:resource">
		                            	<xsl:value-of
										select="concat($NS, 'TimeInterval/', arco-fn:urify(concat($startDate, '-',  $endDate)))" />
		                        	</xsl:attribute>
								</arco-cd:specificTime>
							</xsl:if>
				</rdf:Description>
				<!-- time interval as an individual -->
					<rdf:Description>
						<xsl:variable name="relv">
							<xsl:choose>
								<xsl:when test="./REL/RELV">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELV)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELW">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELW)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELF">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REL/RELF)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revv">
							<xsl:choose>
								<xsl:when test="./REV/REVV">
									<xsl:value-of
										select="concat(arco-fn:urify(normalize-space(./REV/REVV)), '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revw">
							<xsl:choose>
								<xsl:when test="./REV/REVW">
									<xsl:value-of
										select="normalize-space(./REV/REVW)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revf">
							<xsl:choose>
								<xsl:when test="./REV/REVF">
									<xsl:value-of
										select="normalize-space(./REV/REVF)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
							<xsl:attribute name="rdf:about">
                                <xsl:choose>
                                    <xsl:when test="./REV/REVW and ./REV/REVF">
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', $relv, arco-fn:urify(normalize-space(./REL/RELS)), '-', $relw, $revv, arco-fn:urify(normalize-space(./REV/REVS)), arco-fn:urify($revw), '-', arco-fn:urify($revf))" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($NS, 'TimeInterval/', $relv, arco-fn:urify(normalize-space(./REL/RELS)), '-', $relw, $revv, arco-fn:urify(normalize-space(./REV/REVS)), arco-fn:urify($revw), arco-fn:urify($revf))" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
						<xsl:variable name="relv">
							<xsl:choose>
								<xsl:when test="./REL/RELV">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELW">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELW), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELF">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELF), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revv">
							<xsl:choose>
								<xsl:when test="./REV/REVV">
									<xsl:value-of
										select="concat(normalize-space(./REV/REVV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revw">
							<xsl:choose>
								<xsl:when test="./REV/REVW">
									<xsl:value-of
										select="normalize-space(./REV/REVW)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revf">
							<xsl:choose>
								<xsl:when test="./REV/REVF">
									<xsl:value-of
										select="normalize-space(./REV/REVF)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
							<xsl:choose>
                                    <xsl:when test="./REV/REVW and ./REV/REVF">
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, ' ', $revf)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, $revf)" />
                                    </xsl:otherwise>
                                </xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:variable name="relv">
							<xsl:choose>
								<xsl:when test="./REL/RELV">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELW">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELW), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELF">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELF), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revv">
							<xsl:choose>
								<xsl:when test="./REV/REVV">
									<xsl:value-of
										select="concat(normalize-space(./REV/REVV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revw">
							<xsl:choose>
								<xsl:when test="./REV/REVW">
									<xsl:value-of
										select="normalize-space(./REV/REVW)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revf">
							<xsl:choose>
								<xsl:when test="./REV/REVF">
									<xsl:value-of
										select="normalize-space(./REV/REVF)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
							<xsl:choose>
                                    <xsl:when test="./REV/REVW and ./REV/REVF">
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, ' ', $revf)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, $revf)" />
                                    </xsl:otherwise>
                                </xsl:choose>
						</l0:name>
						<tiapit:time>
							<xsl:variable name="relv">
							<xsl:choose>
								<xsl:when test="./REL/RELV">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELW">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELW), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="relw">
							<xsl:choose>
								<xsl:when test="./REL/RELF">
									<xsl:value-of
										select="concat(normalize-space(./REL/RELF), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revv">
							<xsl:choose>
								<xsl:when test="./REV/REVV">
									<xsl:value-of
										select="concat(normalize-space(./REV/REVV), ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revw">
							<xsl:choose>
								<xsl:when test="./REV/REVW">
									<xsl:value-of
										select="normalize-space(./REV/REVW)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="revf">
							<xsl:choose>
								<xsl:when test="./REV/REVF">
									<xsl:value-of
										select="normalize-space(./REV/REVF)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
							<xsl:choose>
                                    <xsl:when test="./REV/REVW and ./REV/REVF">
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, ' ', $revf)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($relv, normalize-space(./REL/RELS), ' ', $relw, '- ', $revv, normalize-space(./REV/REVS), $revw, $revf)" />
                                    </xsl:otherwise>
                                </xsl:choose>
						</tiapit:time>
					</rdf:Description>
					<!-- Time interval with start time and end time -->
					<xsl:if test="./REV/REVI or ./REL/RELI">
							<xsl:variable name="startDate">
								<xsl:choose>
									<xsl:when test="./REL/RELX">
										<xsl:value-of
											select="concat(normalize-space(./REL/RELI), ' ', normalize-space(./REL/RELX))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./REL/RELI)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="endDate">
								<xsl:choose>
									<xsl:when test="./REV/REVX">
										<xsl:value-of
											select="concat(normalize-space(./REV/REVI), ' ', normalize-space(./REV/REVX))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./REV/REVI)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
		                            <xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(concat($startDate, '-',  $endDate)))" />
		                        </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
		                                <xsl:value-of
										select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
		                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="concat($startDate, ' - ', $endDate)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="concat($startDate, ' - ', $endDate)" />
								</l0:name>
									<arco-core:startTime>
										<xsl:value-of select="$startDate" />
									</arco-core:startTime>
									<arco-core:endTime>
										<xsl:value-of select="$endDate" />
									</arco-core:endTime>
							</rdf:Description>
						</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="schede/*/OG/OGT">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:choose>
                            <xsl:when test="./OGTT">
                                <xsl:value-of
						select="concat($NS, 'CulturalPropertyType/', arco-fn:urify(normalize-space(./OGTD)), '-', arco-fn:urify(normalize-space(./OGTT)))" />
                            </xsl:when>
                            <xsl:when test="./OGTD">
                                <xsl:value-of
						select="concat($NS, 'CulturalPropertyType/', arco-fn:urify(normalize-space(./OGTD)))" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/denotative-description/CulturalPropertyType'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:choose>
							<xsl:when test="./OGTT">
								<xsl:value-of select="concat('Tipo del bene: ', ./OGTD, ' ', ./OGTT)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Tipo del bene: ', ./OGTD)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:choose>
							<xsl:when test="./OGTT">
								<xsl:value-of
									select="concat('Cultural property type: ', ./OGTD, ' ', ./OGTT)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Cultural property type: ', ./OGTD)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:choose>
							<xsl:when test="./OGTT">
								<xsl:value-of select="concat('Tipo del bene: ', ./OGTD, ' ', ./OGTT)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Tipo del bene: ', ./OGTD)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<l0:name xml:lang="en">
						<xsl:choose>
							<xsl:when test="./OGTT">
								<xsl:value-of
									select="concat('Cultural property type: ', ./OGTD, ' ', ./OGTT)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Cultural property type: ', ./OGTD)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<xsl:if
						test="./OGTD and not(lower-case(normalize-space(./OGTD))='nr' or lower-case(normalize-space(./OGTD))='n.r.' or lower-case(normalize-space(./OGTD))='nr (recupero pregresso)')">
						<arco-dd:hasCulturalPropertyDefinition>
							<xsl:attribute name="rdf:resource">
                            <xsl:value-of
								select="concat('https://w3id.org/arco/resource/CulturalPropertyDefinition/', arco-fn:urify(normalize-space(./OGTD)))" />
                        </xsl:attribute>
						</arco-dd:hasCulturalPropertyDefinition>
					</xsl:if>
					<xsl:if
						test="./OGTT and not(lower-case(normalize-space(./OGTT))='nr' or lower-case(normalize-space(./OGTT))='n.r.' or lower-case(normalize-space(./OGTT))='nr (recupero pregresso)')">
						<arco-dd:hasCulturalPropertySpecification>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat('https://w3id.org/arco/resource/CulturalPropertySpecification/', arco-fn:urify(normalize-space(./OGTT)))" />
                            </xsl:attribute>
						</arco-dd:hasCulturalPropertySpecification>
					</xsl:if>
				</rdf:Description>
			</xsl:for-each>
			<!-- We add the definition as an individual. The definition is associated 
				with a Cultural Property Type by the property arco-dd:hasCulturalPropertyDefinition. -->
			<xsl:if
				test="schede/*/OG/OGT/OGTD and not(lower-case(normalize-space(schede/*/OG/OGT/OGTD))='nr' or lower-case(normalize-space(schede/*/OG/OGT/OGTD))='n.r.' or lower-case(normalize-space(schede/*/OG/OGT/OGTD))='nr (recupero pregresso)')">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat('https://w3id.org/arco/resource/CulturalPropertyDefinition/', arco-fn:urify(normalize-space(schede/*/OG/OGT/OGTD)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/denotative-description/CulturalPropertyDefinition'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/OG/OGT/OGTD)" />
					</rdfs:label>
					<xsl:if test="$sheetType='RA'">
						<xsl:variable name="ra-definition" select="arco-fn:ra-definition(normalize-space(schede/*/OG/OGT/OGTD))" />
						<xsl:if test="$ra-definition != ''">
							<skos:closeMatch>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="$ra-definition" />
								</xsl:attribute>
							</skos:closeMatch>
						</xsl:if>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- We add the cultural property specification as an individual. It's 
				associated with a Cultural Property Type by the property arco-dd:hasCulturalPropertySpecification. -->
			<xsl:if
				test="schede/*/OG/OGT/OGTT and not(lower-case(normalize-space(schede/*/OG/OGT/OGTT))='nr' or lower-case(normalize-space(schede/*/OG/OGT/OGTT))='n.r.' or lower-case(normalize-space(schede/*/OG/OGT/OGTT))='nr (recupero pregresso)')">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat('https://w3id.org/arco/resource/CulturalPropertySpecification/', arco-fn:urify(normalize-space(schede/*/OG/OGT/OGTT)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/denotative-description/CulturalPropertySpecification'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/OG/OGT/OGTT)" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- Cataloguing Agency - Agent Role CD/ESC -->
			<xsl:if test="(not(starts-with(lower-case(normalize-space(schede/*/CD/ESC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CD/ESC)), 'n.r')))">
			<xsl:for-each select="schede/*/CD/ESC">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'AgentRole/', $itemURI, '-cataloguing-agency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/core/AgentRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Ente schedatore del bene ', $itemURI, ': ', .)" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Cataloguing agency for cultural property ', $itemURI, ': ', .)" />
					</rdfs:label>
					<arco-core:hasRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/CataloguinAgency')" />
                        </xsl:attribute>
					</arco-core:hasRole>
					<arco-core:hasAgent>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                        </xsl:attribute>
					</arco-core:hasAgent>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/CataloguinAgency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="'Ente schedatore'" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Cataloguing agency'" />
					</rdfs:label>
					<arco-core:isRoleOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-cataloguing-agency')" />
                        </xsl:attribute>
					</arco-core:isRoleOf>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="arco-fn:cataloguing-entity(normalize-space(.))" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="arco-fn:cataloguing-entity(normalize-space(.))" />
					</l0:name>
					<arco-core:isCataloguingAgencyOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                        </xsl:attribute>
					</arco-core:isCataloguingAgencyOf>
					<arco-core:isAgentOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-cataloguing-agency')" />
                        </xsl:attribute>
					</arco-core:isAgentOf>
				</rdf:Description>
			</xsl:for-each>
			</xsl:if>
			<!-- Proponent Agency - Agent Role CD/EPR -->
			<xsl:if test="(not(starts-with(lower-case(normalize-space(schede/*/CD/EPR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CD/EPR)), 'n.r')))">
			<xsl:for-each select="schede/*/CD/EPR">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'AgentRole/', $itemURI, '-proponent-agency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/core/AgentRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Ente proponente del bene ', $itemURI, ': ', .)" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Proponent agency for cultural property ', $itemURI, ': ', .)" />
					</rdfs:label>
					<arco-core:hasRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/ProponentAgency')" />
                        </xsl:attribute>
					</arco-core:hasRole>
					<arco-core:hasAgent>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                        </xsl:attribute>
					</arco-core:hasAgent>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/ProponentAgency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="'Ente proponente'" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Proponent agency'" />
					</rdfs:label>
					<arco-core:isRoleOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-proponent-agency')" />
                        </xsl:attribute>
					</arco-core:isRoleOf>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="arco-fn:cataloguing-entity(normalize-space(.))" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="arco-fn:cataloguing-entity(normalize-space(.))" />
					</l0:name>
					<arco-cd:isProponentAgencyOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                        </xsl:attribute>
					</arco-cd:isProponentAgencyOf>
					<arco-core:isAgentOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-proponent-agency')" />
                        </xsl:attribute>
					</arco-core:isAgentOf>
				</rdf:Description>
			</xsl:for-each>
			</xsl:if>
			<!-- Heritage Protection Agency - Agent Role CD/ECP -->
			<xsl:if test="schede/*/CD/ECP and (not(starts-with(lower-case(normalize-space(schede/*/CD/ECP)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/CD/ECP)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'AgentRole/', $itemURI, '-heritage-protection-agency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/core/AgentRole'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Ente competente per tutela del bene ', $itemURI, ': ', schede/*/CD/ECP)" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Heritage protection agency for cultural property ', $itemURI, ': ', schede/*/CD/ECP)" />
					</rdfs:label>
					<arco-core:hasRole>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Role/HeritageProtectionAgency')" />
                        </xsl:attribute>
					</arco-core:hasRole>
					<arco-core:hasAgent>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CD/ECP)))" />
                        </xsl:attribute>
					</arco-core:hasAgent>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Role/HeritageProtectionAgency')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/RO/Role'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="'Ente competente per tutela'" />
					</rdfs:label>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="'Heritage Protection Agency'" />
					</rdfs:label>
					<arco-core:isRoleOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-heritage-protection-agency')" />
                        </xsl:attribute>
					</arco-core:isRoleOf>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/CD/ECP)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of
							select="arco-fn:cataloguing-entity(normalize-space(schede/*/CD/ECP))" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of
							select="arco-fn:cataloguing-entity(normalize-space(schede/*/CD/ECP))" />
					</l0:name>
					<arco-core:isAgentOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-heritage-protection-agency')" />
                        </xsl:attribute>
					</arco-core:isAgentOf>
					<arco-core:isHeritageProtectionAgencyOf>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                        </xsl:attribute>
					</arco-core:isHeritageProtectionAgencyOf>
				</rdf:Description>
			</xsl:if>
			<!-- Acquisition of cultural property as an individual -->
			<xsl:for-each select="schede/*/TU/ACQ">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'Acquisition/', $itemURI, '-acquisition-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/Acquisition'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Acquisizione ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Acquisizione ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Acquisition ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Acquisition ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./ACQT and (not(starts-with(lower-case(normalize-space(./ACQT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQT)), 'n.r')))">
						<arco-cd:hasAcquisitionType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AcquisitionType/', arco-fn:urify(normalize-space(./ACQT)))" />
            				</xsl:attribute>
						</arco-cd:hasAcquisitionType>
					</xsl:if>
					<xsl:if test="./ACQN and (not(starts-with(lower-case(normalize-space(./ACQN)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQN)), 'n.r')))">
						<arco-cd:hasPreviousOwner>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ACQN)))" />
            				</xsl:attribute>
						</arco-cd:hasPreviousOwner>
					</xsl:if>
					<xsl:if test="./ACQD and (not(starts-with(lower-case(normalize-space(./ACQD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./ACQD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./ACQE">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./ACQE)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./ACQL and (not(starts-with(lower-case(normalize-space(./ACQL)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQL)), 'n.r')))">
						<arco-cd:acquisitionLocation>
							<xsl:value-of select="normalize-space(./ACQL)" />
						</arco-cd:acquisitionLocation>
					</xsl:if>
				</rdf:Description>
				<!-- acquisition type as an individual -->
				<xsl:if test="./ACQT and (not(starts-with(lower-case(normalize-space(./ACQT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQT)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'AcquisitionType/', arco-fn:urify(normalize-space(./ACQT)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/AcquisitionType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ACQT)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ACQT)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- previous owner in acquisition as an individual -->
				<xsl:if test="./ACQN and (not(starts-with(lower-case(normalize-space(./ACQN)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACQN)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ACQN)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ACQN)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ACQN)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Change of availability of cultural property as an individual -->
			<xsl:for-each select="schede/*/TU/ALN">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'ChangeOfAvailability/', $itemURI, '-change-of-availability')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/ChangeOfAvailability'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Mutamento condizione materiale del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Mutamento condizione materiale del bene culturale: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Change of availability of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Change of availability of cultural property: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./ALNT and (not(starts-with(lower-case(normalize-space(./ALNT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ALNT)), 'n.r')))">
						<arco-cd:hasChangeOfAvailabilityType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'ChangeOfAvailabilityType/', arco-fn:urify(normalize-space(./ALNT)))" />
            				</xsl:attribute>
						</arco-cd:hasChangeOfAvailabilityType>
					</xsl:if>
					<xsl:if test="./ALND and (not(starts-with(lower-case(normalize-space(./ALND)), 'nr')) and not(starts-with(lower-case(normalize-space(./ALND)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./ALND)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./ALNN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./ALNN)" />
						</arco-core:note>
					</xsl:if>
				</rdf:Description>
				<!-- acquisition type as an individual -->
				<xsl:if test="./ALNT and (not(starts-with(lower-case(normalize-space(./ALNT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ALNT)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'ChangeOfAvailabilityType/', arco-fn:urify(normalize-space(./ALNT)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/ChangeOfAvailabilityType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ALNT)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ALNT)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Photographic documentation of cultural property as an individual -->
			<xsl:for-each select="schede/*/DO/FTA">
				<xsl:variable name="photodocu-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'PhotographicDocumentation/', $itemURI, '-photographic-documentation-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/PhotographicDocumentation'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Photographic documentation ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Photographic documentation ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Documentazione fotografica ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Documentazione fotografica ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./FTAM and (not(starts-with(lower-case(normalize-space(./FTAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAM)), 'n.r')))">
						<arco-cd:documentationTitle>
							<xsl:value-of select="normalize-space(./FTAM)" />
						</arco-cd:documentationTitle>
					</xsl:if>
					<xsl:if test="./FTAM and (not(starts-with(lower-case(normalize-space(./FTAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAM)), 'n.r')))">
						<arco-cd:caption>
							<xsl:value-of select="normalize-space(./FTAM)" />
						</arco-cd:caption>
					</xsl:if>
					<xsl:if test="./FTAN and (not(starts-with(lower-case(normalize-space(./FTAN)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAN)), 'n.r')))">
						<arco-cd:documentationIdentifier>
							<xsl:value-of select="normalize-space(./FTAN)" />
						</arco-cd:documentationIdentifier>
					</xsl:if>
					<xsl:if test="./FTAD and (not(starts-with(lower-case(normalize-space(./FTAD)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./FTAD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./FTAC and not(./FTAC='N/R') and (not(starts-with(lower-case(normalize-space(./FTAC)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAC)), 'n.r')))">
						<arco-cd:documentationLocation>
							<xsl:value-of select="normalize-space(./FTAC)" />
						</arco-cd:documentationLocation>
					</xsl:if>
					<xsl:if test="./FTAS and (not(starts-with(lower-case(normalize-space(./FTAS)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAS)), 'n.r')))">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(./FTAS)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./FTAK and (not(starts-with(lower-case(normalize-space(./FTAK)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAK)), 'n.r')))">
						<arco-cd:digitalFileName>
							<xsl:value-of select="normalize-space(./FTAK)" />
						</arco-cd:digitalFileName>
					</xsl:if>
					<xsl:if test="./FTAT and (not(starts-with(lower-case(normalize-space(./FTAT)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAT)), 'n.r')))">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./FTAT)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./FTAW and (not(starts-with(lower-case(normalize-space(./FTAW)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./FTAW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./FTAY and (not(starts-with(lower-case(normalize-space(./FTAY)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAY)), 'n.r')))">
						<arco-cd:rights>
							<xsl:value-of select="normalize-space(./FTAY)" />
						</arco-cd:rights>
					</xsl:if>
					<xsl:if test="./FTAR and (not(starts-with(lower-case(normalize-space(./FTAR)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAR)), 'n.r')))">
						<arco-cd:stripRunAndFrameNumber>
							<xsl:value-of select="normalize-space(./FTAR)" />
						</arco-cd:stripRunAndFrameNumber>
					</xsl:if>
					<xsl:if
						test="./FTAX and not(lower-case(normalize-space(./FTAX))='nr' or lower-case(normalize-space(./FTAX))='n.r.' or lower-case(normalize-space(./FTAX))='nr (recupero pregresso)')">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./FTAX))='documentazione esistente'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ExistingDocumentation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./FTAX))='documentazione allegata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AttachedDocumentation'" />
                                    </xsl:when>
                                    <xsl:when test="./FTAX">
                                        <xsl:value-of
								select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./FTAX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./FTAP and (not(starts-with(lower-case(normalize-space(./FTAP)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAP)), 'n.r')))">
						<arco-cd:hasDocumentationType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./FTAP)))" />
            				</xsl:attribute>
						</arco-cd:hasDocumentationType>
					</xsl:if>
					<xsl:if test="./FTAF and (not(starts-with(lower-case(normalize-space(./FTAF)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAF)), 'n.r')))">
						<arco-cd:hasFormat>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./FTAF)))" />
            				</xsl:attribute>
						</arco-cd:hasFormat>
					</xsl:if>
					<xsl:if test="./FTAA and (not(starts-with(lower-case(normalize-space(./FTAA)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAA)), 'n.r')))">
						<arco-cd:hasAuthor>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FTAA)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthor>
					</xsl:if>
					<xsl:if test="./FTAE and (not(starts-with(lower-case(normalize-space(./FTAE)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAE)), 'n.r')))">
						<arco-core:hasAgentRole>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-photographic-documentation-', $photodocu-position, '-photographic-documentation-owner')" />
            				</xsl:attribute>
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- documentation category of photographic documentation as an individual -->
				<xsl:if
					test="./FTAX and not(lower-case(normalize-space(./FTAX))='nr' or lower-case(normalize-space(./FTAX))='n.r.' or lower-case(normalize-space(./FTAX))='nr (recupero pregresso)')">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./FTAX))='documentazione esistente'" />
						<xsl:when
							test="lower-case(normalize-space(./FTAX))='documentazione allegata'" />
						<xsl:when test="./FTAX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./FTAX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/DocumentationCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./FTAX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./FTAX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- documentation type of photographic documentation as an individual -->
				<xsl:if test="./FTAP and (not(starts-with(lower-case(normalize-space(./FTAP)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./FTAP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/DocumentationType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FTAP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FTAP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation format of photographic documentation as an individual -->
				<xsl:if test="./FTAF and (not(starts-with(lower-case(normalize-space(./FTAF)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAF)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./FTAF)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Format'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FTAF)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FTAF)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation author of photographic documentation as an individual -->
				<xsl:if test="./FTAA and (not(starts-with(lower-case(normalize-space(./FTAA)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAA)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FTAA)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FTAA)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FTAA)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent role of photographic documentation as an individual -->
				<xsl:if test="./FTAE and (not(starts-with(lower-case(normalize-space(./FTAE)), 'nr')) and not(starts-with(lower-case(normalize-space(./FTAE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-photographic-documentation-', $photodocu-position, '-photographic-documentation-owner')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione fotografica ', $photodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./FTAE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of photographic documentation ', $photodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./FTAE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione fotografica ', $photodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./FTAE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of photographic documentation ', $photodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./FTAE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/Owner')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FTAE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of select="concat($NS, 'Role/Owner')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proprietario della documentazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Owner of documentation'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-photographic-documentation-', $photodocu-position, '-photographic-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FTAE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FTAE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FTAE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-photographic-documentation-', $photodocu-position, '-photographic-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Graphic or cartographic documentation of cultural property as an 
				individual -->
			<xsl:for-each select="schede/*/DO/DRA">
				<xsl:variable name="cartodocu-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'GraphicOrCartographicDocumentation/', $itemURI, '-graphic-cartographic-documentation-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/GraphicOrCartographicDocumentation'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Graphic or cartographic documentation ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Graphic or cartographic documentation ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Documentazione grafica o cartografica ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Documentazione grafica o cartografica ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./DRAN and (not(starts-with(lower-case(normalize-space(./DRAN)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAN)), 'n.r')))">
						<arco-cd:documentationIdentifier>
							<xsl:value-of select="normalize-space(./DRAN)" />
						</arco-cd:documentationIdentifier>
					</xsl:if>
					<xsl:if test="./DRAD and (not(starts-with(lower-case(normalize-space(./DRAD)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./DRAD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./DRAC and not(./DRAC='N/R') and (not(starts-with(lower-case(normalize-space(./DRAC)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAC)), 'n.r')))">
						<arco-cd:documentationLocation>
							<xsl:value-of select="normalize-space(./DRAC)" />
						</arco-cd:documentationLocation>
					</xsl:if>
					<xsl:if test="./DRAP and (not(starts-with(lower-case(normalize-space(./DRAP)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAP)), 'n.r')))">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(./DRAP)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./DRAK and (not(starts-with(lower-case(normalize-space(./DRAK)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAK)), 'n.r')))">
						<arco-cd:digitalFileName>
							<xsl:value-of select="normalize-space(./DRAK)" />
						</arco-cd:digitalFileName>
					</xsl:if>
					<xsl:if test="./DRAO and (not(starts-with(lower-case(normalize-space(./DRAO)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAO)), 'n.r')))">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./DRAO)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./DRAW">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./DRAW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./DRAY and (not(starts-with(lower-case(normalize-space(./DRAY)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAY)), 'n.r')))">
						<arco-cd:rights>
							<xsl:value-of select="normalize-space(./DRAY)" />
						</arco-cd:rights>
					</xsl:if>
					<xsl:if test="./DRAM and (not(starts-with(lower-case(normalize-space(./DRAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAM)), 'n.r')))">
						<arco-cd:documentationTitle>
							<xsl:value-of select="normalize-space(./DRAM)" />
						</arco-cd:documentationTitle>
					</xsl:if>
					<xsl:if test="./DRAS and (not(starts-with(lower-case(normalize-space(./DRAS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAS)), 'n.r')))">
						<arco-cd:hasScale>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Scale/', arco-fn:urify(normalize-space(./DRAS)))" />
            				</xsl:attribute>
						</arco-cd:hasScale>
					</xsl:if>
					<xsl:if
						test="./DRAX and not(lower-case(normalize-space(./DRAX))='nr' or lower-case(normalize-space(./DRAX))='n.r.' or lower-case(normalize-space(./DRAX))='nr (recupero pregresso)')">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./DRAX))='documentazione esistente'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ExistingDocumentation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./DRAX))='documentazione allegata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AttachedDocumentation'" />
                                    </xsl:when>
                                    <xsl:when test="./DRAX">
                                        <xsl:value-of
								select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./DRAX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./DRAT and (not(starts-with(lower-case(normalize-space(./DRAT)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAT)), 'n.r')))">
						<arco-cd:hasDocumentationType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./DRAT)))" />
            				</xsl:attribute>
						</arco-cd:hasDocumentationType>
					</xsl:if>
					<xsl:if test="./DRAF and (not(starts-with(lower-case(normalize-space(./DRAF)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAF)), 'n.r')))">
						<arco-cd:hasFormat>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./DRAF)))" />
            				</xsl:attribute>
						</arco-cd:hasFormat>
					</xsl:if>
					<xsl:if test="./DRAA and (not(starts-with(lower-case(normalize-space(./DRAA)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAA)), 'n.r')))">
						<arco-cd:hasAuthor>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DRAA)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthor>
					</xsl:if>
					<xsl:if test="./DRAE and (not(starts-with(lower-case(normalize-space(./DRAE)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAE)), 'n.r')))">
						<arco-core:hasAgentRole>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-carto-graphic-documentation-', $cartodocu-position, '-carto-graphic-documentation-owner')" />
            				</xsl:attribute>
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- documentation scale of graphic or cartographic documentation as 
					an individual -->
				<xsl:if test="./DRAS and (not(starts-with(lower-case(normalize-space(./DRAS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAS)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Scale/', arco-fn:urify(normalize-space(./DRAS)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Scale'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./DRAS)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./DRAS)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation category of graphic or cartographic documentation 
					as an individual -->
				<xsl:if
					test="./DRAX and not(lower-case(normalize-space(./DRAX))='nr' or lower-case(normalize-space(./DRAX))='n.r.' or lower-case(normalize-space(./DRAX))='nr (recupero pregresso)')">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./DRAX))='documentazione esistente'" />
						<xsl:when
							test="lower-case(normalize-space(./DRAX))='documentazione allegata'" />
						<xsl:when test="./DRAX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./DRAX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/DocumentationCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./DRAX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./DRAX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- documentation type of graphic and cartographic documentation as 
					an individual -->
				<xsl:if test="./DRAT and (not(starts-with(lower-case(normalize-space(./DRAT)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAT)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./DRAT)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/DocumentationType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./DRAT)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./DRAT)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation format of graphic or cartographic documentation as 
					an individual -->
				<xsl:if test="./DRAF and (not(starts-with(lower-case(normalize-space(./DRAF)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAF)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./DRAF)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Format'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./DRAF)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./DRAF)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation author of photographic documentation as an individual -->
				<xsl:if test="./DRAA and (not(starts-with(lower-case(normalize-space(./DRAA)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAA)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DRAA)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./DRAA)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./DRAA)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent role of graphic or cartographic documentation as an individual -->
				<xsl:if test="./DRAE and (not(starts-with(lower-case(normalize-space(./DRAE)), 'nr')) and not(starts-with(lower-case(normalize-space(./DRAE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-carto-graphic-documentation-', $cartodocu-position, '-carto-graphic-documentation-owner')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione grafica o cartografica ', $cartodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DRAE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of graphic or cartographic documentation ', $cartodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DRAE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione grafica o cartografica ', $cartodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DRAE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of graphic or cartographic documentation ', $cartodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DRAE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/Owner')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DRAE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of select="concat($NS, 'Role/Owner')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proprietario della documentazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Owner of documentation'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-carto-graphic-documentation-', $cartodocu-position, '-carto-graphic-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DRAE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./DRAE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./DRAE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-carto-graphic-documentation-', $cartodocu-position, '-carto-graphic-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Film documentation of cultural property as an individual -->
			<xsl:for-each select="schede/*/DO/VDC">
				<xsl:variable name="filmdocu-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'FilmDocumentation/', $itemURI, '-film-documentation-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/FilmDocumentation'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Film documentation ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Film documentation ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Documentazione video-cinematografica ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Documentazione video-cinematografica ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./VDCN and (not(starts-with(lower-case(normalize-space(./VDCN)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCN)), 'n.r')))">
						<arco-cd:documentationIdentifier>
							<xsl:value-of select="normalize-space(./VDCN)" />
						</arco-cd:documentationIdentifier>
					</xsl:if>
					<xsl:if test="./VDCD and (not(starts-with(lower-case(normalize-space(./VDCD)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./VDCD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./VDCC and not(./VDCC='N/R') and (not(starts-with(lower-case(normalize-space(./VDCC)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCC)), 'n.r')))">
						<arco-cd:documentationLocation>
							<xsl:value-of select="normalize-space(./VDCC)" />
						</arco-cd:documentationLocation>
					</xsl:if>
					<xsl:if test="./VDCS">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(./VDCS)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./VDCK and (not(starts-with(lower-case(normalize-space(./VDCK)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCK)), 'n.r')))">
						<arco-cd:digitalFileName>
							<xsl:value-of select="normalize-space(./VDCK)" />
						</arco-cd:digitalFileName>
					</xsl:if>
					<xsl:if test="./VDCT">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./VDCT)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./VDCW and (not(starts-with(lower-case(normalize-space(./VDCW)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./VDCW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./VDCY and (not(starts-with(lower-case(normalize-space(./VDCY)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCY)), 'n.r')))">
						<arco-cd:rights>
							<xsl:value-of select="normalize-space(./VDCY)" />
						</arco-cd:rights>
					</xsl:if>
					<xsl:if test="./VDCA and (not(starts-with(lower-case(normalize-space(./VDCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCA)), 'n.r')))">
						<arco-cd:documentationTitle>
							<xsl:value-of select="normalize-space(./VDCA)" />
						</arco-cd:documentationTitle>
					</xsl:if>
					<xsl:if
						test="./VDCX and not(lower-case(normalize-space(./VDCX))='nr' or lower-case(normalize-space(./VDCX))='n.r.' or lower-case(normalize-space(./VDCX))='nr (recupero pregresso)')">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./VDCX))='documentazione esistente'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ExistingDocumentation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./VDCX))='documentazione allegata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AttachedDocumentation'" />
                                    </xsl:when>
                                    <xsl:when test="./VDCX">
                                        <xsl:value-of
								select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./VDCX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./VDCP and (not(starts-with(lower-case(normalize-space(./VDCP)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCP)), 'n.r')))">
						<arco-cd:hasDocumentationType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./VDCP)))" />
            				</xsl:attribute>
						</arco-cd:hasDocumentationType>
					</xsl:if>
					<xsl:if test="./VDCP and (not(starts-with(lower-case(normalize-space(./VDCP)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCP)), 'n.r')))">
						<arco-cd:hasFormat>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./VDCP)))" />
            				</xsl:attribute>
						</arco-cd:hasFormat>
					</xsl:if>
					<xsl:if test="./VDCR and (not(starts-with(lower-case(normalize-space(./VDCR)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCR)), 'n.r')))">
						<arco-cd:hasAuthor>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./VDCR)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthor>
					</xsl:if>
					<xsl:if test="./VDCE and (not(starts-with(lower-case(normalize-space(./VDCE)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCE)), 'n.r')))">
						<arco-core:hasAgentRole>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-film-documentation-', $filmdocu-position, '-film-documentation-owner')" />
            				</xsl:attribute>
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- documentation category of graphic or cartographic documentation 
					as an individual -->
				<xsl:if
					test="./VDCX and not(lower-case(normalize-space(./VDCX))='nr' or lower-case(normalize-space(./VDCX))='n.r.' or lower-case(normalize-space(./VDCX))='nr (recupero pregresso)')">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./VDCX))='documentazione esistente'" />
						<xsl:when
							test="lower-case(normalize-space(./VDCX))='documentazione allegata'" />
						<xsl:when test="./VDCX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./VDCX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/DocumentationCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./VDCX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./VDCX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- documentation type of film documentation as an individual - for 
					film documentation type and format are the same resource -->
				<xsl:if test="./VDCP and (not(starts-with(lower-case(normalize-space(./VDCP)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./VDCP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/DocumentationType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./VDCP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./VDCP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation format of film documentation as an individual - for 
					film documentation type and format are the same resource -->
				<xsl:if test="./VDCP and (not(starts-with(lower-case(normalize-space(./VDCP)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./VDCP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Format'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./VDCP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./VDCP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation author of FILM documentation as an individual -->
				<xsl:if test="./VDCR and (not(starts-with(lower-case(normalize-space(./VDCR)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCR)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./VDCR)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./VDCR)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./VDCR)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent role of film documentation as an individual -->
				<xsl:if test="./VDCE and (not(starts-with(lower-case(normalize-space(./VDCE)), 'nr')) and not(starts-with(lower-case(normalize-space(./VDCE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-film-documentation-', $filmdocu-position, '-film-documentation-owner')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione video-cinematografica ', $filmdocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./VDCE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of film documentation ', $filmdocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./VDCE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione video-cinematografica ', $filmdocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./VDCE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of film documentation ', $filmdocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./VDCE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/Owner')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./VDCE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of select="concat($NS, 'Role/Owner')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proprietario della documentazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Owner of documentation'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-film-documentation-', $filmdocu-position, '-film-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./VDCE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./VDCE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./VDCE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-film-documentation-', $filmdocu-position, '-film-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Audio documentation of cultural property as an individual -->
			<xsl:for-each select="schede/*/DO/REG">
				<xsl:variable name="audiodocu-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'AudioDocumentation/', $itemURI, '-audio-documentation-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/AudioDocumentation'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Audio documentation ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Audio documentation ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Documentazione audio ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Documentazione audio ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./REGN and (not(starts-with(lower-case(normalize-space(./REGN)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGN)), 'n.r')))">
						<arco-cd:documentationIdentifier>
							<xsl:value-of select="normalize-space(./REGN)" />
						</arco-cd:documentationIdentifier>
					</xsl:if>
					<xsl:if test="./REGD and (not(starts-with(lower-case(normalize-space(./REGD)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./REGD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./REGC and not(./REGC='N/R') and (not(starts-with(lower-case(normalize-space(./REGC)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGC)), 'n.r')))">
						<arco-cd:documentationLocation>
							<xsl:value-of select="normalize-space(./REGC)" />
						</arco-cd:documentationLocation>
					</xsl:if>
					<xsl:if test="./REGS">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(./REGS)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./REGK and (not(starts-with(lower-case(normalize-space(./REGK)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGK)), 'n.r')))">
						<arco-cd:digitalFileName>
							<xsl:value-of select="normalize-space(./REGK)" />
						</arco-cd:digitalFileName>
					</xsl:if>
					<xsl:if test="./REGT">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./REGT)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./REGW and (not(starts-with(lower-case(normalize-space(./REGW)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./REGW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./REGZ and (not(starts-with(lower-case(normalize-space(./REGZ)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGZ)), 'n.r')))">
						<arco-cd:documentationTitle>
							<xsl:value-of select="normalize-space(./REGZ)" />
						</arco-cd:documentationTitle>
					</xsl:if>
					<xsl:if
						test="./REGX and not(lower-case(normalize-space(./REGX))='nr' or lower-case(normalize-space(./REGX))='n.r.' or lower-case(normalize-space(./REGX))='nr (recupero pregresso)')">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./REGX))='documentazione esistente'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ExistingDocumentation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./REGX))='documentazione allegata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AttachedDocumentation'" />
                                    </xsl:when>
                                    <xsl:when test="./REGX">
                                        <xsl:value-of
								select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./REGX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./REGP and (not(starts-with(lower-case(normalize-space(./REGP)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGP)), 'n.r')))">
						<arco-cd:hasDocumentationType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./REGP)))" />
            				</xsl:attribute>
						</arco-cd:hasDocumentationType>
					</xsl:if>
					<xsl:if test="./REGP and (not(starts-with(lower-case(normalize-space(./REGP)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGP)), 'n.r')))">
						<arco-cd:hasFormat>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./REGP)))" />
            				</xsl:attribute>
						</arco-cd:hasFormat>
					</xsl:if>
					<xsl:if test="./REGA and (not(starts-with(lower-case(normalize-space(./REGA)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGA)), 'n.r')))">
						<arco-cd:hasAuthor>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./REGA)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthor>
					</xsl:if>
					<xsl:if test="./REGE and (not(starts-with(lower-case(normalize-space(./REGE)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGE)), 'n.r')))">
						<arco-core:hasAgentRole>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-audio-documentation-', $audiodocu-position, '-audio-documentation-owner')" />
            				</xsl:attribute>
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- documentation category of audio documentation as an individual -->
				<xsl:if
					test="./REGX and not(lower-case(normalize-space(./REGX))='nr' or lower-case(normalize-space(./REGX))='n.r.' or lower-case(normalize-space(./REGX))='nr (recupero pregresso)')">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./REGX))='documentazione esistente'" />
						<xsl:when
							test="lower-case(normalize-space(./REGX))='documentazione allegata'" />
						<xsl:when test="./REGX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./REGX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/DocumentationCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./REGX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./REGX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- documentation type of audio documentation as an individual - for 
					audio documentation type and format are the same resource -->
				<xsl:if test="./REGP and (not(starts-with(lower-case(normalize-space(./REGP)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./REGP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/DocumentationType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./REGP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./REGP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation format of audio documentation as an individual - for 
					audio documentation type and format are the same resource -->
				<xsl:if test="./REGP and (not(starts-with(lower-case(normalize-space(./REGP)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./REGP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Format'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./REGP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./REGP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation author of audio documentation as an individual -->
				<xsl:if test="./REGA and (not(starts-with(lower-case(normalize-space(./REGA)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGA)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./REGA)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./REGA)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./REGA)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent role of audio documentation as an individual -->
				<xsl:if test="./REGE and (not(starts-with(lower-case(normalize-space(./REGE)), 'nr')) and not(starts-with(lower-case(normalize-space(./REGE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-audio-documentation-', $audiodocu-position, '-audio-documentation-owner')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione audio ', $audiodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./REGE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of audio documentation ', $audiodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./REGE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario della documentazione audio ', $audiodocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./REGE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of audio documentation ', $audiodocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./REGE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/Owner')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./REGE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of select="concat($NS, 'Role/Owner')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proprietario della documentazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Owner of documentation'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-audio-documentation-', $audiodocu-position, '-audio-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./REGE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./REGE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./REGE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-audio-documentation-', $audiodocu-position, '-audio-documentation-owner')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Sources and documents of cultural property as an individual -->
			<xsl:for-each select="schede/*/DO/FNT">
				<xsl:variable name="sourcedocu-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'SourceAndDocument/', $itemURI, '-source-document-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/SourceAndDocument'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Sources and documents ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Sources and documents ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Fonti e documenti ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Fonti e documenti ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./FNTI and (not(starts-with(lower-case(normalize-space(./FNTI)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTI)), 'n.r')))">
						<arco-cd:documentationIdentifier>
							<xsl:value-of select="normalize-space(./FNTI)" />
						</arco-cd:documentationIdentifier>
					</xsl:if>
					<xsl:if test="./FNTD and (not(starts-with(lower-case(normalize-space(./FNTD)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./FNTD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./FNTS and not(./FNTS='-' or ./FNTS='.' or ./FNTS='N/R') and (not(starts-with(lower-case(normalize-space(./FNTS)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTS)), 'n.r')))">
						<arco-cd:documentationLocation>
							<xsl:value-of select="normalize-space(./FNTS)" />
						</arco-cd:documentationLocation>
					</xsl:if>
					<xsl:if test="./FNTF and (not(starts-with(lower-case(normalize-space(./FNTF)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTF)), 'n.r')))">
						<arco-cd:folio>
							<xsl:value-of select="normalize-space(./FNTF)" />
						</arco-cd:folio>
					</xsl:if>
					<xsl:if test="./FNTY and (not(starts-with(lower-case(normalize-space(./FNTY)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTY)), 'n.r')))">
						<arco-cd:rights>
							<xsl:value-of select="normalize-space(./FNTY)" />
						</arco-cd:rights>
					</xsl:if>
					<xsl:if test="./FNTK and (not(starts-with(lower-case(normalize-space(./FNTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTK)), 'n.r')))">
						<arco-cd:digitalFileName>
							<xsl:value-of select="normalize-space(./FNTK)" />
						</arco-cd:digitalFileName>
					</xsl:if>
					<xsl:if test="./FNTO">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./FNTO)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./FNTW and (not(starts-with(lower-case(normalize-space(./FNTW)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./FNTW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./FNTT and (not(starts-with(lower-case(normalize-space(./FNTT)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTT)), 'n.r')))">
						<arco-cd:documentationTitle>
							<xsl:value-of select="normalize-space(./FNTT)" />
						</arco-cd:documentationTitle>
					</xsl:if>
					<xsl:if
						test="./FNTX and (not(starts-with(lower-case(normalize-space(./FNTX)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTX)), 'n.r')))">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./FNTX))='documentazione esistente'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ExistingDocumentation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./FNTX))='documentazione allegata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AttachedDocumentation'" />
                                    </xsl:when>
                                    <xsl:when test="./FNTX">
                                        <xsl:value-of
								select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./FNTX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./FNTP and (not(starts-with(lower-case(normalize-space(./FNTP)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTP)), 'n.r')))">
						<arco-cd:hasDocumentationType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./FNTP)))" />
            				</xsl:attribute>
						</arco-cd:hasDocumentationType>
					</xsl:if>
					<xsl:if test="./FNTR and (not(starts-with(lower-case(normalize-space(./FNTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTR)), 'n.r')))">
						<arco-cd:hasFormat>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./FNTR)))" />
            				</xsl:attribute>
						</arco-cd:hasFormat>
					</xsl:if>
					<xsl:if test="./FNTA and (not(starts-with(lower-case(normalize-space(./FNTA)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTA)), 'n.r')))">
						<arco-cd:hasAuthor>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTA)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthor>
					</xsl:if>
					<xsl:if test="./FNTN and (not(starts-with(lower-case(normalize-space(./FNTN)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTN)), 'n.r')))">
						<arco-cd:hasArchive>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTN)))" />
            				</xsl:attribute>
						</arco-cd:hasArchive>
					</xsl:if>
					<xsl:if test="./FNTE and (not(starts-with(lower-case(normalize-space(./FNTE)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTE)), 'n.r')))">
						<arco-core:hasAgentRole>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-source-document-', $sourcedocu-position, '-source-document-owner')" />
            				</xsl:attribute>
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- documentation category of sources and documents as an individual -->
				<xsl:if
					test="./FNTX and (not(starts-with(lower-case(normalize-space(./FNTX)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTX)), 'n.r')))">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./FNTX))='documentazione esistente'" />
						<xsl:when
							test="lower-case(normalize-space(./FNTX))='documentazione allegata'" />
						<xsl:when test="./FNTX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'DocumentationCategory/', arco-fn:urify(normalize-space(./FNTX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/DocumentationCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./FNTX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./FNTX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- documentation type of sources and documents as an individual -->
				<xsl:if test="./FNTP and (not(starts-with(lower-case(normalize-space(./FNTP)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'DocumentationType/', arco-fn:urify(normalize-space(./FNTP)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/DocumentationType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FNTP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FNTP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation format of sources and documents as an individual -->
				<xsl:if test="./FNTR and (not(starts-with(lower-case(normalize-space(./FNTR)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTR)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Format/', arco-fn:urify(normalize-space(./FNTR)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/Format'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FNTR)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FNTR)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- documentation author of sources and documents as an individual -->
				<xsl:if test="./FNTA and (not(starts-with(lower-case(normalize-space(./FNTA)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTA)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTA)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FNTA)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FNTA)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- archive of sources and documents as an individual -->
				<xsl:if test="./FNTN and (not(starts-with(lower-case(normalize-space(./FNTN)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTN)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTN)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FNTN)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FNTN)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent role of sources and documents as an individual -->
				<xsl:if test="./FNTE and (not(starts-with(lower-case(normalize-space(./FNTE)), 'nr')) and not(starts-with(lower-case(normalize-space(./FNTE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-source-document-', $sourcedocu-position, '-source-document-owner')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario di fonti e documenti ', $sourcedocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./FNTE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of sources and documents ', $sourcedocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./FNTE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proprietario di fonti e documenti ', $sourcedocu-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./FNTE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Owner agency of sources and documents ', $sourcedocu-position, ' of cultural property ', $itemURI, ': ', normalize-space(./FNTE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/Owner')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of select="concat($NS, 'Role/Owner')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proprietario della documentazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Owner of documentation'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-source-document-', $sourcedocu-position, '-source-document-owner')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FNTE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./FNTE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./FNTE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-source-document-', $sourcedocu-position, '-source-document-owner')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Bibliography of cultural property as an individual -->
			<xsl:for-each select="schede/*/DO/BIB">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'Bibliography/', $itemURI, '-bibliography-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/Bibliography'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Bibliography ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Bibliography ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Bibliografia ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Bibliografia ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./BIBH">
						<arco-cd:bibliographyLocalIdentifier>
							<xsl:value-of select="normalize-space(./BIBH)" />
						</arco-cd:bibliographyLocalIdentifier>
					</xsl:if>
					<xsl:if test="./BIBK or ./NCUN and (not(starts-with(lower-case(normalize-space(./BIBK)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBK)), 'n.r')) and not(starts-with(lower-case(normalize-space(./NCUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./NCUN)), 'n.r')))">
						<arco-cd:bibliographyICCDIdentifier>
							<xsl:choose>
								<xsl:when test="./BIBK">
									<xsl:value-of select="normalize-space(./BIBK)" />
								</xsl:when>
								<xsl:when test="./NCUN">
									<xsl:value-of select="normalize-space(./NCUN)" />
								</xsl:when>
							</xsl:choose>
						</arco-cd:bibliographyICCDIdentifier>
					</xsl:if>
					<xsl:if test="./BIBM or ../BIL and (not(starts-with(lower-case(normalize-space(./BIBM)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBM)), 'n.r')) and not(starts-with(lower-case(normalize-space(../BIL)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIL)), 'n.r')))">
						<arco-cd:completeBibliographicReference>
							<xsl:choose>
								<xsl:when test="./BIBM">
									<xsl:value-of select="normalize-space(./BIBM)" />
								</xsl:when>
								<xsl:when test="../BIL">
									<xsl:value-of select="normalize-space(../BIL)" />
								</xsl:when>
							</xsl:choose>
						</arco-cd:completeBibliographicReference>
					</xsl:if>
					<xsl:if test="./BIBR and (not(starts-with(lower-case(normalize-space(./BIBR)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBR)), 'n.r')))">
						<arco-cd:abbreviation>
							<xsl:value-of select="normalize-space(./BIBR)" />
						</arco-cd:abbreviation>
					</xsl:if>
					<xsl:if test="./BIBY and (not(starts-with(lower-case(normalize-space(./BIBY)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBY)), 'n.r')))">
						<arco-cd:rights>
							<xsl:value-of select="normalize-space(./BIBY)" />
						</arco-cd:rights>
					</xsl:if>
					<xsl:if test="./BIBN or ./BIBI">
						<arco-core:note>
							<xsl:choose>
								<xsl:when test="./BIBI">
									<xsl:value-of
										select="concat(normalize-space(./BIBM), normalize-space(./BIBI))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(./BIBN)" />
								</xsl:otherwise>
							</xsl:choose>
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./BIBW">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./BIBW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./BIBJ and (not(starts-with(lower-case(normalize-space(./BIBJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBJ)), 'n.r')))">
						<arco-cd:hasAuthorityFileCataloguingAgency>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./BIBJ)))" />
            				</xsl:attribute>
						</arco-cd:hasAuthorityFileCataloguingAgency>
					</xsl:if>
					<xsl:if
						test="./BIBX and not(lower-case(normalize-space(./BIBX))='nr' or lower-case(normalize-space(./BIBX))='n.r.' or lower-case(normalize-space(./BIBX))='nr (recupero pregresso)')">
						<arco-core:hasCategory>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./BIBX))='bibliografia di corredo'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/AccompanyingBibliography'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./BIBX))='bibliografia di confronto'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ComparativeBibliography'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./BIBX))='bibliografia specifica'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/SpecificBibliography'" />
                                    </xsl:when>
                                    <xsl:when test="./BIBX">
                                        <xsl:value-of
								select="concat($NS, 'BibliographyCategory/', arco-fn:urify(normalize-space(./BIBX)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-core:hasCategory>
					</xsl:if>
					<xsl:if test="./BIBF and (not(starts-with(lower-case(normalize-space(./BIBF)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBF)), 'n.r')))">
						<arco-cd:hasBibliographyType>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'BibliographyType/', arco-fn:urify(normalize-space(./BIBF)))" />
            				</xsl:attribute>
						</arco-cd:hasBibliographyType>
					</xsl:if>
				</rdf:Description>
				<!-- bibliography category as an individual -->
				<xsl:if
					test="./BIBX and not(lower-case(normalize-space(./BIBX))='nr' or lower-case(normalize-space(./BIBX))='n.r.' or lower-case(normalize-space(./BIBX))='nr (recupero pregresso)')">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./BIBX))='bibliografia di corredo'" />
						<xsl:when
							test="lower-case(normalize-space(./BIBX))='bibliografia di confronto'" />
						<xsl:when
							test="lower-case(normalize-space(./BIBX))='bibliografia specifica'" />
						<xsl:when test="./BIBX">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'BibliographyCategory/', arco-fn:urify(normalize-space(./BIBX)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/BibliographyCategory" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./BIBX)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./BIBX)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- bibliography cataloguing agent as an individual -->
				<xsl:if test="./BIBJ and (not(starts-with(lower-case(normalize-space(./BIBJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBJ)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                				<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./BIBJ)))" />
                			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                        		</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./BIBJ)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./BIBJ)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- bibliography type as an individual -->
				<xsl:if test="./BIBF and (not(starts-with(lower-case(normalize-space(./BIBF)), 'nr')) and not(starts-with(lower-case(normalize-space(./BIBF)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            				<xsl:value-of
							select="concat($NS, 'BibliographyType/', arco-fn:urify(normalize-space(./BIBF)))" />
            			</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="'https://w3id.org/arco/context-description/BibliographyType'" />
            				</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./BIBF)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./BIBF)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Legal situation of cultural property as an individual -->
			<xsl:if test="schede/*/TU/CDG">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                		<xsl:value-of
						select="concat($NS, 'LegalSituation/', $itemURI, '-legal-situation-', arco-fn:urify(normalize-space(schede/*/TU/CDG/CDGG)))" />
                	</xsl:attribute>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Condizione giuridica del bene culturale ', $itemURI, ': ', normalize-space(schede/*/TU/CDG/CDGG))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Condizione giuridica del bene culturale ', $itemURI, ': ', normalize-space(schede/*/TU/CDG/CDGG))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Legal situation of cultural property ', $itemURI, ': ', normalize-space(schede/*/TU/CDG/CDGG))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Legal situation of cultural property ', $itemURI, ': ', normalize-space(schede/*/TU/CDG/CDGG))" />
					</l0:name>
					<rdf:type>
						<xsl:value-of
							select="'https://w3id.org/arco/context-description/LegalSituation'" />
					</rdf:type>
					<xsl:if test="schede/*/TU/CDG/CDGN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(schede/*/TU/CDG/CDGN)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="schede/*/TU/CDG/CDGS and (not(starts-with(lower-case(normalize-space(schede/*/TU/CDG/CDGS)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/TU/CDG/CDGS)), 'n.r')))">
						<arco-cd:hasOwner>
							<xsl:attribute name="rdf:resource">
	            				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/TU/CDG/CDGS)))" />
	            			</xsl:attribute>
						</arco-cd:hasOwner>
					</xsl:if>
				</rdf:Description>
				<xsl:if test="schede/*/TU/CDG/CDGS and (not(starts-with(lower-case(normalize-space(schede/*/TU/CDG/CDGS)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/TU/CDG/CDGS)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	            			<xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(schede/*/TU/CDG/CDGS)))" />
	            		</xsl:attribute>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/TU/CDG/CDGS)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/TU/CDG/CDGS)" />
						</l0:name>
						<rdf:type>
							<xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
						</rdf:type>
						<xsl:if test="schede/*/TU/CDG/CDGI ">
							<arco-cd:address>
								<xsl:value-of select="normalize-space(schede/*/TU/CDG/CDGI)" />
							</arco-cd:address>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
			</xsl:if>
			<!-- Export import certification of cultural property as an individual -->
			<xsl:for-each select="schede/*/TU/ESP">
				<xsl:variable name="exp-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                		<xsl:value-of
						select="concat($NS, 'ExportImportCertification/', $itemURI, '-export-import-certification-', position())" />
                	</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
						<xsl:value-of
							select="'https://w3id.org/arco/context-description/ExportImportCertification'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:choose>
							<xsl:when test="./ESPT">
								<xsl:value-of
									select="concat(normalize-space(./ESPT), ' ', position(), ' del bene culturale ', $itemURI)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Certificazione ', position(), ' per la circolazione del bene culturale ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:choose>
							<xsl:when test="./ESPT and (not(starts-with(lower-case(normalize-space(./ESPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPT)), 'n.r')))">
								<xsl:value-of
									select="concat(normalize-space(./ESPT), ' ', position(), ' del bene culturale ', $itemURI)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat('Certificazione ', position(), ' per la circolazione del bene culturale ', $itemURI)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Certification ', position(), ' for import and export of cultural property ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Certification ', position(), ' for import and export of cultural property ', $itemURI)" />
					</l0:name>
					<xsl:if test="./ESPD and (not(starts-with(lower-case(normalize-space(./ESPD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPD)), 'n.r')))">
						<arco-cd:issueDate>
							<xsl:value-of select="normalize-space(./ESPD)" />
						</arco-cd:issueDate>
					</xsl:if>
					<xsl:if test="./ESPN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./ESPN)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./ESPT">
						<arco-cd:hasExportImportCertificationType>
							<xsl:attribute name="rdf:resource">
	                				<xsl:if
								test="./ESPT and not(./ESPT='.' or ./ESPT='-' or ./ESPT='/') and (not(starts-with(lower-case(normalize-space(./ESPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPT)), 'n.r')))">
	                                <xsl:choose>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='attestato di libera circolazione' or lower-case(normalize-space(./ESPT))='attestato libera circolazione'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/FreeMovementCertification'" />
	                                    </xsl:when>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='attestato di circolazione temporanea' or lower-case(normalize-space(./ESPT))='attestato circolazione temporanea'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/TemporaryMovementCertification'" />
	                                    </xsl:when>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='licenza di esportazione definitiva' or lower-case(normalize-space(./ESPT))='licenza esportazione definitiva'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/PermanentExportLicense'" />
	                                    </xsl:when>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='licenza di esportazione temporanea' or lower-case(normalize-space(./ESPT))='licenza esportazione temporanea'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/TemporaryExportLicense'" />
	                                    </xsl:when>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='certificato di avvenuta spedizione' or lower-case(normalize-space(./ESPT))='certificato avvenuta spedizione'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/DeliveryConfirmationCertification'" />
	                                    </xsl:when>
	                                    <xsl:when
								test="lower-case(normalize-space(./ESPT))='certificato di avvenuta importazione' or lower-case(normalize-space(./ESPT))='certificato avvenuta importazione'">
	                                        <xsl:value-of
								select="'https://w3id.org/arco/context-description/ImportConfirmationCertification'" />
	                                    </xsl:when>
	                                    <xsl:when test="./ESPT">
	                                        <xsl:value-of
								select="concat($NS, 'ExportImportCertificationType/', arco-fn:urify(normalize-space(./ESPT)))" />
	                                    </xsl:when>
	                                </xsl:choose>
                    			</xsl:if>
	                			</xsl:attribute>
						</arco-cd:hasExportImportCertificationType>
					</xsl:if>
					<xsl:if test="./ESPU and (not(starts-with(lower-case(normalize-space(./ESPU)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPU)), 'n.r')))">
						<arco-cd:hasExportOffice>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ESPU)))" />
	                			</xsl:attribute>
						</arco-cd:hasExportOffice>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-export-import-certification-', $exp-position, '-export-office')" />
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- export import certification type as an individual -->
				<xsl:if test="./ESPT">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='attestato di libera circolazione' or lower-case(normalize-space(./ESPT))='attestato libera circolazione'" />
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='attestato di circolazione temporanea' or lower-case(normalize-space(./ESPT))='attestato circolazione temporanea'" />
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='licenza di esportazione definitiva' or lower-case(normalize-space(./ESPT))='licenza esportazione definitiva'" />
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='licenza di esportazione temporanea' or lower-case(normalize-space(./ESPT))='licenza esportazione temporanea'" />
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='certificato di avvenuta spedizione' or lower-case(normalize-space(./ESPT))='certificato avvenuta spedizione'" />
						<xsl:when
							test="lower-case(normalize-space(./ESPT))='certificato di avvenuta importazione' or lower-case(normalize-space(./ESPT))='certificato avvenuta importazione'" />
						<xsl:when test="./ESPT and not(./ESPT='.' or ./ESPT='-' or ./ESPT='/') and (not(starts-with(lower-case(normalize-space(./ESPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPT)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'ExportImportCertificationType/', arco-fn:urify(normalize-space(./ESPT)))" />
                                </xsl:attribute>
								<rdf:type
									rdf:resource="https://w3id.org/arco/context-description/ExportImportCertificationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./ESPT)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./ESPT)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- agent role of export import certification as an individual -->
				<xsl:if test="./ESPU and (not(starts-with(lower-case(normalize-space(./ESPU)), 'nr')) and not(starts-with(lower-case(normalize-space(./ESPU)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-export-import-certification-', $exp-position, '-export-office')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ufficio Esportazione della certificazione ', $exp-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./ESPU))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Export Office of certification ', $exp-position, ' of cultural property ', $itemURI, ': ', normalize-space(./ESPU))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ufficio Esportazione della certificazione ', $exp-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./ESPU))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Export Office of certification ', $exp-position, ' of cultural property ', $itemURI, ': ', normalize-space(./ESPU))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/ExportOffice')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ESPU)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Role/ExportOffice')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ufficio Esportazione'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Export Office'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-export-import-certification-', $exp-position, '-export-office')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ESPU)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ESPU)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ESPU)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-export-import-certification-', $exp-position, '-export-office')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Protective measures of cultural property as an individual -->
			<xsl:for-each select="schede/*/TU/NVC">
				<xsl:variable name="measure-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                			<xsl:value-of
						select="concat($NS, 'ProtectiveMeasure/', $itemURI, '-protective-measure-', position())" />
                		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of
							select="'https://w3id.org/arco/context-description/ProtectiveMeasure'" />
					</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Protective measure ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./NVCT))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Protective measure ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./NVCT))" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Provvedimento di tutela ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./NVCT))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Provvedimento di tutela ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./NVCT))" />
					</l0:name>
					<xsl:if test="./NVCE and (not(starts-with(lower-case(normalize-space(./NVCE)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCE)), 'n.r')))">
						<arco-cd:issueDate>
							<xsl:value-of select="normalize-space(./NVCE)" />
						</arco-cd:issueDate>
					</xsl:if>
					<xsl:if test="./NVCR and (not(starts-with(lower-case(normalize-space(./NVCR)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCR)), 'n.r')))">
						<arco-cd:registrationDateOrGU>
							<xsl:value-of select="normalize-space(./NVCR)" />
						</arco-cd:registrationDateOrGU>
					</xsl:if>
					<xsl:if test="./NVCI and (not(starts-with(lower-case(normalize-space(./NVCI)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCI)), 'n.r')))">
						<arco-cd:openingNoticeDate>
							<xsl:value-of select="normalize-space(./NVCI)" />
						</arco-cd:openingNoticeDate>
					</xsl:if>
					<xsl:if test="./NVCD and (not(starts-with(lower-case(normalize-space(./NVCD)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCD)), 'n.r')))">
						<arco-cd:noticeDate>
							<xsl:value-of select="normalize-space(./NVCD)" />
						</arco-cd:noticeDate>
					</xsl:if>
					<xsl:if test="./NVCW and (not(starts-with(lower-case(normalize-space(./NVCW)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./NVCW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./NVCN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./NVCN)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./NVCA and (not(starts-with(lower-case(normalize-space(./NVCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCA)), 'n.r')))">
						<arco-cd:hasProponentAgency>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./NVCA)))" />
	                			</xsl:attribute>
						</arco-cd:hasProponentAgency>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-protective-meausure-', $measure-position, '-proponent-agency')" />
						</arco-core:hasAgentRole>
					</xsl:if>
				</rdf:Description>
				<!-- agent role for protective measure as an individual -->
				<xsl:if test="./NVCA and (not(starts-with(lower-case(normalize-space(./NVCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./NVCA)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-protective-meausure-', $measure-position, '-proponent-agency')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente proponente del provvedimento di tutela ', $measure-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./NVCA))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Proponent agency of protective measure ', $measure-position, ' of cultural property ', $itemURI, ': ', normalize-space(./NVCA))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente proponente del provvedimento di tutela ', $measure-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./NVCA))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Proponent agency of protective measure ', $measure-position, ' of cultural property ', $itemURI, ': ', normalize-space(./NVCA))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/ProponentAgency')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./NVCA)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Role/ProponentAgency')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente proponente'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Proponent Agency'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-protective-meausure-', $measure-position, '-proponent-agency')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./NVCA)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./NVCA)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./NVCA)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-protective-meausure-', $measure-position, '-proponent-agency')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Urban planning instrument of culturale property as an individual -->
			<xsl:for-each select="schede/*/TU/STU">
				<xsl:variable name="upinstrument-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                			<xsl:value-of
						select="concat($NS, 'UrbanPlanningInstrument/', $itemURI, '-urban-planning-instrument-', position())" />
                		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of
							select="'https://w3id.org/arco/context-description/UrbanPlanningInstrument'" />
					</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Urban planning instrument ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./STUT))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Urban planning instrument ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./STUT))" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Strumento urbanistico-territoriale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./STUT))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Strumento urbanistico-territoriale ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./STUT))" />
					</l0:name>
					<xsl:if test="./STUW and (not(starts-with(lower-case(normalize-space(./STUW)), 'nr')) and not(starts-with(lower-case(normalize-space(./STUW)), 'n.r')))">
						<smapit:URL>
							<xsl:value-of select="normalize-space(./STUW)" />
						</smapit:URL>
					</xsl:if>
					<xsl:if test="./STUS">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./STUS)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./STUE and (not(starts-with(lower-case(normalize-space(./STUE)), 'nr')) and not(starts-with(lower-case(normalize-space(./STUE)), 'n.r')))">
						<arco-cd:hasIssuingAgency>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./STUE)))" />
	                			</xsl:attribute>
						</arco-cd:hasIssuingAgency>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-urban-planning-instrument-', $upinstrument-position, '-issuing-agency')" />
						</arco-core:hasAgentRole>
					</xsl:if>
					<xsl:if test="./STUN and (not(starts-with(lower-case(normalize-space(./STUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./STUN)), 'n.r')))">
						<arco-cd:hasEligibleIntervention>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'EligibleIntervention/', arco-fn:urify(normalize-space(./STUN)))" />
	                			</xsl:attribute>
						</arco-cd:hasEligibleIntervention>
					</xsl:if>
				</rdf:Description>
				<!-- agent role for urban planning instrument as an individual -->
				<xsl:if test="./STUE and (not(starts-with(lower-case(normalize-space(./STUE)), 'nr')) and not(starts-with(lower-case(normalize-space(./STUE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
							select="concat($NS, 'AgentRole/', $itemURI, '-urban-planning-instrument-', $upinstrument-position, '-issuing-agency')" />
		                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Ente che ha emanato il provvedimento ', $upinstrument-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./STUE))" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Issuing agency of urban planning instrument ', $upinstrument-position, ' of cultural property ', $itemURI, ': ', normalize-space(./STUE))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Ente che ha emanato il provvedimento ', $upinstrument-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./STUE))" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Issuing agency of urban planning instrument ', $upinstrument-position, ' of cultural property ', $itemURI, ': ', normalize-space(./STUE))" />
						</l0:name>
						<arco-core:hasRole>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Role/IssuingAgency')" />
				                        </xsl:attribute>
						</arco-core:hasRole>
						<arco-core:hasAgent>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./STUE)))" />
				                        </xsl:attribute>
						</arco-core:hasAgent>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Role/IssuingAgency')" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente che ha emanato il provvedimento'" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Issuing Agency'" />
						</rdfs:label>
						<arco-core:isRoleOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-urban-planning-instrument-', $upinstrument-position, '-issuing-agency')" />
				                        </xsl:attribute>
						</arco-core:isRoleOf>
					</rdf:Description>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
				                        <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./STUE)))" />
				                    </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./STUE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./STUE)" />
						</l0:name>
						<arco-core:isAgentOf>
							<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-urban-planning-instrument-', $upinstrument-position, '-issuing-agency')" />
				                        </xsl:attribute>
						</arco-core:isAgentOf>
					</rdf:Description>
				</xsl:if>
				<!-- eligible intervention of u.p.instrument as an individual -->
				<xsl:if test="./STUN and (not(starts-with(lower-case(normalize-space(./STUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./STUN)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
			                			<xsl:value-of
							select="concat($NS, 'EligibleIntervention/', arco-fn:urify(normalize-space(./STUN)))" />
									</xsl:attribute>
						<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/context-description/EligibleIntervention'" />
						</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./STUN)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./STUN)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Other related agents of cultural property as an individual -->
			<xsl:for-each select="schede/*/AU/NMC">
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/*/AU/NMC/NMCN)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/AU/NMC/NMCN)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                			<xsl:choose>
                				<xsl:when test="./NMCA">
                					<xsl:value-of
						select="concat($NS, 'RelatedAgent/', $itemURI, '-', arco-fn:urify(normalize-space(./NMCN)), '-', arco-fn:urify(normalize-space(./NMCA)))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of
						select="concat($NS, 'RelatedAgent/', $itemURI, '-', arco-fn:urify(normalize-space(./NMCN)))" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/context-description/RelatedAgent'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Related agent ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./NMCN))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Related agent ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./NMCN))" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Agente correlato ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./NMCN))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Agente correlato ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(./NMCN))" />
					</l0:name>
					<xsl:if test="./NMCA and (not(starts-with(lower-case(normalize-space(./NMCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./NMCA)), 'n.r')))">
						<arco-cd:agentDate>
							<xsl:value-of select="normalize-space(./NMCA)" />
						</arco-cd:agentDate>
					</xsl:if>
					<xsl:if test="./NMCY">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./NMCY)" />
						</arco-core:note>
					</xsl:if>
				</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Surveys -->
                <!-- Archaeological field survey of cultural property -->
                <xsl:if test="not(schede/*/RE/RCG/RCGD='0000/00/00' or schede/*/RE/RCG/RCGD='/') and schede/*/RE/RCG/*">
                <xsl:for-each select="schede/*/RE/RCG">
	                <xsl:variable name="survey-position">
						<xsl:value-of select="position()" />
					</xsl:variable>
                	<rdf:Description>
                		<xsl:attribute name="rdf:about">
                			<xsl:value-of select="concat($NS, 'ArchaeologicalFieldSurvey/', $itemURI, '-survey-', position())" />
                		</xsl:attribute>
                		<rdf:type>
                			<xsl:attribute name="rdf:resource">
                			<xsl:value-of select="'https://w3id.org/arco/context-description/ArchaeologicalFieldSurvey'" />
                		</xsl:attribute>
                		</rdf:type>
                		<rdfs:label xml:lang="it">
                			<xsl:choose>
                				<xsl:when test="./RCGV and (not(starts-with(lower-case(normalize-space(./RCGV)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGV)), 'n.r')))">
                					<xsl:value-of select="concat('Ricognizione archeologica ', position(), ' sul bene ', $itemURI, ': ', normalize-space(./RCGV))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Ricognizione archeologica ' , position(), ' sul bene ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</rdfs:label>
                		<l0:name xml:lang="it">
                			<xsl:choose>
                				<xsl:when test="./RCGV and (not(starts-with(lower-case(normalize-space(./RCGV)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGV)), 'n.r')))">
                					<xsl:value-of select="concat('Ricognizione archeologica ', position(), ' sul bene ', $itemURI, ': ', normalize-space(./RCGV))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Ricognizione archeologica ' , position(), ' sul bene ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</l0:name>
                		<rdfs:label xml:lang="en">
                			<xsl:choose>
                				<xsl:when test="./RCGV and (not(starts-with(lower-case(normalize-space(./RCGV)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGV)), 'n.r')))">
                					<xsl:value-of select="concat('Archaeological field survey ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./RCGV))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Archaeological field survey ' , position(), ' of cultural property ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</rdfs:label>
                		<l0:name xml:lang="en">
                			<xsl:choose>
                				<xsl:when test="./RCGV and (not(starts-with(lower-case(normalize-space(./RCGV)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGV)), 'n.r')))">
                					<xsl:value-of select="concat('Ricognizione archeologica ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./RCGV))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Ricognizione archeologica ' , position(), ' of cultural property ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</l0:name>
                		<xsl:if test="./RCGZ">
                			<arco-core:note>
                				<xsl:value-of select="normalize-space(./RCGZ)" />
                			</arco-core:note>
                		</xsl:if>
                		<xsl:if test="./RCGD and (not(starts-with(lower-case(normalize-space(./RCGD)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGD)), 'n.r')))">
                			<tiapit:time>
                				<xsl:value-of select="normalize-space(./RCGD)" />
                			</tiapit:time>
                		</xsl:if>
                		<xsl:if test="./RCGK and (not(starts-with(lower-case(normalize-space(./RCGK)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGK)), 'n.r')))">
                			<arco-cd:archeologicalFieldSurveyICCDIdentifier>
                				<xsl:value-of select="normalize-space(./RCGK)" />
                			</arco-cd:archeologicalFieldSurveyICCDIdentifier>
                		</xsl:if>
                		<xsl:if test="./NCUN and (not(starts-with(lower-case(normalize-space(./NCUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./NCUN)), 'n.r')))">
                			<arco-cd:archeologicalFieldSurveyICCDIdentifier>
                				<xsl:value-of select="normalize-space(./NCUN)" />
                			</arco-cd:archeologicalFieldSurveyICCDIdentifier>
                		</xsl:if>
                		<xsl:if test="./RCGH and (not(starts-with(lower-case(normalize-space(./RCGH)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGH)), 'n.r')))">
                			<arco-cd:archeologicalFielSurveyLocalIdentifier>
                				<xsl:value-of select="normalize-space(./RCGH)" />
                			</arco-cd:archeologicalFielSurveyLocalIdentifier>
                		</xsl:if>
                		<xsl:if test="./RCGU or ./RCGT or ./RCGC">
                			<arco-cd:environmentalState>
                				<xsl:choose>
                					<xsl:when test="./RCGT">
                						<xsl:value-of select="normalize-space(./RCGT)" />
                					</xsl:when>
                					<xsl:when test="./RCGU and ./RCGC">
                						<xsl:value-of select="concat(normalize-space(./RCGU), ' - ', normalize-space(./RCGC))" />
                					</xsl:when>
                					<xsl:otherwise>
                						<xsl:value-of select="concat(normalize-space(./RCGC), normalize-space(./RCGU))" />
                					</xsl:otherwise>
                				</xsl:choose>
                			</arco-cd:environmentalState>
                		</xsl:if>
                		<xsl:if test="./RCGS and (not(starts-with(lower-case(normalize-space(./RCGS)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGS)), 'n.r')))">
                			<arco-cd:hasBibliography>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Bibliography/', $itemURI, '-archaeological-field-survey-bibliography-', position())" />
	                		</xsl:attribute>
                			</arco-cd:hasBibliography>
                		</xsl:if>
                		<xsl:if test="./RCGM and (not(starts-with(lower-case(normalize-space(./RCGM)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGM)), 'n.r')))">
                			<arco-cd:hasMethod>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Method/', arco-fn:urify(normalize-space(./RCGM)))" />
	                		</xsl:attribute>
                			</arco-cd:hasMethod>
                		</xsl:if>
                		<xsl:if test="./RCGA and (not(starts-with(lower-case(normalize-space(./RCGA)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGA)), 'n.r')))">
						<arco-cd:hasSurveyScientificDirector>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGA)))" />
	                			</xsl:attribute>
						</arco-cd:hasSurveyScientificDirector>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-scientific-director')" />
						</arco-core:hasAgentRole>
					</xsl:if>
					<xsl:if test="./RCGR and (not(starts-with(lower-case(normalize-space(./RCGR)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGR)), 'n.r')))">
						<arco-cd:hasActivityResponsible>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGR)))" />
	                			</xsl:attribute>
						</arco-cd:hasActivityResponsible>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-activity-responsible')" />
						</arco-core:hasAgentRole>
					</xsl:if>
					<xsl:if test="./RCGJ and (not(starts-with(lower-case(normalize-space(./RCGJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGJ)), 'n.r')))">
						<arco-cd:hasAuthorityFileCataloguingAgency>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGJ)))" />
	                			</xsl:attribute>
						</arco-cd:hasAuthorityFileCataloguingAgency>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-cataloguing-agency')" />
						</arco-core:hasAgentRole>
					</xsl:if>
                	</rdf:Description>
                	<!-- bibliography of survey as an individual -->
                	<xsl:if test="./RCGS and (not(starts-with(lower-case(normalize-space(./RCGS)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGS)), 'n.r')))">
                			<rdf:Description>
                				<xsl:attribute name="rdf:about">
		                			<xsl:value-of
								select="concat($NS, 'Bibliography/', $itemURI, '-archaeological-field-survey-bibliography-', position())" />
	                		</xsl:attribute>
	                		<rdf:type>
	                			<xsl:attribute name="rdf:resource">
	                				<xsl:value-of select="'https://w3id.org.arco/context-description/Bibliography'" />
	                			</xsl:attribute>
	                		</rdf:type>
	                		<rdfs:label xml:lang="it">
	                			<xsl:value-of select="concat('Bibliografia relativa alla ricognizione archeologica sul bene ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="it">
	                			<xsl:value-of select="concat('Bibliografia relativa alla ricognizione archeologica sul bene ', $itemURI)" />
	                		</l0:name>
	                		<rdfs:label xml:lang="en">
	                			<xsl:value-of select="concat('Bibliography about archaeological field survey of cultural property ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="en">
	                			<xsl:value-of select="concat('Bibliography about archaeological field survey of cultural property ', $itemURI)" />
	                		</l0:name>
	                		<arco-cd:completeBibliographicReference>
	                			<xsl:value-of select="normalize-space(./RCGS)" />
	                		</arco-cd:completeBibliographicReference>
                		</rdf:Description>
                	</xsl:if>
                	<!-- method of survey as an individual -->
                	<xsl:if test="./RCGM and (not(starts-with(lower-case(normalize-space(./RCGM)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGM)), 'n.r')))">
                		<rdf:Description>
                			<xsl:attribute name="rdf:about">
	                			<xsl:value-of
							select="concat($NS, 'Method/', arco-fn:urify(normalize-space(./RCGM)))" />
	                		</xsl:attribute>
	                		<rdfs:label>
	                			<xsl:value-of select="normalize-space(./RCGM)" />
	                		</rdfs:label>
	                		<l0:name>
	                			<xsl:value-of select="normalize-space(./RCGM)" />
	                		</l0:name>
                		</rdf:Description>
                	</xsl:if>
                	<!-- agent role of survey scientific director as an individual -->
					<xsl:if test="./RCGA and (not(starts-with(lower-case(normalize-space(./RCGA)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGA)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-scientific-director')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Responsabile scientifico della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGA))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Responsabile scientifico della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGA))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Scientific director of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGA))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Scientific director of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGA))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/ScientificDirector')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGA)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/ScientificDirector')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile Scientifico'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Scientific Director'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-scientific-director')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGA)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./RCGA)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./RCGA)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-scientific-director')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
					<!-- agent role of activity responsible as an individual -->
					<xsl:if test="./RCGR and (not(starts-with(lower-case(normalize-space(./RCGR)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGR)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-activity-responsible')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGR))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGR))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGR))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGR))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/ActivityResponsible')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGR)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/ActivityResponsible')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile dell''attività'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Activity Responsible'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGR)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./RCGR)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./RCGR)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
					<!-- agent role of authority file cataloguing agency as an individual -->
					<xsl:if test="./RCGJ and (not(starts-with(lower-case(normalize-space(./RCGJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./RCGJ)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-cataloguing-agency')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente schedatore dell''Authority File della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGJ))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente schedatore dell''Authority File della ricognizione archeologica ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./RCGJ))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Authority File cataloguing agency of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGJ))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Authority File cataloguing agency of archaeological field survey ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./RCGJ))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/AuthorityFileCataloguingAgency')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGJ)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/AuthorityFileCataloguingAgency')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Ente Schedatore dell''Authority File'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Authority File Cataloguing Agency'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-cataloguing-agency')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./RCGJ)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./RCGJ)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./RCGJ)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-field-survey-', $survey-position, '-cataloguing-agency')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
                </xsl:for-each>
               </xsl:if>
               <!-- Archaeological excavation of cultural property -->
                <xsl:if test="not(schede/*/RE/DSC/DSCD='0000/00/00' or schede/*/RE/DSC/DSCD='/') and schede/*/RE/DSC/*">
                <xsl:for-each select="schede/*/RE/DSC">
	                <xsl:variable name="survey-position">
						<xsl:value-of select="position()" />
					</xsl:variable>
                	<rdf:Description>
                		<xsl:attribute name="rdf:about">
                			<xsl:value-of select="concat($NS, 'ArchaeologicalExcavation/', $itemURI, '-survey-', position())" />
                		</xsl:attribute>
                		<rdf:type>
                			<xsl:attribute name="rdf:resource">
                			<xsl:value-of select="'https://w3id.org/arco/context-description/ArchaeologicalExcavation'" />
                		</xsl:attribute>
                		</rdf:type>
                		<rdfs:label xml:lang="it">
                			<xsl:choose>
                				<xsl:when test="./DSCV">
                					<xsl:value-of select="concat('Scavo archeologico ', position(), ' del bene ', $itemURI, ': ', normalize-space(./DSCV))" />
                				</xsl:when>
                				<xsl:when test="./SCAN">
                					<xsl:value-of select="concat('Scavo archeologico ', position(), ' del bene ', $itemURI, ': ', normalize-space(./SCAN))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Scavo archeologico ' , position(), ' del bene ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</rdfs:label>
                		<l0:name xml:lang="it">
                			<xsl:choose>
                				<xsl:when test="./DSCV">
                					<xsl:value-of select="concat('Scavo archeologico ', position(), ' del bene ', $itemURI, ': ', normalize-space(./DSCV))" />
                				</xsl:when>
                				<xsl:when test="./SCAN">
                					<xsl:value-of select="concat('Scavo archeologico ', position(), ' del bene ', $itemURI, ': ', normalize-space(./SCAN))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Scavo archeologico ' , position(), ' del bene ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</l0:name>
                		<rdfs:label xml:lang="en">
                			<xsl:choose>
                				<xsl:when test="./DSCV">
                					<xsl:value-of select="concat('Archaeological excavation ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./DSCV))" />
                				</xsl:when>
                				<xsl:when test="./SCAN">
                					<xsl:value-of select="concat('Archaeological excavation ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./SCAN))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Archaeological excavation ' , position(), ' of cultural property ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</rdfs:label>
                		<l0:name xml:lang="en">
                			<xsl:choose>
                				<xsl:when test="./DSCV">
                					<xsl:value-of select="concat('Archaeological excavation ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./DSCV))" />
                				</xsl:when>
                				<xsl:when test="./SCAN">
                					<xsl:value-of select="concat('Archaeological excavation ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(./SCAN))" />
                				</xsl:when>
                				<xsl:otherwise>
                					<xsl:value-of select="concat('Archaeological excavation ' , position(), ' of cultural property ', $itemURI)" />
                				</xsl:otherwise>
                			</xsl:choose>
                		</l0:name>
                		<xsl:if test="./DSCN">
                			<arco-core:note>
                				<xsl:value-of select="normalize-space(./DSCN)" />
                			</arco-core:note>
                		</xsl:if>
                		<xsl:if test="./DSCD and (not(starts-with(lower-case(normalize-space(./DSCD)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCD)), 'n.r')))">
                			<tiapit:time>
                				<xsl:value-of select="normalize-space(./DSCD)" />
                			</tiapit:time>
                		</xsl:if>
                		<xsl:if test="./DSCK and (not(starts-with(lower-case(normalize-space(./DSCK)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCK)), 'n.r')))">
                			<arco-cd:archeologicalExcavationICCDIdentifier>
                				<xsl:value-of select="normalize-space(./DSCK)" />
                			</arco-cd:archeologicalExcavationICCDIdentifier>
                		</xsl:if>
                		<xsl:if test="./NCUN and (not(starts-with(lower-case(normalize-space(./NCUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./NCUN)), 'n.r')))">
                			<arco-cd:archeologicalExcavationICCDIdentifier>
                				<xsl:value-of select="normalize-space(./NCUN)" />
                			</arco-cd:archeologicalExcavationICCDIdentifier>
                		</xsl:if>
                		<xsl:if test="./DSCH and (not(starts-with(lower-case(normalize-space(./DSCH)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCH)), 'n.r')))">
                			<arco-cd:archeologicalExcavationLocalIdentifier>
                				<xsl:value-of select="normalize-space(./DSCH)" />
                			</arco-cd:archeologicalExcavationLocalIdentifier>
                		</xsl:if>
                		<xsl:if test="./DSCQ and (not(starts-with(lower-case(normalize-space(./DSCQ)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCQ)), 'n.r')))">
                			<arco-cd:areaRoomSquare>
                				<xsl:value-of select="normalize-space(./DSCQ)" />
                			</arco-cd:areaRoomSquare>
                		</xsl:if>
                		<xsl:if test="./DSCZ and (not(starts-with(lower-case(normalize-space(./DSCZ)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCZ)), 'n.r')))">
                			<arco-cd:hasBibliography>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Bibliography/', $itemURI, '-archaeological-excavation-bibliography')" />
	                		</xsl:attribute>
                			</arco-cd:hasBibliography>
                		</xsl:if>
                		<xsl:if test="./DSCI and (not(starts-with(lower-case(normalize-space(./DSCI)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCI)), 'n.r')))">
                			<arco-cd:hasInventory>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Inventory/', $itemURI, '-archaeological-excavation-inventory')" />
	                		</xsl:attribute>
                			</arco-cd:hasInventory>
                		</xsl:if>
                		<xsl:if test="./DSCM and (not(starts-with(lower-case(normalize-space(./DSCM)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCM)), 'n.r')))">
                			<arco-cd:hasMethod>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Method/', arco-fn:urify(normalize-space(./DSCM)))" />
	                		</xsl:attribute>
                			</arco-cd:hasMethod>
                		</xsl:if>
                		<xsl:if test="./DSCT and (not(starts-with(lower-case(normalize-space(./DSCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCT)), 'n.r')))">
                			<arco-cd:hasMotivation>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Motivation/', arco-fn:urify(normalize-space(./DSCT)))" />
	                		</xsl:attribute>
                			</arco-cd:hasMotivation>
                		</xsl:if>
                		<xsl:if test="./DSCU and (not(starts-with(lower-case(normalize-space(./DSCU)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCU)), 'n.r')))">
                			<arco-cd:hasStratigraphicUnit>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'StratigraphicUnit/', arco-fn:urify(normalize-space(./DSCU)))" />
	                		</xsl:attribute>
                			</arco-cd:hasStratigraphicUnit>
                		</xsl:if>
                		<xsl:if test="./DSCS and (not(starts-with(lower-case(normalize-space(./DSCS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCS)), 'n.r')))">
                			<arco-cd:hasTomb>
                				<xsl:attribute name="rdf:resource">
	                			<xsl:value-of
							select="concat($NS, 'Tomb/', arco-fn:urify(normalize-space(./DSCS)))" />
	                		</xsl:attribute>
                			</arco-cd:hasTomb>
                		</xsl:if>
                		<xsl:if test="./DSCA and (not(starts-with(lower-case(normalize-space(./DSCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCA)), 'n.r')))">
						<arco-cd:hasSurveyScientificDirector>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCA)))" />
	                			</xsl:attribute>
						</arco-cd:hasSurveyScientificDirector>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-scientific-director')" />
						</arco-core:hasAgentRole>
					</xsl:if>
					<xsl:if test="./DSCF and (not(starts-with(lower-case(normalize-space(./DSCF)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCF)), 'n.r')))">
						<arco-cd:hasActivityResponsible>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCF)))" />
	                			</xsl:attribute>
						</arco-cd:hasActivityResponsible>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-activity-responsible')" />
						</arco-core:hasAgentRole>
					</xsl:if>
					<xsl:if test="./DSCJ and (not(starts-with(lower-case(normalize-space(./DSCJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCJ)), 'n.r')))">
						<arco-cd:hasAuthorityFileCataloguingAgency>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCJ)))" />
	                			</xsl:attribute>
						</arco-cd:hasAuthorityFileCataloguingAgency>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-cataloguing-agency')" />
						</arco-core:hasAgentRole>
					</xsl:if>
                	</rdf:Description>
                	<!-- bibliography of survey as an individual -->
                	<xsl:if test="./DSCZ and (not(starts-with(lower-case(normalize-space(./DSCZ)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCZ)), 'n.r')))">
                			<rdf:Description>
                				<xsl:attribute name="rdf:about">
		                			<xsl:value-of
								select="concat($NS, 'Bibliography/', $itemURI, '-archaeological-excavation-bibliography')" />
	                		</xsl:attribute>
	                		<rdf:type>
	                			<xsl:attribute name="rdf:resource">
	                				<xsl:value-of select="'https://w3id.org.arco/context-description/Bibliography'" />
	                			</xsl:attribute>
	                		</rdf:type>
	                		<rdfs:label xml:lang="it">
	                			<xsl:value-of select="concat('Bibliografia relativa allo scavo archeologico del bene ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="it">
	                			<xsl:value-of select="concat('Bibliografia relativa allo scavo archeologico del bene ', $itemURI)" />
	                		</l0:name>
	                		<rdfs:label xml:lang="en">
	                			<xsl:value-of select="concat('Bibliography about archaeological excavation of cultural property ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="en">
	                			<xsl:value-of select="concat('Bibliography about archaeological excavation of cultural property ', $itemURI)" />
	                		</l0:name>
	                		<arco-cd:completeBibliographicReference>
	                			<xsl:value-of select="normalize-space(./DSCZ)" />
	                		</arco-cd:completeBibliographicReference>
                		</rdf:Description>
                	</xsl:if>
                	<!-- inventory of survey as an individual -->
                	<xsl:if test="./DSCI and (not(starts-with(lower-case(normalize-space(./DSCI)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCI)), 'n.r')))">
                			<rdf:Description>
                				<xsl:attribute name="rdf:about">
		                			<xsl:value-of
								select="concat($NS, 'Inventory/', $itemURI, '-archaeological-excavation-inventory')" />
	                		</xsl:attribute>
	                		<rdf:type>
	                			<xsl:attribute name="rdf:resource">
	                				<xsl:value-of select="'https://w3id.org.arco/context-description/Inventory'" />
	                			</xsl:attribute>
	                		</rdf:type>
	                		<rdfs:label xml:lang="it">
	                			<xsl:value-of select="concat('Inventario relativo allo scavo archeologico del bene ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="it">
	                			<xsl:value-of select="concat('Inventario relativo allo scavo archeologico del bene ', $itemURI)" />
	                		</l0:name>
	                		<rdfs:label xml:lang="en">
	                			<xsl:value-of select="concat('Inventory about archaeological excavation of cultural property ', $itemURI)" />
	                		</rdfs:label>
	                		<l0:name xml:lang="en">
	                			<xsl:value-of select="concat('Inventory about archaeological excavation of cultural property ', $itemURI)" />
	                		</l0:name>
	                		<arco-cd:completeBibliographicReference>
	                			<xsl:value-of select="normalize-space(./DSCI)" />
	                		</arco-cd:completeBibliographicReference>
                		</rdf:Description>
                	</xsl:if>
                	<!-- method of survey as an individual -->
                	<xsl:if test="./DSCM and (not(starts-with(lower-case(normalize-space(./DSCM)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCM)), 'n.r')))">
                		<rdf:Description>
                			<xsl:attribute name="rdf:about">
	                			<xsl:value-of
							select="concat($NS, 'Method/', arco-fn:urify(normalize-space(./DSCM)))" />
	                		</xsl:attribute>
	                		<rdfs:label>
	                			<xsl:value-of select="normalize-space(./DSCM)" />
	                		</rdfs:label>
	                		<l0:name>
	                			<xsl:value-of select="normalize-space(./DSCM)" />
	                		</l0:name>
                		</rdf:Description>
                	</xsl:if>
                	<!-- motivation of survey as an individual -->
                	<xsl:if test="./DSCT and (not(starts-with(lower-case(normalize-space(./DSCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCT)), 'n.r')))">
                		<rdf:Description>
                			<xsl:attribute name="rdf:about">
	                			<xsl:value-of
							select="concat($NS, 'Motivation/', arco-fn:urify(normalize-space(./DSCT)))" />
	                		</xsl:attribute>
	                		<rdfs:label>
	                			<xsl:value-of select="normalize-space(./DSCT)" />
	                		</rdfs:label>
	                		<l0:name>
	                			<xsl:value-of select="normalize-space(./DSCT)" />
	                		</l0:name>
                		</rdf:Description>
                	</xsl:if>
                	<!-- stratigraphic unit of survey as an individual -->
                	<xsl:if test="./DSCU and (not(starts-with(lower-case(normalize-space(./DSCU)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCU)), 'n.r')))">
                		<rdf:Description>
                			<xsl:attribute name="rdf:about">
	                			<xsl:value-of
							select="concat($NS, 'StratigraphicUnit/', arco-fn:urify(normalize-space(./DSCU)))" />
	                		</xsl:attribute>
	                		<rdfs:label>
	                			<xsl:value-of select="normalize-space(./DSCU)" />
	                		</rdfs:label>
	                		<l0:name>
	                			<xsl:value-of select="normalize-space(./DSCU)" />
	                		</l0:name>
                		</rdf:Description>
                	</xsl:if>
                	<!-- tomb of survey as an individual -->
                	<xsl:if test="./DSCS and (not(starts-with(lower-case(normalize-space(./DSCS)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCS)), 'n.r')))">
                		<rdf:Description>
                			<xsl:attribute name="rdf:about">
	                			<xsl:value-of
							select="concat($NS, 'Tomb/', arco-fn:urify(normalize-space(./DSCS)))" />
	                		</xsl:attribute>
	                		<rdfs:label>
	                			<xsl:value-of select="normalize-space(./DSCS)" />
	                		</rdfs:label>
	                		<l0:name>
	                			<xsl:value-of select="normalize-space(./DSCS)" />
	                		</l0:name>
                		</rdf:Description>
                	</xsl:if>
                	<!-- agent role of survey scientific director as an individual -->
					<xsl:if test="./DSCA and (not(starts-with(lower-case(normalize-space(./DSCA)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCAs)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-scientific-director')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Responsabile scientifico dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCA))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Responsabile scientifico dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCA))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Scientific director of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCA))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Scientific director of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCA))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/ScientificDirector')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCA)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/ScientificDirector')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile Scientifico'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Scientific Director'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-scientific-director')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCA)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./DSCA)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./DSCA)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-scientific-director')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
					<!-- agent role of activity responsible as an individual -->
					<xsl:if test="./DSCF and (not(starts-with(lower-case(normalize-space(./DSCF)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCF)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-activity-responsible')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCF))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCF))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCF))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCF))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/ActivityResponsible')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCF)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/ActivityResponsible')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile dell''attività'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Activity Responsible'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCF)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./DSCF)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./DSCF)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
					<!-- agent role of authority file cataloguing agency as an individual -->
					<xsl:if test="./DSCJ and (not(starts-with(lower-case(normalize-space(./DSCJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./DSCJ)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-cataloguing-agency')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente schedatore dell''Authority File dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCJ))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente schedatore dell''Authority File dello scavo archeologico ', $survey-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./DSCJ))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Authority File cataloguing agency of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCJ))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Authority File cataloguing agency of archaeological excavation ', $survey-position, ' of cultural property ', $itemURI, ': ', normalize-space(./DSCJ))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/AuthorityFileCataloguingAgency')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCJ)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/AuthorityFileCataloguingAgency')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Ente Schedatore dell''Authority File'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Authority File Cataloguing Agency'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-cataloguing-agency')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./DSCJ)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./DSCJ)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./DSCJ)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-archaeological-excavation-', $survey-position, '-cataloguing-agency')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
                </xsl:for-each>
               </xsl:if>
               <!-- Inspection of cultural property -->
              	<xsl:if test="not(schede/*/CM/ISP/ISPD='0000/00/00' or schede/*/CM/ISP/ISPD='/') and schede/*/CM/ISP/*">
                <xsl:for-each select="schede/*/CM/ISP">
					<xsl:variable name="inspection-position">
						<xsl:value-of select="position()" />
					</xsl:variable>
                	<rdf:Description>
                		<xsl:attribute name="rdf:about">
                			<xsl:value-of select="concat($NS, 'Inspection/', $itemURI, '-inspection-', position())" />
                		</xsl:attribute>
                		<rdf:type>
                			<xsl:attribute name="rdf:resource">
                				<xsl:value-of select="'https://w3id.org/arco/context-description/Inspection'" />
                			</xsl:attribute>
                		</rdf:type>
                		<rdfs:label xml:lang="it">
                			<xsl:value-of select="concat('Ispezione ' , position(), ' del bene ', $itemURI)" />
                		</rdfs:label>
                		<l0:name xml:lang="it">
                			<xsl:value-of select="concat('Ispezione ' , position(), ' del bene ', $itemURI)" />
                		</l0:name>
                		<rdfs:label xml:lang="en">
                			<xsl:value-of select="concat('Inspection ' , position(), ' of cultural property ', $itemURI)" />
                		</rdfs:label>
                		<l0:name xml:lang="en">
                			<xsl:value-of select="concat('Inspection ' , position(), ' of cultural property ', $itemURI)" />
                		</l0:name>
                		<xsl:if test="./ISPS">
                			<arco-core:note>
                				<xsl:value-of select="normalize-space(./DSCN)" />
                			</arco-core:note>
                		</xsl:if>
                		<xsl:if test="./ISPD and (not(starts-with(lower-case(normalize-space(./ISPD)), 'nr')) and not(starts-with(lower-case(normalize-space(./ISPD)), 'n.r')))">
                			<tiapit:time>
                				<xsl:value-of select="normalize-space(./ISPD)" />
                			</tiapit:time>
                		</xsl:if>
                		<xsl:if test="./ISPN and (not(starts-with(lower-case(normalize-space(./ISPN)), 'nr')) and not(starts-with(lower-case(normalize-space(./ISPN)), 'n.r')))">
						<arco-cd:hasActivityResponsible>
							<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ISPN)))" />
	                			</xsl:attribute>
						</arco-cd:hasActivityResponsible>
						<arco-core:hasAgentRole>
							<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-inspection-', $inspection-position, '-activity-responsible')" />
						</arco-core:hasAgentRole>
					</xsl:if>
                	</rdf:Description>
                	<!-- agent role of activity responsible as an individual -->
					<xsl:if test="./ISPN and (not(starts-with(lower-case(normalize-space(./ISPN)), 'nr')) and not(starts-with(lower-case(normalize-space(./ISPN)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
			                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-inspection-', $inspection-position, '-activity-responsible')" />
			                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile dell''ispezione ', $inspection-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./ISPN))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile dell''ispezione ', $inspection-position, ' del bene culturale ', $itemURI, ': ', normalize-space(./ISPN))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of inspection ', $inspection-position, ' of cultural property ', $itemURI, ': ', normalize-space(./ISPN))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency of inspection ', $inspection-position, ' of cultural property ', $itemURI, ': ', normalize-space(./ISPN))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Role/ActivityResponsible')" />
					                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ISPN)))" />
					                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Role/ActivityResponsible')" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile dell''attività'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Activity Responsible'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-inspection-', $inspection-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
					                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ISPN)))" />
					                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
					                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ISPN)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ISPN)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
					                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-inspection-', $inspection-position, '-activity-responsible')" />
					                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
                </xsl:for-each>
                </xsl:if>
			<!-- Use of cultural property -->
			<xsl:if test="not(schede/A/UT or schede/PG/UT)">
				<xsl:for-each select="schede/*/UT">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Use/', $itemURI, '-use-', position())" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            				<xsl:value-of select="'https://w3id.org/arco/context-description/Use'" />
            			</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Use ', position(), ' of cultural property ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Use ', position(), ' of cultural property ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Uso ', position(), ' del bene culturale ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Uso ', position(), ' del bene culturale ', $itemURI)" />
						</l0:name>
						<xsl:if test="./UTA and (not(starts-with(lower-case(normalize-space(./UTA)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTA)), 'n.r')))">
							<arco-cd:isKeptIn>
								<xsl:value-of select="normalize-space(./UTA)" />
							</arco-cd:isKeptIn>
						</xsl:if>
						<xsl:if test="./UTU/UTUN">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./UTU/UTUN)" />
							</arco-core:note>
						</xsl:if>
						<xsl:if test="./UTU/UTUD or ./UTS and (not(starts-with(lower-case(normalize-space(./UTU/UTUD)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUD)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTS)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTS)), 'n.r')))">
							<tiapit:time>
								<xsl:choose>
									<xsl:when test="./UTU/UTUD">
										<xsl:value-of select="normalize-space(./UTU/UTUD)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./UTS)" />
									</xsl:otherwise>
								</xsl:choose>
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./UTU/UTUT or ./UTF and (not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTF)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTF)), 'n.r')))">
							<arco-cd:useFunction>
								<xsl:choose>
									<xsl:when test="./UTU/UTUF">
										<xsl:value-of select="normalize-space(./UTU/UTUF)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./UTF)" />
									</xsl:otherwise>
								</xsl:choose>
							</arco-cd:useFunction>
						</xsl:if>
						<xsl:if test="./UTU/UTUM or ./UTM and (not(starts-with(lower-case(normalize-space(./UTU/UTUM)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUM)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTM)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTM)), 'n.r')))">
							<arco-cd:useConditions>
								<xsl:choose>
									<xsl:when test="./UTU/UTUM">
										<xsl:value-of select="normalize-space(./UTU/UTUM)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./UTM)" />
									</xsl:otherwise>
								</xsl:choose>
							</arco-cd:useConditions>
						</xsl:if>
						<xsl:if test="./UTU/UTUT and (not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'n.r')))">
							<arco-cd:hasUseType>
								<xsl:attribute name="rdf:resource">
	                				<xsl:if
									test="./UTU/UTUT and not(./UTU/UTUT='.' or ./UTU/UTUT='-' or ./UTU/UTUT='/')">
		                                <xsl:choose>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUT))='attuale'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Current'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUT))='precedente'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Previous'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUT))='storico'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Historical'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUT))='dato non disponibile'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/UseTypeUnavailable'" />
		                                    </xsl:when>
		                                    <xsl:when test="./UTU/UTUT">
		                                        <xsl:value-of
									select="concat($NS, 'UseType/', arco-fn:urify(normalize-space(./UTU/UTUT)))" />
		                                    </xsl:when>
		                                </xsl:choose>
                    				</xsl:if>
	                			</xsl:attribute>
							</arco-cd:hasUseType>
						</xsl:if>
						<xsl:if test="./UTU/UTUS and (not(starts-with(lower-case(normalize-space(./UTU/UTUS)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUS)), 'n.r')))">
							<arco-cd:hasUseTypeSpecification>
								<xsl:attribute name="rdf:resource">
	                				<xsl:if
									test="./UTU/UTUS and not(./UTU/UTUS='.' or ./UTU/UTUS='-' or ./UTU/UTUS='/')">
		                                <xsl:choose>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='edilizio'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Building'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='epigrafico'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Epigraphic'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='strutturale'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Structural'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='ornamentale'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Ornamental'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='strumentale'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Instrumental'" />
		                                    </xsl:when>
		                                    <xsl:when
									test="lower-case(normalize-space(./UTU/UTUS))='reimpiego'">
		                                        <xsl:value-of
									select="'https://w3id.org/arco/context-description/Reusing'" />
		                                    </xsl:when>
		                                    <xsl:when test="./UTU/UTUS">
		                                        <xsl:value-of
									select="concat($NS, 'UseTypeSpecification/', arco-fn:urify(normalize-space(./UTU/UTUS)))" />
		                                    </xsl:when>
		                                </xsl:choose>
                    				</xsl:if>
	                			</xsl:attribute>
							</arco-cd:hasUseTypeSpecification>
						</xsl:if>
						<xsl:if test="./UTU/UTUO or ./UTO and (not(starts-with(lower-case(normalize-space(./UTU/UTUO)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUO)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTO)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTO)), 'n.r')))">
							<arco-cd:hasCircumstance>
								<xsl:attribute name="rdf:resource">
	                				<xsl:choose>
	                					<xsl:when test="./UTU/UTUO">
	                						<xsl:value-of
									select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./UTU/UTUO)))" />
	                					</xsl:when>
	                					<xsl:otherwise>
	                						<xsl:value-of
									select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./UTO)))" />
	                					</xsl:otherwise>
	                				</xsl:choose>
	                			</xsl:attribute>
							</arco-cd:hasCircumstance>
						</xsl:if>
						<xsl:if test="./UTN">
							<arco-cd:hasUser>
								<xsl:attribute name="rdf:resource">
	                				<xsl:choose>
				            			<xsl:when test="./UTN/UTNN">
				            				<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./UTNN)))" />
				            			</xsl:when>
				            			<xsl:otherwise>
				            				<xsl:value-of
									select="concat($NS, 'Agent/', $itemURI, '-user')" />
				            			</xsl:otherwise>
		            				</xsl:choose>
	                			</xsl:attribute>
							</arco-cd:hasUser>
						</xsl:if>
						<xsl:if test="./UTL and (not(starts-with(lower-case(normalize-space(./UTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL)), 'n.r')))">
							<clvapit:hasSpatialCoverage>
								<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
									select="concat($NS, 'Feature/', arco-fn:urify(arco-fn:md5(normalize-space(./UTL))))" />
	                			</xsl:attribute>
							</clvapit:hasSpatialCoverage>
						</xsl:if>
						<xsl:if test="./AGC and (not(starts-with(lower-case(normalize-space(./AGC)), 'nr')) and not(starts-with(lower-case(normalize-space(./AGC)), 'n.r')))">
							<clvapit:hasSpatialCoverage>
								<xsl:attribute name="rdf:resource">
	                				<xsl:value-of
									select="concat($NS, 'Feature/', arco-fn:urify(normalize-space(./AGC)))" />
	                			</xsl:attribute>
							</clvapit:hasSpatialCoverage>
						</xsl:if>
					</rdf:Description>
					<!-- use type as an individual -->
					<xsl:if test="./UTU/UTUT and (not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUT)), 'n.r')))">
						<xsl:choose>
							<xsl:when test="lower-case(normalize-space(./UTU/UTUT))='attuale'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUT))='precedente'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUT))='storico'" />
							<xsl:when
								test="lower-case(normalize-space(./UTU/UTUT))='dato non disponibile'" />
							<xsl:when
								test="../UTU/UTUT and not(./UTU/UTUT='.' or ./UTU/UTUT='-' or ./UTU/UTUT='/')">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    <xsl:value-of
										select="concat($NS, 'UseType/', arco-fn:urify(normalize-space(./UTU/UTUT)))" />
                                </xsl:attribute>
									<rdf:type rdf:resource="https://w3id.org/arco/context-description/UseType" />
									<rdfs:label>
										<xsl:value-of select="normalize-space(./UTU/UTUT)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./UTU/UTUT)" />
									</l0:name>
								</rdf:Description>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<!-- use type specification as an individual -->
					<xsl:if test="./UTU/UTUS and (not(starts-with(lower-case(normalize-space(./UTU/UTUS)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUS)), 'n.r')))">
						<xsl:choose>
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='strumentale'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='strutturale'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='edilizio'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='ornamentale'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='epigrafico'" />
							<xsl:when test="lower-case(normalize-space(./UTU/UTUS))='reimpiego'" />
							<xsl:when
								test="../UTU/UTUS and not(./UTU/UTUS='.' or ./UTU/UTUS='-' or ./UTU/UTUS='/')">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    <xsl:value-of
										select="concat($NS, 'UseTypeSpecification/', arco-fn:urify(normalize-space(./UTU/UTUS)))" />
                                </xsl:attribute>
									<rdf:type rdf:resource="https://w3id.org/arco/context-description/UseType" />
									<rdfs:label>
										<xsl:value-of select="normalize-space(./UTU/UTUT)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./UTU/UTUT)" />
									</l0:name>
								</rdf:Description>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<!-- use circumstance as an individual -->
					<xsl:if test="./UTU/UTUO or ./UTO and (not(starts-with(lower-case(normalize-space(./UTU/UTUO)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTU/UTUO)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTO)), 'n.r')) and not(starts-with(lower-case(normalize-space(./UTO)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                             <xsl:choose>
	                			<xsl:when test="./UTU/UTUO">
	                				<xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./UTU/UTUO)))" />
	                			</xsl:when>
	                			<xsl:otherwise>
	                				<xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./UTO)))" />
	                			</xsl:otherwise>
	                		</xsl:choose>
                           </xsl:attribute>
							<rdf:type>
							<xsl:attribute name="rdf:resource">
								<xsl:value-of select="'https://w3id.org/arco/context-description/Circumstance'" />
							</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./UTU/UTUO">
										<xsl:value-of select="normalize-space(./UTU/UTUO)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./UTO)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./UTU/UTUO">
										<xsl:value-of select="normalize-space(./UTU/UTUO)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./UTO)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- user as individual -->
					<xsl:if test="./UTN">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		            		<xsl:choose>
		            			<xsl:when test="./UTN/UTNN">
		            				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./UTNN)))" />
		            			</xsl:when>
		            			<xsl:otherwise>
		            				<xsl:value-of
								select="concat($NS, 'Agent/', $itemURI, '-user')" />
		            			</xsl:otherwise>
		            		</xsl:choose>	
	            		</xsl:attribute>
							<xsl:choose>
								<xsl:when test="./UTN/UTNN">
									<rdfs:label>
										<xsl:value-of select="normalize-space(./UTNN)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./UTNN)" />
									</l0:name>
								</xsl:when>
								<xsl:otherwise>
									<rdfs:label xml:lang="en">
										<xsl:value-of select="concat('User of cultural property ', $itemURI)" />
									</rdfs:label>
									<l0:name xml:lang="en">
										<xsl:value-of select="concat('User of cultural property ', $itemURI)" />
									</l0:name>
									<rdfs:label xml:lang="it">
										<xsl:value-of select="concat('Utente del bene culturale ', $itemURI)" />
									</rdfs:label>
									<l0:name xml:lang="it">
										<xsl:value-of select="concat('Utente del bene culturale ', $itemURI)" />
									</l0:name>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="./UTN/UTNA and (not(starts-with(lower-case(normalize-space(./UTN/UTNA)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTN/UTNA)), 'n.r')))">
								<arco-cd:agentDate>
									<xsl:value-of select="normalize-space(./UTN/UTNA)" />
								</arco-cd:agentDate>
							</xsl:if>
							<xsl:if test="./UTN/UTNM and (not(starts-with(lower-case(normalize-space(./UTN/UTNM)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTN/UTNM)), 'n.r')))">
								<arco-cd:hasProfession>
									<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
										select="concat($NS, 'Profession/', arco-fn:urify(normalize-space(./UTN/UTNM)))" />
	            				</xsl:attribute>
								</arco-cd:hasProfession>
							</xsl:if>
							<xsl:if test="./UTN/UTNC and (not(starts-with(lower-case(normalize-space(./UTN/UTNC)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTN/UTNC)), 'n.r')))">
								<arco-cd:hasUserSocialCategory>
									<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
										select="concat($NS, 'SocialCategory/', arco-fn:urify(normalize-space(./UTN/UTNC)))" />
	            				</xsl:attribute>
								</arco-cd:hasUserSocialCategory>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
					<!-- profession of user as an individual -->
					<xsl:if test="./UTN/UTNM and (not(starts-with(lower-case(normalize-space(./UTN/UTNM)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTN/UTNM)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
            				<xsl:value-of
								select="concat($NS, 'Profession/', arco-fn:urify(normalize-space(./UTN/UTNM)))" />
            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/Profession'" />
            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./UTN/UTNM)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./UTN/UTNM)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- social category of user as an individual -->
					<xsl:if test="./UTN/UTNC and (not(starts-with(lower-case(normalize-space(./UTN/UTNC)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTN/UTNC)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
            				<xsl:value-of
								select="concat($NS, 'UserSocialCategory/', arco-fn:urify(normalize-space(./UTN/UTNC)))" />
            			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="'https://w3id.org/arco/context-description/UserSocialCategory'" />
            				</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./UTN/UTNC)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./UTN/UTNC)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- use location AGC as an individual -->
					<xsl:if test="./AGC and (not(starts-with(lower-case(normalize-space(./AGC)), 'nr')) and not(starts-with(lower-case(normalize-space(./AGC)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                	<xsl:value-of
								select="concat($NS, 'Feature/', arco-fn:urify(normalize-space(./AGC)))" />
		                </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resouce">
								<xsl:value-of select="'https://w3id.org/italia/onto/CLV/Feature'" />
								</xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Luogo identificato da: ', normalize-space(./AGC))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Luogo identificato da: ', normalize-space(./AGC))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Location identified by: ', normalize-space(./AGC))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Location identified by: ', normalize-space(./AGC))" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- use location UTL as an individual -->
					<xsl:if test="./UTL and (not(starts-with(lower-case(normalize-space(./UTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                	<xsl:value-of
								select="concat($NS, 'Feature/', arco-fn:urify(arco-fn:md5(normalize-space(./UTL))))" />
		                </xsl:attribute>
							<rdf:type>
							<xsl:attribute name="rdf:resource">
								<xsl:value-of select="'https://w3id.org/italia/onto/CLV/Feature'" />
							</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./UTL)" />
							</rdfs:label>
							<clvapit:hasAddress>
								<xsl:attribute name="rdf:resource">
	                           <xsl:value-of
									select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(normalize-space(./UTL))))" />
	                        </xsl:attribute>
							</clvapit:hasAddress>
						</rdf:Description>
						<!-- address of use location as an individual -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                	<xsl:value-of
								select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(normalize-space(./UTL))))" />
		                </xsl:attribute>
							<rdf:type>
							<xsl:attribute name="rdf:resource">
								<xsl:value-of select="'https://w3id.org/italia/onto/CLV/Address'" />
							</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:for-each select="./UTL/*">
									<xsl:choose>
										<xsl:when test="position() = 1">
											<xsl:value-of select="./text()" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat(', ', ./text())" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</rdfs:label>
							<l0:name>
								<xsl:for-each select="./UTL/*">
									<xsl:choose>
										<xsl:when test="position() = 1">
											<xsl:value-of select="./text()" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat(', ', ./text())" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</l0:name>
							<xsl:if test="./UTL/UTLL and (not(starts-with(lower-case(normalize-space(./UTL/UTLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLL)), 'n.r')))">
								<clvapit:hasAddressArea>
									<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(normalize-space(./UTL/UTLL)))" />
								</xsl:attribute>
								</clvapit:hasAddressArea>
							</xsl:if>
							<xsl:if test="./UTL/UTLF and (not(starts-with(lower-case(normalize-space(./UTL/UTLF)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLF)), 'n.r')))">
								<clvapit:hasAddressArea>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(normalize-space(./UTL/UTLF)))" />
								</xsl:attribute>
								</clvapit:hasAddressArea>
							</xsl:if>
							<xsl:if test="./UTL/UTLS and (not(starts-with(lower-case(normalize-space(./UTL/UTLS)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLS)), 'n.r')))">
								<clvapit:hasCountry>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'Country/', arco-fn:urify(normalize-space(./UTL/UTLS)))" />
								</xsl:attribute>
								</clvapit:hasCountry>
							</xsl:if>
							<xsl:if test="./UTL/UTLR and (not(starts-with(lower-case(normalize-space(./UTL/UTLR)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLR)), 'n.r')))">
								<clvapit:hasRegion>
									<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'Region/', arco-fn:urify(normalize-space(./UTL/UTLR)))" />
									</xsl:attribute>
								</clvapit:hasRegion>
							</xsl:if>
							<xsl:if test="./UTL/UTLP and (not(starts-with(lower-case(normalize-space(./UTL/UTLP)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLP)), 'n.r')))">
								<clvapit:hasProvince>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'Province/', arco-fn:urify(normalize-space(./UTL/UTLP)))" />
								</xsl:attribute>
								</clvapit:hasProvince>
							</xsl:if>
							<xsl:if test="./UTL/UTLC and (not(starts-with(lower-case(normalize-space(./UTL/UTLC)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLC)), 'n.r')))">
								<clvapit:hasCity>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
										select="concat($NS, 'City/', arco-fn:urify(normalize-space(./UTL/UTLC)))" />
								</xsl:attribute>
								</clvapit:hasCity>
							</xsl:if>
						</rdf:Description>
						<xsl:if test="./UTL/UTLL and (not(starts-with(lower-case(normalize-space(./UTL/UTLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLL)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'AddressArea/', arco-fn:urify(normalize-space(./UTL/UTLL)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLL)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<xsl:if test="./UTL/UTLF and (not(starts-with(lower-case(normalize-space(./UTL/UTLF)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLF)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'AddressArea/', arco-fn:urify(normalize-space(./UTL/UTLF)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLF)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLF)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<xsl:if test="./UTL/UTLS and (not(starts-with(lower-case(normalize-space(./UTL/UTLS)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLS)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'Country/', arco-fn:urify(normalize-space(./UTL/UTLS)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
	                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/Country'" />
	                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLS)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLS)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<xsl:if test="./UTL/UTLR and (not(starts-with(lower-case(normalize-space(./UTL/UTLR)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLR)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'Region/', arco-fn:urify(normalize-space(./UTL/UTLR)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
	                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/Region'" />
	                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLR)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLR)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<xsl:if test="./UTL/UTLP and (not(starts-with(lower-case(normalize-space(./UTL/UTLP)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLP)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'Province/', arco-fn:urify(normalize-space(./UTL/UTLP)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
	                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/Province'" />
	                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLP)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLP)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<xsl:if test="./UTL/UTLC and (not(starts-with(lower-case(normalize-space(./UTL/UTLC)), 'nr')) and not(starts-with(lower-case(normalize-space(./UTL/UTLC)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                            	<xsl:value-of
									select="concat($NS, 'City/', arco-fn:urify(normalize-space(./UTL/UTLC)))" />
                       	 	</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
	                                <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/City'" />
	                            </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(./UTL/UTLC)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./UTL/UTLC)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
					</xsl:if>
					<!-- address of location of use as an individual -->
				</xsl:for-each>
			</xsl:if>
			<!-- SMO and PST NORM - Use of cultural property -->
			<xsl:if test="schede/*/DA/UTM or schede/*/DA/UTF or schede/*/DA/UTS">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of select="concat($NS, 'Use/', $itemURI, '-use')" />
            		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="'https://w3id.org/arco/context-description/Use'" />
					</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of select="concat('Use of cultural property ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of select="concat('Use of cultural property ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of select="concat('Uso del bene culturale ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of select="concat('Uso del bene culturale ', $itemURI)" />
					</l0:name>
					<xsl:if test="schede/*/DA/UTS">
						<tiapit:time>
							<xsl:value-of select="normalize-space(schede/*/DA/UTS)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="schede/*/DA/UTF">
						<arco-cd:useFunction>
							<xsl:value-of select="normalize-space(schede/*/DA/UTF)" />
						</arco-cd:useFunction>
					</xsl:if>
					<xsl:if test="schede/*/DA/UTM">
						<arco-cd:useConditions>
							<xsl:value-of select="normalize-space(schede/*/DA/UTM)" />
						</arco-cd:useConditions>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- material of cultural property (version 4.00) and VeAC as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/*/MT/MTC/MTCM)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCF)), 'n.r')) and not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCF)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/MT/MTC/MTCM)), 'n.r'))">
			<xsl:for-each select="schede/*/MT/MTC/MTCM | schede/VeAC/MT/MTC/MTCF">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-material-', position())" />
            		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
					</xsl:attribute>
					</rdf:type>
					<xsl:choose>
						<xsl:when test=".">
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Materia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Materia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Material ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Material ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
							</l0:name>
							<xsl:if test="../MTCS">
								<arco-core:note>
									<xsl:value-of select="../MTCS" />
								</arco-core:note>
							</xsl:if>
						</xsl:when>
						<xsl:when test="schede/VeAC/MT/MTC/MTCF">
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Materia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCF))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Materia ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCF))" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Material ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCF))" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Material ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCF))" />
							</l0:name>
						</xsl:when>
					</xsl:choose>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:choose>
            					<xsl:when test=".">
            						<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            					</xsl:when>
            					<xsl:when test="schede/VeAC/MT/MTC/MTCF">
            						<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCF)))" />
            					</xsl:when>
            				</xsl:choose>
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/Material'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:choose>
            				<xsl:when test=".">
            					<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            				</xsl:when>
            				<xsl:when test="schede/VeAC/MT/MTC/MTCF">
            					<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCF)))" />
            				</xsl:when>
            			</xsl:choose>
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<xsl:choose>
						<xsl:when test=".">
							<rdfs:label>
								<xsl:value-of select="normalize-space(.)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(.)" />
							</l0:name>
						</xsl:when>
						<xsl:when test="schede/VeAC/MT/MTC/MTCF">
							<rdfs:label>
								<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCF)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCF)" />
							</l0:name>
						</xsl:when>
					</xsl:choose>
				</rdf:Description>
			</xsl:for-each>
			</xsl:if>
			<!-- technique of cultural property (version 4.00) as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/*/MT/MTC/MTCT)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/MT/MTC/MTCT)), 'n.r'))">
			<xsl:for-each select="schede/*/MT/MTC/MTCT">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-technique-', position())" />
            		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Tecnica ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Tecnica ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Technique ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Technique ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
					</l0:name>
					<xsl:if test="../MTCS">
						<arco-core:note>
							<xsl:value-of select="../MTCS" />
						</arco-core:note>
					</xsl:if>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/Technique'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
				</rdf:Description>
			</xsl:for-each>
			</xsl:if>
			<!-- materialOrTechnique of cultural property (previous versions) as an 
				individual -->
			<xsl:if test="not(schede/*/MT/MTC/*) and (not(starts-with(lower-case(normalize-space(schede/*/MT/MTC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/MT/MTC)), 'n.r')))">
				<xsl:for-each select="schede/*/MT/MTC">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-material-technique-', position())" />
            		</xsl:attribute>
						<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Materia e/o tecnica ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Materia e/o tecnica ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Material and/or technique ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Material and/or technique ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
						</l0:name>
						<arco-dd:satisfiesTechnicalDetail>
							<xsl:attribute name="rdf:resource">
            				<xsl:value-of
								select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
						</arco-dd:satisfiesTechnicalDetail>
						<arco-dd:usesTechnicalCharacteristic>
							<xsl:attribute name="rdf:resource">
            				<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/MaterialOrTechnique'" />
            			</xsl:attribute>
						</arco-dd:usesTechnicalCharacteristic>
					</rdf:Description>
					<!-- Technical detail as an individual -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
					</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- shape of cultural property as an individual -->
			<xsl:if test="schede/*/MT/FRM and not(schede/F/MT/FRM)">
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/*/MT/FRM)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/MT/FRM)), 'n.r'))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-shape')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Formato del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FRM))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Formato del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FRM))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Shape of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FRM))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Shape of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FRM))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FRM)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of select="'https://w3id.org/arco/denotative-description/Shape'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FRM)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/MT/FRM)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/*/MT/FRM)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			</xsl:if>
			<!-- filigree of cultural property as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/*/MT/FIL)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/MT/FIL)), 'n.r'))">
                 <xsl:for-each select="schede/*/MT/FIL">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-filigree')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Filigrana del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FIL))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Filigrana del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FIL))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Filigree of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FIL))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Filigree of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FIL))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FIL)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/Filigree'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FIL)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/MT/FIL)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/*/MT/FIL)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- file format of photograph (F) as an individual -->
			 <xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCF)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCF)), 'n.r'))">
                 <xsl:for-each select="schede/F/MT/FVC/FVCF">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-file-format')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Formato di compressione/estensione file del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FVC/FVCF))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Formato di compressione/estensione file del bene culturale ', $itemURI, ': ', normalize-space(schede/*/MT/FVC/FVCF))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('File format of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FVC/FVCF))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('File format of cultural property ', $itemURI, ': ', normalize-space(schede/*/MT/FVC/FVCF))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FVC/FVCF)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/FileFormat'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/*/MT/FVC/FVCF)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/MT/FVC/FVCF)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/*/MT/FVC/FVCF)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- photo size of photograph (F) as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FRM)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FRM)), 'n.r'))">
			<xsl:for-each select="schede/F/MT/FRM">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-photo-size')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Formato (dimensione standard) del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FRM))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Formato (dimensione standard) del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FRM))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Photo size of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FRM))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Photo size of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FRM))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FRM)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/PhotoSize'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FRM)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/FRM)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/FRM)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- photo program of photograph (F) as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCP)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCP)), 'n.r'))">
			<xsl:for-each select="schede/F/MT/FVC/FVCP">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-photo-program')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Programma di visualizzazione, memorizzazione ed elaborazione del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCP))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Programma di visualizzazione, memorizzazione ed elaborazione del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCP))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Visualization, storage and processing program of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCP))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Visualization, storage and processing program of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCP))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCP)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/PhotoProgram'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCP)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCP)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCP)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- storage method and colour depth of photograph (F) as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCC)), 'n.r'))">
                 <xsl:for-each select="schede/F/MT/FVC/FVCC">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-storage-method-colour-depth')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Metodo di memorizzazione e profondità di colore del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCC))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Metodo di memorizzazione e profondità di colore del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCC))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Storage method and colour depth of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCC))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Storage method and colour depth of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCC))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCC)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/StorageMethodColourDepth'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCC)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCC)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCC)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- resolution of photograph (F) as an individual -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCU)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCU)), 'n.r'))">
                 <xsl:for-each select="schede/F/MT/FVC/FVCU">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-resolution')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Risoluzione del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCU))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Risoluzione del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCU))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Resolution of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCU))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Resolution of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVC/FVCU))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCU)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/Resolution'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVC/FVCU)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCU)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/FVC/FVCU)" />
					</l0:name>
				</rdf:Description>
				</xsl:for-each>
			</xsl:if>
			<!-- pixel dimension of photograph (F) -->
			<xsl:if test="not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCM)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVC/FVCM)), 'n.r'))">
			<xsl:for-each select="schede/F/MT/FVC/FVCM">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-pixel-dimension-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Dimensioni in pixel ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Dimensioni in pixel ', position(), ' del bene culturale ', $itemURI, ': ', normalize-space(.))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Pixel dimension ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Pixel dimension ', position(), ' of cultural property ', $itemURI, ': ', normalize-space(.))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/PixelDimension'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(.)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(.)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(.)" />
					</l0:name>
				</rdf:Description>
			</xsl:for-each>
			</xsl:if>
			<!-- mass storage of photograph (F) as an individual -->
			<xsl:if test="schede/F/MT/FVM and (not(starts-with(lower-case(normalize-space(schede/F/MT/FVM)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/FVM)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-mass-storage')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Memoria di massa del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVM))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Memoria di massa del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/FVM))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Mass storage of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVM))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Mass storage of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/FVM))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVM)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/MassStorage'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/FVM)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/FVM)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/FVM)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			<!-- colour of photograph (F) as an individual -->
			<xsl:if test="schede/F/MT/MTX and (not(starts-with(lower-case(normalize-space(schede/F/MT/MTX)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/F/MT/MTX)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-photo-colour')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Colore del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/MTX))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Colore del bene culturale ', $itemURI, ': ', normalize-space(schede/F/MT/MTX))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Colour of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/MTX))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Colour of cultural property ', $itemURI, ': ', normalize-space(schede/F/MT/MTX))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/MTX)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/PhotoColour'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/F/MT/MTX)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/F/MT/MTX)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/F/MT/MTX)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			<!-- garment colour (VeAC) as an individual -->
			<xsl:if test="schede/VeAC/MT/MTC/MTCC and (not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCC)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-garment-colour')" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of
								select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Colore del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCC))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Colore del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCC))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Colour of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCC))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Colour of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCC))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCC)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/GarmentColour'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCC)))" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCC)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCC)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			<!-- garment analysis (VeAC) as an individual -->
			<xsl:if test="schede/VeAC/MT/MTC/MTCA and (not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCA)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/VeAC/MT/MTC/MTCA)), 'n.r')))">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetailOccurrence/', $itemURI, '-garment-analysis')" />
            		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resouce">
						<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/TechnicalDetailOccurrence'" />
					</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Analisi del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCA))" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Analisi del bene culturale ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCA))" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Analysis of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCA))" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Analysis of cultural property ', $itemURI, ': ', normalize-space(schede/VeAC/MT/MTC/MTCA))" />
					</l0:name>
					<arco-dd:satisfiesTechnicalDetail>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCA)))" />
            			</xsl:attribute>
					</arco-dd:satisfiesTechnicalDetail>
					<arco-dd:usesTechnicalCharacteristic>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/arco/denotative-description/GarmentAnalysis'" />
            			</xsl:attribute>
					</arco-dd:usesTechnicalCharacteristic>
				</rdf:Description>
				<!-- Technical detail as an individual -->
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'TechnicalDetail/', arco-fn:urify(normalize-space(schede/VeAC/MT/MTC/MTCA)))" />
            		</xsl:attribute>
					<rdf:type>
					<xsl:attribute name="rdf:resource">
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/TechnicalDetail'" />
						</xsl:attribute>
					</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCA)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/VeAC/MT/MTC/MTCA)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			<!-- Geometry of cultural property as an individual for GE (version 4.00) -->
			<xsl:for-each
				select="schede/*/GE | schede/*/MT/MTA/MTAR | schede/*/MT/MTA/MTAX / schede/*/MT/MTA/MTAM">
				<xsl:variable name="geometry-position" select="position()" />
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'Geometry/', $itemURI, '-geometry-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Geometry'" />
            			</xsl:attribute>
					</rdf:type>
					<clvapit:isGeometryFor>
						<xsl:attribute name="rdf:resource">
				           <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
				        </xsl:attribute>
					</clvapit:isGeometryFor>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Geometry ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Geometry ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Georeferenziazione ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Georeferenziazione ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./GET and (not(starts-with(lower-case(normalize-space(./GET)), 'nr')) and not(starts-with(lower-case(normalize-space(./GET)), 'n.r')))">
					<clvapit:hasGeometryType>
						<xsl:attribute name="rdf:resource">
                            <xsl:choose>
                                <xsl:when
							test="./GET='georeferenziazione puntuale'">
                                    <xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Point'" />
                                </xsl:when>
                                <xsl:when
							test="./GET='georeferenziazione areale'">
                                    <xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Polygon'" />
                                </xsl:when>
                                <xsl:when
							test="./GET='georeferenziazione lineare'">
                                    <xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Line'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
							select="concat($NS, 'GeometryType/', arco-fn:urify(normalize-space(./GET)))" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
					</clvapit:hasGeometryType>
					</xsl:if>
					<xsl:for-each select="./GEC">
						<arco-location:hasCoordinates>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Coordinates/', $itemURI, '-geometry-', $geometry-position, '-coordinates', '-', position())" />
            				</xsl:attribute>
						</arco-location:hasCoordinates>
					</xsl:for-each>
					<xsl:if test="./GEP and (not(starts-with(lower-case(normalize-space(./GEP)), 'nr')) and not(starts-with(lower-case(normalize-space(./GEP)), 'n.r')))">
						<arco-location:spacialReferenceSystem>
							<xsl:value-of select="normalize-space(./GEP)" />
						</arco-location:spacialReferenceSystem>
					</xsl:if>
					<xsl:if test="./GPT and (not(starts-with(lower-case(normalize-space(./GPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPT)), 'n.r')))">
						<arco-location:hasGeometryTechnique>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GPT)))" />
            				</xsl:attribute>
						</arco-location:hasGeometryTechnique>
					</xsl:if>
					<xsl:if test="./GPM and (not(starts-with(lower-case(normalize-space(./GPM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPM)), 'n.r')))">
						<arco-location:hasGeometryMethod>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GPM)))" />
            				</xsl:attribute>
						</arco-location:hasGeometryMethod>
					</xsl:if>
					<xsl:if test="./GPB">
						<arco-location:hasBaseMap>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'BaseMap/', $itemURI, '-geometry-', $geometry-position, '-base-map')" />
            				</xsl:attribute>
						</arco-location:hasBaseMap>
					</xsl:if>
					<xsl:if test="./GEL and not(./GEL='.' or ./GEL='-' or ./GEL='/') and (not(starts-with(lower-case(normalize-space(./GEL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GEL)), 'n.r')))">
						<arco-location:hasReferredLocationType>
							<xsl:attribute name="rdf:resource">
					                                <xsl:choose>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GEL))='luogo di provenienza' or lower-case(normalize-space(./GEL))='provenienza' or lower-case(normalize-space(./GEL))='provenienza'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/LastLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GEL))='luogo di esecuzione/fabbricazione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ProductionRealizationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di reperimento' or lower-case(normalize-space(./GEL))='luogo di reperimento' or lower-case(normalize-space(./GEL))='reperimento' or lower-case(normalize-space(./GEL))='reperimento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/FindingLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di deposito' or lower-case(normalize-space(./GEL))='luogo di deposito' or lower-case(normalize-space(./GEL))='deposito temporaneo' or lower-case(normalize-space(./GEL))='deposito temporaneo' or lower-case(normalize-space(./GEL))='deposito' or lower-case(normalize-space(./GEL))='deposito'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/StorageLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di esposizione' or lower-case(normalize-space(./GEL))='luogo di esposizione' or lower-case(normalize-space(./GEL))='espositiva' or lower-case(normalize-space(./GEL))='espositiva' or lower-case(normalize-space(./GEL))='espositivo' or lower-case(normalize-space(./GEL))='espositivo' or lower-case(normalize-space(./GEL))='esposizione' or lower-case(normalize-space(./GEL))='esposizione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ExhibitionLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='luogo di rilevamento' or lower-case(normalize-space(./GEL))='luogo di rilevamento' or lower-case(normalize-space(./GEL))='di rilevamento' or lower-case(normalize-space(./GEL))='di rilevamento' or lower-case(normalize-space(./GEL))='localizzazione di rilevamento' or lower-case(normalize-space(./GEL))='localizzazione di rilevamento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ObservationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='area rappresentata' or lower-case(normalize-space(./GEL))='area rappresentata'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/SubjectLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GEL))='localizzazione fisica'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/CurrentPhysicalLocation'" />
					                                    </xsl:when>
					                                    <xsl:when test="./GEL">
					                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GEL)))" />
					                                    </xsl:when>
					                                </xsl:choose>
					                            </xsl:attribute>
						</arco-location:hasReferredLocationType>
					</xsl:if>
				</rdf:Description>
				<!-- referred location type for GE as an individual -->
				<xsl:if test="./GEL and not(./GEL='.' or ./GEL='-' or ./GEL='/') and (not(starts-with(lower-case(normalize-space(./GEL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GEL)), 'n.r')))">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GEL))='luogo di provenienza' or lower-case(normalize-space(./GEL))='provenienza' or lower-case(normalize-space(./GEL))='provenienza'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GEL))='luogo di esecuzione/fabbricazione'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di reperimento' or lower-case(normalize-space(./GEL))='luogo di reperimento' or lower-case(normalize-space(./GEL))='reperimento' or lower-case(normalize-space(./GEL))='reperimento'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di deposito' or lower-case(normalize-space(./GEL))='luogo di deposito' or lower-case(normalize-space(./GEL))='deposito temporaneo' or lower-case(normalize-space(./GEL))='deposito temporaneo' or lower-case(normalize-space(./GEL))='deposito' or lower-case(normalize-space(./GEL))='deposito'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di esposizione' or lower-case(normalize-space(./GEL))='luogo di esposizione' or lower-case(normalize-space(./GEL))='espositiva' or lower-case(normalize-space(./GEL))='espositiva' or lower-case(normalize-space(./GEL))='espositivo' or lower-case(normalize-space(./GEL))='espositivo' or lower-case(normalize-space(./GEL))='esposizione' or lower-case(normalize-space(./GEL))='esposizione'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='luogo di rilevamento' or lower-case(normalize-space(./GEL))='luogo di rilevamento' or lower-case(normalize-space(./GEL))='di rilevamento' or lower-case(normalize-space(./GEL))='di rilevamento' or lower-case(normalize-space(./GEL))='localizzazione di rilevamento' or lower-case(normalize-space(./GEL))='localizzazione di rilevamento'" />
						<xsl:when
							test="lower-case(normalize-space(./GEL))='area rappresentata' or lower-case(normalize-space(./GEL))='area rappresentata'" />
						<xsl:when test="./GEL">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GEL)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./GEL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./GEL)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- geometry type for GE as an individual -->
				<xsl:if test="./GET and not(./GET='.' or ./GET='-' or ./GET='/') and (not(starts-with(lower-case(normalize-space(./GET)), 'nr')) and not(starts-with(lower-case(normalize-space(./GET)), 'n.r')))">
					<xsl:choose>
						<xsl:when test="./GET='georeferenziazione puntuale'" />
						<xsl:when test="./GET='georeferenziazione areale'" />
						<xsl:when test="./GET='georeferenziazione lineare'" />
						<xsl:otherwise>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'GeometryType/', arco-fn:urify(normalize-space(./GET)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/italia/onto/CLV/GeometryType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./GET)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./GET)" />
								</l0:name>
							</rdf:Description>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<!-- geometry coordinates for GE as an individual -->
				<xsl:for-each select="./GEC">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Coordinates/', $itemURI, '-geometry-', $geometry-position, '-coordinates', '-', position())" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/Coordinates" />
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GECX and (not(starts-with(lower-case(normalize-space(./GECX)), 'nr')) and not(starts-with(lower-case(normalize-space(./GECX)), 'n.r')))">
							<arco-location:long>
								<xsl:value-of select="normalize-space(./GECX)" />
							</arco-location:long>
						</xsl:if>
						<xsl:if test="./GECY and (not(starts-with(lower-case(normalize-space(./GECY)), 'nr')) and not(starts-with(lower-case(normalize-space(./GECY)), 'n.r')))">
							<arco-location:lat>
								<xsl:value-of select="normalize-space(./GECY)" />
							</arco-location:lat>
						</xsl:if>
						<xsl:if
							test="./GECZ | ../../MT/MTA/MTAR | ../../MT/MTA/MTAX / ../../MT/MTA/MTAM">
							<arco-location:hasAltitude>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'Altitude/', $itemURI, '-geometry-', $geometry-position, '-altitude')" />
            				</xsl:attribute>
							</arco-location:hasAltitude>
						</xsl:if>
					</rdf:Description>
				</xsl:for-each>
				<!-- geometry technique for GE as an individual -->
				<xsl:if test="./GPT and (not(starts-with(lower-case(normalize-space(./GPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPT)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GPT)))" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryTechnique" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./GPT)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./GPT)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- geometry method for GE as an individual -->
				<xsl:if test="./GPM and (not(starts-with(lower-case(normalize-space(./GPM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPM)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GPM)))" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryMethod" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./GPM)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./GPM)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- geometry base map for GE as an individual -->
				<xsl:if test="./GPB">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'BaseMap/', $itemURI, '-geometry-', $geometry-position, '-base-map')" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/BaseMap" />
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Base cartografica del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Base cartografica del bene culturale: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Base map of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Base map of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GPB/GPBB">
							<arco-core:description>
								<xsl:value-of select="normalize-space(./GPB/GPBB)" />
							</arco-core:description>
						</xsl:if>
						<xsl:if test="./GPB/GPBT and (not(starts-with(lower-case(normalize-space(./GPB/GPBT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPB/GPBT)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(./GPB/GPBT)" />
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./GPB/GPBU and (not(starts-with(lower-case(normalize-space(./GPB/GPBU)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPB/GPBU)), 'n.r')))">
							<smapit:url>
								<xsl:value-of select="normalize-space(./GPB/GPBU)" />
							</smapit:url>
						</xsl:if>
						<xsl:if test="./GPB/GPBO and (not(starts-with(lower-case(normalize-space(./GPB/GPBO)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPB/GPBO)), 'n.r')))">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./GPB/GPBO)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
				<!-- altitude for GE as an individual -->
				<xsl:if
					test="./GEC/GECZ | ../MT/MTA/MTAR | ../MT/MTA/MTAX / ../MT/MTA/MTAM">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Altitude/', $itemURI, '-geometry-', $geometry-position, '-altitude')" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/Altitude" />
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Altitudine del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Altitudine del bene culturale: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Altitude of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Altitude of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GEC/GECZ and (not(starts-with(lower-case(normalize-space(./GEC/GECZ)), 'nr')) and not(starts-with(lower-case(normalize-space(./GEC/GECZ)), 'n.r')))">
							<arco-location:alt>
								<xsl:value-of select="normalize-space(./GEC/GECZ)" />
							</arco-location:alt>
						</xsl:if>
						<xsl:if test="../MT/MTA/MTAR and (not(starts-with(lower-case(normalize-space(../MT/MTA/MTAR)), 'nr')) and not(starts-with(lower-case(normalize-space(./MT/MTA/MTAR)), 'n.r')))">
							<arco-location:relativeAlt>
								<xsl:value-of select="../MT/MTA/MTAR" />
							</arco-location:relativeAlt>
						</xsl:if>
						<xsl:if test="../MT/MTA/MTAX and (not(starts-with(lower-case(normalize-space(./MT/MTA/MTAX)), 'nr')) and not(starts-with(lower-case(normalize-space(./MT/MTA/MTAX)), 'n.r')))">
							<arco-location:maxAlt>
								<xsl:value-of select="../MT/MTA/MTAX" />
							</arco-location:maxAlt>
						</xsl:if>
						<xsl:if test="../MT/MTA/MTAM and (not(starts-with(lower-case(normalize-space(./MT/MTA/MTAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./MT/MTA/MTAM)), 'n.r')))">
							<arco-location:minAlt>
								<xsl:value-of select="../MT/MTA/MTAM" />
							</arco-location:minAlt>
						</xsl:if>
						<xsl:if test="../MT/MTA/MTAS">
							<arco-core:note>
								<xsl:value-of select="../MT/MTA/MTAS" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Geometry of cultural property as an individual for GP (Point) -->
			<xsl:for-each select="schede/*/GP">
				<xsl:variable name="geometry-position" select="position()" />
				<rdf:Description>
					<xsl:attribute name="rdf:about">
            			<xsl:value-of
						select="concat($NS, 'Geometry/', $itemURI, '-geometry-point-', position())" />
            		</xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
            				<xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Geometry'" />
            			</xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Geometry (point) ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Geometry (point) ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Georeferenziazione (puntuale) ', position(), ' del bene culturale: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Georeferenziazione (puntuale) ', position(), ' del bene culturale: ', $itemURI)" />
					</l0:name>
					<clvapit:isGeometryFor>
						<xsl:attribute name="rdf:resource">
				           <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
				        </xsl:attribute>
					</clvapit:isGeometryFor>
					<clvapit:hasGeometryType>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Point'" />
                        </xsl:attribute>
					</clvapit:hasGeometryType>
					<xsl:for-each select="./GPD/GPDP">
						<arco-location:hasCoordinates>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'Coordinates/', $itemURI, '-geometry-point-', $geometry-position, '-coordinates', '-', position())" />
            				</xsl:attribute>
						</arco-location:hasCoordinates>
					</xsl:for-each>
					<xsl:if test="./GPP and (not(starts-with(lower-case(normalize-space(./GPP)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPP)), 'n.r')))">
						<arco-location:spacialReferenceSystem>
							<xsl:value-of select="normalize-space(./GPP)" />
						</arco-location:spacialReferenceSystem>
					</xsl:if>
					<xsl:if test="./GPC/GPCT and (not(starts-with(lower-case(normalize-space(./GPC/GPCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPC/GPCT)), 'n.r')))">
						<arco-location:pointType>
							<xsl:value-of select="normalize-space(./GPC/GPCT)" />
						</arco-location:pointType>
					</xsl:if>
					<xsl:if test="./GPT and (not(starts-with(lower-case(normalize-space(./GPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPT)), 'n.r')))">
						<arco-location:hasGeometryTechnique>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GPT)))" />
            				</xsl:attribute>
						</arco-location:hasGeometryTechnique>
					</xsl:if>
					<xsl:if test="./GPM and (not(starts-with(lower-case(normalize-space(./GPM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPM)), 'n.r')))">
						<arco-location:hasGeometryMethod>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GPM)))" />
            				</xsl:attribute>
						</arco-location:hasGeometryMethod>
					</xsl:if>
					<xsl:if test="./GPB">
						<arco-location:hasBaseMap>
							<xsl:attribute name="rdf:resource">
            					<xsl:value-of
								select="concat($NS, 'BaseMap/', $itemURI, '-geometry-point-', $geometry-position, '-base-map')" />
            				</xsl:attribute>
						</arco-location:hasBaseMap>
					</xsl:if>
					<!-- has referred laction type -->
					<xsl:if test="./GPL and not(./GPL='.' or ./GPL='-' or ./GPL='/') and (not(starts-with(lower-case(normalize-space(./GPL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPL)), 'n.r')))">
						<arco-location:hasReferredLocationType>
							<xsl:attribute name="rdf:resource">
					                                <xsl:choose>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GPL))='luogo di provenienza' or lower-case(normalize-space(./GPL))='provenienza' or lower-case(normalize-space(./GPL))='provenienza'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/LastLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GPL))='luogo di esecuzione/fabbricazione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ProductionRealizationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di reperimento' or lower-case(normalize-space(./GPL))='luogo di reperimento' or lower-case(normalize-space(./GPL))='reperimento' or lower-case(normalize-space(./GPL))='reperimento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/FindingLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di deposito' or lower-case(normalize-space(./GPL))='luogo di deposito' or lower-case(normalize-space(./GPL))='deposito temporaneo' or lower-case(normalize-space(./GPL))='deposito temporaneo' or lower-case(normalize-space(./GPL))='deposito' or lower-case(normalize-space(./GPL))='deposito'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/StorageLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di esposizione' or lower-case(normalize-space(./GPL))='luogo di esposizione' or lower-case(normalize-space(./GPL))='espositiva' or lower-case(normalize-space(./GPL))='espositiva' or lower-case(normalize-space(./GPL))='espositivo' or lower-case(normalize-space(./GPL))='espositivo' or lower-case(normalize-space(./GPL))='esposizione' or lower-case(normalize-space(./GPL))='esposizione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ExhibitionLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='luogo di rilevamento' or lower-case(normalize-space(./GPL))='luogo di rilevamento' or lower-case(normalize-space(./GPL))='di rilevamento' or lower-case(normalize-space(./GPL))='di rilevamento' or lower-case(normalize-space(./GPL))='localizzazione di rilevamento' or lower-case(normalize-space(./GPL))='localizzazione di rilevamento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ObservationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='area rappresentata' or lower-case(normalize-space(./GPL))='area rappresentata'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/SubjectLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GPL))='localizzazione fisica'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/CurrentPhysicalLocation'" />
					                                    </xsl:when>
					                                    <xsl:when test="./GPL">
					                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GPL)))" />
					                                    </xsl:when>
					                                </xsl:choose>
					                            </xsl:attribute>
						</arco-location:hasReferredLocationType>
					</xsl:if>
				</rdf:Description>
				<!-- referred location type for GE as an individual -->
				<xsl:if test="./GPL and not(./GPL='.' or ./GPL='-' or ./GPL='/') and (not(starts-with(lower-case(normalize-space(./GPL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPL)), 'n.r')))">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GPL))='luogo di provenienza' or lower-case(normalize-space(./GPL))='provenienza' or lower-case(normalize-space(./GPL))='provenienza'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GPL))='luogo di esecuzione/fabbricazione'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di reperimento' or lower-case(normalize-space(./GPL))='luogo di reperimento' or lower-case(normalize-space(./GPL))='reperimento' or lower-case(normalize-space(./GPL))='reperimento'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di deposito' or lower-case(normalize-space(./GPL))='luogo di deposito' or lower-case(normalize-space(./GPL))='deposito temporaneo' or lower-case(normalize-space(./GPL))='deposito temporaneo' or lower-case(normalize-space(./GPL))='deposito' or lower-case(normalize-space(./GPL))='deposito'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di esposizione' or lower-case(normalize-space(./GPL))='luogo di esposizione' or lower-case(normalize-space(./GPL))='espositiva' or lower-case(normalize-space(./GPL))='espositiva' or lower-case(normalize-space(./GPL))='espositivo' or lower-case(normalize-space(./GPL))='espositivo' or lower-case(normalize-space(./GEL))='esposizione' or lower-case(normalize-space(./GPL))='esposizione'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='luogo di rilevamento' or lower-case(normalize-space(./GPL))='luogo di rilevamento' or lower-case(normalize-space(./GPL))='di rilevamento' or lower-case(normalize-space(./GPL))='di rilevamento' or lower-case(normalize-space(./GPL))='localizzazione di rilevamento' or lower-case(normalize-space(./GPL))='localizzazione di rilevamento'" />
						<xsl:when
							test="lower-case(normalize-space(./GPL))='area rappresentata' or lower-case(normalize-space(./GPL))='area rappresentata'" />
						<xsl:when test="./GPL">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GPL)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./GPL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./GPL)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- geometry coordinates for GP as an individual -->
				<xsl:for-each select="./GPD/GPDP">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	            			<xsl:value-of
							select="concat($NS, 'Coordinates/', $itemURI, '-geometry-point-', $geometry-position, '-coordinates', '-', position())" />
	            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/Coordinates" />
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GPDPX and (not(starts-with(lower-case(normalize-space(./GPDPX)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPDPX)), 'n.r')))">
							<arco-location:long>
								<xsl:value-of select="normalize-space(./GPDPX)" />
							</arco-location:long>
						</xsl:if>
						<xsl:if test="./GPDPY and (not(starts-with(lower-case(normalize-space(./GPDPY)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPDPY)), 'n.r')))">
							<arco-location:lat>
								<xsl:value-of select="normalize-space(./GPDPY)" />
							</arco-location:lat>
						</xsl:if>
						<xsl:if test="../../GPC/GPCL | ../../GPC/GPCI | ../../GPC/GPCS">
							<arco-location:hasAltitude>
								<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
									select="concat($NS, 'Altitude/', $itemURI, '-geometry-point-', $geometry-position, '-altitude')" />
	            				</xsl:attribute>
							</arco-location:hasAltitude>
						</xsl:if>
					</rdf:Description>
				</xsl:for-each>
				<!-- geometry technique for GP as an individual -->
				<xsl:if test="./GPT and (not(starts-with(lower-case(normalize-space(./GPT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPT)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	            			<xsl:value-of
							select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GPT)))" />
	            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryTechnique" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./GPT)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./GPT)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- geometry method for GP as an individual -->
				<xsl:if test="./GPM and (not(starts-with(lower-case(normalize-space(./GPM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPM)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	            			<xsl:value-of
							select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GPM)))" />
	            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryMethod" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./GPM)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./GPM)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- geometry base map for GP as an individual -->
				<xsl:if test="./GPB">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	            			<xsl:value-of
							select="concat($NS, 'BaseMap/', $itemURI, '-geometry-point-', $geometry-position, '-base-map')" />
	            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/BaseMap" />
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Base cartografica del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Base cartografica del bene culturale: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Base map of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Base map of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GPB/GPBB">
							<arco-core:description>
								<xsl:value-of select="normalize-space(./GPB/GPBB)" />
							</arco-core:description>
						</xsl:if>
						<xsl:if test="./GPB/GPBT and (not(starts-with(lower-case(normalize-space(./GPB/GPBT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPB/GPBT)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(./GPB/GPBT)" />
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./GPB/GPBO">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./GPB/GPBO)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
				<!-- altitude for GP as an individual -->
				<xsl:if test="./GPC/GPCL | ./GPC/GPCI | ./GPC/GPCS">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Altitude/', $itemURI, '-geometry-point-', $geometry-position, '-altitude')" />
            		</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/location/Altitude" />
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Altitudine del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Altitudine del bene culturale: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Altitude of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Altitude of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./GPC/GPCL and (not(starts-with(lower-case(normalize-space(./GPC/GPCL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPC/GPCL)), 'n.r')))">
							<arco-location:alt>
								<xsl:value-of select="normalize-space(./GPC/GPCL)" />
							</arco-location:alt>
						</xsl:if>
						<xsl:if test="./GPC/GPCS and (not(starts-with(lower-case(normalize-space(./GPC/GPCS)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPC/GPCS)), 'n.r')))">
							<arco-location:maxAlt>
								<xsl:value-of select="normalize-space(./GPC/GPCS)" />
							</arco-location:maxAlt>
						</xsl:if>
						<xsl:if test="./GPC/GPCI and (not(starts-with(lower-case(normalize-space(./GPC/GPCI)), 'nr')) and not(starts-with(lower-case(normalize-space(./GPC/GPCI)), 'n.r')))">
							<arco-location:minAlt>
								<xsl:value-of select="normalize-space(./GPC/GPCI)" />
							</arco-location:minAlt>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- Geometry of cultural property as an individual for GL (Line) -->
			<xsl:if test="schede/*/GL">
				<xsl:for-each select="schede/*/GL">
					<xsl:variable name="geometry-position" select="position()" />
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Geometry/', $itemURI, '-geometry-line-', position())" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            				<xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Geometry'" />
            			</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Geometry (line) ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Geometry (line) ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Georeferenziazione (lineare) ', position(), ' del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Georeferenziazione (lineare) ', position(), ' del bene culturale: ', $itemURI)" />
						</l0:name>
						<clvapit:isGeometryFor>
							<xsl:attribute name="rdf:resource">
				           <xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
				        </xsl:attribute>
						</clvapit:isGeometryFor>
						<clvapit:hasGeometryType>
							<xsl:attribute name="rdf:resource">
                            <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Line'" />
                        </xsl:attribute>
						</clvapit:hasGeometryType>
						<xsl:for-each select="./GLD/GLDP">
							<arco-location:hasCoordinates>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'Coordinates/', $itemURI, '-geometry-line-', $geometry-position, '-coordinates', '-', position())" />
            				</xsl:attribute>
							</arco-location:hasCoordinates>
						</xsl:for-each>
						<xsl:if test="./GLP and (not(starts-with(lower-case(normalize-space(./GLP)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLP)), 'n.r')))">
							<arco-location:spacialReferenceSystem>
								<xsl:value-of select="normalize-space(./GLP)" />
							</arco-location:spacialReferenceSystem>
						</xsl:if>
						<xsl:if test="./GLT and (not(starts-with(lower-case(normalize-space(./GLT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLT)), 'n.r')))">
							<arco-location:hasGeometryTechnique>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GLT)))" />
            				</xsl:attribute>
							</arco-location:hasGeometryTechnique>
						</xsl:if>
						<xsl:if test="./GLM and (not(starts-with(lower-case(normalize-space(./GLM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLM)), 'n.r')))">
							<arco-location:hasGeometryMethod>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GLM)))" />
            				</xsl:attribute>
							</arco-location:hasGeometryMethod>
						</xsl:if>
						<xsl:if test="./GLB">
							<arco-location:hasBaseMap>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'BaseMap/', $itemURI, '-geometry-line-', $geometry-position, '-base-map')" />
            				</xsl:attribute>
							</arco-location:hasBaseMap>
						</xsl:if>
						<xsl:if test="./GLL and not(./GLL='.' or ./GLL='-' or ./GLL='/') and (not(starts-with(lower-case(normalize-space(./GLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLL)), 'n.r')))">
						<arco-location:hasReferredLocationType>
							<xsl:attribute name="rdf:resource">
					                                <xsl:choose>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GLL))='luogo di provenienza' or lower-case(normalize-space(./GLL))='provenienza' or lower-case(normalize-space(./GLL))='provenienza'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/LastLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GLL))='luogo di esecuzione/fabbricazione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ProductionRealizationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di reperimento' or lower-case(normalize-space(./GLL))='luogo di reperimento' or lower-case(normalize-space(./GLL))='reperimento' or lower-case(normalize-space(./GLL))='reperimento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/FindingLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di deposito' or lower-case(normalize-space(./GLL))='luogo di deposito' or lower-case(normalize-space(./GLL))='deposito temporaneo' or lower-case(normalize-space(./GLL))='deposito temporaneo' or lower-case(normalize-space(./GLL))='deposito' or lower-case(normalize-space(./GLL))='deposito'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/StorageLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di esposizione' or lower-case(normalize-space(./GLL))='luogo di esposizione' or lower-case(normalize-space(./GLL))='espositiva' or lower-case(normalize-space(./GLL))='espositiva' or lower-case(normalize-space(./GLL))='espositivo' or lower-case(normalize-space(./GLL))='espositivo' or lower-case(normalize-space(./GLL))='esposizione' or lower-case(normalize-space(./GLL))='esposizione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ExhibitionLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='luogo di rilevamento' or lower-case(normalize-space(./GLL))='luogo di rilevamento' or lower-case(normalize-space(./GLL))='di rilevamento' or lower-case(normalize-space(./GLL))='di rilevamento' or lower-case(normalize-space(./GLL))='localizzazione di rilevamento' or lower-case(normalize-space(./GLL))='localizzazione di rilevamento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ObservationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='area rappresentata' or lower-case(normalize-space(./GLL))='area rappresentata'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/SubjectLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GLL))='localizzazione fisica'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/CurrentPhysicalLocation'" />
					                                    </xsl:when>
					                                    <xsl:when test="./GLL">
					                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GLL)))" />
					                                    </xsl:when>
					                                </xsl:choose>
					                            </xsl:attribute>
						</arco-location:hasReferredLocationType>
					</xsl:if>
					</rdf:Description>
					<!-- referred location type for GL as an individual -->
				<xsl:if test="./GLL and not(./GLL='.' or ./GLL='-' or ./GLL='/') and (not(starts-with(lower-case(normalize-space(./GLL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLL)), 'n.r')))">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GLL))='luogo di provenienza' or lower-case(normalize-space(./GLL))='provenienza' or lower-case(normalize-space(./GLL))='provenienza'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GLL))='luogo di esecuzione/fabbricazione'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di reperimento' or lower-case(normalize-space(./GLL))='luogo di reperimento' or lower-case(normalize-space(./GLL))='reperimento' or lower-case(normalize-space(./GLL))='reperimento'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di deposito' or lower-case(normalize-space(./GLL))='luogo di deposito' or lower-case(normalize-space(./GLL))='deposito temporaneo' or lower-case(normalize-space(./GLL))='deposito temporaneo' or lower-case(normalize-space(./GLL))='deposito' or lower-case(normalize-space(./GLL))='deposito'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di esposizione' or lower-case(normalize-space(./GLL))='luogo di esposizione' or lower-case(normalize-space(./GLL))='espositiva' or lower-case(normalize-space(./GLL))='espositiva' or lower-case(normalize-space(./GLL))='espositivo' or lower-case(normalize-space(./GLL))='espositivo' or lower-case(normalize-space(./GLL))='esposizione' or lower-case(normalize-space(./GLL))='esposizione'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='luogo di rilevamento' or lower-case(normalize-space(./GLL))='luogo di rilevamento' or lower-case(normalize-space(./GLL))='di rilevamento' or lower-case(normalize-space(./GLL))='di rilevamento' or lower-case(normalize-space(./GLL))='localizzazione di rilevamento' or lower-case(normalize-space(./GLL))='localizzazione di rilevamento'" />
						<xsl:when
							test="lower-case(normalize-space(./GLL))='area rappresentata' or lower-case(normalize-space(./GLL))='area rappresentata'" />
						<xsl:when test="./GLL">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GLL)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./GLL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./GLL)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
					<!-- geometry coordinates for GL as an individual -->
					<xsl:for-each select="./GLD/GLDP">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'Coordinates/', $itemURI, '-geometry-line-', $geometry-position, '-coordinates', '-', position())" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/Coordinates" />
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GLDPX and (not(starts-with(lower-case(normalize-space(./GLDPX)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLDPX)), 'n.r')))">
								<arco-location:long>
									<xsl:value-of select="normalize-space(./GLDPX)" />
								</arco-location:long>
							</xsl:if>
							<xsl:if test="./GLDPY and (not(starts-with(lower-case(normalize-space(./GLDPY)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLDPY)), 'n.r')))">
								<arco-location:lat>
									<xsl:value-of select="normalize-space(./GLDPY)" />
								</arco-location:lat>
							</xsl:if>
							<xsl:if test="../../GLQ/GLQI | ../../GLQ/GLQS">
								<arco-location:hasAltitude>
									<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
										select="concat($NS, 'Altitude/', $itemURI, '-geometry-line-', $geometry-position, '-altitude')" />
	            				</xsl:attribute>
								</arco-location:hasAltitude>
							</xsl:if>
						</rdf:Description>
					</xsl:for-each>
					<!-- geometry technique for GL as an individual -->
					<xsl:if test="./GLT">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GLT)))" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryTechnique" />
							<rdfs:label>
								<xsl:value-of select="normalize-space(./GLT)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./GLT)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- geometry method for GL as an individual -->
					<xsl:if test="./GLM and (not(starts-with(lower-case(normalize-space(./GLM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLM)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GLM)))" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryMethod" />
							<rdfs:label>
								<xsl:value-of select="normalize-space(./GLM)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./GLM)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- geometry base map for GL as an individual -->
					<xsl:if test="./GLB and (not(starts-with(lower-case(normalize-space(./GLB)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLB)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'BaseMap/', $itemURI, '-geometry-line-', $geometry-position, '-base-map')" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/BaseMap" />
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Base cartografica del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Base cartografica del bene culturale: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Base map of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Base map of cultural property: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GLB/GLBB">
								<arco-core:description>
									<xsl:value-of select="normalize-space(./GLB/GLBB)" />
								</arco-core:description>
							</xsl:if>
							<xsl:if test="./GLB/GLBT and (not(starts-with(lower-case(normalize-space(./GLB/GLBT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLB/GLBT)), 'n.r')))">
								<tiapit:time>
									<xsl:value-of select="normalize-space(./GLB/GLBT)" />
								</tiapit:time>
							</xsl:if>
							<xsl:if test="./GLB/GLBO">
								<arco-core:note>
									<xsl:value-of select="normalize-space(./GLB/GLBO)" />
								</arco-core:note>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
					<!-- altitude for GL as an individual -->
					<xsl:if test="./GLQ/GLQI | ./GLQ/GLQS">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'Altitude/', $itemURI, '-geometry-line-', $geometry-position, '-altitude')" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/Altitude" />
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Altitudine del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Altitudine del bene culturale: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Altitude of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Altitude of cultural property: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GLQ/GLQS and (not(starts-with(lower-case(normalize-space(./GLQ/GLQS)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLQ/GLQS)), 'n.r')))">
								<arco-location:maxAlt>
									<xsl:value-of select="normalize-space(./GLQ/GLQS)" />
								</arco-location:maxAlt>
							</xsl:if>
							<xsl:if test="./GLQ/GLQI and (not(starts-with(lower-case(normalize-space(./GLQ/GLQI)), 'nr')) and not(starts-with(lower-case(normalize-space(./GLQ/GLQI)), 'n.r')))">
								<arco-location:minAlt>
									<xsl:value-of select="normalize-space(./GLQ/GLQI)" />
								</arco-location:minAlt>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- Geometry of cultural property as an individual for GA (Area) -->
			<xsl:if test="schede/*/GA">
				<xsl:variable name="geometry-position" select="position()" />
				<xsl:for-each select="schede/*/GA">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
            			<xsl:value-of
							select="concat($NS, 'Geometry/', $itemURI, '-geometry-polygon-', position())" />
            		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
            				<xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Geometry'" />
            			</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Geometry (area) ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Geometry (area) ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Georeferenziazione (areale) ', position(), ' del bene culturale: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Georeferenziazione (areale) ', position(), ' del bene culturale: ', $itemURI)" />
						</l0:name>
						<clvapit:isGeometryFor>
							<xsl:attribute name="rdf:resource">
				           <xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
				        </xsl:attribute>
						</clvapit:isGeometryFor>
						<clvapit:hasGeometryType>
							<xsl:attribute name="rdf:resource">
                            <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Polygon'" />
                        </xsl:attribute>
						</clvapit:hasGeometryType>
						<xsl:for-each select="./GAD/GADP">
							<arco-location:hasCoordinates>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'Coordinates/', $itemURI, '-geometry-polygon-', $geometry-position, '-coordinates', '-', position())" />
            				</xsl:attribute>
							</arco-location:hasCoordinates>
						</xsl:for-each>
						<xsl:if test="./GAP and (not(starts-with(lower-case(normalize-space(./GAP)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAP)), 'n.r')))">
							<arco-location:spacialReferenceSystem>
								<xsl:value-of select="normalize-space(./GAP)" />
							</arco-location:spacialReferenceSystem>
						</xsl:if>
						<xsl:if test="./GAT and (not(starts-with(lower-case(normalize-space(./GAT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAT)), 'n.r')))">
							<arco-location:hasGeometryTechnique>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GAT)))" />
            				</xsl:attribute>
							</arco-location:hasGeometryTechnique>
						</xsl:if>
						<xsl:if test="./GAM and (not(starts-with(lower-case(normalize-space(./GAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAM)), 'n.r')))">
							<arco-location:hasGeometryMethod>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GAM)))" />
            				</xsl:attribute>
							</arco-location:hasGeometryMethod>
						</xsl:if>
						<xsl:if test="./GAB">
							<arco-location:hasBaseMap>
								<xsl:attribute name="rdf:resource">
            					<xsl:value-of
									select="concat($NS, 'BaseMap/', $itemURI, '-geometry-polygon-', $geometry-position, '-base-map')" />
            				</xsl:attribute>
							</arco-location:hasBaseMap>
						</xsl:if>
						<xsl:if test="./GAL and not(./GAL='.' or ./GAL='-' or ./GAL='/') and (not(starts-with(lower-case(normalize-space(./GAL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAL)), 'n.r')))">
						<arco-location:hasReferredLocationType>
							<xsl:attribute name="rdf:resource">
					                                <xsl:choose>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GAL))='luogo di provenienza' or lower-case(normalize-space(./GAL))='provenienza' or lower-case(normalize-space(./GAL))='provenienza'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/LastLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GAL))='luogo di esecuzione/fabbricazione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ProductionRealizationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di reperimento' or lower-case(normalize-space(./GAL))='luogo di reperimento' or lower-case(normalize-space(./GAL))='reperimento' or lower-case(normalize-space(./GAL))='reperimento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/FindingLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di deposito' or lower-case(normalize-space(./GAL))='luogo di deposito' or lower-case(normalize-space(./GAL))='deposito temporaneo' or lower-case(normalize-space(./GAL))='deposito temporaneo' or lower-case(normalize-space(./GAL))='deposito' or lower-case(normalize-space(./GAL))='deposito'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/StorageLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di esposizione' or lower-case(normalize-space(./GAL))='luogo di esposizione' or lower-case(normalize-space(./GAL))='espositiva' or lower-case(normalize-space(./GAL))='espositiva' or lower-case(normalize-space(./GAL))='espositivo' or lower-case(normalize-space(./GAL))='espositivo' or lower-case(normalize-space(./GAL))='esposizione' or lower-case(normalize-space(./GAL))='esposizione'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ExhibitionLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='luogo di rilevamento' or lower-case(normalize-space(./GAL))='luogo di rilevamento' or lower-case(normalize-space(./GAL))='di rilevamento' or lower-case(normalize-space(./GAL))='di rilevamento' or lower-case(normalize-space(./GAL))='localizzazione di rilevamento' or lower-case(normalize-space(./GAL))='localizzazione di rilevamento'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ObservationLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='area rappresentata' or lower-case(normalize-space(./GAL))='area rappresentata'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/SubjectLocation'" />
					                                    </xsl:when>
					                                    <xsl:when
								test="lower-case(normalize-space(./GAL))='localizzazione fisica'">
					                                        <xsl:value-of
								select="'https://w3id.org/arco/location/CurrentPhysicalLocation'" />
					                                    </xsl:when>
					                                    <xsl:when test="./GAL">
					                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GAL)))" />
					                                    </xsl:when>
					                                </xsl:choose>
					                            </xsl:attribute>
						</arco-location:hasReferredLocationType>
					</xsl:if>
					</rdf:Description>
					<!-- referred location type for GA as an individual -->
				<xsl:if test="./GAL and not(./GAL='.' or ./GAL='-' or ./GAL='/') and (not(starts-with(lower-case(normalize-space(./GAL)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAL)), 'n.r')))">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./GAL))='luogo di provenienza' or lower-case(normalize-space(./GAL))='provenienza' or lower-case(normalize-space(./GAL))='provenienza'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di produzione/realizzazione' or lower-case(normalize-space(./GAL))='luogo di esecuzione/fabbricazione'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di reperimento' or lower-case(normalize-space(./GAL))='luogo di reperimento' or lower-case(normalize-space(./GAL))='reperimento' or lower-case(normalize-space(./GAL))='reperimento'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di deposito' or lower-case(normalize-space(./GAL))='luogo di deposito' or lower-case(normalize-space(./GAL))='deposito temporaneo' or lower-case(normalize-space(./GAL))='deposito temporaneo' or lower-case(normalize-space(./GAL))='deposito' or lower-case(normalize-space(./GAL))='deposito'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di esposizione' or lower-case(normalize-space(./GAL))='luogo di esposizione' or lower-case(normalize-space(./GAL))='espositiva' or lower-case(normalize-space(./GAL))='espositiva' or lower-case(normalize-space(./GAL))='espositivo' or lower-case(normalize-space(./GAL))='espositivo' or lower-case(normalize-space(./GAL))='esposizione' or lower-case(normalize-space(./GAL))='esposizione'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='luogo di rilevamento' or lower-case(normalize-space(./GAL))='luogo di rilevamento' or lower-case(normalize-space(./GAL))='di rilevamento' or lower-case(normalize-space(./GAL))='di rilevamento' or lower-case(normalize-space(./GAL))='localizzazione di rilevamento' or lower-case(normalize-space(./GAL))='localizzazione di rilevamento'" />
						<xsl:when
							test="lower-case(normalize-space(./GAL))='area rappresentata' or lower-case(normalize-space(./GAL))='area rappresentata'" />
						<xsl:when test="./GAL">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./GAL)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./GAL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./GAL)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
					<!-- geometry coordinates for GL as an individual -->
					<xsl:for-each select="./GAD/GADP">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'Coordinates/', $itemURI, '-geometry-polygon-', $geometry-position, '-coordinates', '-', position())" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/Coordinates" />
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Coordinates ', position(), ' of cultural property: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Coordinate ', position(), ' del bene culturale: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GADPX and (not(starts-with(lower-case(normalize-space(./GADPX)), 'nr')) and not(starts-with(lower-case(normalize-space(./GADPX)), 'n.r')))">
								<arco-location:long>
									<xsl:value-of select="normalize-space(./GADPX)" />
								</arco-location:long>
							</xsl:if>
							<xsl:if test="./GADPY and (not(starts-with(lower-case(normalize-space(./GADPY)), 'nr')) and not(starts-with(lower-case(normalize-space(./GADPY)), 'n.r')))">
								<arco-location:lat>
									<xsl:value-of select="normalize-space(./GADPY)" />
								</arco-location:lat>
							</xsl:if>
							<xsl:if test="../../GAQ/GAQI | ../../GAQ/GAQS">
								<arco-location:hasAltitude>
									<xsl:attribute name="rdf:resource">
	            					<xsl:value-of
										select="concat($NS, 'Altitude/', $itemURI, '-geometry-polygon-', $geometry-position, '-altitude')" />
	            				</xsl:attribute>
								</arco-location:hasAltitude>
							</xsl:if>
						</rdf:Description>
					</xsl:for-each>
					<!-- geometry technique for GA as an individual -->
					<xsl:if test="./GAT and (not(starts-with(lower-case(normalize-space(./GAT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAT)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'GeometryTechnique/', arco-fn:urify(normalize-space(./GAT)))" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryTechnique" />
							<rdfs:label>
								<xsl:value-of select="normalize-space(./GAT)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./GAT)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- geometry method for GA as an individual -->
					<xsl:if test="./GAM and (not(starts-with(lower-case(normalize-space(./GAM)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAM)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'GeometryMethod/', arco-fn:urify(normalize-space(./GAM)))" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/GeometryMethod" />
							<rdfs:label>
								<xsl:value-of select="normalize-space(./GAM)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./GAM)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<!-- geometry base map for GA as an individual -->
					<xsl:if test="./GAB">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'BaseMap/', $itemURI, '-geometry-polygon-', $geometry-position, '-base-map')" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/BaseMap" />
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Base cartografica del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Base cartografica del bene culturale: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Base map of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Base map of cultural property: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GAB/GABB">
								<arco-core:description>
									<xsl:value-of select="normalize-space(./GAB/GABB)" />
								</arco-core:description>
							</xsl:if>
							<xsl:if test="./GAB/GABT and (not(starts-with(lower-case(normalize-space(./GAB/GABT)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAB/GABT)), 'n.r')))">
								<tiapit:time>
									<xsl:value-of select="normalize-space(./GAB/GABT)" />
								</tiapit:time>
							</xsl:if>
							<xsl:if test="./GAB/GABO">
								<arco-core:note>
									<xsl:value-of select="normalize-space(./GAB/GABO)" />
								</arco-core:note>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
					<!-- altitude for GA as an individual -->
					<xsl:if test="./GAQ/GAQI | ./GAQ/GAQS">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
	            			<xsl:value-of
								select="concat($NS, 'Altitude/', $itemURI, '-geometry-polygon-', $geometry-position, '-altitude')" />
	            		</xsl:attribute>
							<rdf:type rdf:resource="https://w3id.org/arco/location/Altitude" />
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Altitudine del bene culturale: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Altitudine del bene culturale: ', $itemURI)" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Altitude of cultural property: ', $itemURI)" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Altitude of cultural property: ', $itemURI)" />
							</l0:name>
							<xsl:if test="./GAQ/GAQS and (not(starts-with(lower-case(normalize-space(./GAQ/GAQS)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAQ/GAQS)), 'n.r')))">
								<arco-location:maxAlt>
									<xsl:value-of select="normalize-space(./GAQ/GAQS)" />
								</arco-location:maxAlt>
							</xsl:if>
							<xsl:if test="./GAQ/GAQI and (not(starts-with(lower-case(normalize-space(./GAQ/GAQI)), 'nr')) and not(starts-with(lower-case(normalize-space(./GAQ/GAQI)), 'n.r')))">
								<arco-location:minAlt>
									<xsl:value-of select="normalize-space(./GAQ/GAQI)" />
								</arco-location:minAlt>
							</xsl:if>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- Name in time -->
			<xsl:if test="schede/*/OG/OGD or schede/*/OG/OGT/OGTN">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                    <xsl:choose>
                        <xsl:when test="schede/*/OG/OGD/OGDN">
                        	<xsl:value-of
						select="concat('https://w3id.org/arco/resource/DesignationInTime/', arco-fn:urify(normalize-space(schede/*/OG/OGD/OGDN)))" />
                        </xsl:when>
                        <xsl:when test="schede/*/OG/OGT/OGTN">
                        	<xsl:value-of
						select="concat('https://w3id.org/arco/resource/DesignationInTime/', arco-fn:urify(normalize-space(schede/*/OG/OGT/OGTN)))" />
                        </xsl:when>
                    </xsl:choose>
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/denotative-description/DesignationInTime'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:choose>
							<xsl:when test="schede/*/OG/OGD/OGDN">
								<xsl:value-of select="normalize-space(schede/*/OG/OGD/OGDN)" />
							</xsl:when>
							<xsl:when test="schede/*/OG/OGT/OGTN">
								<xsl:value-of select="normalize-space(schede/*/OG/OGT/OGTN)" />
							</xsl:when>
						</xsl:choose>
					</rdfs:label>
					<l0:name>
						<xsl:choose>
							<xsl:when test="schede/*/OG/OGD/OGDN">
								<xsl:value-of select="normalize-space(schede/*/OG/OGD/OGDN)" />
							</xsl:when>
							<xsl:when test="schede/*/OG/OGT/OGTN">
								<xsl:value-of select="normalize-space(schede/*/OG/OGT/OGTN)" />
							</xsl:when>
						</xsl:choose>
					</l0:name>
					<xsl:if test="schede/*/OG/OGD/OGDR and (not(starts-with(lower-case(normalize-space(schede/*/OG/OGD/OGDR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/OG/OGD/OGDR)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="schede/*/OG/OGD/OGDR" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="schede/*/OG/OGD/OGDS">
						<arco-core:note>
							<xsl:value-of select="schede/*/OG/OGD/OGDS" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="schede/*/OG/OGD/OGDT and (not(starts-with(lower-case(normalize-space(schede/*/OG/OGD/OGDT)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/OG/OGD/OGDT)), 'n.r')))">
						<arco-dd:hasDesignationType>
							<xsl:attribute name="rdf:resource">
                        		<xsl:value-of
								select="concat('https://w3id.org/arco/resource/DesignationType/', arco-fn:urify(normalize-space(schede/*/OG/OGD/OGDT)))" />
                        	</xsl:attribute>
						</arco-dd:hasDesignationType>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<xsl:if test="schede/*/OG/OGD/OGDT">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        	<xsl:value-of
						select="concat('https://w3id.org/arco/resource/DesignationType/', arco-fn:urify(normalize-space(schede/*/OG/OGD/OGDT)))" />
                       </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="'https://w3id.org/arco/denotative-description/DesignationType'" />
						</xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/OG/OGD/OGDT)" />
					</rdfs:label>
					<l0:name>
						<xsl:value-of select="normalize-space(schede/*/OG/OGD/OGDT)" />
					</l0:name>
				</rdf:Description>
			</xsl:if>
			<!-- Name in time - Time interval - rules for previous model <xsl:if test="schede/*/OG/OGD/OGDR"> 
				<rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of select="concat('https://w3id.org/arco/resource/TimeInterval/', 
				arco-fn:urify(schede/*/OG/OGD/OGDR))" /> </xsl:attribute> <rdf:type> <xsl:attribute 
				name="rdf:resource"> <xsl:value-of select="'https://w3id.org/italia/onto/TI/TimeInterval'" 
				/> </xsl:attribute> </rdf:type> <rdfs:label> <xsl:value-of select="normalize-space(schede/*/OG/OGD/OGDR)" 
				/> </rdfs:label> <arco-core:startTime> <xsl:value-of select="schede/*/OG/OGD/OGDR" 
				/> </arco-core:startTime> </rdf:Description> </xsl:if> -->

			<!-- We add the scope of protection as an individual. The scope of protection 
				is associated with a Cultural Property by the property arco-dd:hasMibactScopeOfProtection. 
				ALERT: this part has been removed in version 0.2 as the Mibact Scope of Protection 
				has been defined within the ontologies. -->
			<!-- xsl:if test="schede/*/OG/AMB"> <rdf:Description> <xsl:attribute name="rdf:about"> 
				<xsl:value-of select="concat('https://w3id.org/arco/resource/MibactScopeOfProtection/', 
				arco-fn:urify(normalize-space(schede/*/OG/AMB)))" /> </xsl:attribute> <rdf:type> 
				<xsl:attribute name="rdf:resource"> <xsl:value-of select="'https://w3id.org/arco/cpdescription/MibactScopeOfProtection'" 
				/> </xsl:attribute> </rdf:type> <rdfs:label> <xsl:value-of select="normalize-space(schede/*/OG/AMB)" 
				/> </rdfs:label> </rdf:Description> </xsl:if -->
			<!-- We add the category as an individual. The category is associated 
				with a Cultural Property by the property arco-dd:hasCategory. -->
			<xsl:if test="schede/*/OG/CTG">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat('https://w3id.org/arco/resource/CulturalPropertyCategory/', arco-fn:urify(normalize-space(schede/*/OG/CTG)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/core/CulturalPropertyCategory'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:value-of select="normalize-space(schede/*/OG/CTG)" />
					</rdfs:label>
				</rdf:Description>
			</xsl:if>
			<!-- fruition (VeAC) as an individual -->
			<xsl:if test="schede/*/AU/FRU">
				<xsl:for-each select="schede/*/AU/FRU">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
	                            <xsl:value-of
							select="concat($NS, 'Fruition/', $itemURI, '-', position())" />
	                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
	                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Fruition'" />
	                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Fruizione ', position(), ' del bene: ', $itemURI)" />
						</rdfs:label>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Fruition ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Fruizione ', position(), ' del bene: ', $itemURI)" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Fruition ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if test="./FRUD and (not(starts-with(lower-case(normalize-space(./FRUD)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUD)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(./FRUD)" />
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./FRUN and (not(starts-with(lower-case(normalize-space(./FRUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUN)), 'n.r')))">
							<arco-cd:hasUser>
								<xsl:attribute name="rdf:resource">
	                        			<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FRUN)))" />
	                        		</xsl:attribute>
							</arco-cd:hasUser>
						</xsl:if>
						<xsl:if test="./FRUC and (not(starts-with(lower-case(normalize-space(./FRUC)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUC)), 'n.r')))">
							<arco-cd:hasCircumstance>
								<xsl:attribute name="rdf:resource">
	                        			<xsl:value-of
									select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./FRUC)))" />
	                        		</xsl:attribute>
							</arco-cd:hasCircumstance>
						</xsl:if>
						<xsl:if test="./FRUF and (not(starts-with(lower-case(normalize-space(./FRUF)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUF)), 'n.r')))">
							<arco-cd:hasSource>
								<xsl:attribute name="rdf:resource">
	                        			<xsl:value-of
									select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./FRUF)))" />
	                        		</xsl:attribute>
							</arco-cd:hasSource>
						</xsl:if>
					</rdf:Description>
					<xsl:if test="./FRUN and (not(starts-with(lower-case(normalize-space(./FRUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUN)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                				<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./FRUN)))" />
                			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                        		</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./FRUN)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./FRUN)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<xsl:if test="./FRUC and (not(starts-with(lower-case(normalize-space(./FRUC)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUC)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                				<xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./FRUC)))" />
                			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
									select="'https://w3id.org/arco/context-description/Circumstance'" />
                        		</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./FRUC)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./FRUC)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
					<xsl:if test="./FRUF and (not(starts-with(lower-case(normalize-space(./FRUF)), 'nr')) and not(starts-with(lower-case(normalize-space(./FRUF)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                				<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./FRUF)))" />
                			</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
									select="'https://w3id.org/arco/context-description/Source'" />
                        		</xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./FRUF)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./FRUF)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- Alternative Identifier as an individual (AC/ACC) -->
			<xsl:if test="schede/*/AC/ACC">
				<xsl:for-each select="schede/*/AC/ACC">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                        		<xsl:value-of
							select="concat($NS, 'AlternativeIdentifier/', $itemURI, '-', position())" />
                    		</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="'https://w3id.org/arco/catalogue/AlternativeIdentifier'" />
                        		</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:choose>
								<xsl:when test="./*">
									<xsl:value-of
										select="concat('Codice alternativo ', normalize-space(./ACCC), ' del bene culturale: ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Codice alternativo ', normalize-space(.), ' del bene culturale: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:choose>
								<xsl:when test="./*">
									<xsl:value-of
										select="concat('Codice alternativo ', normalize-space(./ACCC), ' del bene culturale: ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Codice alternativo ', normalize-space(.), ' del bene culturale: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:choose>
								<xsl:when test="./*">
									<xsl:value-of
										select="concat('Alternative identifier ', normalize-space(./ACCC), ' of cultural property: ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Alternative identifier ', normalize-space(.), ' of cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:choose>
								<xsl:when test="./*">
									<xsl:value-of
										select="concat('Alternative identifier ', normalize-space(./ACCC), ' of cultural property: ', $itemURI)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Alternative identifier ', normalize-space(.), ' of cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./ACCS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./ACCS)" />
							</arco-core:note>
						</xsl:if>
						<xsl:if test="./ACCP and (not(starts-with(lower-case(normalize-space(./ACCP)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACCP)), 'n.r')))">
							<arco-catalogue:referenceProject>
								<xsl:value-of select="normalize-space(./ACCP)" />
							</arco-catalogue:referenceProject>
						</xsl:if>
						<xsl:if test="./ACCW and (not(starts-with(lower-case(normalize-space(./ACCW)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACCW)), 'n.r')))">
							<smapit:URL>
								<xsl:value-of select="normalize-space(./ACCW)" />
							</smapit:URL>
						</xsl:if>
						<xsl:if test="./ACCE and (not(starts-with(lower-case(normalize-space(./ACCE)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACCE)), 'n.r')))">
							<arco-core:hasAgentRole>
								<xsl:attribute name="rdf:resource">
                            			<xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-catalogue-record-responsible')" />
                        			</xsl:attribute>
							</arco-core:hasAgentRole>
						</xsl:if>
					</rdf:Description>
					<!-- agent role for catalogue record responsible for alternative identifier 
						as an individual -->
					<xsl:if test="./ACCE and (not(starts-with(lower-case(normalize-space(./ACCE)), 'nr')) and not(starts-with(lower-case(normalize-space(./ACCE)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                        		<xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-catalogue-record-responsible')" />
		                    		</xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile della scheda del bene ', $itemURI, ': ', normalize-space(./ACCE))" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency for catalogue record of cultural property ', $itemURI, ': ', normalize-space(./ACCE))" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of
									select="concat('Ente responsabile della scheda del bene ', $itemURI, ': ', normalize-space(./ACCE))" />
							</l0:name>
							<l0:name xml:lang="en">
								<xsl:value-of
									select="concat('Responsible agency for catalogue record of cultural property ', $itemURI, ': ', normalize-space(./ACCE))" />
							</l0:name>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="concat($NS, 'Role/CatalogueRecordResponsible')" />
				                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ACCE)))" />
				                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				                        <xsl:value-of
								select="concat($NS, 'Role/CatalogueRecordResponsible')" />
				                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Ente responsabile della scheda catalografica'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Responsible agency for catalogue record'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-catalogue-record-responsible')" />
				                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
				                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./ACCE)))" />
				                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
				                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./ACCE)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./ACCE)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
				                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-catalogue-record-responsible')" />
				                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!-- We add the cultural scope attribution as an individual. -->
			<xsl:for-each select="schede/*/AU/ATB">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'CulturalScopeAttribution/', $itemURI, '-cultural-scope-attribution-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/CulturalScopeAttribution'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione di ambito culturale del bene: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione di ambito culturale del bene: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Cultural scope attribution of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Cultural scope attribution of cultural property: ', $itemURI)" />
					</l0:name>
					<xsl:if
						test="./ATBD and not(lower-case(normalize-space(./ATBD))='nr' or lower-case(normalize-space(./ATBD))='n.r.' or lower-case(normalize-space(./ATBD))='nr (recupero pregresso)')">
						<arco-cd:hasCulturalScope>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'CulturalScope/', arco-fn:urify(normalize-space(./ATBD)))" />
                            </xsl:attribute>
						</arco-cd:hasCulturalScope>
					</xsl:if>
					<xsl:if test="./ATBR and (not(starts-with(lower-case(normalize-space(./ATBR)), 'nr')) and not(starts-with(lower-case(normalize-space(./ATBR)), 'n.r')))">
						<arco-cd:hasInterventionRole>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Role/', $itemURI, '-', arco-fn:urify(normalize-space(./ATBR)))" />
                            </xsl:attribute>
						</arco-cd:hasInterventionRole>
					</xsl:if>
					<xsl:if test="./ATBS">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./ATBS)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if
						test="./ATBM and not(lower-case(normalize-space(./ATBM))='nr' or lower-case(normalize-space(./ATBM))='nr (recupero pregresso)' or lower-case(normalize-space(./ATBM))='n.r.')">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./ATBM)))" />
                            </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<!-- We add the cultural scope attribution source as an individual. -->
				<xsl:if
					test="./ATBM and not(lower-case(normalize-space(./ATBM))='nr' or lower-case(normalize-space(./ATBM))='nr (recupero pregresso)' or lower-case(normalize-space(./ATBM))='n.r.')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./ATBM)))" />
                        </xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/context-description/Source" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ATBM)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ATBM)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- We add the cultural scope attribution role as an individual. -->
				<xsl:if test="./ATBR and (not(starts-with(lower-case(normalize-space(./ATBR)), 'nr')) and not(starts-with(lower-case(normalize-space(./ATBR)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Role/', $itemURI, '-', arco-fn:urify(normalize-space(./ATBR)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ATBR)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ATBR)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- We add the cultural scope as an individual. -->
				<xsl:if
					test="./ATBD and not(lower-case(normalize-space(./ATBD))='nr' or lower-case(normalize-space(./ATBD))='n.r.' or lower-case(normalize-space(./ATBD))='nr (recupero pregresso)')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'CulturalScope/', arco-fn:urify(normalize-space(./ATBD)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/CulturalScope'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./ATBD)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./ATBD)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="schede/*/AU/AUT | schede/F/AU/AUF">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'PreferredAuthorshipAttribution/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/PreferredAuthorshipAttribution'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione di autore preferita, maggiormente accreditata o convincente del bene: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione di autore preferita, maggiormente accreditata o convincente del bene: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Preferred authorship attribution of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Preferred authorship attribution of cultural property: ', $itemURI)" />
					</l0:name>
					<xsl:if test="../AUF/AUFK">
						<arco-core:specifications>
							<xsl:value-of select="../AUF/AUFK" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./AUTN or ../AUF/AUFN or ../AUF/AUFB">
						<arco-cd:hasAttributedAuthor>
							<xsl:attribute name="rdf:resource">
                            	<xsl:variable name="author">
		                            <xsl:choose>
		                                <xsl:when test="./AUTA">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTN)), '-', arco-fn:urify(normalize-space(./AUTA)))" />
		                                </xsl:when>
		                                <xsl:when
								test="../AUF/AUFA and ../AUF/AUFN">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFN)), '-', arco-fn:urify(normalize-space(../AUF/AUFA)))" />
		                                </xsl:when>
		                                <xsl:when
								test="../AUF/AUFA and ../AUF/AUFB">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFB)), '-', arco-fn:urify(normalize-space(../AUF/AUFA)))" />
		                                </xsl:when>
		                                <xsl:when test="../AUF/AUFB">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFB)))" />
		                                </xsl:when>
		                                <xsl:when test="../AUF/AUFN">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFN)))" />
		                                </xsl:when>
		                                <xsl:otherwise>
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTN)))" />
		                                </xsl:otherwise>
		                            </xsl:choose>
	                            </xsl:variable>
	                            <xsl:choose>
	                                <xsl:when test="./AUTS">
	                                    <xsl:value-of
								select="concat($author, '-', arco-fn:urify(normalize-space(./AUTS)))" />
	                                </xsl:when>
	                                <xsl:when test="../AUF/AUFS">
	                                    <xsl:value-of
								select="concat($author, '-', arco-fn:urify(normalize-space(../AUF/AUFS)))" />
	                                </xsl:when>
	                                <xsl:otherwise>
	                                    <xsl:value-of select="$author" />
	                                </xsl:otherwise>
	                            </xsl:choose>
                            </xsl:attribute>
						</arco-cd:hasAttributedAuthor>
					</xsl:if>
					<xsl:if
						test="./AUTR or ../AUF/AUFR and not(lower-case(normalize-space(./AUTR))='nr' or lower-case(normalize-space(./AUTR))='nr (recupero pregresso)' or lower-case(normalize-space(./AUTR))='n.r.' or lower-case(normalize-space(./AUTR))='nr [non rilevabile]' or lower-case(normalize-space(./AUTR))='n.r. (non rilevabile)' or lower-case(normalize-space(../AUF/AUFR))='nr' or lower-case(normalize-space(../AUF/AUFR))='nr (recupero pregresso)' or lower-case(normalize-space(../AUF/AUFR))='n.r.' or lower-case(normalize-space(../AUF/AUFR))='nr [non rilevabile]' or lower-case(normalize-space(../AUF/AUFR))='n.r. (non rilevabile)')">
						<arco-cd:hasInterventionRole>
							<xsl:attribute name="rdf:resource">
                            <xsl:choose>
                            	<xsl:when test="./AUTR">
                            		<xsl:value-of
								select="concat($NS, 'Role/', arco-fn:urify(normalize-space(./AUTR)))" />
                            	</xsl:when>
                            	<xsl:otherwise>
                            		<xsl:value-of
								select="concat($NS, 'Role/', arco-fn:urify(normalize-space(../AUF/AUFR)))" />
                           		</xsl:otherwise>
                            </xsl:choose>
                           </xsl:attribute>
						</arco-cd:hasInterventionRole>
					</xsl:if>
					<xsl:if test="./AUTY and (not(starts-with(lower-case(normalize-space(./AUTY)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTY)), 'n.r')))">
						<arco-cd:authorIntervention>
							<xsl:value-of select="normalize-space(./AUTY)" />
						</arco-cd:authorIntervention>
					</xsl:if>
					<xsl:if test="./AUTZ">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./AUTZ)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="./AUTJ and (not(starts-with(lower-case(normalize-space(./AUTJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTJ)), 'n.r')))">
						<arco-cd:hasAuthorityFileCataloguingAgency>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTJ)))" />
                            </xsl:attribute>
						</arco-cd:hasAuthorityFileCataloguingAgency>
					</xsl:if>
					<xsl:if
						test="./AUTM or ../AUF/AUFM and (not(starts-with(lower-case(normalize-space(./AUTM)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTM)), 'n.r')) and not(starts-with(lower-case(normalize-space(../AUF/AUFM)), 'nr')) and not(starts-with(lower-case(normalize-space(../AUF/AUFM)), 'n.r')))">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
                            	<xsl:choose>
                            		<xsl:when test="./AUTM">
                            			<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./AUTM)))" />
                            		</xsl:when>
                                	<xsl:otherwise>
                                		<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../AUF/AUFM)))" />                         	
                                	</xsl:otherwise>
                            	</xsl:choose>
                            </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<xsl:if test="./AUTJ and (not(starts-with(lower-case(normalize-space(./AUTJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTJ)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTJ)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./AUTJ)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./AUTJ)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if
					test="./AUTM or ../AUF/AUFM and (not(starts-with(lower-case(normalize-space(./AUTM)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTM)), 'n.r')) and not(starts-with(lower-case(normalize-space(../AUF/AUFM)), 'nr')) and not(starts-with(lower-case(normalize-space(../AUF/AUFM)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                            		<xsl:when test="./AUTM">
                            			<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./AUTM)))" />
                            		</xsl:when>
                                	<xsl:otherwise>
                                		<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../AUF/AUFM)))" />                         	
                                	</xsl:otherwise>
                            	</xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./AUTM">
									<xsl:value-of select="normalize-space(./AUTM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AUF/AUFM)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./AUTM">
									<xsl:value-of select="normalize-space(./AUTM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AUF/AUFM)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if
					test="./AUTR or ../AUF/AUFR and not(lower-case(normalize-space(./AUTR))='nr' or lower-case(normalize-space(./AUTR))='nr (recupero pregresso)' or lower-case(normalize-space(./AUTR))='n.r.' or lower-case(normalize-space(./AUTR))='nr [non rilevabile]' or lower-case(normalize-space(./AUTR))='n.r. (non rilevabile)' or lower-case(normalize-space(../AUF/AUFR))='nr' or lower-case(normalize-space(../AUF/AUFR))='nr (recupero pregresso)' or lower-case(normalize-space(../AUF/AUFR))='n.r.' or lower-case(normalize-space(../AUF/AUFR))='nr [non rilevabile]' or lower-case(normalize-space(../AUF/AUFR))='n.r. (non rilevabile)')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                            	<xsl:when test="./AUTR">
                            		<xsl:value-of
							select="concat($NS, 'Role/', arco-fn:urify(normalize-space(./AUTR)))" />
                            	</xsl:when>
                            	<xsl:otherwise>
                            		<xsl:value-of
							select="concat($NS, 'Role/', arco-fn:urify(normalize-space(../AUF/AUFR)))" />
                           		</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./AUTR">
									<xsl:value-of select="normalize-space(./AUTR)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AUF/AUFR)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./AUTR">
									<xsl:value-of select="normalize-space(./AUTR)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AUF/AUFR)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if test="./AUTN or ../AUF/AUFN or ../AUF/AUFB">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                        	<xsl:variable name="author">
		                            <xsl:choose>
		                                <xsl:when test="./AUTA">
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTN)), '-', arco-fn:urify(normalize-space(./AUTA)))" />
		                                </xsl:when>
		                                <xsl:when
							test="../AUF/AUFA and ../AUF/AUFN">
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFN)), '-', arco-fn:urify(normalize-space(../AUF/AUFA)))" />
		                                </xsl:when>
		                                <xsl:when
							test="../AUF/AUFA and ../AUF/AUFB">
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFB)), '-', arco-fn:urify(normalize-space(../AUF/AUFA)))" />
		                                </xsl:when>
		                                <xsl:when test="../AUF/AUFB">
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFB)))" />
		                                </xsl:when>
		                                <xsl:when test="../AUF/AUFN">
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(../AUF/AUFN)))" />
		                                </xsl:when>
		                                <xsl:otherwise>
		                                    <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AUTN)))" />
		                                </xsl:otherwise>
		                            </xsl:choose>
	                            </xsl:variable>
	                            <xsl:choose>
	                                <xsl:when test="./AUTS">
	                                    <xsl:value-of
							select="concat($author, '-', arco-fn:urify(normalize-space(./AUTS)))" />
	                                </xsl:when>
	                                <xsl:when test="../AUF/AUFS">
	                                    <xsl:value-of
							select="concat($author, '-', arco-fn:urify(normalize-space(../AUF/AUFS)))" />
	                                </xsl:when>
	                                <xsl:otherwise>
	                                    <xsl:value-of select="$author" />
	                                </xsl:otherwise>
	                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./AUTP))='p'">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./AUTP))='e'">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/COV/Organization'" />
                                    </xsl:when>
                                    <xsl:when test="../AUF/AUFN">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    </xsl:when>
                                    <xsl:when test="./AUTN">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    </xsl:when>
                                    <xsl:when test="./AUTB">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/COV/Organization'" />
                                    </xsl:when>
                                    <xsl:when test="../AUF/AUFB">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/COV/Organization'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./AUTN">
									<xsl:choose>
										<xsl:when test="./AUTS">
											<xsl:value-of
												select="concat(normalize-space(./AUTN), ' (', normalize-space(./AUTS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUTN)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="../AUF/AUFN">
									<xsl:choose>
										<xsl:when test="../AUF/AUFS">
											<xsl:value-of
												select="concat(normalize-space(./AUFN), ' (', normalize-space(./AUFS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUFN)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="../AUF/AUFB">
									<xsl:choose>
										<xsl:when test="../AUF/AUFS">
											<xsl:value-of
												select="concat(normalize-space(./AUFB), ' (', normalize-space(./AUFS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUFB)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./AUTN">
									<xsl:choose>
										<xsl:when test="./AUTS">
											<xsl:value-of
												select="concat(normalize-space(./AUTN), ' (', normalize-space(./AUTS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUTN)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="../AUF/AUFN">
									<xsl:choose>
										<xsl:when test="../AUF/AUFS">
											<xsl:value-of
												select="concat(normalize-space(./AUFN), ' (', normalize-space(./AUFS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUFN)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="../AUF/AUFB">
									<xsl:choose>
										<xsl:when test="../AUF/AUFS">
											<xsl:value-of
												select="concat(normalize-space(./AUFB), ' (', normalize-space(./AUFS), ')')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="normalize-space(./AUFB)" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./AUTA">
							<arco-cd:agentDate>
								<xsl:value-of select="normalize-space(./AUTA)" />
							</arco-cd:agentDate>
						</xsl:if>
						<xsl:if test="../AUF/AUFA">
							<arco-cd:agentDate>
								<xsl:value-of select="normalize-space(../AUF/AUFA)" />
							</arco-cd:agentDate>
						</xsl:if>
						<xsl:if test="./AUTH and (not(starts-with(lower-case(normalize-space(./AUTH)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTH)), 'n.r')))">
							<arco-cd:agentLocalIdentifier>
								<xsl:value-of select="normalize-space(./AUTH)" />
							</arco-cd:agentLocalIdentifier>
						</xsl:if>
						<xsl:if test="../AUF/AUFH and (not(starts-with(lower-case(normalize-space(./AUF/AUFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUF/AUFH)), 'n.r')))">
							<arco-cd:agentLocalIdentifier>
								<xsl:value-of select="normalize-space(../AUF/AUFH)" />
							</arco-cd:agentLocalIdentifier>
						</xsl:if>
						<xsl:if test="./AUTK and (not(starts-with(lower-case(normalize-space(./AUTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./AUTK)), 'n.r')))">
							<arco-cd:authorICCDIdentifier>
								<xsl:value-of select="normalize-space(./AUTK)" />
							</arco-cd:authorICCDIdentifier>
						</xsl:if>
						<xsl:if test="./NCUN and (not(starts-with(lower-case(normalize-space(./NCUN)), 'nr')) and not(starts-with(lower-case(normalize-space(./NCUN)), 'n.r')))">
							<arco-cd:authorICCDIdentifier>
								<xsl:value-of select="normalize-space(./NCUN)" />
							</arco-cd:authorICCDIdentifier>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- responsibility for cultural property (F and FF) -->
			<xsl:for-each select="schede/*/PD/PDF">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Responsibility/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/Responsibility'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Responsabilità ', position(), ' relativamente al bene fotografico: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Responsabilità ', position(), ' relativamente al bene fotografico: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Responsibility ', position(), ' for photographic heritage: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Responsibility ', position(), ' for photographic heritage: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./PDFS">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./PDFS)" />
						</arco-core:note>
					</xsl:if>
						<arco-cd:hasAgentWithResponsibility>
							<xsl:attribute name="rdf:resource">
		                            <xsl:choose>
		                                <xsl:when test="./PDFN and ./PDFA">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFN)), '-', arco-fn:urify(normalize-space(./PDFA)))" />
		                                </xsl:when>
		                                <xsl:when
								test="./PDFN">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFN)))" />
		                                </xsl:when>
		                                <xsl:when
								test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0') and ./PDFA">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFB)), '-', arco-fn:urify(normalize-space(./PDFA)))" />
		                                </xsl:when>
		                                <xsl:when test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFB)))" />
		                                </xsl:when>
		                            </xsl:choose>
                            </xsl:attribute>
						</arco-cd:hasAgentWithResponsibility>
					<xsl:if
						test="./PDFR and not(lower-case(normalize-space(./PDFR))='nr' or lower-case(normalize-space(./PDFR))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFR))='n.r.' or lower-case(normalize-space(./PDFR))='n.r. [non rilevabile]')">
						<arco-cd:hasResponsibilityType>
							<xsl:attribute name="rdf:resource">
                            	<xsl:value-of
								select="concat($NS, 'ResponsibilityType/', arco-fn:urify(normalize-space(./PDFR)))" />
                           </xsl:attribute>
						</arco-cd:hasResponsibilityType>
					</xsl:if>
					<xsl:if test="./PDFD and (not(starts-with(lower-case(normalize-space(./PDFD)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFD)), 'n.r')))">
						<tiapit:time>
							<xsl:value-of select="normalize-space(./PDFD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./PDFJ and (not(starts-with(lower-case(normalize-space(./PDFJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFJ)), 'n.r')))">
						<arco-cd:hasAuthorityFileCataloguingAgency>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFJ)))" />
                            </xsl:attribute>
						</arco-cd:hasAuthorityFileCataloguingAgency>
					</xsl:if>
					<xsl:if test="./PDFL and (not(starts-with(lower-case(normalize-space(./PDFL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFL)), 'n.r')))">
						<arco-core:hasLocation>
							<xsl:attribute name="rdf:resource">
			                     <xsl:value-of
												select="concat($NS, 'GeographicalFeature/', arco-fn:urify(normalize-space(./PDFL)))" />
			                </xsl:attribute>
						</arco-core:hasLocation>
					</xsl:if>
					<xsl:if
						test="./PDFM and not(lower-case(normalize-space(./PDFM))='nr' or lower-case(normalize-space(./PDFM))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFM))='n.r.' or lower-case(normalize-space(./PDFM))='n.r. [non rilevabile]' or lower-case(normalize-space(./PDFM))='n.r. (non rilevabile)')">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./PDFM)))" />
                            </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
					<xsl:if
						test="./PDFC and not(lower-case(normalize-space(./PDFC))='nr' or lower-case(normalize-space(./PDFC))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFC))='n.r.' or lower-case(normalize-space(./PDFC))='n.r. [non rilevabile]' or lower-case(normalize-space(./PDFM))='n.r. (non rilevabile)')">
						<arco-cd:hasCircumstance>
							<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./PDFC)))" />
                            </xsl:attribute>
						</arco-cd:hasCircumstance>
					</xsl:if>
				</rdf:Description>
				<xsl:if test="./PDFJ and (not(starts-with(lower-case(normalize-space(./PDFJ)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFJ)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFJ)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./PDFJ)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./PDFJ)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if
					test="./PDFM and not(lower-case(normalize-space(./PDFM))='nr' or lower-case(normalize-space(./PDFM))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFM))='n.r.' or lower-case(normalize-space(./PDFM))='n.r. [non rilevabile]')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                             <xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./PDFM)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./PDFM)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./PDFM)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
					<xsl:if test="./PDFL and (not(starts-with(lower-case(normalize-space(./PDFL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFL)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'GeographicalFeature/', arco-fn:urify(normalize-space(./PDFL)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'http://dati.beniculturali.it/cis/GeographicalFeature'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./PDFL)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./PDFL)" />
							</l0:name>
						</rdf:Description>
					</xsl:if>
				<xsl:if
					test="./PDFC and not(lower-case(normalize-space(./PDFC))='nr' or lower-case(normalize-space(./PDFC))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFC))='n.r.' or lower-case(normalize-space(./PDFC))='n.r. [non rilevabile]')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                             <xsl:value-of
							select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./PDFC)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Circumstance'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./PDFC)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./PDFC)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if
					test="./PDFR and not(lower-case(normalize-space(./PDFR))='nr' or lower-case(normalize-space(./PDFR))='nr (recupero pregresso)' or lower-case(normalize-space(./PDFR))='n.r.' or lower-case(normalize-space(./PDFR))='n.r. [non rilevabile]')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            		<xsl:value-of
							select="concat($NS, 'ResponsibilityType/', arco-fn:urify(normalize-space(./PDFR)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/ResponsibilityType'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./PDFR)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./PDFR)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- agent with responsibility -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		                            <xsl:choose>
		                                <xsl:when test="./PDFN and ./PDFA">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFN)), '-', arco-fn:urify(normalize-space(./PDFA)))" />
		                                </xsl:when>
		                                <xsl:when
								test="./PDFN">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFN)))" />
		                                </xsl:when>
		                                <xsl:when
								test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0') and ./PDFA">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFB)), '-', arco-fn:urify(normalize-space(./PDFA)))" />
		                                </xsl:when>
		                                <xsl:when test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
		                                    <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./PDFB)))" />
		                                </xsl:when>
		                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./PDFP))='p'">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./PDFP))='e'">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/COV/Organization'" />
                                    </xsl:when>
                                    <xsl:when test="./PDFN and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/CPV/Person'" />
                                    </xsl:when>
                                    <xsl:when test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/COV/Organization'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./PDFN">
									<xsl:value-of select="normalize-space(./PDFN)" />
								</xsl:when>
								<xsl:when test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
									<xsl:value-of select="normalize-space(./PDFB)" />
								</xsl:when>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./PDFN">
									<xsl:value-of select="normalize-space(./PDFN)" />
								</xsl:when>
								<xsl:when test="./PDFB and not($sheetVersion='4.00' or $sheetVersion='4.00_ICCD0')">
									<xsl:value-of select="normalize-space(./PDFB)" />
								</xsl:when>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./PDFA">
							<arco-cd:agentDate>
								<xsl:value-of select="normalize-space(./PDFA)" />
							</arco-cd:agentDate>
						</xsl:if>
						<xsl:if test="./PDFH and (not(starts-with(lower-case(normalize-space(./PDFH)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFH)), 'n.r')))">
							<arco-cd:agentLocalIdentifier>
								<xsl:value-of select="normalize-space(./PDFH)" />
							</arco-cd:agentLocalIdentifier>
						</xsl:if>
						<xsl:if test="./PDFB and $sheetVersion='4.00_ICCD0' and (not(starts-with(lower-case(normalize-space(./PDFB)), 'nr')) and not(starts-with(lower-case(normalize-space(./PDFB)), 'n.r')))">
							<arco-cd:historicalBiographicalInformation>
								<xsl:value-of select="normalize-space(./PDFB)" />
							</arco-cd:historicalBiographicalInformation>
						</xsl:if>
					</rdf:Description>
			</xsl:for-each>
			<!-- inventory as an individual -->
			<xsl:for-each select="schede/*/UB/INV">
				<xsl:if test="./*">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
		            		<xsl:value-of
							select="concat($NS, 'Inventory/', $itemURI, '-', position())" />
		            	</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            	<xsl:value-of
								select="'https://w3id.org/arco/context-description/Inventory'" />
                        	</xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:choose>
								<xsl:when test="./INVA">
									<xsl:value-of select="normalize-space(./INVA)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Inventory ', normalize-space(./INVN), 'of cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<rdfs:label xml:lang="it">
							<xsl:choose>
								<xsl:when test="./INVA">
									<xsl:value-of select="normalize-space(./INVA)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Inventario ', normalize-space(./INVN), 'del bene culturale: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:choose>
								<xsl:when test="./INVA">
									<xsl:value-of select="normalize-space(./INVA)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Inventory ', normalize-space(./INVN), ' of cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<l0:name xml:lang="it">
							<xsl:choose>
								<xsl:when test="./INVA">
									<xsl:value-of select="normalize-space(./INVA)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Inventario ', normalize-space(./INVN), ' del bene culturale: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<xsl:if test="./INVC and (not(starts-with(lower-case(normalize-space(./INVC)), 'nr')) and not(starts-with(lower-case(normalize-space(./INVC)), 'n.r')))">
							<arco-cd:inventoryLocation>
								<xsl:value-of select="normalize-space(./INVC)" />
							</arco-cd:inventoryLocation>
						</xsl:if>
						<xsl:if test="./INVD and (not(starts-with(lower-case(normalize-space(./INVD)), 'nr')) and not(starts-with(lower-case(normalize-space(./INVD)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(./INVD)" />
							</tiapit:time>
						</xsl:if>
						<xsl:if test="./INVS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./INVS)" />
							</arco-core:note>
						</xsl:if>
						<xsl:if test="./INVN and (not(starts-with(lower-case(normalize-space(./INVN)), 'nr')) and not(starts-with(lower-case(normalize-space(./INVN)), 'n.r')))"></xsl:if>
						<arco-cd:inventoryIdentifier>
							<xsl:value-of select="normalize-space(./INVN)" />
						</arco-cd:inventoryIdentifier>
						<!-- responsible of inventory identifier -->
						<xsl:if test="./INVG and (not(starts-with(lower-case(normalize-space(./INVG)), 'nr')) and not(starts-with(lower-case(normalize-space(./INVG)), 'n.r')))">
							<arco-core:hasAgentRole>
								<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-inventory-identifier-responsible')" />
                        		</xsl:attribute>
							</arco-core:hasAgentRole>
							<arco-cd:hasInventoryIdentifierResponsible>
								<xsl:attribute name="rdf:resource">
                            		<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./INVG)))" />
                        		</xsl:attribute>
							</arco-cd:hasInventoryIdentifierResponsible>
						</xsl:if>
					</rdf:Description>
					<!-- agent role for responsible of inventory identifier -->
					<xsl:if test="./INVG and (not(starts-with(lower-case(normalize-space(./INVG)), 'nr')) and not(starts-with(lower-case(normalize-space(./INVG)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                        <xsl:value-of
								select="concat($NS, 'AgentRole/', $itemURI, '-inventory-identifier-responsible')" />
		                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="'https://w3id.org/arco/core/AgentRole'" />
		                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of
									select="concat('Responsabile del numero di inventario del bene ', $itemURI, ': ', normalize-space(./INVG))" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of
									select="concat('Responsible for inventory identifier of cultural property ', $itemURI, ': ', normalize-space(./INVG))" />
							</rdfs:label>
							<arco-core:hasRole>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="concat($NS, 'Role/InventoryIdentifierResponsible')" />
		                        </xsl:attribute>
							</arco-core:hasRole>
							<arco-core:hasAgent>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./INVG)))" />
		                        </xsl:attribute>
							</arco-core:hasAgent>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                        <xsl:value-of
								select="concat($NS, 'Role/InventoryIdentifierResponsible')" />
		                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="'https://w3id.org/italia/onto/RO/Role'" />
		                        </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Responsabile del numero di inventario'" />
							</rdfs:label>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Inventory Identifier Responsible'" />
							</rdfs:label>
							<arco-core:isRoleOf>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-inventory-identifier-responsible')" />
		                        </xsl:attribute>
							</arco-core:isRoleOf>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
		                        <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./INVG)))" />
		                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
		                        </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./INVG)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(./INVG)" />
							</l0:name>
							<arco-core:isAgentOf>
								<xsl:attribute name="rdf:resource">
		                            <xsl:value-of
									select="concat($NS, 'AgentRole/', $itemURI, '-inventory-identifier-responsible')" />
		                        </xsl:attribute>
							</arco-core:isAgentOf>
						</rdf:Description>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- commission as an individual -->
			<xsl:for-each select="schede/*/AU/CMM">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'Commission/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/Commission'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Committenza ', position(), ' del bene ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Commission ', position(), ' of cultural property ', $itemURI)" />
					</l0:name>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Committenza ', position(), ' del bene ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Commission ', position(), ' of cultural property ', $itemURI)" />
					</rdfs:label>
					<xsl:if test="./CMMN">
						<arco-cd:hasCommittent>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CMMN)))" />
                            </xsl:attribute>
						</arco-cd:hasCommittent>
					</xsl:if>
					<xsl:if test="./CMMC and (not(starts-with(lower-case(normalize-space(./CMMC)), 'nr')) and not(starts-with(lower-case(normalize-space(./CMMC)), 'n.r')))">
						<arco-cd:hasCircumstance>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./CMMC)))" />
                            </xsl:attribute>
						</arco-cd:hasCircumstance>
					</xsl:if>
					<xsl:if
						test="./CMMF and not(lower-case(normalize-space(./CMMF))='nr' or lower-case(normalize-space(./CMMF))='nr (recupero pregresso)' or lower-case(normalize-space(./CMMF))='n.r.')">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./CMMF)))" />
                            </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
					<xsl:if test="./CMMD and (not(starts-with(lower-case(normalize-space(./CMMD)), 'nr')) and not(starts-with(lower-case(normalize-space(./CMMD)), 'n.r')))">
						<tiapit:time>
                                <xsl:value-of
								select="normalize-space(./CMMD)" />
						</tiapit:time>
					</xsl:if>
					<xsl:if test="./CMMY">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./CMMY)" />
						</arco-core:note>
					</xsl:if>
				</rdf:Description>
				<xsl:if
					test="./CMMF and not(lower-case(normalize-space(./CMMF))='nr' or lower-case(normalize-space(./CMMF))='nr (recupero pregresso)' or lower-case(normalize-space(./CMMF))='n.r.')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./CMMF)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./CMMF)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./CMMF)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if test="./CMMC and (not(starts-with(lower-case(normalize-space(./CMMC)), 'nr')) and not(starts-with(lower-case(normalize-space(./CMMC)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(./CMMC)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Circumstance'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./CMMC)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./CMMC)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if test="./CMMN">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./CMMN)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./CMMN)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./CMMN)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="schede/*/AU/AAT | schede/F/AU/AAF">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'AlternativeAuthorshipAttribution/', $itemURI, '-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/context-description/AlternativeAuthorshipAttribution'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione superata, alternativa o tradizionale di autore del bene: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Attribuzione superata, alternativa o tradizionale di autore del bene: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Alternative authorship attribution of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Alternative authorship attribution of cultural property: ', $itemURI)" />
					</l0:name>
					<arco-cd:hasAttributedAuthor>
						<xsl:attribute name="rdf:resource">
                        	<xsl:variable name="author">
	                            <xsl:choose>
	                                <xsl:when test="./AATN">
		                                <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AATN)))" />
		                            </xsl:when>
		                            <!-- alternative authorship attribution in F 3.00 -->
		                            <xsl:when test="../AAF/AAFN">
		                                <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AAFN)))" />
		                            </xsl:when>
		                            <!-- alternative authorship attribution in F 3.00 -->
		                            <xsl:when test="../AAF/AAFB">
		                                <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AAFB)))" />
		                            </xsl:when>
		                            <xsl:otherwise>
		                                <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
		                            </xsl:otherwise>
	                            </xsl:choose>
	                        </xsl:variable>
	                        <xsl:choose>
	                        	<xsl:when test="./AATA">
	                            	<xsl:value-of
							select="concat($author, '-', arco-fn:urify(normalize-space(./AATA)))" />
	                            </xsl:when>
	                            <xsl:otherwise>
	                            	<xsl:value-of select="$author" />
	                            </xsl:otherwise>
	                       </xsl:choose>
                        </xsl:attribute>
					</arco-cd:hasAttributedAuthor>
					<xsl:if test="./AATY">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./AATY)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if
						test="./AATM or ../AAF/AAFM and not(lower-case(normalize-space(./AATM))='nr' or lower-case(normalize-space(./AATM))='nr (recupero pregresso)' or lower-case(normalize-space(./AATM))='n.r.' or lower-case(normalize-space(./AATM))='n.r. (non rilevabile)' or lower-case(normalize-space(./AATM))='n.r. [non rilevabile]' or lower-case(normalize-space(../AAF/AAFM))='nr' or lower-case(normalize-space(../AAF/AAFM))='nr (recupero pregresso)' or lower-case(normalize-space(../AAF/AAFM))='n.r.' or lower-case(normalize-space(../AAF/AAFM))='n.r. (non rilevabile)' or lower-case(normalize-space(../AAF/AAFM))='n.r. [non rilevabile]')">
						<arco-cd:hasSource>
							<xsl:attribute name="rdf:resource">
                            <xsl:choose>
                            	<xsl:when test="./AATM">
                            		<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./AATM)))" />
                            	</xsl:when>
                            	<xsl:otherwise>
                            		<xsl:value-of
								select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../AAF/AAFM)))" />
                            	</xsl:otherwise>
                            </xsl:choose>
                            </xsl:attribute>
						</arco-cd:hasSource>
					</xsl:if>
				</rdf:Description>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                    	<xsl:variable name="author">
                            <xsl:choose>
                                <xsl:when test="./AATN">
	                                <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AATN)))" />
	                            </xsl:when>
	                            <xsl:when test="../AAF/AAFN">
	                                <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AAFN)))" />
	                            </xsl:when>
	                            <xsl:when test="../AAF/AAFB">
		                                <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./AAFB)))" />
		                            </xsl:when>
	                            <xsl:otherwise>
	                                <xsl:value-of
						select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
	                            </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                        	<xsl:when test="./AATA">
                            	<xsl:value-of
						select="concat($author, '-', arco-fn:urify(normalize-space(./AATA)))" />
                            </xsl:when>
                            <xsl:otherwise>
                            	<xsl:value-of select="$author" />
                            </xsl:otherwise>
                       </xsl:choose>
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/l0/Agent'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:choose>
							<xsl:when test="./AATN">
								<xsl:value-of select="normalize-space(./AATN)" />
							</xsl:when>
							<xsl:when test="../AAF/AAFN">
								<xsl:value-of select="normalize-space(../AAF/AAFN)" />
							</xsl:when>
							<xsl:when test="../AAF/AAFB">
								<xsl:value-of select="normalize-space(../AAF/AAFB)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)" />
							</xsl:otherwise>
						</xsl:choose>
					</rdfs:label>
					<l0:name>
						<xsl:choose>
							<xsl:when test="./AATN">
								<xsl:value-of select="normalize-space(./AATN)" />
							</xsl:when>
							<xsl:when test="../AAF/AAFN">
								<xsl:value-of select="normalize-space(../AAF/AAFN)" />
							</xsl:when>
							<xsl:when test="../AAF/AAFB">
								<xsl:value-of select="normalize-space(../AAF/AAFB)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)" />
							</xsl:otherwise>
						</xsl:choose>
					</l0:name>
					<xsl:if test="./AATA">
						<arco-cd:agentDate>
							<xsl:value-of select="normalize-space(./AATA)" />
						</arco-cd:agentDate>
					</xsl:if>
				</rdf:Description>
				<xsl:if
					test="./AATM or ../AAF/AAFM and not(lower-case(normalize-space(./AATM))='nr' or lower-case(normalize-space(./AATM))='nr (recupero pregresso)' or lower-case(normalize-space(./AATM))='n.r.' or lower-case(normalize-space(./AATM))='n.r. (non rilevabile)' or lower-case(normalize-space(./AATM))='n.r. [non rilevabile]' or lower-case(normalize-space(../AAF/AAFM))='nr' or lower-case(normalize-space(../AAF/AAFM))='nr (recupero pregresso)' or lower-case(normalize-space(../AAF/AAFM))='n.r.' or lower-case(normalize-space(../AAF/AAFM))='n.r. (non rilevabile)' or lower-case(normalize-space(../AAF/AAFM))='n.r. [non rilevabile]')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                       	 <xsl:choose>
                        	<xsl:when test="./AATM">
                            	<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(./AATM)))" />
                            </xsl:when>
                            <xsl:otherwise>
                            	<xsl:value-of
							select="concat($NS, 'Source/', arco-fn:urify(normalize-space(../AAF/AAFM)))" />                      
                            </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Source'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="./AATM">
									<xsl:value-of select="normalize-space(./AATM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AAF/AAFM)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="./AATM">
									<xsl:value-of select="normalize-space(./AATM)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(../AAF/AAFM)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<!-- xsl:if test="schede/*/AU/ATB/ATBD"> <rdf:Description> <xsl:attribute 
				name="rdf:about"> <xsl:value-of select="concat($NS, 'CulturalScope/', arco-fn:urify(normalize-space(schede/*/AU/ATB/ATBD)))" 
				/> </xsl:attribute> <rdf:type> <xsl:attribute name="rdf:resource"> <xsl:value-of 
				select="'https://w3id.org/arco/culturaldefinition/CulturalScope'" /> </xsl:attribute> 
				</rdf:type> <rdfs:label> <xsl:value-of select="normalize-space(schede/*/AU/ATB/ATBD)" 
				/> </rdfs:label> </rdf:Description> </xsl:if> <xsl:if test="schede/*/AU/ATB/ATBR"> 
				<rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of select="concat($NS, 
				'Role/', arco-fn:urify(normalize-space(schede/*/AU/ATB/ATBR)))" /> </xsl:attribute> 
				<rdf:type> <xsl:attribute name="rdf:resource"> <xsl:value-of select="'https://w3id.org/italia/onto/RO/Role'" 
				/> </xsl:attribute> </rdf:type> <rdfs:label> <xsl:value-of select="normalize-space(schede/*/AU/ATB/ATBR)" 
				/> </rdfs:label> </rdf:Description> </xsl:if> <xsl:if test="schede/*/AU/ATB/ATBM"> 
				<rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of select="concat($NS, 
				'Source/', arco-fn:urify(normalize-space(schede/*/AU/ATB/ATBM)))" /> </xsl:attribute> 
				<rdf:type> <xsl:attribute name="rdf:resource"> <xsl:value-of select="'https://w3id.org/arco/culturaldefinition/Source'" 
				/> </xsl:attribute> </rdf:type> <rdfs:label> <xsl:value-of select="normalize-space(schede/*/AU/ATB/ATBM)" 
				/> </rdfs:label> </rdf:Description> </xsl:if -->
			<!-- member of collection -->
			<xsl:for-each select="schede/*/UB/COL">
				<xsl:if test="./*">
				<xsl:variable name="collection-membership-position">
					<xsl:value-of select="position()" />
				</xsl:variable>
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'CollectionMembership/', $itemURI, '-collection-membership-', position())" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/CollectionMembership'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Appartenenza a collezione ', position(), ' del bene: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Appartenenza a collezione ', position(), ' del bene: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Collection membership ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Collection membership ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<arco-cd:hasCulturalProperty>
							<xsl:attribute name="rdf:resource">
                        		<xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                        	</xsl:attribute>
						</arco-cd:hasCulturalProperty>
						<arco-cd:hasCollection>
							<xsl:attribute name="rdf:resource">
								<xsl:choose>
									<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', arco-fn:urify(normalize-space(./COLD)))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', $itemURI, '-', $collection-membership-position)" />
									</xsl:otherwise>
								</xsl:choose>
                        	</xsl:attribute>
						</arco-cd:hasCollection>
						<xsl:if test="./COLM and (not(starts-with(lower-case(normalize-space(./COLM)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLM)), 'n.r')))">
							<arco-cd:leavingReason>
								<xsl:value-of select="normalize-space(./COLM)" />
							</arco-cd:leavingReason>
						</xsl:if>
						<xsl:if test="./COLI and (not(starts-with(lower-case(normalize-space(./COLI)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLI)), 'n.r')))">
							<arco-cd:collectionUnitIdentifier>
								<xsl:value-of select="normalize-space(./COLI)" />
							</arco-cd:collectionUnitIdentifier>
						</xsl:if>
						<xsl:if test="./COLV and (not(starts-with(lower-case(normalize-space(./COLV)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLV)), 'n.r')))">
							<arco-cd:culturalPropertyValue>
								<xsl:value-of select="normalize-space(./COLV)" />
							</arco-cd:culturalPropertyValue>
						</xsl:if>
						<xsl:if test="./COLU or ./COLA and (not(starts-with(lower-case(normalize-space(./COLU)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLU)), 'n.r')) and not(starts-with(lower-case(normalize-space(./COLA)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLA)), 'n.r')))">
							<tiapit:atTime>
								<xsl:attribute name="rdf:resource">
                        		<xsl:choose>
                        			<xsl:when test="./COLU and ./COLA">
                        				<xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLA)), '-', arco-fn:urify(normalize-space(./COLU)))" />
                        			</xsl:when>
                        			<xsl:when test="./COLU">
                        				<xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLU)))" />
                        			</xsl:when>
                        			<xsl:when test="./COLA">
                        				<xsl:value-of
									select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLA)))" />
                        			</xsl:when>
                        			</xsl:choose>
                        		</xsl:attribute>
							</tiapit:atTime>
						</xsl:if>
					</rdf:Description>
					<!-- time interval of member of collection -->
					<xsl:if test="./COLU or ./COLA and (not(starts-with(lower-case(normalize-space(./COLU)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLU)), 'n.r')) and not(starts-with(lower-case(normalize-space(./COLA)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLA)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                        <xsl:choose>
                        	<xsl:when test="./COLU and ./COLA">
                        		<xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLA)), '-', arco-fn:urify(normalize-space(./COLU)))" />
                        	</xsl:when>
                        	<xsl:when test="./COLU">
                        		<xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLU)))" />
                        	</xsl:when>
                        	<xsl:when test="./COLA">
                        		<xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(./COLA)))" />
                        	</xsl:when>
                        	</xsl:choose>
                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                            <xsl:value-of
									select="'https://w3id.org/italia/onto/TI/TimeInterval'" />
                        </xsl:attribute>
							</rdf:type>
							<arco-core:startTime>
								<xsl:value-of select="normalize-space(./COLA)" />
							</arco-core:startTime>
							<arco-core:endTime>
								<xsl:value-of select="normalize-space(./COLU)" />
							</arco-core:endTime>
						</rdf:Description>
					</xsl:if>
					<!-- collection of cultural entities -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
						<xsl:choose>
									<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', arco-fn:urify(normalize-space(./COLD)))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', $itemURI, '-', $collection-membership-position)" />
									</xsl:otherwise>
						</xsl:choose>
                	</xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                            <xsl:value-of
								select="'http://dati.beniculturali.it/cis/CollectionOfCulturalEntities'" />
                        </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:choose>
								<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
									<xsl:value-of select="normalize-space(./COLD)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Collezione contenente il bene: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:choose>
								<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
									<xsl:value-of select="normalize-space(./COLD)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Collezione contenente il bene: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:choose>
								<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
									<xsl:value-of select="normalize-space(./COLD)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Collection with cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:choose>
								<xsl:when test="./COLD and (not(starts-with(lower-case(normalize-space(./COLD)), 'nr')) and not(starts-with(lower-case(normalize-space(./COLD)), 'n.r')))">
									<xsl:value-of select="normalize-space(./COLD)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="concat('Collection with cultural property: ', $itemURI)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
						<arco-cd:isCollectionIn>
							<xsl:attribute name="rdf:resource">
                    		<xsl:value-of
								select="concat($NS, 'CollectionMembership/', $itemURI, '-collection-membership-', position())" />
                    	</xsl:attribute>
						</arco-cd:isCollectionIn>
						<xsl:if test="./COLS">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./COLS)" />
							</arco-core:note>
						</xsl:if>
						<xsl:if test="./COLC or ./COLN">
							<arco-cd:hasCollector>
								<xsl:attribute name="rdf:resource">
                    			<xsl:choose>
                    				<xsl:when test="./COLC">
                    					<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COLC)))" />
                    				</xsl:when>
                    				<xsl:otherwise>
                    					<xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COLN)))" />
                    				</xsl:otherwise>
                    			</xsl:choose>
                    		</xsl:attribute>
							</arco-cd:hasCollector>
						</xsl:if>
					</rdf:Description>
					<!-- collector of collection of cultural entities -->
					<xsl:if test="./COLC or ./COLN">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                		<xsl:choose>
                    		<xsl:when test="./COLC">
                    			<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COLC)))" />
                    		</xsl:when>
                    		<xsl:otherwise>
                    			<xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(./COLN)))" />
                    		</xsl:otherwise>
                    	</xsl:choose>
                    </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:choose>
									<xsl:when test="./COLC">
										<xsl:value-of select="normalize-space(./COLC)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./COLN)" />
									</xsl:otherwise>
								</xsl:choose>
							</rdfs:label>
							<l0:name>
								<xsl:choose>
									<xsl:when test="./COLC">
										<xsl:value-of select="normalize-space(./COLC)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="normalize-space(./COLN)" />
									</xsl:otherwise>
								</xsl:choose>
							</l0:name>
							<arco-cd:isCollectorOf>
								<xsl:choose>
									<xsl:when test="./COLD">
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', arco-fn:urify(normalize-space(./COLD)))" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
								select="concat($NS, 'CollectionOfCulturalEntities/', $itemURI, '-', $collection-membership-position)" />
									</xsl:otherwise>
								</xsl:choose>
							</arco-cd:isCollectorOf>
						</rdf:Description>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- conservation status -->
			<xsl:for-each select="schede/*/CO/STC">
				<xsl:if test="./*">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'ConservationStatus/', $itemURI, '-conservation-status-', position())" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/denotative-description/ConservationStatus'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Stato di conservazione ', position(), ' del bene: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Stato di conservazione ', position(), ' del bene: ', $itemURI)" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Conservation status ', position(), ' of cultural property: ', $itemURI)" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Conservation status ', position(), ' of cultural property: ', $itemURI)" />
						</l0:name>
						<xsl:if
							test="./STCC and not(lower-case(normalize-space(./STCC))='nr' or lower-case(normalize-space(./STCC))='n.r.' or lower-case(normalize-space(./STCC))='nr (recupero pregresso)')">
							<arco-dd:hasConservationStatusType>
								<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
									test="lower-case(normalize-space(./STCC))='buono' or lower-case(normalize-space(./STCC))='buonoe' or lower-case(normalize-space(./STCC))='buona'">
                                        <xsl:value-of
									select="'https://w3id.org/arco/denotative-description/Good'" />
                                    </xsl:when>
                                    <xsl:when
									test="lower-case(normalize-space(./STCC))='mediocre'">
                                        <xsl:value-of
									select="'https://w3id.org/arco/denotative-description/Mediocre'" />
                                    </xsl:when>
                                    <xsl:when
									test="lower-case(normalize-space(./STCC))='discreto' or lower-case(normalize-space(./STCC))='discreta'">
                                        <xsl:value-of
									select="'https://w3id.org/arco/denotative-description/Decent'" />
                                    </xsl:when>
                                    <xsl:when
									test="lower-case(normalize-space(./STCC))='cattivo' or lower-case(normalize-space(./STCC))='cattiva'">
                                        <xsl:value-of
									select="'https://w3id.org/arco/denotative-description/Bad'" />
                                    </xsl:when>
                                    <xsl:when
									test="lower-case(normalize-space(./STCC))='dato non disponibile'">
                                        <xsl:value-of
									select="'https://w3id.org/arco/denotative-description/Unavailable'" />
                                    </xsl:when>
                                    <xsl:when test="./STCC">
                                        <xsl:value-of
									select="concat($NS, 'ConservationStatusType/', arco-fn:urify(normalize-space(./STCC)))" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
							</arco-dd:hasConservationStatusType>
						</xsl:if>
						<xsl:if test="./STCS">
							<arco-core:specifications>
								<xsl:value-of select="normalize-space(./STCS)" />
							</arco-core:specifications>
						</xsl:if>
						<xsl:if test="./STCN">
							<arco-core:note>
								<xsl:value-of select="normalize-space(./STCN)" />
							</arco-core:note>
						</xsl:if>
					</rdf:Description>
					<xsl:if
						test="./STCC and not(lower-case(normalize-space(./STCC))='nr' or lower-case(normalize-space(./STCC))='n.r.' or lower-case(normalize-space(./STCC))='nr (recupero pregresso)')">
						<xsl:choose>
							<xsl:when
								test="lower-case(normalize-space(./STCC))='buono' or lower-case(normalize-space(./STCC))='buonoe' or lower-case(normalize-space(./STCC))='buona'" />
							<xsl:when test="lower-case(normalize-space(./STCC))='mediocre'" />
							<xsl:when
								test="lower-case(normalize-space(./STCC))='discreto' or lower-case(normalize-space(./STCC))='discreta'" />
							<xsl:when
								test="lower-case(normalize-space(./STCC))='cattivo' or lower-case(normalize-space(./STCC))='cattiva'" />
							<xsl:when
								test="lower-case(normalize-space(./STCC))='dato non disponibile'" />
							<xsl:when test="./STCC">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    <xsl:value-of
										select="concat($NS, 'ConservationStatusType/', arco-fn:urify(normalize-space(./STCC)))" />
                                </xsl:attribute>
									<rdf:type
										rdf:resource="https://w3id.org/arco/denotative-description/ConservationStatusType" />
									<rdfs:label>
										<xsl:value-of select="normalize-space(./STCC)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./STCC)" />
									</l0:name>
								</rdf:Description>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<!-- We create the Time Indexed Qualified Location associated with the 
				Cultural Property -->
			<xsl:if test="schede/*/LC">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-current')" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/location/TimeIndexedQualifiedLocation'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Localizzazione fisica attuale del bene: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Localizzazione fisica attuale del bene: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Current physical location of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Current physical location of cultural property: ', $itemURI)" />
					</l0:name>
					<arco-location:hasLocationType>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/location/CurrentPhysicalLocation'" />
                        </xsl:attribute>
					</arco-location:hasLocationType>
					<xsl:if test="schede/*/LC/LDC/LDCS">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCS)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if
						test="schede/*/LC/PVC/PVCV and not(lower-case(normalize-space(schede/*/LC/PVC/PVCV))='nr' or lower-case(normalize-space(schede/*/LC/PVC/PVCV))='n.r.' or lower-case(normalize-space(schede/*/LC/PVC/PVCV))='nr (recupero pregresso)' or lower-case(normalize-space(schede/*/LC/PVC/PVCV))='.' or lower-case(normalize-space(schede/*/LC/PVC/PVCV))='-')">
						<arco-location:locationDetails>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCV)" />
						</arco-location:locationDetails>
					</xsl:if>
					<xsl:if test="schede/*/LC/LCN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(schede/*/LC/LCN)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="schede/*/UB/UBO">
						<arco-core:note>
							<xsl:value-of
								select="concat('Ubicazione originaria: ', normalize-space(schede/*/UB/UBO))" />
						</arco-core:note>
					</xsl:if>
					<xsl:if test="schede/*/LC/LDC/LDCD">
						<tiapit:atTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCD)))" />
                            </xsl:attribute>
						</tiapit:atTime>
					</xsl:if>
				</rdf:Description>
			</xsl:if>
			<!-- Time Interval for Current Location -->
			<xsl:if test="schede/*/LC/LDC/LDCD">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeInterval/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCD)))" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/TI/TimeInteval'" />
                        </xsl:attribute>
					</rdf:type>
					<tiapit:time>
						<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCD)" />
					</tiapit:time>
				</rdf:Description>
			</xsl:if>
			<!-- alternative locations + shot location for F catalogue record -->
			<xsl:for-each select="schede/*/LA | schede/F/LR">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of
						select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-alternative-', position())" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/arco/location/TimeIndexedQualifiedLocation'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Localizzazione alternativa ', position(), ' del bene: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Localizzazione alternativa ', position(), ' del bene: ', $itemURI)" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Alternative location ', position(), ' of cultural property: ', $itemURI)" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Alternative location ', position(), ' of cultural property: ', $itemURI)" />
					</l0:name>
					<xsl:if test="./PRC/PRCS">
						<arco-core:specifications>
							<xsl:value-of select="normalize-space(./PRC/PRCS)" />
						</arco-core:specifications>
					</xsl:if>
					<xsl:if test="./LAN">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./LAN)" />
						</arco-core:note>
					</xsl:if>
					<xsl:if
						test="./TLC or ./TCL or ../../F/LR and not(./TLC='.' or ./TCL='.' or ./TLC='-' or ./TCL='-' or ./TLC='/' or ./TCL='/') and (not(starts-with(lower-case(normalize-space(./TCL)), 'nr')) and not(starts-with(lower-case(normalize-space(./TCL)), 'n.r')) and not(starts-with(lower-case(normalize-space(./TLC)), 'nr')) and not(starts-with(lower-case(normalize-space(./TLC)), 'n.r')))">
						<arco-location:hasLocationType>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./TCL))='luogo di provenienza' or lower-case(normalize-space(./TLC))='provenienza' or lower-case(normalize-space(./TCL))='provenienza'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/LastLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di produzione/realizzazione' or lower-case(normalize-space(./TCL))='luogo di esecuzione/fabbricazione'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ProductionRealizationLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di reperimento' or lower-case(normalize-space(./TCL))='luogo di reperimento' or lower-case(normalize-space(./TLC))='reperimento' or lower-case(normalize-space(./TCL))='reperimento'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/FindingLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di deposito' or lower-case(normalize-space(./TCL))='luogo di deposito' or lower-case(normalize-space(./TLC))='deposito temporaneo' or lower-case(normalize-space(./TCL))='deposito temporaneo' or lower-case(normalize-space(./TLC))='deposito' or lower-case(normalize-space(./TCL))='deposito'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/StorageLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di esposizione' or lower-case(normalize-space(./TCL))='luogo di esposizione' or lower-case(normalize-space(./TLC))='espositiva' or lower-case(normalize-space(./TCL))='espositiva' or lower-case(normalize-space(./TLC))='espositivo' or lower-case(normalize-space(./TCL))='espositivo' or lower-case(normalize-space(./TLC))='esposizione' or lower-case(normalize-space(./TCL))='esposizione'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ExhibitionLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='luogo di rilevamento' or lower-case(normalize-space(./TCL))='luogo di rilevamento' or lower-case(normalize-space(./TCL))='di rilevamento' or lower-case(normalize-space(./TLC))='di rilevamento' or lower-case(normalize-space(./TCL))='localizzazione di rilevamento' or lower-case(normalize-space(./TLC))='localizzazione di rilevamento'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/ObservationLocation'" />
                                    </xsl:when>
                                    <xsl:when
								test="lower-case(normalize-space(./TLC))='area rappresentata' or lower-case(normalize-space(./TCL))='area rappresentata'">
                                        <xsl:value-of
								select="'https://w3id.org/arco/location/SubjectLocation'" />
                                    </xsl:when>
                                    <xsl:when test="./TLC">
                                        <xsl:variable
								name="tlc" select="normalize-space(./TLC)" />
                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./TLC)))" />
                                    </xsl:when>
                                    <xsl:when test="./TCL">
                                        <xsl:variable
								name="tcl" select="normalize-space(./TCL)" />
                                        <xsl:value-of
								select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./TCL)))" />
                                    </xsl:when>
                                    <xsl:when test="../../F/LR">
                                    	<xsl:value-of
								select="'https://w3id.org/arco/location/ShotLocation'" />
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-location:hasLocationType>
					</xsl:if>
					<xsl:if test="./PRD or ../../F/LR/LRD and (not(starts-with(lower-case(normalize-space(./PRD)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRD)), 'n.r')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRD)), 'n.r')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRD)), 'n.r')))">
						<tiapit:atTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeInterval/', $itemURI, '-time-interval-', position())" />
                            </xsl:attribute>
						</tiapit:atTime>
					</xsl:if>
					<!-- hasCircumstance for Shot Location (F) -->
					<xsl:if test="../../F/LR/LRO and (not(starts-with(lower-case(normalize-space(../../F/LR/LRO)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRO)), 'n.r')))">
						<arco-cd:hasCircumstance>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(../../F/LR/LRO)))" />
                            </xsl:attribute>
						</arco-cd:hasCircumstance>
					</xsl:if>
				</rdf:Description>
				<xsl:if test="./TLC or ./TCL">
					<xsl:choose>
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di provenienza/collocazione precedente' or lower-case(normalize-space(./TCL))='luogo di provenienza' or lower-case(normalize-space(./TLC))='provenienza' or lower-case(normalize-space(./TCL))='provenienza'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di produzione/realizzazione' or lower-case(normalize-space(./TCL))='luogo di esecuzione/fabbricazione'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di reperimento' or lower-case(normalize-space(./TCL))='luogo di reperimento' or lower-case(normalize-space(./TLC))='reperimento' or lower-case(normalize-space(./TCL))='reperimento'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di deposito' or lower-case(normalize-space(./TCL))='luogo di deposito' or lower-case(normalize-space(./TLC))='deposito temporaneo' or lower-case(normalize-space(./TCL))='deposito temporaneo' or lower-case(normalize-space(./TLC))='deposito' or lower-case(normalize-space(./TCL))='deposito'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di esposizione' or lower-case(normalize-space(./TCL))='luogo di esposizione' or lower-case(normalize-space(./TLC))='espositiva' or lower-case(normalize-space(./TCL))='espositiva' or lower-case(normalize-space(./TLC))='espositivo' or lower-case(normalize-space(./TCL))='espositivo' or lower-case(normalize-space(./TLC))='esposizione' or lower-case(normalize-space(./TCL))='esposizione'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='luogo di rilevamento' or lower-case(normalize-space(./TCL))='luogo di rilevamento' or lower-case(normalize-space(./TCL))='di rilevamento' or lower-case(normalize-space(./TLC))='di rilevamento' or lower-case(normalize-space(./TCL))='localizzazione di rilevamento' or lower-case(normalize-space(./TLC))='localizzazione di rilevamento'" />
						<xsl:when
							test="lower-case(normalize-space(./TLC))='area rappresentata' or lower-case(normalize-space(./TCL))='area rappresentata'" />
						<xsl:when test="./TLC and not(./TLC='.' or ./TLC='-' or ./TLC='/')  and (not(starts-with(lower-case(normalize-space(./TLC)), 'nr')) and not(starts-with(lower-case(normalize-space(./TLC)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./TLC)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./TLC)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./TLC)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
						<xsl:when test="./TCL and not(./TCL='.' or ./TCL='-' or ./TCL='/') and (not(starts-with(lower-case(normalize-space(./TCL)), 'nr')) and not(starts-with(lower-case(normalize-space(./TCL)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'LocationType/', arco-fn:urify(normalize-space(./TCL)))" />
                                </xsl:attribute>
								<rdf:type rdf:resource="https://w3id.org/arco/location/LocationType" />
								<rdfs:label>
									<xsl:value-of select="normalize-space(./TCL)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(./TCL)" />
								</l0:name>
							</rdf:Description>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				<!-- Circumstance as individual for Shot Location (F) -->
				<xsl:if test="../../F/LR/LRO and (not(starts-with(lower-case(normalize-space(../../F/LR/LRO)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRO)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Circumstance/', arco-fn:urify(normalize-space(../../F/LR/LRO)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/context-description/Circumstance'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(../../F/LR/LRO)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(../../F/LR/LRO)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Monumental Area as individual in the scope of the Site of LA -->
				<xsl:if
					test="./PRC/PRCC and not(lower-case(normalize-space(./PRC/PRCC))='nr' or lower-case(normalize-space(./PRC/PRCC))='n.r.' or lower-case(normalize-space(./PRC/PRCC))='nr (recupero pregresso)')">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'MonumentalArea/', arco-fn:urify(normalize-space(./PRC/PRCC)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'http://dati.beniculturali.it/cis/MonumentalArea'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./PRC/PRCC)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./PRC/PRCC)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Time Interval for Alternative Location and shot location (F) -->
				<xsl:if test="./PRD or ../../F/LR/LRD and (not(starts-with(lower-case(normalize-space(./PRD)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRD)), 'n.r')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRD)), 'n.r')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRD)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeInterval/', $itemURI, '-time-interval-', position())" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/TI/TimeInteval'" />
                            </xsl:attribute>
						</rdf:type>
						<xsl:if test="PRD/PRDI and (not(starts-with(lower-case(normalize-space(./PRD/PRDI)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRD/PRDI)), 'n.r')))">
							<arco-core:startTime>
								<xsl:value-of select="normalize-space(./PRD/PRDI)" />
							</arco-core:startTime>
						</xsl:if>
						<xsl:if test="PRD/PRDU and (not(starts-with(lower-case(normalize-space(./PRD/PRDU)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRD/PRDU)), 'n.r')))">
							<arco-core:endTime>
								<xsl:value-of select="normalize-space(./PRD/PRDU)" />
							</arco-core:endTime>
						</xsl:if>
						<xsl:if test="../LR/LRD and (not(starts-with(lower-case(normalize-space(../LR/LRD)), 'nr')) and not(starts-with(lower-case(normalize-space(../LR/LRD)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(../LR/LRD)" />
							</tiapit:time>
						</xsl:if>
					</rdf:Description>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="schede/*/LC/PVC/*">
				<xsl:variable name="address">
					<xsl:value-of
						select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(schede/*/LC/PVC), normalize-space(schede/*/LC/PVL), normalize-space(schede/*/LC/LDC/LDCU)))))" />
				</xsl:variable>
				<rdf:Description>
					<xsl:attribute name="rdf:about">
                        <xsl:value-of select="$address" />
                    </xsl:attribute>
					<rdf:type>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="'https://w3id.org/italia/onto/CLV/Address'" />
                        </xsl:attribute>
					</rdf:type>
					<rdfs:label>
						<xsl:for-each select="schede/*/LC/PVC/*">
							<xsl:choose>
								<xsl:when test="position() = 1">
									<xsl:value-of select="./text()" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(', ', ./text())" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</rdfs:label>
					<xsl:if test="schede/*/LC/PVL">
						<arco-location:hasToponymInTime>
							<xsl:attribute name="rdf:resource">
                                <xsl:choose>
                                    <xsl:when test="schede/*/LC/PVL/PVLT">
                                        <xsl:value-of
								select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(schede/*/LC/PVL/PVLT)))" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
								select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(schede/*/LC/PVL)))" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
						</arco-location:hasToponymInTime>
					</xsl:if>
					<xsl:if
						test="schede/*/LC/PVC/PVCI and not(schede/*/LC/PVC/PVCI='.' or schede/*/LC/PVC/PVCI='-' or schede/*/LC/PVC/PVCI='/') and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCI)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCI)), 'n.r')))">
						<clvapit:fullAddress>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCI)" />
						</clvapit:fullAddress>
					</xsl:if>
					<xsl:if
						test="schede/*/LC/LDC/LDCU and not(schede/*/LC/LDC/LDCU='.' or schede/*/LC/LDC/LDCU='-' or schede/*/LC/LDC/LDCU='/') and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCU)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCU)), 'n.r')))">
						<clvapit:fullAddress>
							<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCU)" />
						</clvapit:fullAddress>
					</xsl:if>
					<!-- Stato -->
					<xsl:if test="schede/*/LC/PVC/PVCS and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCS)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCS)), 'n.r')))">
						<clvapit:hasCountry>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Country/', arco-fn:urify(schede/*/LC/PVC/PVCS))" />
                            </xsl:attribute>
						</clvapit:hasCountry>
					</xsl:if>
					<!-- Regione -->
					<xsl:if test="schede/*/LC/PVC/PVCR and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCR)), 'n.r')))">
						<clvapit:hasRegion>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Region/', arco-fn:urify(schede/*/LC/PVC/PVCR))" />
                            </xsl:attribute>
						</clvapit:hasRegion>
					</xsl:if>
					<!-- Provincia -->
					<xsl:if test="schede/*/LC/PVC/PVCP and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCP)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCP)), 'n.r')))">
						<clvapit:hasProvince>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Province/', arco-fn:urify(schede/*/LC/PVC/PVCP))" />
                            </xsl:attribute>
						</clvapit:hasProvince>
					</xsl:if>
					<!-- Comune -->
					<xsl:if test="schede/*/LC/PVC/PVCC and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCC)), 'n.r')))">
						<clvapit:hasCity>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'City/', arco-fn:urify(schede/*/LC/PVC/PVCC))" />
                            </xsl:attribute>
						</clvapit:hasCity>
					</xsl:if>
					<!-- Località -->
					<xsl:if test="schede/*/LC/PVC/PVCL and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCL)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCL)), 'n.r')))">
						<clvapit:hasAddressArea>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'AddressArea/', arco-fn:urify(schede/*/LC/PVC/PVCL))" />
                            </xsl:attribute>
						</clvapit:hasAddressArea>
					</xsl:if>
					<xsl:if test="schede/*/LC/PVC/PVCE and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCE)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCE)), 'n.r')))">
						<clvapit:hasAddressArea>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'AddressArea/', arco-fn:urify(schede/*/LC/PVC/PVCE))" />
                            </xsl:attribute>
						</clvapit:hasAddressArea>
					</xsl:if>
				</rdf:Description>
				<!-- Toponym in Time as individual -->
				<xsl:if test="schede/*/LC/PVL">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:choose>
                                <xsl:when test="schede/*/LC/PVL/PVLT">
                                    <xsl:value-of
							select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(schede/*/LC/PVL/PVLT)))" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
							select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(schede/*/LC/PVL)))" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/arco/location/ToponymInTime'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:choose>
								<xsl:when test="schede/*/LC/PVL/PVLT">
									<xsl:value-of select="normalize-space(schede/*/LC/PVL/PVLT)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(schede/*/LC/PVL)" />
								</xsl:otherwise>
							</xsl:choose>
						</rdfs:label>
						<l0:name>
							<xsl:choose>
								<xsl:when test="schede/*/LC/PVL/PVLT">
									<xsl:value-of select="normalize-space(schede/*/LC/PVL/PVLT)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(schede/*/LC/PVL)" />
								</xsl:otherwise>
							</xsl:choose>
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Stato -->
				<xsl:if test="schede/*/LC/PVC/PVCS and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCS)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCS)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Country/', arco-fn:urify(schede/*/LC/PVC/PVCS))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Country'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCS)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCS)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Regione -->
				<xsl:if test="schede/*/LC/PVC/PVCR and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCR)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCR)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Region/', arco-fn:urify(schede/*/LC/PVC/PVCR))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Region'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCR)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCR)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Provincia -->
				<xsl:if test="schede/*/LC/PVC/PVCP and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCP)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCP)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Province/', arco-fn:urify(schede/*/LC/PVC/PVCP))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/Province'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCP)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCP)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Comune -->
				<xsl:if test="schede/*/LC/PVC/PVCC and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCC)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCC)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'City/', arco-fn:urify(schede/*/LC/PVC/PVCC))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/City'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCC)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCC)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<!-- Address Area -->
				<xsl:if test="schede/*/LC/PVC/PVCL and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCL)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCL)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'AddressArea/', arco-fn:urify(schede/*/LC/PVC/PVCL))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCL)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCL)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:if test="schede/*/LC/PVC/PVCE and (not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCE)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/PVC/PVCE)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'AddressArea/', arco-fn:urify(schede/*/LC/PVC/PVCE))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCE)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCE)" />
						</l0:name>
					</rdf:Description>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="schede/*/LC/LDC/*">
						<xsl:variable name="site"
							select="concat($NS, 'Site/', arco-fn:urify(arco-fn:md5(concat(normalize-space(schede/*/LC/LDC), normalize-space(schede/*/LC/PVC)))))" />
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of select="$site" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'http://dati.beniculturali.it/cis/Site'" />
                                </xsl:attribute>
							</rdf:type>
							<xsl:choose>
								<xsl:when test="schede/*/LC/LDC/LDCN">
									<rdfs:label>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCN)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCN)" />
									</l0:name>
								</xsl:when>
								<xsl:when test="schede/*/LC/LDC/LDCM">
									<rdfs:label>
										<xsl:value-of select="concat('Contenitore fisico di: ', normalize-space(schede/*/LC/LDC/LDCM))" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="concat('Contenitore fisico di: ', normalize-space(schede/*/LC/LDC/LDCM))" />
									</l0:name>
								</xsl:when>
								<xsl:otherwise>
									<rdfs:label>Contenitore fisico</rdfs:label>
									<l0:name>Contenitore fisico</l0:name>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="schede/*/LC/PVC">
								<cis:siteAddress>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="$address" />
                                    </xsl:attribute>
								</cis:siteAddress>
							</xsl:if>
							<xsl:if test="schede/*/LC/LDC/LDCK and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCK)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCK)), 'n.r')))">
								<arco-location:siteIdentifier>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCK)" />
								</arco-location:siteIdentifier>
							</xsl:if>
							<xsl:if test="schede/*/LC/LDC/LDCM">
								<cis:isSiteOf>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat($NS, 'CulturalInstituteOrSite/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                    </xsl:attribute>
								</cis:isSiteOf>
							</xsl:if>
							<xsl:if
								test="schede/*/LC/LDC/LDCC and not(lower-case(normalize-space(schede/*/LC/LDC/LDCC))='nr' or lower-case(normalize-space(schede/*/LC/LDC/LDCC))='n.r.' or lower-case(normalize-space(schede/*/LC/LDC/LDCC))='nr (recupero pregresso)')">
								<cis:isPartOf>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat($NS, 'MonumentalArea/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCC)))" />
                                    </xsl:attribute>
								</cis:isPartOf>
							</xsl:if>
							<!-- Site Type -->
							<xsl:if
								test="schede/*/LC/LDC/LDCT and not(normalize-space(schede/*/LC/LDC/LDCT)='.') and (not(starts-with(lower-case(normalize-space(./LDCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./LDCT)), 'n.r')))">
								<arco-location:hasSiteType>
									<xsl:attribute name="rdf:resource">
                                        <xsl:choose>
                                            <xsl:when
										test="schede/*/LC/LDC/LDCQ">
                                                <xsl:value-of
										select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)), '-', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCQ)))" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
										select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)))" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
								</arco-location:hasSiteType>
							</xsl:if>
						</rdf:Description>
						<!-- Site Type as an individual -->
						<xsl:if
							test="schede/*/LC/LDC/LDCT and not(normalize-space(schede/*/LC/LDC/LDCT)='.') and (not(starts-with(lower-case(normalize-space(./LDCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./LDCT)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:choose>
                                        <xsl:when
									test="schede/*/LC/LDC/LDCQ">
                                            <xsl:value-of
									select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)), '-', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCQ)))" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
									select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)))" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'https://w3id.org/arco/location/SiteType'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label xml:lang="it">
									<xsl:choose>
										<xsl:when test="schede/*/LC/LDC/LDCQ">
											<xsl:value-of
												select="concat('Tipo di contenitore fisico:', ' ', normalize-space(schede/*/LC/LDC/LDCT), ' ', normalize-space(schede/*/LC/LDC/LDCQ))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('Tipo di contenitore fisico:', ' ', normalize-space(schede/*/LC/LDC/LDCT))" />
										</xsl:otherwise>
									</xsl:choose>
								</rdfs:label>
								<l0:name xml:lang="it">
									<xsl:choose>
										<xsl:when test="schede/*/LC/LDC/LDCQ">
											<xsl:value-of
												select="concat('Tipo di contenitore fisico:', ' ', normalize-space(schede/*/LC/LDC/LDCT), ' ', normalize-space(schede/*/LC/LDC/LDCQ))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('Tipo di contenitore fisico:', ' ', normalize-space(schede/*/LC/LDC/LDCT))" />
										</xsl:otherwise>
									</xsl:choose>
								</l0:name>
								<rdfs:label xml:lang="en">
									<xsl:choose>
										<xsl:when test="schede/*/LC/LDC/LDCQ">
											<xsl:value-of
												select="concat('Site type:', ' ', normalize-space(schede/*/LC/LDC/LDCT), ' ', normalize-space(schede/*/LC/LDC/LDCQ))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('Site type:', ' ', normalize-space(schede/*/LC/LDC/LDCT))" />
										</xsl:otherwise>
									</xsl:choose>
								</rdfs:label>
								<l0:name xml:lang="en">
									<xsl:choose>
										<xsl:when test="schede/*/LC/LDC/LDCQ">
											<xsl:value-of
												select="concat('Site type:', ' ', normalize-space(schede/*/LC/LDC/LDCT), ' ', normalize-space(schede/*/LC/LDC/LDCQ))" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('Site type:', ' ', normalize-space(schede/*/LC/LDC/LDCT))" />
										</xsl:otherwise>
									</xsl:choose>
								</l0:name>
								<xsl:if test="schede/*/LC/LDC/LDCT and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCT)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCT)), 'n.r')))">
								<arco-location:hasSiteDefinition>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat('https://w3id.org/arco/resource/SiteDefinition/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)))" />
                                    </xsl:attribute>
								</arco-location:hasSiteDefinition>
								</xsl:if>
								<xsl:if test="schede/*/LC/LDC/LDCQ and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCQ)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCQ)), 'n.r')))">
									<arco-location:hasSiteSpecification>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat('https://w3id.org/arco/resource/SiteSpecification/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCQ)))" />
                                        </xsl:attribute>
									</arco-location:hasSiteSpecification>
								</xsl:if>
							</rdf:Description>
						</xsl:if>
						<!-- Site Definition as an individual -->
						<xsl:if test="schede/*/LC/LDC/LDCT and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCT)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCT)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat('https://w3id.org/arco/resource/SiteDefinition/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCT)))" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'https://w3id.org/arco/denotative-description/SiteDefinition'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCT)" />
								</rdfs:label>
							</rdf:Description>
						</xsl:if>
						<!-- Site Specification as an individual -->
						<xsl:if test="schede/*/LC/LDC/LDCQ and (not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCQ)), 'nr')) and not(starts-with(lower-case(normalize-space(schede/*/LC/LDC/LDCQ)), 'n.r')))">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat('https://w3id.org/arco/resource/SiteSpecification/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCQ)))" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'https://w3id.org/arco/denotative-
										description/SiteSpecification'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCQ)" />
								</rdfs:label>
							</rdf:Description>
						</xsl:if>
						<!-- Monumental Area as individual -->
						<xsl:if
							test="schede/*/LC/LDC/LDCC and not(lower-case(normalize-space(schede/*/LC/LDC/LDCC))='nr' or lower-case(normalize-space(schede/*/LC/LDC/LDCC))='n.r.' or lower-case(normalize-space(schede/*/LC/LDC/LDCC))='nr (recupero pregresso)')">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'MonumentalArea/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCC)))" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'http://dati.beniculturali.it/cis/MonumentalArea'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCC)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCC)" />
								</l0:name>
							</rdf:Description>
						</xsl:if>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-current')" />
                            </xsl:attribute>
							<arco-location:atSite>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$site" />
                                </xsl:attribute>
							</arco-location:atSite>
						</rdf:Description>
						<!-- rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of 
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), 
							'/', $itemURI)" /> </xsl:attribute> <arco-location:isInSite> <xsl:attribute name="rdf:resource"> 
							<xsl:value-of select="$site" /> </xsl:attribute> </arco-location:isInSite> </rdf:Description -->
						<!-- Cultural Institute or Site -->
						<xsl:if test="schede/*/LC/LDC/LDCM">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'CulturalInstituteOrSite/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'http://dati.beniculturali.it/cis/CulturalInstituteOrSite'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
								</rdfs:label>
								<l0:name>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
								</l0:name>
								<cis:hasNameInTime>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                    </xsl:attribute>
								</cis:hasNameInTime>
								<cis:hasSite>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="$site" />
                                    </xsl:attribute>
								</cis:hasSite>
							</rdf:Description>
							<!-- Name in time -->
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'http://dati.beniculturali.it/cis/NameInTime'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label xml:lang="it">
									<xsl:value-of
										select="concat('Denominazione nel tempo: ', normalize-space(schede/*/LC/LDC/LDCM))" />
								</rdfs:label>
								<l0:name xml:lang="it">
									<xsl:value-of
										select="concat('Denominazione nel tempo: ', normalize-space(schede/*/LC/LDC/LDCM))" />
								</l0:name>
								<rdfs:label xml:lang="en">
									<xsl:value-of
										select="concat('Name in time: ', normalize-space(schede/*/LC/LDC/LDCM))" />
								</rdfs:label>
								<l0:name xml:lang="en">
									<xsl:value-of
										select="concat('Name in time: ', normalize-space(schede/*/LC/LDC/LDCM))" />
								</l0:name>
								<cis:institutionalName>
									<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
								</cis:institutionalName>
							</rdf:Description>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="location"
							select="concat($NS, 'Feature/', arco-fn:urify(arco-fn:md5(normalize-space(schede/*/LC/PVC))))" />
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-current')" />
                            </xsl:attribute>
							<arco-location:atLocation>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$location" />
                                </xsl:attribute>
							</arco-location:atLocation>
						</rdf:Description>
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of select="$location" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/onto/CLV/Feature'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(schede/*/LC/PVC)" />
							</rdfs:label>
							<xsl:if test="schede/*/LC/PVC/*">
								<clvapit:hasAddress>
									<xsl:attribute name="rdf:resource">
                                    	<xsl:value-of
										select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(schede/*/LC/PVC), normalize-space(schede/*/LC/PVL), normalize-space(schede/*/LC/LDC/LDCU)))))" />
                                    </xsl:attribute>
								</clvapit:hasAddress>
							</xsl:if>
						</rdf:Description>
						<xsl:if test="schede/*/LC/PVC/*">
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                	<xsl:value-of
									select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(schede/*/LC/PVC), normalize-space(schede/*/LC/PVL), normalize-space(schede/*/LC/LDC/LDCU)))))" />
                				</xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/Address'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:for-each select="schede/*/LC/PVC/*">
										<xsl:choose>
											<xsl:when test="position() = 1">
												<xsl:value-of select="./text()" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat(', ', ./text())" />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</rdfs:label>
								<!-- Aggiunto da Valentina - Address details <xsl:if test="schede/*/LC/PVC/PVCV"> 
									<arco-location:addressDetails> <xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCV)"" 
									/> </arco-location:addressDetails> -->
								<!-- Aggiunto da Valentina - Full Address - per issue github #8 <xsl:if 
									test="schede/*/LC/PVC/PVCI"> <clvapit:fullAddress> <xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCI)" 
									/> </clvapit:fullAddress> </xsl:if> <xsl:if test="schede/*/LC/LDC/LDCU"> 
									<clvapit:fullAddress> <xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCU)" 
									/> </clvapit:fullAddress> </xsl:if> -->
								<!-- Stato -->
								<xsl:if test="schede/*/LC/PVC/PVCS">
									<clvapit:hasCountry>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'Country/', arco-fn:urify(schede/*/LC/PVC/PVCS))" />
                                        </xsl:attribute>
									</clvapit:hasCountry>
								</xsl:if>
								<!-- Regione -->
								<xsl:if test="schede/*/LC/PVC/PVCR">
									<clvapit:hasRegion>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'Region/', arco-fn:urify(schede/*/LC/PVC/PVCR))" />
                                        </xsl:attribute>
									</clvapit:hasRegion>
								</xsl:if>
								<!-- Provincia -->
								<xsl:if test="schede/*/LC/PVC/PVCP">
									<clvapit:hasProvince>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'Province/', arco-fn:urify(schede/*/LC/PVC/PVCP))" />
                                        </xsl:attribute>
									</clvapit:hasProvince>
								</xsl:if>
								<!-- Comune -->
								<xsl:if test="schede/*/LC/PVC/PVCC">
									<clvapit:hasCity>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'City/', arco-fn:urify(schede/*/LC/PVC/PVCC))" />
                                        </xsl:attribute>
									</clvapit:hasCity>
								</xsl:if>
								<!-- Località -->
								<xsl:if test="schede/*/LC/PVC/PVCL">
									<clvapit:hasAddressArea>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'AddressArea/', arco-fn:urify(schede/*/LC/PVC/PVCL))" />
                                        </xsl:attribute>
									</clvapit:hasAddressArea>
								</xsl:if>
								<xsl:if
									test="schede/*/LC/PVC/PVCI and not(schede/*/LC/PVC/PVCI='.' or schede/*/LC/PVC/PVCI='-' or schede/*/LC/PVC/PVCI='/')">
									<clvapit:fullAddress>
										<xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCI)" />
									</clvapit:fullAddress>
								</xsl:if>
								<xsl:if
									test="schede/*/LC/LDC/LDCU and not(schede/*/LC/LDC/LDCU='.' or schede/*/LC/LDC/LDCU='-' or schede/*/LC/LDC/LDCU='/')">
									<clvapit:fullAddress>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCU)" />
									</clvapit:fullAddress>
								</xsl:if>
							</rdf:Description>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="schede/*/LA | schede/F/LR">
					<xsl:choose>
						<xsl:when test="./PRC/*">
							<xsl:variable name="site"
								select="concat($NS, 'Site/', arco-fn:urify(arco-fn:md5(concat(normalize-space(./PRC), normalize-space(./PRV)))))" />
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-alternative-', position())" />
                                </xsl:attribute>
								<arco-location:atSite>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="$site" />
                                    </xsl:attribute>
								</arco-location:atSite>
							</rdf:Description>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of select="$site" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'http://dati.beniculturali.it/cis/Site'" />
                                    </xsl:attribute>
								</rdf:type>
								<xsl:choose>
									<!-- Denominazione contenitore fisico in 4.00 -->
									<xsl:when test="./PRC/PRCN">
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRC/PRCN)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRC/PRCN)" />
										</l0:name>
									</xsl:when>
									<!-- Denominazione contenitore fisico in normative precedenti a 
										4.00 -->
									<xsl:when test="./PRC/PRCD">
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRC/PRCD)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRC/PRCD)" />
										</l0:name>
									</xsl:when>
									<xsl:when test="./PRC/PRCM">
									<rdfs:label>
										<xsl:value-of select="concat('Contenitore fisico di: ', normalize-space(./PRC/PRCM))" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="concat('Contenitore fisico di: ', normalize-space(./PRC/PRCM))" />
									</l0:name>
								</xsl:when>
									<xsl:otherwise>
										<rdfs:label>Contenitore fisico</rdfs:label>
										<l0:name>Contenitore fisico</l0:name>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="./PRV/*">
									<cis:siteAddress>
										<xsl:attribute name="rdf:resource">
                                        	<xsl:value-of
											select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(./PRV), normalize-space(./PRL), normalize-space(./PRC/PRCU)))))" />
                                        </xsl:attribute>
									</cis:siteAddress>
								</xsl:if>
								<xsl:if test="./PRC/PRCK and (not(starts-with(lower-case(normalize-space(./PRC/PRCK)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCK)), 'n.r')))">
									<arco-location:siteIdentifier>
										<xsl:value-of select="normalize-space(./PRC/PRCK)" />
									</arco-location:siteIdentifier>
								</xsl:if>
								<xsl:if test="./PRC/PRCM">
									<cis:isSiteOf>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'CulturalInstituteOrSite/', arco-fn:urify(normalize-space(./PRC/PRCM)))" />
                                        </xsl:attribute>
									</cis:isSiteOf>
								</xsl:if>
								<xsl:if
									test="./PRC/PRCC and not(lower-case(normalize-space(./PRC/PRCC))='nr' or lower-case(normalize-space(./PRC/PRCC))='n.r.' or lower-case(normalize-space(./PRC/PRCC))='nr (recupero pregresso)')">
									<cis:isPartOf>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'MonumentalArea/', arco-fn:urify(normalize-space(./PRC/PRCC)))" />
                                        </xsl:attribute>
									</cis:isPartOf>
								</xsl:if>
								<xsl:if test="./PRT/PRTK and (not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'n.r')))">
									<arco-location:hasContinent>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'Continent/', arco-fn:urify(normalize-space(./PRT/PRTK)))" />
                                        </xsl:attribute>
									</arco-location:hasContinent>
								</xsl:if>
								<!-- Site Type -->
								<xsl:if test="./PRC/PRCT and not(normalize-space(./PRC/PRCT)='.') and (not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'n.r')))">
									<arco-location:hasSiteType>
										<xsl:attribute name="rdf:resource">
                                            <xsl:choose>
                                                <xsl:when
											test="./PRC/PRCQ">
                                                    <xsl:value-of
											select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(./PRC/PRCT)), '-', arco-fn:urify(normalize-space(./PRC/PRCQ)))" />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of
											select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(./PRC/PRCT)))" />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
									</arco-location:hasSiteType>
								</xsl:if>
							</rdf:Description>
							<!-- PRCM cultural institute or site as an individual -->
							<xsl:if test="./PRC/PRCM">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'CulturalInstituteOrSite/', arco-fn:urify(normalize-space(./PRC/PRCM)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'http://dati.beniculturali.it/cis/CulturalInstituteOrSite'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRC/PRCM)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRC/PRCM)" />
									</l0:name>
									<cis:hasNameInTime>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(./PRC/PRCM)))" />
                                        </xsl:attribute>
									</cis:hasNameInTime>
									<cis:hasSite>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="$site" />
                                        </xsl:attribute>
									</cis:hasSite>
								</rdf:Description>
								<!-- Name in time of CIS -->
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(./PRC/PRCM)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'http://dati.beniculturali.it/cis/NameInTime'" />
                                        </xsl:attribute>
									</rdf:type>
									<cis:institutionalName>
										<xsl:value-of select="normalize-space(./PRC/PRCM)" />
									</cis:institutionalName>
								</rdf:Description>
							</xsl:if>
							<!-- Site Type as an individual -->
							<xsl:if test="./PRC/PRCT and not(normalize-space(./PRC/PRCT)='.') and (not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    <!-- tolto $itemURI dalle URI -->
                                        <xsl:choose>
                                            <xsl:when test="./PRC/PRCQ">
                                                <xsl:value-of
										select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(./PRC/PRCT)), '-', arco-fn:urify(normalize-space(./PRC/PRCQ)))" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
										select="concat($NS, 'SiteType/', arco-fn:urify(normalize-space(./PRC/PRCT)))" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/location/SiteType'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label xml:lang="it">
										<xsl:choose>
											<xsl:when test="./PRC/PRCQ">
												<xsl:value-of
													select="concat('Tipo di contenitore fisico: ', normalize-space(./PRC/PRCT), ' ', normalize-space(./PRC/PRCQ))" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of
													select="concat('Tipo di contenitore fisico: ', normalize-space(./PRC/PRCT))" />
											</xsl:otherwise>
										</xsl:choose>
									</rdfs:label>
									<l0:name xml:lang="it">
										<xsl:choose>
											<xsl:when test="./PRC/PRCQ">
												<xsl:value-of
													select="concat('Tipo di contenitore fisico: ', normalize-space(./PRC/PRCT), ' ', normalize-space(./PRC/PRCQ))" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of
													select="concat('Tipo di contenitore fisico: ', normalize-space(./PRC/PRCT))" />
											</xsl:otherwise>
										</xsl:choose>
									</l0:name>
									<rdfs:label xml:lang="en">
										<xsl:choose>
											<xsl:when test="./PRC/PRCQ">
												<xsl:value-of
													select="concat('Site type: ', normalize-space(./PRC/PRCT), ' ', normalize-space(./PRC/PRCQ))" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of
													select="concat('Site type: ', normalize-space(./PRC/PRCT))" />
											</xsl:otherwise>
										</xsl:choose>
									</rdfs:label>
									<l0:name xml:lang="en">
										<xsl:choose>
											<xsl:when test="./PRC/PRCQ">
												<xsl:value-of
													select="concat('Site type: ', normalize-space(./PRC/PRCT), ' ', normalize-space(./PRC/PRCQ))" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of
													select="concat('Site type: ', normalize-space(./PRC/PRCT))" />
											</xsl:otherwise>
										</xsl:choose>
									</l0:name>
									<xsl:if test="./PRC/PRCT and (not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'n.r')))">
									<arco-location:hasSiteDefinition>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat('https://w3id.org/arco/resource/SiteDefinition/', arco-fn:urify(normalize-space(./PRC/PRCT)))" />
                                        </xsl:attribute>
									</arco-location:hasSiteDefinition>
									</xsl:if>
									<xsl:if test="./PRC/PRCQ and (not(starts-with(lower-case(normalize-space(./PRC/PRCQ)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCQ)), 'n.r')))">
										<arco-location:hasSiteSpecification>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat('https://w3id.org/arco/resource/SiteSpecification/', arco-fn:urify(normalize-space(./PRC/PRCQ)))" />
                                            </xsl:attribute>
										</arco-location:hasSiteSpecification>
									</xsl:if>
								</rdf:Description>
							</xsl:if>
							<!-- Site Definition as an individual -->
							<xsl:if test="./PRC/PRCT and (not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCT)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat('https://w3id.org/arco/resource/SiteDefinition/', arco-fn:urify(normalize-space(./PRC/PRCT)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/denotative-description/SiteDefinition'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRC/PRCT)" />
									</rdfs:label>
								</rdf:Description>
							</xsl:if>
							<!-- Site Specification as an individual -->
							<xsl:if test="./PRC/PRCQ and (not(starts-with(lower-case(normalize-space(./PRC/PRCQ)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCQ)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat('https://w3id.org/arco/resource/SiteSpecification/', arco-fn:urify(normalize-space(./PRC/PRCQ)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/denotative-description/SiteSpecification'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRC/PRCQ)" />
									</rdfs:label>
								</rdf:Description>
							</xsl:if>
							<!-- Continent as individual -->
							<xsl:if test="./PRT/PRTK and (not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Continent/', arco-fn:urify(normalize-space(./PRT/PRTK)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/location/Continent'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRT/PRTK)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRT/PRTK)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="./PRV/*">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    	<xsl:value-of
										select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(./PRV), normalize-space(./PRL), normalize-space(./PRC/PRCU)))))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Address'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:for-each select="./PRV/*">
											<xsl:choose>
												<xsl:when test="position() = 1">
													<xsl:value-of select="./text()" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat(', ', ./text())" />
												</xsl:otherwise>
											</xsl:choose>
											<!-- xsl:value-of select="normalize-space(schede/*/OG/OGD)" / -->
										</xsl:for-each>
										<xsl:for-each select="./PRL/*">
											<xsl:value-of select="concat(', ', ./text())" />
										</xsl:for-each>
									</rdfs:label>
									<!-- ToponymInTime associated with schede/*/LA -->
									<xsl:if test="./PRL">
										<arco-location:hasToponymInTime>
											<xsl:attribute name="rdf:resource">
                                                <xsl:choose>
                                                    <xsl:when
												test="./PRL/PRLT">
                                                        <xsl:value-of
												select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL/PRLT)))" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of
												select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL)))" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
										</arco-location:hasToponymInTime>
									</xsl:if>
									<xsl:if
										test="./PRC/PRCU and not(./PRC/PRCU='.' or ./PRC/PRCU='-' or ./PRC/PRCU='/') and (not(starts-with(lower-case(normalize-space(./PRC/PRCU)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCU)), 'n.r')))">
										<clvapit:fullAddress>
											<xsl:value-of select="normalize-space(./PRC/PRCU)" />
										</clvapit:fullAddress>
									</xsl:if>
									<!-- Stato -->
									<xsl:if test="./PRV/PRVS and (not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'n.r')))">
										<clvapit:hasCountry>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Country/', arco-fn:urify(./PRV/PRVS))" />
                                            </xsl:attribute>
										</clvapit:hasCountry>
									</xsl:if>
									<!-- Regione -->
									<xsl:if test="./PRV/PRVR and (not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'n.r')))">
										<clvapit:hasRegion>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVR))" />
                                            </xsl:attribute>
										</clvapit:hasRegion>
									</xsl:if>
									<!-- Provincia -->
									<xsl:if test="./PRV/PRVP and (not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'n.r')))">
										<clvapit:hasProvince>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Province/', arco-fn:urify(./PRV/PRVP))" />
                                            </xsl:attribute>
										</clvapit:hasProvince>
									</xsl:if>
									<!-- Comune -->
									<xsl:if test="./PRV/PRVC and (not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'n.r')))">
										<clvapit:hasCity>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'City/', arco-fn:urify(./PRV/PRVC))" />
                                            </xsl:attribute>
										</clvapit:hasCity>
									</xsl:if>
									<!-- Località -->
									<xsl:if test="./PRV/PRVL and (not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVL))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="./PRT/PRTL and (not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRT/PRTL))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="./PRV/PRVE and (not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVE))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
								</rdf:Description>
								<!-- Country -->
								<xsl:if test="./PRV/PRVS and (not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'Country/', arco-fn:urify(./PRV/PRVS))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/Country'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVS)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVS)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<!-- Regione -->
								<xsl:if test="./PRV/PRVR and (not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVR))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/Region'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVR)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVR)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<!-- Provincia -->
								<xsl:if test="./PRV/PRVP and (not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVP))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/Province'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVP)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVP)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<!-- Comune -->
								<xsl:if test="./PRV/PRVC and (not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVC))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/City'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVC)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVC)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<!-- Località -->
								<xsl:if test="./PRV/PRVL and (not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVL))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVL)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVL)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<xsl:if test="./PRT/PRTL and (not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'AddressArea/', arco-fn:urify(./PRT/PRTL))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRT/PRTL)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRT/PRTL)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
								<xsl:if test="./PRV/PRVE and (not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'n.r')))">
									<rdf:Description>
										<xsl:attribute name="rdf:about">
                                            <xsl:value-of
											select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVE))" />
                                        </xsl:attribute>
										<rdf:type>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                            </xsl:attribute>
										</rdf:type>
										<rdfs:label>
											<xsl:value-of select="normalize-space(./PRV/PRVE)" />
										</rdfs:label>
										<l0:name>
											<xsl:value-of select="normalize-space(./PRV/PRVE)" />
										</l0:name>
									</rdf:Description>
								</xsl:if>
							</xsl:if>
							<!-- Toponym in Time as individual -->
							<xsl:if test="./PRL">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:choose>
                                            <xsl:when test="./PRL/PRLT">
                                                <xsl:value-of
										select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL/PRLT)))" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
										select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL)))" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/location/ToponymInTime'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:choose>
											<xsl:when test="./PRL/PRLT">
												<xsl:value-of select="normalize-space(./PRL/PRLT)" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(./PRL)" />
											</xsl:otherwise>
										</xsl:choose>
									</rdfs:label>
									<l0:name>
										<xsl:choose>
											<xsl:when test="./PRL/PRLT">
												<xsl:value-of select="normalize-space(./PRL/PRLT)" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(./PRL)" />
											</xsl:otherwise>
										</xsl:choose>
									</l0:name>
									<!-- TODO: PRL/PRLR never exists in XML data we have. -->
									<xsl:if test="./PRL/PRLR">
										<tiapit:atTime />
									</xsl:if>
								</rdf:Description>
							</xsl:if>
							<!-- Valentina - unfixed bug: it doesn't generate the resource ToponymInTime 
								for LRL or LRCF (tested on ICCD8532322.xml -->
							<xsl:if test="../../F/LR/LRL">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                       <xsl:value-of
										select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(../../F/LR/LRL)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/location/ToponymInTime'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRL)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRL)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="../../F/LR/LRC/LRCF">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                       <xsl:value-of
										select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(../../F/LR/LRC/LRCF)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/location/ToponymInTime'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCF)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCF)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of 
								select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-current')" 
								/> </xsl:attribute> <arco-location:atSite> <xsl:attribute name="rdf:resource"> 
								<xsl:value-of select="$site" /> </xsl:attribute> </arco-location:atSite> </rdf:Description -->
							<!-- rdf:Description> <xsl:attribute name="rdf:about"> <xsl:value-of 
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), 
								'/', $itemURI)" /> </xsl:attribute> <arco-location:isInSite> <xsl:attribute name="rdf:resource"> 
								<xsl:value-of select="$site" /> </xsl:attribute> </arco-location:isInSite> </rdf:Description -->
							<!-- Cultural Institute or Site -->
							<xsl:if test="schede/*/LC/LDC/LDCM">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'CulturalInstituteOrSite/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'http://dati.beniculturali.it/cis/CulturalInstituteOrSite'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
									</l0:name>
									<cis:hasNameInTime>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                        </xsl:attribute>
									</cis:hasNameInTime>
									<cis:hasSite>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="$site" />
                                        </xsl:attribute>
									</cis:hasSite>
								</rdf:Description>
								<!-- Name in time -->
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'NameInTime/', arco-fn:urify(normalize-space(schede/*/LC/LDC/LDCM)))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'http://dati.beniculturali.it/cis/NameInTime'" />
                                        </xsl:attribute>
									</rdf:type>
									<cis:institutionalName>
										<xsl:value-of select="normalize-space(schede/*/LC/LDC/LDCM)" />
									</cis:institutionalName>
								</rdf:Description>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="location">
								<xsl:if test="./PRV">
									<xsl:value-of
										select="concat($NS, 'Feature/', arco-fn:urify(arco-fn:md5(normalize-space(./PRV))))" />
								</xsl:if>
								<xsl:if test="../../F/LR">
									<xsl:value-of
										select="concat($NS, 'Feature/', arco-fn:urify(arco-fn:md5(normalize-space(../../F/LR/LRC))))" />
								</xsl:if>
							</xsl:variable>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of
									select="concat($NS, 'TimeIndexedQualifiedLocation/', $itemURI, '-alternative-', position())" />
                                </xsl:attribute>
								<arco-location:atLocation>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="$location" />
                                    </xsl:attribute>
								</arco-location:atLocation>
							</rdf:Description>
							<rdf:Description>
								<xsl:attribute name="rdf:about">
                                    <xsl:value-of select="$location" />
                                </xsl:attribute>
								<rdf:type>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="'https://w3id.org/italia/onto/CLV/Feature'" />
                                    </xsl:attribute>
								</rdf:type>
								<rdfs:label>
									<xsl:if test="./PRV">
										<xsl:value-of select="normalize-space(./PRV)" />
									</xsl:if>
									<xsl:if test="../../F/LR">
										<xsl:value-of select="normalize-space(../../F/LR/LRC)" />
									</xsl:if>
								</rdfs:label>
								<xsl:if test="./PRV/*">
									<clvapit:hasAddress>
										<xsl:attribute name="rdf:resource">
                                        	<xsl:value-of
											select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(./PRV), normalize-space(./PRC/PRL), normalize-space(./PRC/PRCU)))))" />
                                        </xsl:attribute>
									</clvapit:hasAddress>
								</xsl:if>
								<xsl:if test="../../F/LR/*">
									<clvapit:hasAddress>
										<xsl:attribute name="rdf:resource">
                                        	<xsl:value-of
											select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(../../F/LR/LRC), normalize-space(../../F/LR/LRL)))))" />
                                        </xsl:attribute>
									</clvapit:hasAddress>
								</xsl:if>
								<xsl:if test="./PRT/PRTK and (not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'n.r')))">
									<arco-location:hasContinent>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="concat($NS, 'Continent/', arco-fn:urify(arco-fn:md5(normalize-space(./PRT/PRTK))))" />
                                        </xsl:attribute>
									</arco-location:hasContinent>
								</xsl:if>
								<xsl:if test="./PRL">
									<arco-location:hasToponymInTime>
										<xsl:attribute name="rdf:resource">
                                                <xsl:choose>
                                                    <xsl:when
											test="./PRL/PRLT">
                                                        <xsl:value-of
											select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL/PRLT)))" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of
											select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(./PRL)))" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
									</arco-location:hasToponymInTime>
								</xsl:if>
								<xsl:if test="../../F/LR/LRL">
									<arco-location:hasToponymInTime>
										<xsl:attribute name="rdf:resource">
                                            	<xsl:value-of
											select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(../../F/LR/LRL)))" />
                                            </xsl:attribute>
									</arco-location:hasToponymInTime>
								</xsl:if>
								<xsl:if test="../../F/LR/LRC/LRCF">
									<arco-location:hasToponymInTime>
										<xsl:attribute name="rdf:resource">
                                            	<xsl:value-of
											select="concat($NS, 'ToponymInTime/', arco-fn:urify(normalize-space(../../F/LR/LRC/LRCF)))" />
                                            </xsl:attribute>
									</arco-location:hasToponymInTime>
								</xsl:if>
							</rdf:Description>
							<!-- Continent as individual -->
							<xsl:if test="./PRT/PRTK and (not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTK)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    <xsl:value-of
										select="concat($NS, 'Continent/', arco-fn:urify(arco-fn:md5(normalize-space(./PRT/PRTK))))" />
                                </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
											select="'https://w3id.org/arco/location/Continent'" />
                                    </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRT/PRTK)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRT/PRTK)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="./PRV/* | ../../F/LR/LRC/*">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                    	<xsl:choose>
                                    		<xsl:when
										test="./PRC/PRCU and not(./PRC/PRCU='.' or ./PRC/PRCU='-' or ./PRC/PRCU='/')">
                                    			<xsl:value-of
										select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(./PRV), normalize-space(./PRC/PRCU)))))" />
                                    		</xsl:when>
                                    		<xsl:when test="../../F/LR/LRC/*">
                                    			<xsl:value-of
										select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(concat(normalize-space(../../F/LR/LRC), normalize-space(../../F/LR/LRL)))))" />
                                    		</xsl:when>
                                    		<xsl:otherwise>
                                    			<xsl:value-of
										select="concat($NS, 'Address/', arco-fn:urify(arco-fn:md5(normalize-space(./PRV))))" />
                                    		</xsl:otherwise>
                                    	</xsl:choose>
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Address'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:for-each select="./PRV/*">
											<xsl:choose>
												<xsl:when test="position() = 1">
													<xsl:value-of select="./text()" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat(', ', ./text())" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
										<xsl:for-each select="../../F/LR/LRC/*">
											<xsl:choose>
												<xsl:when test="position() = 1">
													<xsl:value-of select="./text()" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat(', ', ./text())" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</rdfs:label>
									<!-- Address details <xsl:if test="schede/*/LC/PVC/PVCV"> 
										<arco-location:addressDetails> <xsl:value-of select="normalize-space(schede/*/LC/PVC/PVCV)"" 
										/> </arco-location:addressDetails> -->
									<!-- Full Address - per issue github #8 
										<xsl:if test="schede/*/LC/PVC/PVCI"> <clvapit:fullAddress> <xsl:value-of 
										select="normalize-space(schede/*/LC/PVC/PVCI)" /> </clvapit:fullAddress> 
										</xsl:if> <xsl:if test="schede/*/LC/LDC/LDCU"> <clvapit:fullAddress> <xsl:value-of 
										select="normalize-space(schede/*/LC/LDC/LDCU)" /> </clvapit:fullAddress> 
										</xsl:if> -->
									<!-- Stato -->
									<xsl:if test="./PRV/PRVS and (not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'n.r')))">
										<clvapit:hasCountry>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Country/', arco-fn:urify(./PRV/PRVS))" />
                                            </xsl:attribute>
										</clvapit:hasCountry>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCS and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCS)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCS)), 'n.r')))">
										<clvapit:hasCountry>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Country/', arco-fn:urify(../../F/LR/LRC/LRCS))" />
                                            </xsl:attribute>
										</clvapit:hasCountry>
									</xsl:if>
									<!-- Regione -->
									<xsl:if test="./PRV/PRVR and (not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'n.r')))">
										<clvapit:hasRegion>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVR))" />
                                            </xsl:attribute>
										</clvapit:hasRegion>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCR and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCR)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCR)), 'n.r')))">
										<clvapit:hasRegion>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Region/', arco-fn:urify(../../F/LR/LRC/LRCR))" />
                                            </xsl:attribute>
										</clvapit:hasRegion>
									</xsl:if>
									<!-- Provincia -->
									<xsl:if test="./PRV/PRVP and (not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'n.r')))">
										<clvapit:hasProvince>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Province/', arco-fn:urify(./PRV/PRVP))" />
                                            </xsl:attribute>
										</clvapit:hasProvince>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCP and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCP)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCP)), 'n.r')))">
										<clvapit:hasProvince>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'Province/', arco-fn:urify(../../F/LR/LRC/LRCP))" />
                                            </xsl:attribute>
										</clvapit:hasProvince>
									</xsl:if>
									<!-- Comune -->
									<xsl:if test="./PRV/PRVC and (not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'n.r')))">
										<clvapit:hasCity>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'City/', arco-fn:urify(./PRV/PRVC))" />
                                            </xsl:attribute>
										</clvapit:hasCity>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCC and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCC)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCC)), 'n.r')))">
										<clvapit:hasCity>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'City/', arco-fn:urify(../../F/LR/LRC/LRCC))" />
                                            </xsl:attribute>
										</clvapit:hasCity>
									</xsl:if>
									<!-- Località -->
									<xsl:if test="./PRV/PRVL and (not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVL))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="./PRT/PRTL and (not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRT/PRTL))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="./PRV/PRVE and (not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVE))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCL and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCL)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCL)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRC/LRCL))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="../../F/LR/LRA and (not(starts-with(lower-case(normalize-space(../../F/LR/LRA)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRA)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRA))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if test="../../F/LR/LRC/LRCE and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCE)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCE)), 'n.r')))">
										<clvapit:hasAddressArea>
											<xsl:attribute name="rdf:resource">
                                                <xsl:value-of
												select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRC/LRCE))" />
                                            </xsl:attribute>
										</clvapit:hasAddressArea>
									</xsl:if>
									<xsl:if
										test="./PRC/PRCU and not(./PRC/PRCU='.' or ./PRC/PRCU='-' or ./PRC/PRCU='/') and (not(starts-with(lower-case(normalize-space(./PRC/PRCU)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRC/PRCU)), 'n.r')))">
										<clvapit:fullAddress>
											<xsl:value-of select="normalize-space(./PRC/PRCU)" />
										</clvapit:fullAddress>
									</xsl:if>
								</rdf:Description>
							</xsl:if>
							<!-- Country LA -->
							<xsl:if test="./PRV/PRVS and (not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVS)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Country/', arco-fn:urify(./PRV/PRVS))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Country'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVS)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVS)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Country LR -->
							<xsl:if test="../../F/LR/LRC/LRCS and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCS)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCS)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Country/', arco-fn:urify(../../F/LR/LRC/LRCS))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Country'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCS)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCS)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Region LA -->
							<xsl:if test="./PRV/PRVR and (not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVR)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVR))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Region'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVR)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVR)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Region LR -->
							<xsl:if test="../../F/LR/LRC/LRCR and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCR)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCR)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Region/', arco-fn:urify(../../F/LR/LRC/LRCR))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Region'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCR)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCR)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Province LA -->
							<xsl:if test="./PRV/PRVP and (not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVP)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Province/', arco-fn:urify(./PRV/PRVP))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Province'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVP)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVP)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Province LR -->
							<xsl:if test="../../F/LR/LRC/LRCP and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCP)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCP)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Province/', arco-fn:urify(../../F/LR/LRC/LRCP))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/Province'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCP)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCP)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- City LA -->
							<xsl:if test="./PRV/PRVC and (not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVC)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Region/', arco-fn:urify(./PRV/PRVC))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/City'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVC)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVC)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- City LR -->
							<xsl:if test="../../F/LR/LRC/LRCC and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCC)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCC)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Region/', arco-fn:urify(../../F/LR/LRC/LRCC))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/City'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCC)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCC)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Località (Address Area) LA -->
							<xsl:if test="./PRV/PRVL and (not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVL)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVL))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVL)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVL)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="./PRT/PRTL and (not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRT/PRTL)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(./PRT/PRTL))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRT/PRTL)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRT/PRTL)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="./PRV/PRVE and (not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'nr')) and not(starts-with(lower-case(normalize-space(./PRV/PRVE)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(./PRV/PRVE))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(./PRV/PRVE)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(./PRV/PRVE)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<!-- Località (Address Area) LR -->
							<xsl:if test="../../F/LR/LRC/LRCL and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCL)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCL)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRC/LRCL))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCL)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCL)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="../../F/LR/LRC/LRCE and (not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCE)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRC/LRCE)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRC/LRCE))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCE)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRC/LRCE)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
							<xsl:if test="../../F/LR/LRA and (not(starts-with(lower-case(normalize-space(../../F/LR/LRA)), 'nr')) and not(starts-with(lower-case(normalize-space(../../F/LR/LRA)), 'n.r')))">
								<rdf:Description>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'AddressArea/', arco-fn:urify(../../F/LR/LRA))" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/italia/onto/CLV/AddressArea'" />
                                        </xsl:attribute>
									</rdf:type>
									<rdfs:label>
										<xsl:value-of select="normalize-space(../../F/LR/LRA)" />
									</rdfs:label>
									<l0:name>
										<xsl:value-of select="normalize-space(../../F/LR/LRA)" />
									</l0:name>
								</rdf:Description>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<!-- xsl:otherwise> <rdf:Description> <xsl:attribute name="rdf:about"> 
					<xsl:value-of select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), 
					'/', $itemURI)" /> </xsl:attribute> <cis:siteAddress> <xsl:attribute name="rdf:resource"> 
					<xsl:value-of select="$address" /> </xsl:attribute> </cis:siteAddress> </rdf:Description> 
					</xsl:otherwise -->
			</xsl:if>
			<!-- We create the cultural event or the exhibition - norm version 4.00 -->
			<xsl:for-each select="schede/*/MS/MST">
				<rdf:Description>
					<xsl:choose>
						<xsl:when test="./MSTI">
							<xsl:choose>
								<xsl:when test="./MSTI='mostra'">
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'Exhibition/', $itemURI, '-', position())" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'https://w3id.org/arco/cultural-event/Exhibition'" />
                                        </xsl:attribute>
									</rdf:type>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="rdf:about">
                                        <xsl:value-of
										select="concat($NS, 'CulturalEvent/', $itemURI, '-', position())" />
                                    </xsl:attribute>
									<rdf:type>
										<xsl:attribute name="rdf:resource">
                                            <xsl:value-of
											select="'http://dati.beniculturali.it/cis/CulturalEvent'" />
                                        </xsl:attribute>
									</rdf:type>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'CulturalEvent/', $itemURI, '-', position())" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'http://dati.beniculturali.it/cis/CulturalEvent'" />
                                </xsl:attribute>
							</rdf:type>
						</xsl:otherwise>
					</xsl:choose>
					<cis:involves>
						<xsl:attribute name="rdf:resource">
                            <xsl:value-of
							select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                        </xsl:attribute>
					</cis:involves>
					<!-- Event name -->
					<xsl:if test="./MSTT">
						<l0:name>
							<xsl:value-of select="normalize-space(./MSTT)" />
						</l0:name>
						<rdfs:label>
							<xsl:value-of select="normalize-space(./MSTT)" />
						</rdfs:label>
					</xsl:if>
					<!-- Event organizer -->
					<xsl:for-each select="./MSTE and (not(starts-with(lower-case(normalize-space(./MSTE)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTE)), 'n.r')))">
						<cis:isRelatedToRiT>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
						</cis:isRelatedToRiT>
						<arco-ce:hasEventOrganiser>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
						</arco-ce:hasEventOrganiser>
					</xsl:for-each>
					<!-- Event location and time -->
					<xsl:for-each select="./MSTL and (not(starts-with(lower-case(normalize-space(./MSTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTL)), 'n.r')))">
						<arco-ce:eventTimeLocation>
							<xsl:value-of select="normalize-space(.)" />
						</arco-ce:eventTimeLocation>
					</xsl:for-each>
					<!-- Event notes -->
					<xsl:if test="./MSTS">
						<arco-core:note>
							<xsl:value-of select="normalize-space(./MSTS)" />
						</arco-core:note>
					</xsl:if>
				</rdf:Description>
				<!-- Event organizer - Time Indexed Role -->
				<xsl:for-each select="./MSTE and (not(starts-with(lower-case(normalize-space(./MSTE)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTES)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                            </xsl:attribute>
						</rdf:type>
						<roapit:withRole>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Role/Organiser')" />
                            </xsl:attribute>
						</roapit:withRole>
						<roapit:isRoleInTimeOf>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
						</roapit:isRoleInTimeOf>
					</rdf:Description>
					<!-- Event organizer - Role -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Role/Organiser')" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/RO/Role'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label xml:lang="en">
							<xsl:value-of select="'Organiser'" />
						</rdfs:label>
						<rdfs:label xml:lang="it">
							<xsl:value-of select="'Ente/Soggetto organizzatore'" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of select="'Ente/Soggetto organizzatore'" />
						</l0:name>
						<l0:name xml:lang="en">
							<xsl:value-of select="'Organiser'" />
						</l0:name>
					</rdf:Description>
					<!-- Event organizer - Agent -->
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'https://w3id.org/italia/onto/l0/Agent'" />
                            </xsl:attribute>
						</rdf:type>
						<rdfs:label>
							<xsl:value-of select="normalize-space(.)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(.)" />
						</l0:name>
					</rdf:Description>
				</xsl:for-each>
			</xsl:for-each>
			<!-- We create the cultural event or the exhibition - norm version 3.00 -->
			<xsl:for-each select="schede/*/DO/MST">
				<xsl:if test="./*">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
                            <xsl:value-of
							select="concat($NS, 'CulturalEvent/', $itemURI, '-', position())" />
                        </xsl:attribute>
						<rdf:type>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="'http://dati.beniculturali.it/cis/CulturalEvent'" />
                            </xsl:attribute>
						</rdf:type>
						<cis:involves>
							<xsl:attribute name="rdf:resource">
                                <xsl:value-of
								select="concat($NS, arco-fn:local-name(arco-fn:getSpecificPropertyType($sheetType)), '/', $itemURI)" />
                            </xsl:attribute>
						</cis:involves>
						<!-- Event name -->
						<xsl:if test="./MSTT">
							<l0:name>
								<xsl:value-of select="normalize-space(./MSTT)" />
							</l0:name>
							<rdfs:label>
								<xsl:value-of select="normalize-space(./MSTT)" />
							</rdfs:label>
						</xsl:if>
						<!-- Event organizer -->
						<xsl:if test="./MSTO and (not(starts-with(lower-case(normalize-space(./MSTO)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTO)), 'n.r')))">
							<xsl:for-each select="./MSTO">
								<cis:isRelatedToRiT>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
                                    </xsl:attribute>
								</cis:isRelatedToRiT>
								<arco-ce:hasEventOrganiser>
									<xsl:attribute name="rdf:resource">
                                        <xsl:value-of
										select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                                    </xsl:attribute>
								</arco-ce:hasEventOrganiser>
							</xsl:for-each>
						</xsl:if>
						<!-- Event time -->
						<xsl:for-each select="./MSTD and (not(starts-with(lower-case(normalize-space(./MSTD)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTD)), 'n.r')))">
							<tiapit:time>
								<xsl:value-of select="normalize-space(.)" />
							</tiapit:time>
						</xsl:for-each>
						<!-- Event location -->
						<xsl:for-each select="./MSTL and (not(starts-with(lower-case(normalize-space(./MSTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTL)), 'n.r')))">
							<xsl:choose>
								<xsl:when test="$sheetVersion='3.01_ICCD0' or $sheetVersion='3.01'">
									<arco-ce:eventTimeLocation>
										<xsl:value-of select="normalize-space(.)" />
									</arco-ce:eventTimeLocation>
								</xsl:when>
								<xsl:otherwise>
									<arco-core:hasLocation>
										<xsl:attribute name="rdf:resource">
		                                   <xsl:value-of
											select="concat($NS, 'GeographicalFeature/', arco-fn:urify(normalize-space(.)))" />
		                               </xsl:attribute>
									</arco-core:hasLocation>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<!-- Event site -->
						<xsl:for-each select="./MSTS and (not(starts-with(lower-case(normalize-space(./MSTS)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTS)), 'n.r')))">
							<cis:isHostedBy>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Site/', arco-fn:urify(arco-fn:md5(normalize-space(.))))" />
                                </xsl:attribute>
							</cis:isHostedBy>
						</xsl:for-each>
					</rdf:Description>
					<!-- Event site -->
					<xsl:for-each select="./MSTS and (not(starts-with(lower-case(normalize-space(./MSTS)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTS)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'Site/', arco-fn:urify(arco-fn:md5(normalize-space(.))))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'http://dati.beniculturali.it/cis/Site'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(.)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(.)" />
							</l0:name>
						</rdf:Description>
					</xsl:for-each>
					<!-- Event organizer - Time Indexed Role -->
					<xsl:for-each select="./MSTO and (not(starts-with(lower-case(normalize-space(./MSTO)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTO)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'TimeIndexedRole/', $itemURI, '-', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/RO/TimeIndexedRole'" />
                                </xsl:attribute>
							</rdf:type>
							<roapit:withRole>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Role/Organiser')" />
                                </xsl:attribute>
							</roapit:withRole>
							<roapit:isRoleInTimeOf>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                                </xsl:attribute>
							</roapit:isRoleInTimeOf>
						</rdf:Description>
						<!-- Event organizer - Role -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'Role/Organiser')" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/RO/Role'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label xml:lang="it">
								<xsl:value-of select="'Ente/Soggetto organizzatore'" />
							</rdfs:label>
							<l0:name xml:lang="it">
								<xsl:value-of select="'Ente/Soggetto organizzatore'" />
							</l0:name>
							<rdfs:label xml:lang="en">
								<xsl:value-of select="'Organiser'" />
							</rdfs:label>
							<l0:name xml:lang="en">
								<xsl:value-of select="'Organiser'" />
							</l0:name>
						</rdf:Description>
						<!-- Event organizer - Agent -->
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'Agent/', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'https://w3id.org/italia/onto/l0/Agent'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(.)" />
							</rdfs:label>
							<l0:name>
								<xsl:value-of select="normalize-space(.)" />
							</l0:name>
						</rdf:Description>
					</xsl:for-each>
					<!-- Event location -->
					<xsl:for-each select="./MSTL and (not(starts-with(lower-case(normalize-space(./MSTL)), 'nr')) and not(starts-with(lower-case(normalize-space(./MSTL)), 'n.r')))">
						<rdf:Description>
							<xsl:attribute name="rdf:about">
                                <xsl:value-of
								select="concat($NS, 'GeographicalFeature/', arco-fn:urify(normalize-space(.)))" />
                            </xsl:attribute>
							<rdf:type>
								<xsl:attribute name="rdf:resource">
                                    <xsl:value-of
									select="'http://dati.beniculturali.it/cis/GeographicalFeature'" />
                                </xsl:attribute>
							</rdf:type>
							<rdfs:label>
								<xsl:value-of select="normalize-space(.)" />
							</rdfs:label>
						</rdf:Description>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

			<!-- The individual typed as RelatedWorkSituation is created here (cf. 
				rule #RWS in component.xslt). -->
			<xsl:for-each select="schede/*/RV/RSE">
				<xsl:if test="./* 
				and (not(starts-with(lower-case(normalize-space(./RSEC)), 'nr')) and not(starts-with(lower-case(normalize-space(./RSEC)), 'n.r')))">
					<rdf:Description>
						<xsl:attribute name="rdf:about">
							<xsl:value-of
							select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-typed-related-cultural-property-', position())" />
						</xsl:attribute>
						<rdf:type rdf:resource="https://w3id.org/arco/context-description/RelatedWorkSituation" />
						<rdfs:label xml:lang="it">
							<xsl:value-of
								select="concat('Relazione ', position(), ' tra il bene culturale ', $itemURI, ' e altro bene culturale')" />
						</rdfs:label>
						<l0:name xml:lang="it">
							<xsl:value-of
								select="concat('Relazione ', position(), ' tra il bene culturale ', $itemURI, ' e altro bene culturale')" />
						</l0:name>
						<rdfs:label xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and other cultural property')" />
						</rdfs:label>
						<l0:name xml:lang="en">
							<xsl:value-of
								select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and other cultural property')" />
						</l0:name>

						<xsl:choose>
							<xsl:when test="(lower-case(normalize-space(./RSER))='è in relazione con' 
							or lower-case(normalize-space(./RSER))='scheda altra fotografia'
							or lower-case(normalize-space(./RSER))='scheda opera raffigurata'
							or lower-case(normalize-space(./RSER))='nr (recupero pregresso)')">
								<arco-cd:hasRelatedWork>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of
										select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
									</xsl:attribute>
								</arco-cd:hasRelatedWork>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='è contenuto in' 
							or lower-case(normalize-space(./RSER))='luogo di collocazione/localizzazione'
							or lower-case(normalize-space(./RSER))='scheda contenitore')">
								<arco-cd:isLocatedIn>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:isLocatedIn>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='era contenuto in' 
							or lower-case(normalize-space(./RSER))='luogo di provenienza')">
								<arco-cd:wasLocatedIn>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:wasLocatedIn>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='esecuzione/evento di riferimento' 
							or lower-case(normalize-space(./RSER))='è coinvolto in')">
								<arco-cd:isInvolvedIn>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:isInvolvedIn>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='sede di realizzazione' 
							or lower-case(normalize-space(./RSER))='è stato realizzato in')">
								<arco-cd:wasCreatedAt>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:wasCreatedAt>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='bene composto' 
							or lower-case(normalize-space(./RSER))='è compreso in')">
								<arco-cd:isReusedBy>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:isReusedBy>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='fonte di rappresentazione' 
							or lower-case(normalize-space(./RSER))='è rappresentato in')">
								<arco-cd:isSubjectOf>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:isSubjectOf>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='relazione urbanistico ambientale' 
							or lower-case(normalize-space(./RSER))='è in relazione urbanistico - ambientale con')">
								<arco-cd:hasUrbanPlanningEnvironmentalRelationWith>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:hasUrbanPlanningEnvironmentalRelationWith>
							</xsl:when>
							<xsl:when test="(lower-case(normalize-space(./RSER))='sede di rinvenimento' 
							or lower-case(normalize-space(./RSER))='è stato rinvenuto in')">
								<arco-cd:wasRediscoveredAt>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of
									select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
								</xsl:attribute>
							</arco-cd:wasRediscoveredAt>
							</xsl:when>
							<xsl:otherwise>
								<arco-cd:hasRelatedWork>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of
										select="arco-fn:related-property(normalize-space(./RSEC), 'foaf')" />
									</xsl:attribute>
								</arco-cd:hasRelatedWork>
							</xsl:otherwise>
						</xsl:choose>
						
						
					</rdf:Description>
				
				</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="schede/*/RV/ROZ">

				<rdf:Description>
					<xsl:attribute name="rdf:about">
						<xsl:value-of
						select="concat($NS, 'RelatedWorkSituation/', $itemURI, '-related-cultural-property-', position())" />
					</xsl:attribute>
					<rdf:type rdf:resource="https://w3id.org/arco/context-description/RelatedWorkSituation" />
					<rdfs:label xml:lang="it">
						<xsl:value-of
							select="concat('Relazione ', position(), ' tra il bene culturale ', $itemURI, ' e altro bene culturale')" />
					</rdfs:label>
					<l0:name xml:lang="it">
						<xsl:value-of
							select="concat('Relazione ', position(), ' tra il bene culturale ', $itemURI, ' e altro bene culturale')" />
					</l0:name>
					<rdfs:label xml:lang="en">
						<xsl:value-of
							select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and other cultural property')" />
					</rdfs:label>
					<l0:name xml:lang="en">
						<xsl:value-of
							select="concat('Relation ', position(), ' between the cultural property ', $itemURI, ' and other cultural property')" />
					</l0:name>

					<xsl:for-each select="arco-fn:related-property(normalize-space(.), '')">
						<arco-cd:hasRelatedWork>
							<xsl:attribute name="rdf:resource">
								<xsl:value-of select="." />
							</xsl:attribute>
						</arco-cd:hasRelatedWork>
					</xsl:for-each>


				</rdf:Description>
			</xsl:for-each>
			
			<xsl:for-each select="schede/*/MT/MIS">
				<rdf:Description>
					<xsl:attribute name="rdf:about">
						<xsl:value-of
							select="concat($NS, 'MeasurementCollection/', $itemURI, '-', position())" />
					</xsl:attribute>
					<rdf:type rdf:resource="https://w3id.org/arco/denotative-description/MeasurementCollection" />
					<rdfs:label>
					</rdfs:label>
					<l0:name>
					</l0:name>
					<xsl:choose>
						<xsl:when test="not($sheetVersion='4.00_ICCD0' or $sheetVersion='4.00')">
							<xsl:if test="./MISV">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-waist-circumference')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISF">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-hip-circumference')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISO">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-edge-circumference')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISL">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-width')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISD">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-diameter')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISA">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-height')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISP">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-depth')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
							<xsl:if test="./MISG">
								<arco-dd:hasMeasurement>
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-weight')" />
									</xsl:attribute>
								</arco-dd:hasMeasurement>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<arco-dd:hasMeasurement>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-', arco-fn:uncamelize(arco-fn:map-measure(lower-case(./MISZ))))" />
								</xsl:attribute>
							</arco-dd:hasMeasurement>
						</xsl:otherwise>
					</xsl:choose>
				</rdf:Description>
				
				<xsl:variable name="measurement-type">
					<xsl:choose>
						<xsl:when test="not($sheetVersion='4.00_ICCD0' or $sheetVersion='4.00')">
							<xsl:choose>
								<xsl:when test="./MISV">
									<xsl:value-of select="'WaistCircumference'" />
								</xsl:when>
								<xsl:when test="./MISF">
									<xsl:value-of select="'HipCircumference'" />
								</xsl:when>
								<xsl:when test="./MISO">
									<xsl:value-of select="'EdgeCircumference'" />
								</xsl:when>
								<xsl:when test="./MISL">
									<xsl:value-of select="'Width'" />
								</xsl:when>
								<xsl:when test="./MISD">
									<xsl:value-of select="'Diameter'" />
								</xsl:when>
								<xsl:when test="./MISA">
									<xsl:value-of select="'Height'" />
								</xsl:when>
								<xsl:when test="./MISP">
									<xsl:value-of select="'Depth'" />
								</xsl:when>
								<xsl:when test="./MISG">
									<xsl:value-of select="'Weight'" />
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="arco-fn:map-measure(lower-case(./MISZ))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<rdf:Description>
					<xsl:attribute name="rdf:about" select="concat($NS, 'Measurement/', $itemURI, '-', position(), '-', arco-fn:uncamelize($measurement-type))" />
					<rdf:type rdf:resource="https://w3id.org/arco/denotative-description/Measurement" />
					<rdfs:label>
					</rdfs:label>
					<l0:name>
					</l0:name>
					<arco-dd:hasMeasurementType>
						<xsl:attribute name="rdf:resource" select="concat('https://w3id.org/arco/denotative-description/', $measurement-type)" />
					</arco-dd:hasMeasurementType>
					<mu:hasValue>
						<xsl:choose>
							<xsl:when test="not($sheetVersion='4.00_ICCD0' or $sheetVersion='4.00')">
								<xsl:variable name="mu-value">
									<xsl:choose>
										<xsl:when test="./MISV">
											<xsl:value-of select="normalize-space(./MISV)" />
										</xsl:when>
										<xsl:when test="./MISF">
											<xsl:value-of select="normalize-space(./MISF)" />
										</xsl:when>
										<xsl:when test="./MISO">
											<xsl:value-of select="normalize-space(./MISO)" />
										</xsl:when>
										<xsl:when test="./MISL">
											<xsl:value-of select="normalize-space(./MISL)" />
										</xsl:when>
										<xsl:when test="./MISD">
											<xsl:value-of select="normalize-space(./MISD)" />
										</xsl:when>
										<xsl:when test="./MISA">
											<xsl:value-of select="normalize-space(./MISA)" />
										</xsl:when>
										<xsl:when test="./MISP">
											<xsl:value-of select="normalize-space(./MISP)" />
										</xsl:when>
										<xsl:when test="./MISG">
											<xsl:value-of select="normalize-space(./MISG)" />
										</xsl:when>
									</xsl:choose>
								</xsl:variable>	
								<xsl:attribute name="rdf:resource" select="concat($NS, 'Measurement/', $itemURI, '-', arco-fn:uncamelize($measurement-type)), '-', $mu-value" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:resource" select="concat($NS, 'Measurement/', $itemURI, '-', arco-fn:uncamelize($measurement-type), '-', normalize-space(./MISM))" />
							</xsl:otherwise>
						</xsl:choose>
						
					</mu:hasValue>
				</rdf:Description>
					
				<rdf:Description>
					<xsl:variable name="mu-value">
						<xsl:choose>
							<xsl:when test="not($sheetVersion='4.00_ICCD0' or $sheetVersion='4.00')">
								<xsl:choose>
									<xsl:when test="./MISV">
										<xsl:value-of select="normalize-space(./MISV)" />
									</xsl:when>
									<xsl:when test="./MISF">
										<xsl:value-of select="normalize-space(./MISF)" />
									</xsl:when>
									<xsl:when test="./MISO">
										<xsl:value-of select="normalize-space(./MISO)" />
									</xsl:when>
									<xsl:when test="./MISL">
										<xsl:value-of select="normalize-space(./MISL)" />
									</xsl:when>
									<xsl:when test="./MISD">
										<xsl:value-of select="normalize-space(./MISD)" />
									</xsl:when>
									<xsl:when test="./MISA">
										<xsl:value-of select="normalize-space(./MISA)" />
									</xsl:when>
									<xsl:when test="./MISP">
										<xsl:value-of select="normalize-space(./MISP)" />
									</xsl:when>
									<xsl:when test="./MISG">
										<xsl:value-of select="normalize-space(./MISG)" />
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(./MISM)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="rdf:about" select="concat($NS, 'Measurement/', $itemURI, '-', arco-fn:uncamelize($measurement-type), '-', $mu-value)" />
					<rdf:type rdf:resource="https://w3id.org/italia/onto/MU/Value" />
					<mu:value>
						<xsl:value-of select="$mu-value" />
					</mu:value> 
					<xsl:choose>
						<xsl:when test="./MISU">
							<mu:hasMeasurementUnit>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="concat($NS, 'MeasurementUnit/', arco-fn:urify(normalize-space(./MISU)))" />
								</xsl:attribute>
							</mu:hasMeasurementUnit>
						</xsl:when>
						<xsl:when test="$sheetType='VeAC'">
						<mu:hasMeasurementUnit>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="concat($NS, 'MeasurementUnit/cm')" />
								</xsl:attribute>
							</mu:hasMeasurementUnit>
						</xsl:when>
					</xsl:choose>
				</rdf:Description>
					
				<xsl:if test="./MISU">
					<rdf:Description>
						<xsl:attribute name="rdf:about" select="concat($NS, 'MeasurementUnit/', arco-fn:urify(normalize-space(./MISU)))" />
						<rdf:type rdf:resource="https://w3id.org/italia/onto/MU/MeasurementUnit" />
						<rdfs:label>
							<xsl:value-of select="normalize-space(./MISU)" />
						</rdfs:label>
						<l0:name>
							<xsl:value-of select="normalize-space(./MISU)" />
						</l0:name>
					</rdf:Description>	
				</xsl:if>
				
				
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>