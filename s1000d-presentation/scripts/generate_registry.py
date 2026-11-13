#!/usr/bin/env python3
"""Deterministic first-pass S1000D presentation registry. No XML/XSD rewrites.

The source dictionary is structural evidence, not a presentation specification.
Hand changes belong in registry/overrides.json and styles/manual-overrides.css.
"""
from pathlib import Path
import argparse, collections, csv, hashlib, json, re

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = 'appliccrossreftable brex checklist condcrossreftable descript dml fault ipd pm prdcrossreftable proced'.split()

def write_json(path, value):
    p=ROOT/path; p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n')
def kebab(s): return re.sub(r'(?<!^)(?=[A-Z])','-',s).lower().replace(':','-')
def meaningful_definition(record):
    return record.get('definition','').strip().lower() not in {'','no definition available','not mentioned','n/a'}
def words(s): return re.sub(r'([a-z])([A-Z])',r'\1 \2',s).lower().split()
def contains_unresolved(m):
    if not isinstance(m,dict): return False
    return (m.get('kind')=='group' and not m.get('items')) or any(contains_unresolved(i) for i in m.get('items',[]))

def rules():
    return [
      {'id':'nested-requirements','priority':20,'match':{'elements':['reqCondGroup','reqTechInfoGroup','reqPersons','reqSupportEquips','reqSupplies','reqSpares','supportEquipDescrGroup','supplyDescrGroup','spareDescrGroup','reqCond','reqCondNoRef','reqCondDm','reqCondPm','reqCondExternalPub','reqTechInfo','reqCondCircuitBreaker'],'ancestors':['preliminaryRqmts','closeRqmts']},'apply':{'classes':['s1000d-nested-requirements']}},
      {'id':'media-block-context','priority':10,'match':{'elements':['graphic','multimediaObject','logo'],'parents':['figure','table','multimedia']},'apply':{'classes':['s1000d-media-block']}},
      {'id':'media-inline-context','priority':20,'match':{'elements':['graphic','symbol','multimediaObject','logo'],'parents':['para','simplePara','title','captionLine','captionText']},'apply':{'classes':['s1000d-media-inline']}},
      {'id':'paragraph-table-spacing','priority':10,'match':{'elements':['para','simplePara','notePara','warningAndCautionPara'],'ancestors':['entry','captionEntry']},'apply':{'classes':['s1000d-in-cell']}},
      {'id':'paragraph-safety-spacing','priority':10,'match':{'elements':['para','simplePara','notePara','warningAndCautionPara'],'ancestors':['warning','caution','note']},'apply':{'classes':['s1000d-in-safety']}},
      {'id':'paragraph-procedure-spacing','priority':10,'match':{'elements':['para','simplePara'],'ancestors':['proceduralStep','isolationStep','checkListStep']},'apply':{'classes':['s1000d-in-step']}},
      {'id':'title-figure-caption','priority':30,'match':{'elements':['title'],'parents':['figure']},'apply':{'htmlTag':'figcaption','classes':['s1000d-figure-caption']}},
      {'id':'title-table-caption','priority':30,'match':{'elements':['title'],'parents':['table']},'apply':{'htmlTag':'div','classes':['s1000d-table-caption']}},
      {'id':'title-step-heading','priority':20,'match':{'elements':['title'],'parents':['proceduralStep','isolationStep','checkListStep']},'apply':{'htmlTag':'div','classes':['s1000d-step-heading'],'props':{'role':'heading','aria-level':4}}},
      {'id':'title-list-heading','priority':20,'match':{'elements':['title'],'parents':['randomList','sequentialList','definitionList','attentionSequentialList','attentionRandomList']},'apply':{'htmlTag':'div','classes':['s1000d-list-heading'],'props':{'role':'heading','aria-level':4}}},
      {'id':'title-in-table-cell','priority':30,'match':{'elements':['title'],'ancestors':['entry']},'apply':{'classes':['s1000d-cell-heading']}},
      {'id':'entry-header-cell','priority':30,'match':{'elements':['entry'],'ancestors':['thead']},'apply':{'htmlTag':'th','classes':['s1000d-header-cell'],'props':{'scope':'col'}}},
      {'id':'verbatim-inline-context','priority':25,'match':{'elements':['verbatimText'],'parents':['externalPubCode','externalPubTitle','shortExternalPubTitle','externalPubIssue','para','simplePara','title']},'apply':{'htmlTag':'code','classes':['s1000d-verbatim-inline']}},
      {'id':'parts-catalog-structure','priority':10,'match':{'elements':['catalogSeqNumber','itemSequenceNumber'],'families':['ipd']},'apply':{'classes':['s1000d-parts-record']}},
      {'id':'fault-branch-layout','priority':10,'match':{'elements':['isolationStep','isolationStepAnswer','yesAnswer','noAnswer','yesNoAnswer'],'families':['fault']},'apply':{'classes':['s1000d-diagnostic-branch']}},
      {'id':'emphasis-bold','priority':20,'match':{'elements':['emphasis'],'attributes':{'emphasisType':['em01','bold']}},'apply':{'htmlTag':'strong','classes':['s1000d-bold']}},
      {'id':'emphasis-italic','priority':20,'match':{'elements':['emphasis'],'attributes':{'emphasisType':['em02','italic']}},'apply':{'htmlTag':'em','classes':['s1000d-italic']}},
      {'id':'emphasis-underline','priority':20,'match':{'elements':['emphasis'],'attributes':{'emphasisType':['em03','underline']}},'apply':{'htmlTag':'span','classes':['s1000d-underline']}},
      {'id':'emphasis-overline','priority':20,'match':{'elements':['emphasis'],'attributes':{'emphasisType':['em04','overline']}},'apply':{'htmlTag':'span','classes':['s1000d-overline']}},
      {'id':'emphasis-strike','priority':20,'match':{'elements':['emphasis'],'attributes':{'emphasisType':['em05','strikethrough']}},'apply':{'htmlTag':'span','classes':['s1000d-strike']}},
    ]

# Role -> shared React primitive and safe default HTML. Runtime context can override.
PRIMITIVES={
 'paragraph':('Paragraph','div','block'), 'heading':('Heading','div','block'),
 'inline':('Inline','span','inline'), 'emphasis':('Inline','em','inline'),
 'subscript':('Inline','sub','inline'), 'superscript':('Inline','sup','inline'),
 'verbatim':('Verbatim','pre','block'), 'ordered-list':('List','ol','block'),
 'unordered-list':('List','ul','block'), 'list-item':('ListItem','li','list-item'),
 'definition-list':('DefinitionList','dl','block'), 'definition-term':('DefinitionTerm','dt','block'),
 'definition-description':('DefinitionDescription','dd','block'),
 'table':('Table','table','table'), 'table-group':('TableGroup','table','table'),
 'table-head':('TableSection','thead','table-header-group'), 'table-body':('TableSection','tbody','table-row-group'),
 'table-foot':('TableSection','tfoot','table-footer-group'), 'table-row':('TableRow','tr','table-row'),
 'table-cell':('TableCell','td','table-cell'), 'column-spec':('ColumnSpec','col','nonvisual'),
 'span-spec':('SpanSpec','span','nonvisual'), 'procedure-step':('Step','section','block'),
 'diagnostic-step':('Step','section','block'), 'diagnostic':('Container','section','block'),
 'warning':('Safety','aside','block'), 'caution':('Safety','aside','block'), 'note':('Safety','aside','block'),
 'safety':('Container','section','block'), 'figure':('Media','figure','block'), 'media':('Media','div','block'),
 'caption':('Container','div','block'), 'reference':('Reference','span','inline'),
 'metadata':('Metadata','span','inline'), 'metadata-section':('Metadata','section','block'),
 'requirements':('Container','section','block'), 'section':('Container','section','block'),
 'structural':('Container','div','block'), 'technical-value':('Primitive','span','inline'),
 'condition':('Container','div','block'), 'interactive':('Container','div','block'),
 'unknown':('Primitive','span','inline'),
}
EXACT={}
def add(role,names):
    for n in names.split(): EXACT[n]=role
add('paragraph','para paraBasic simplePara notePara warningAndCautionPara attentionListItemPara checkListPara copyrightPara simpleRemark remarks displayText policyStatement exportRegistrationStmt')
add('heading','title dmTitle pmTitle pmEntryTitle techName infoName taskTitle termTitle definitionTitle snsTitle modificationTitle commentTitle scoEntryTitle scormContentPackageTitle lcPlanTitle')
add('inline','acronym acronymTerm acronymDefinition inlineSignificantData changeInline quantity quantityValue quantityTolerance unitOfMeasure name shortName techName emphasisText symbol externalPubTitle shortExternalPubTitle externalPubCode externalPubIssue externalPubIssueInfo')
add('emphasis','emphasis');add('subscript','subScript');add('superscript','superScript');add('verbatim','verbatimText')
add('ordered-list','sequentialList attentionSequentialList');add('unordered-list','randomList attentionRandomList')
add('list-item','listItem attentionRandomListItem attentionSequentialListItem')
add('definition-list','definitionList');add('structural','definitionListItem definitionListHeader');add('definition-term','listItemTerm');add('definition-description','listItemDefinition')
add('table','table');add('table-group','tgroup');add('table-head','thead');add('table-body','tbody');add('table-foot','tfoot');add('table-row','row');add('table-cell','entry');add('column-spec','colspec');add('span-spec','spanspec')
add('procedure-step','proceduralStep checkListStep crewDrillStep subCrewDrill');add('diagnostic-step','isolationStep isolationProcedureEnd')
add('diagnostic','fault faultIsolation faultIsolationProcedure faultIsolationTest diagnosticProcess detectedFault observedFault isolatedFault isolationStepQuestion isolationStepAnswer yesAnswer noAnswer yesNoAnswer diagnosticReason diagnosticsReason detailedFaultDescr faultDescr faultContext faultCond faultEquip faultMessageBody faultMessageIndication faultReporting faultIsolationRef contextAndIsolationInfo isolationInfo detectionInfo correlatedFault basicCorrelatedFaults isolateDetectedFault locateAndRepair')
add('warning','warning');add('caution','caution');add('note','note');add('safety','warningsAndCautions reqSafety safetyRqmts productSafety warningMalfunction assocWarningMalfunction')
add('figure','figure');add('media','graphic multimedia multimediaObject hotspot logo lcAsset lcGraphics lcHotspot lcHotspotMap');add('caption','captionBody captionEntry captionGroup captionRow legend'); add('inline','caption captionLine captionText')
add('reference','variableRef internalRef dmRef pmRef dmlRef externalPubRef footnoteRef catalogSeqNumberRef illustrationRef brexDmRef applicCrossRefTableRef condCrossRefTableRef productCrossRefTableRef attachmentRef dmRefIdent pmRefIdent dmlRefIdent externalPubRefIdent')
add('metadata-section','identAndStatusSection dmAddress dmAddressItems dmIdent dmStatus pmAddress pmAddressItems pmIdent pmStatus dmlAddress dmlAddressItems dmlIdent dmlStatus qualityAssurance dataRestrictions restrictionInfo restrictionInstructions security copyright authorityInfo authorityInfoAndTp changeAuthorityNumber reasonForUpdate reasonForAmendment sourceDmIdent sourcePmIdent')
add('metadata','dmCode pmCode dmlCode identExtension issueDate issueInfo language security responsiblePartnerCompany originator enterpriseCode firstVerification secondVerification unverified skillLevel')
add('requirements','preliminaryRqmts closeRqmts reqCondGroup reqTechInfoGroup reqPersons reqSupportEquips reqSupplies reqSpares supportEquipDescrGroup supplyDescrGroup spareDescrGroup reqCond reqCondNoRef reqCondDm reqCondPm reqCondExternalPub reqTechInfo reqCondCircuitBreaker')
add('section','levelledPara commonInfo commonInfoDescrPara description procedure mainProcedure isolationProcedure isolationMainProcedure checkList checkListInfo checkListProcedure checkListItems checkListItem illustratedPartsCatalog catalogSeqNumber itemSequenceNumber pmEntry dmlEntry dmEntry task taskDefinition taskGroup taskItem taskDescr taskDuration schedule scheduledMaint')
add('structural','dmodule dml pm content dmlContent Description refs referencedApplicGroup faultIsolation mainProcedure brex contextRules structureObjectRuleGroup structureObjectRule snsRules snsSystem snsSubSystem snsSubSubSystem snsAssy applicCrossRefTable condCrossRefTable productCrossRefTable productAttributeList condTypeList condList techRepository endMatter proceduralStepAlt')
add('condition','applic assert assertion evaluate cond condType productAttribute product productConfiguration applicabilitySegment expression case caseCond booleanFunction booleanOperator booleanValue trueValue falseValue')
add('interactive','action behavior if elseIf choice default menu menuChoice dialog dialogAlt dialogGroup initialize setValue variable variableDeclarations variablePreSet variablePostSet externalApplication trigger send receiveValue pushButton userEntry prompt response answer listOfChoices lcInteraction lcQuestion lcAnswerOption lcAnswerOptionGroup lcSingleSelect lcMultipleSelect lcMatching lcTrueFalse lcSequencing lcAssessment')

COMPLEX_ROLES={'table','table-group','column-spec','span-spec','table-cell','procedure-step','diagnostic-step','diagnostic','media','reference','interactive','condition'}
META_WORDS={'code','ident','status','address','issue','copyright','security','originator'}
CONTAINER_WORDS={'group','repository','spec','list','segment','content','information','info','data','entry','items','records','definition','structure','process','catalog','plan','requirements'}

def classify(name,e):
    w=words(name); parents=e.get('parents',[]); views=e.get('schemaViews',{})
    has_model=any(v.get('model') for v in views.values())
    if name in EXACT: return EXACT[name],.94,'Explicit baseline mapping to a shared technical-publication primitive.'
    if name.startswith('no') and len(w)>1: return 'technical-value',.70,'Negative-status element retained as a visible value; no technical instruction is synthesized.'
    if name.endswith('Ref') or name.endswith('RefGroup'):
        return ('reference' if name.endswith('Ref') else 'structural'),.76,'Reference-name pattern supported by identifier/reference presentation convention; resolution is separate behavior.'
    if w and w[-1] in {'title'}: return 'heading',.79,'Title suffix suggests a heading; contextual rules may replace heading semantics.'
    if w and w[-1] in {'para','description','descr','text','statement','remarks','instruction'}: return 'paragraph',.72,'Text-bearing name suggests a readable content block, preserving all children.'
    if w and w[-1] in {'step'}: return 'procedure-step',.75,'Step suffix suggests ordered procedural containment; source order is retained.'
    if name.startswith('lc') or name.startswith('learning'):
        if has_model or e.get('children') or any(t in w for t in CONTAINER_WORDS): return 'section',.56,'Learning vocabulary retained as a section; assessment behavior is not implemented from naming.'
        return 'technical-value',.44,'Learning vocabulary value preserved inline; semantics require learning-schema evidence.'
    if has_model or e.get('children'):
        if any(t in w for t in META_WORDS): return 'metadata-section',.70,'Structural content and identification/status naming suggest visible metadata containment.'
        if any(t in w for t in CONTAINER_WORDS): return 'structural',.69,'Dictionary child/model evidence supports a content-preserving structural container.'
        return 'structural',.58,'Dictionary describes child structure; conservative undecorated container preserves order.'
    if any(t in w for t in CONTAINER_WORDS): return 'structural',.46,'Container-name inference only; empty dictionary structure is treated as unresolved, never proof of emptiness.'
    if w and w[-1] in META_WORDS: return 'metadata',.59,'Identification/status naming suggests an inline metadata value; it remains visible.'
    if parents and all(p in {'para','simplePara','title','captionText','acronymDefinition','emphasis','listItemTerm'} for p in parents): return 'inline',.72,'All known immediate parent contexts are text-bearing; use inline content-preserving semantics.'
    return 'technical-value',(.58 if e.get('sourceSchemas') else .38),'Conservative visible value mapping; no supported evidence justifies decoration or operational behavior.'

ATTR_EXACT={
 'typography':'emphasisType verbatimStyle color changeMark updateHighlight',
 'alignment':'align valign alignCaption alignCaptionEntry textDisplayPosition listDirection',
 'dimensions':'colwidth captionHeight captionWidth reproductionHeight reproductionWidth reproductionScale multimediaObjectHeight multimediaObjectWidth dataEntryFieldLength',
 'table-structure':'colname colnum cols namest nameend spanname morerows char charoff',
 'borders':'frame colsep rowsep separatorStyle dialogSeparator',
 'applicability':'applicConfiguration applicDisplayClass applicPropertyIdent applicPropertyType applicPropertyValue applicPropertyValues applicRefId applicRefIds productConfigurationFlag',
 'visibility':'visibility show linkShow',
 'numbering':'listItemPrefix orderedStepsFlag stepLabel label markerType footnoteMark seqNumber itemSeqNumberValue catalogSeqNumberValue indenture',
 'reference':'id href internalRefId internalRefTargetType infoEntityIdent nextActionRefId warningRefs cautionRefs condRefId condTypeRefId referredFragment reasonForUpdateRefIds applicationStructureIdent sourceIdent contextIdent',
 'behavior':'actuate linkActuate autoPlay fullScreen showPluginControls choiceSelection menuChoiceDefaultFlag menuChoiceFlow initialStateFlag andOr booleanAction booleanOperation numberAction numberOperation setAction setOperation stringAction stringOperation variableName variableScope parameterName parameterValue parameterIdent xPath rulesContext function releaseEvent',
 'pagination':'keepWithNext orient pgwide rotate tocentry',
}
ATTR_LOOKUP={n:r for r,ns in ATTR_EXACT.items() for n in ns.split()}
HANDLING={
 'typography':('variant','Apply allowlisted CSS variants; preserve unknown values without interpretation.'),
 'alignment':('variant','Apply allowlisted horizontal/vertical/direction CSS variants.'),
 'dimensions':('layout','Parse validated numeric/CSS lengths in renderer; never interpolate arbitrary style text.'),
 'table-structure':('component','CALS resolver handles named columns/spans and row spans. Character alignment remains unsupported and is preserved for a measurement adapter.'),
 'borders':('variant','Apply allowlisted separators/frame variants; preserve unrecognized styles.'),
 'applicability':('evaluator-required','Retain and expose applicability metadata; never hide content without a validated evaluator.'),
 'visibility':('behavior-required','Preserve declared visibility; do not discard content through unconditional CSS.'),
 'numbering':('component','Display numbering/labels with source sequence; explicit XML label values take precedence.'),
 'reference':('resolver','Preserve identifiers and targets; resolve references using a host-supplied resolver.'),
 'behavior':('behavior-required','Preserve control parameters; no execution or interaction inferred from attribute naming.'),
 'pagination':('layout','Apply supported print/layout hints; rotation and page-wide behavior need renderer support.'),
 'metadata':('preserve','Preserve exact value as metadata and in source contract; no visual change is inferred.'),
}

def attr_record(n,a,owners):
    role=ATTR_LOOKUP.get(n,'metadata'); conf=.91 if n in ATTR_LOOKUP else .56
    reason='Explicit baseline attribute classification.' if n in ATTR_LOOKUP else 'No defensible direct style effect; preserve technical/domain value as metadata.'
    if role=='metadata' and (n.endswith('RefId') or n.endswith('RefIds')): role='reference';conf=.78;reason='Reference identifier suffix; preserve target values without guessing resolution.'
    elif role=='metadata' and (n.endswith('Action') or n.endswith('Operation')): role='behavior';conf=.65;reason='Operation suffix suggests behavior rather than CSS; no action is executed.'
    if not a.get('sourceSchemas'): conf=min(conf,.62)
    handling,note=HANDLING[role]
    return {'attribute':n,'role':role,'handling':handling,'proposedMapping':{'type':handling,'dataAttribute':'data-s1000d-attr-'+kebab(n),'preserveOriginal':True},'classification':'inferred','confidence':conf,'rationale':reason,'sourceSchemas':a.get('sourceSchemas',[]),'owners':sorted(owners.get(n,set())),'constraints':a.get('constraints',{}),'validationStatus':'untested','provenance':{'inventory':'sources/data-dict.json#/attributes/'+n,'method':'explicit-baseline' if n in ATTR_LOOKUP else 'conservative-inference','definitionAvailable':bool(a.get('definition'))},'limitations':[note]+(['No definition or enumerated values supplied; value semantics require authoritative XSD evidence.'] if not a.get('definition') else [])}

def generate():
    source=ROOT/'sources/data-dict.json'; raw=source.read_bytes(); d=json.loads(raw)
    contexts=rules(); owners=collections.defaultdict(set)
    official_path=ROOT/'sources/official-evidence.json'
    official=json.loads(official_path.read_text()) if official_path.exists() else {'elements':{},'attributes':{}}
    structure_path=ROOT/'sources/schema-structure.json'
    structure=json.loads(structure_path.read_text()).get('elements',{}) if structure_path.exists() else {}
    for r in contexts:
        r['classification']='inferred'
        r['validationStatus']='untested'
        r['rationale']='Shared contextual presentation baseline; source order and content are preserved.'
        if r['id'].startswith('emphasis-'):
            r['source']='https://www.oxygenxml.com/doc/versions/28.1/ug-editor/topics/s1000d-doc-type.html'
            r['rationale']='Coded emphasis meanings corroborated by Oxygen S1000D implementation documentation; not an operational instruction.'
    for n,families in structure.items():
        for v in families.values():
            for a in v.get('attributeRefs',[]): owners[a].add(n)
    for n,e in d['elements'].items():
        for a in e.get('attributes',[]): owners[a['name']].add(n)
        for view in e.get('schemaViews',{}).values():
            for a in view.get('attributes',[]):
                if a.get('ref'): owners[a['ref']].add(n)
    attrs={n:attr_record(n,a,owners) for n,a in sorted(d['attributes'].items())}
    for n,a in attrs.items():
        evidence=official.get('attributes',{}).get(n,[])
        a['officialDefinitions']=evidence
        a['provenance']['officialEvidence']='sources/official-evidence.json#/attributes/'+n if evidence else None
        a['provenance']['definitionAvailable']=any(meaningful_definition(e) for e in evidence)
        a['enumValues']=sorted({v for e in evidence for v in e.get('enumValues',[])})
        if any(meaningful_definition(e) for e in evidence):
            a['confidence']=round(min(.96,a['confidence']+.06),2)
            a['limitations']=[x for x in a['limitations'] if not x.startswith('No definition')]
        if n in {'emphasisType','verbatimStyle','listItemPrefix'}:
            a['limitations'].append('Enumeration membership does not define presentation. Only documented common emphasis codes receive automatic typography; project-specific values are preserved.')
    elems={}
    for n,e in sorted(d['elements'].items()):
        role,conf,reason=classify(n,e)
        evidence=official.get('elements',{}).get(n,[])
        family_structure=structure.get(n,{})
        resolved_children=sorted({c for v in family_structure.values() for c in v.get('childRefs',[])})
        # Actual XSD structure outranks an absent dictionary model. Preserve simple/mixed values inline.
        if n not in EXACT and family_structure:
            if resolved_children and role in {'technical-value','metadata'}:
                role='metadata-section' if role=='metadata' else 'structural'
                reason='Authoritative flat XSD child structure supports a content-preserving container.'
                conf=max(conf,.76)
            elif not resolved_children and role=='structural' and all(v.get('contentKind') in {'simple','simple-content'} or v.get('mixed') for v in family_structure.values()):
                role='technical-value'; reason='Authoritative XSD describes simple or text-only mixed content; use a visible inline value.'; conf=.82
        if any(meaningful_definition(e) for e in evidence):
            conf=min(.96,conf+.06)
            reason+=' Official definition retained as semantic evidence.'
        comp,tag,display=PRIMITIVES[role]
        attr_names={a['name'] for a in e.get('attributes',[])}
        for view in e.get('schemaViews',{}).values(): attr_names.update(a['ref'] for a in view.get('attributes',[]) if a.get('ref'))
        for view in family_structure.values(): attr_names.update(view.get('attributeRefs',[]))
        unresolved_groups=[f for f,v in e.get('schemaViews',{}).items() if contains_unresolved(v.get('model'))]
        remaining_groups=[f for f in unresolved_groups if f not in family_structure or family_structure[f].get('unresolvedGroups')]
        limitations=[]
        if not e.get('definition') and not any(meaningful_definition(v) for v in evidence): limitations.append('No dictionary definition; presentation is an editable inference, not an official S1000D requirement.')
        if not e.get('schemaViews') and not family_structure: limitations.append('No family-specific content model supplied; empty children must not be interpreted as empty content.')
        if remaining_groups:
            unresolved_names=sorted({g for f in remaining_groups for g in family_structure.get(f,{}).get('unresolvedGroups',[])})
            if unresolved_names==['attributeGroup:XLINKATT3']:
                limitations.append('The local structural summary does not expand imported xlink:XLINKATT3 attributes. Full XSDs compile; raw namespaced attributes are preserved. This is an evidence-summary gap, not an unresolved content model.')
            else:
                limitations.append('Unexpanded group references occur in family content models; content and mixed text must be preserved at runtime.')
        if role in {'table','table-group','table-cell','column-spec','span-spec'}:
            limitations.append('Baseline CALS named spans, row spans and inherited alignment/separators are implemented. Character alignment requires a measurement adapter; rotation and complex width expressions are not fully supported.')
        if not e.get('sourceSchemas') and not family_structure: limitations.append('No source-family association supplied; schema membership is unverified.')
        if role in COMPLEX_ROLES: limitations.append('Dedicated rendering/resolution/evaluation logic is required in addition to CSS; see component contract.')
        if role in {'condition','interactive'}: limitations.append('Static content-preserving baseline only; applicability and executable interaction semantics require separately validated logic.')
        # Never promote confidence to validation. Exact presentation choices are still inferred.
        if not e.get('sourceSchemas') and not family_structure: conf=min(conf,.68 if evidence else .62)
        empty_label=n if n in {'noSafety','noReferences','noSpares','noSupplies','noSupportEquips','noConds','noAssertions','noValue','notIllustrated','yesAnswer','noAnswer'} else None
        overrides=[r['id'] for r in contexts if n in r['match'].get('elements',[])]
        elems[n]={'element':n,'role':role,'roles':[role], 'display':display,'component':comp,'htmlTag':tag,'cssClass':'s1000d-'+role,'emptyLabel':empty_label,'selector':'.s1000d-document .s1000d-'+role,'attributes':{a:{'handling':attrs[a]['handling'] if a in attrs else 'preserve','registryRef':'attributes.json#/'+a,'source':'canonical-and-family-union'} for a in sorted(attr_names)},'contextOverrides':overrides,'classification':'inferred','confidence':round(conf,2),'rationale':reason,'validationStatus':'untested','sourceSchemas':e.get('sourceSchemas',[]),'parents':e.get('parents',[]),'knownChildren':sorted(set(c['name'] for c in e.get('children',[]))|set(resolved_children)),'officialDefinitions':evidence,'familyStructure':family_structure,'requiresStructuralLogic':role in COMPLEX_ROLES,'knownLimitations':limitations,'provenance':{'inventory':'sources/data-dict.json#/elements/'+n,'schemaViews':'sources/data-dict.json#/elements/'+n+'/schemaViews','method':'explicit-baseline' if n in EXACT else 'structure-and-name-inference','definitionAvailable':bool(e.get('definition') or any(meaningful_definition(v) for v in evidence)),'officialEvidence':('sources/official-evidence.json#/elements/'+n if evidence else None),'structuralEvidence':('sources/schema-structure.json#/elements/'+n if family_structure else None),'familyModelsAvailable':sorted(e.get('schemaViews',{})),'unexpandedGroupFamilies':remaining_groups,'dictionaryUnexpandedGroupFamilies':unresolved_groups}}
    overrides_path=ROOT/'registry/overrides.json'
    if overrides_path.exists():
        overrides=json.loads(overrides_path.read_text())
        for layer,target in [('elements',elems),('attributes',attrs)]:
            for n,changes in overrides.get(layer,{}).items():
                if n not in target: raise ValueError(f'Override unknown {layer} identifier {n}')
                if 'element' in changes or 'attribute' in changes: raise ValueError('Cannot change canonical identity')
                target[n].update(changes)
        for override_rule in overrides.get('contextualRules',[]):
            if not all(k in override_rule for k in ['id','priority','match','apply']): raise ValueError('Context rule override needs id, priority, match, apply')
            contexts=[r for r in contexts if r['id']!=override_rule['id']]+[override_rule]
        for n,e in elems.items(): e['contextOverrides']=[r['id'] for r in contexts if n in r['match'].get('elements',[])]
    else: write_json('registry/overrides.json',{'elements':{},'attributes':{},'contextualRules':[]})
    # A passing fixture grants scoped render-smoke evidence, never approved visual semantics.
    browser_path=ROOT/'tests/visual/browser-report.json'
    browser=json.loads(browser_path.read_text()) if browser_path.exists() else {}
    passed=[r for r in browser.get('results',[]) if r.get('passed')]
    for n,e in elems.items():
        seen=[r for r in passed if n in r.get('elements',[])]
        e.setdefault('visualStatus','unapproved')
        if seen:
            e['validationStatus']='render-tested'
            e['validationScope']='content-order-and-browser-smoke; visual semantics unapproved'
            e['validationEvidence']={'report':'tests/visual/browser-report.json','renderer':browser.get('renderer'),'fixtures':[r['id'] for r in seen],'checks':sorted({c for r in seen for c in r.get('checks',[])})}
    for n,a in attrs.items():
        seen=[r for r in passed if n in r.get('attributes',[])]
        if seen:
            a['validationStatus']='observed-in-render'
            a['validationScope']='observed in rendered fixtures; attribute behavior not individually verified'
            a['validationEvidence']={'report':'tests/visual/browser-report.json','fixtures':[r['id'] for r in seen]}
    for r in contexts:
        seen=[f for f in passed if r['id'] in f.get('contextRules',[])]
        if seen:
            r['validationStatus']='observed-in-render'
            r['validationEvidence']={'report':'tests/visual/browser-report.json','fixtures':[f['id'] for f in seen],'visualSemantics':'unapproved'}
    write_json('registry/elements.json',elems);write_json('registry/attributes.json',attrs);write_json('registry/contextual-rules.json',contexts)
    write_json('mappings/component-registry.json',{role:{'component':v[0],'htmlTag':v[1],'display':v[2],'cssClass':'s1000d-'+role,'contentPolicy':'Preserve exact source order and mixed content; never silently omit unrecognized children.','runtimeRequirement':component_requirement(role)} for role,v in PRIMITIVES.items()})
    coverage={'inventory':{'elements':len(d['elements']),'attributes':len(d['attributes']),'sourceSha256':hashlib.sha256(raw).hexdigest(),'scopeDecision':'User confirmed the dictionary families are exact scope, including checklist; schedul is excluded.','dictionaryFamilies':sorted(d['schemas']),'requiredFamilies':REQUIRED,'missingRequiredFamilies':sorted(set(REQUIRED)-set(d['schemas'])),'extraDictionaryFamilies':sorted(set(d['schemas'])-set(REQUIRED))},'registration':{'elementsRegistered':len(elems),'attributesRegistered':len(attrs),'elementsMissing':sorted(set(d['elements'])-set(elems)),'attributesMissing':sorted(set(d['attributes'])-set(attrs)),'elementsWithSharedPresentationRule':sum(e['display']!='nonvisual' for e in elems.values()),'elementsIntentionallyNonvisual':sum(e['display']=='nonvisual' for e in elems.values()),'elementsRequiringStructuralLogic':sum(e['requiresStructuralLogic'] for e in elems.values()),'attributeRoles':dict(sorted(collections.Counter(a['role'] for a in attrs.values()).items())),'elementRoles':dict(sorted(collections.Counter(e['role'] for e in elems.values()).items()))},'evidence':{'elementsWithoutDefinition':sum(not e.get('definition') for e in d['elements'].values()),'attributesWithoutDefinition':sum(not a.get('definition') for a in d['attributes'].values()),'elementsWithoutSchemaViews':sum(not e.get('schemaViews') for e in d['elements'].values()),'elementsWithoutSourceFamily':sum(not e.get('sourceSchemas') for e in d['elements'].values()),'elementsWithOfficialDefinition':sum(any(meaningful_definition(v) for v in e['officialDefinitions']) for e in elems.values()),'attributesWithOfficialDefinition':sum(any(meaningful_definition(v) for v in a['officialDefinitions']) for a in attrs.values()),'elementsWithAuthoritativeStructuralEvidence':sum(bool(e['familyStructure']) for e in elems.values()),'elementsWithUnexpandedGroups':sum(bool(e['provenance']['unexpandedGroupFamilies']) for e in elems.values())},'validation':{'registryGeneration':'deterministic','visuallyValidatedMappings':0,'renderTestedElementMappings':sum(e['validationStatus']=='render-tested' for e in elems.values()),'observedAttributeMappings':sum(a['validationStatus']=='observed-in-render' for a in attrs.values()),'observedContextRules':sum(r['validationStatus']=='observed-in-render' for r in contexts),'unknownElementNamesExercised':sorted({n for r in passed for n in r.get('elements',[])}-set(elems)),'passingBrowserFixtures':len(passed),'browserReport':'tests/visual/browser-report.json' if browser else None,'untestedElementMappings':sum(e['validationStatus']=='untested' for e in elems.values()),'untestedAttributeMappings':sum(e['validationStatus']=='untested' for e in attrs.values()),'note':'Scoped render evidence comes from passing browser fixtures in the included reference renderer. It does not establish approved visual semantics, complete attribute behavior, customer-renderer integration or S1000D conformance.'},'schemaFamilies':{f:{'dictionaryElements':len(s['elements']),'registered':sum(n in elems for n in s['elements']),'release':s.get('release'),'renderValidation':'fixture-smoke-tested' if any(r.get('family')==f for r in passed) else 'untested'} for f,s in sorted(d['schemas'].items())},'unsupportedStructures':['Imported xlink:XLINKATT3 attribute group is not expanded by the local structural summary; full XSDs compile and raw attributes are preserved.','CALS character alignment, rotation and complex width expressions need adapters; baseline named spans, row spans and inherited alignment/separators are supported.','CGM, 3D media, multimedia controls and hotspot coordinate transforms require media adapters.','Applicability evaluation, executable process/learning logic and diagnostic traversal require host logic.','Cross-module target lookup and complete DMC identity formatting require the host repository.','Vocabulary absent from the confirmed 11-family source dictionary is outside this release scope.']}
    write_json('registry/coverage.json',coverage)
    with (ROOT/'registry/review-queue.csv').open('w',newline='') as fp:
        w=csv.writer(fp);w.writerow(['kind','identifier','role','confidence','validationStatus','priority','reason'])
        entries=[('element',n,e) for n,e in elems.items()]+[('attribute',n,a) for n,a in attrs.items()]
        for kind,n,e in sorted(entries,key=lambda x:(x[2]['confidence'],x[0],x[1])):
            priority='high' if e['confidence']<.5 or e.get('requiresStructuralLogic') else 'normal'
            w.writerow([kind,n,e['role'],e['confidence'],e['validationStatus'],priority,e['rationale']])
    styles()
    print(json.dumps({'elements':len(elems),'attributes':len(attrs),'roles':coverage['registration']['elementRoles'],'missingFamilies':coverage['inventory']['missingRequiredFamilies']},indent=2))

def component_requirement(role):
    return {'table':'CALS-aware resolver: table/title/tgroup wrappers, named columns and multiple groups.','table-group':'Resolve colspec/spanspec without invalid table nesting; provide rowSpan/colSpan, inherited align/valign and row/column separators. Character alignment remains unsupported and emits a diagnostic.','column-spec':'Consume structural column metadata; preserve original node in source contract.','span-spec':'Consume named span metadata; preserve original node in source contract.','table-cell':'Resolve named column spans and morerows; use th under thead.','reference':'Resolve IDs locally and data-module/external identities via host callback; preserve unresolved target.','media':'Resolve infoEntityIdent via host adapter. Expose a placeholder and all child content when unavailable.','diagnostic-step':'Preserve explicit branching target attributes; no operational interpretation inferred.','condition':'Preserve expression order; do not evaluate applicability from CSS.','interactive':'Render static content until host supplies a separately validated behavior adapter.','procedure-step':'Preserve nested order and labels; do not synthesize technical instructions.'}.get(role,'Shared content-preserving primitive; contextual tag/class overrides are applied before rendering.')


def styles():
    # Generated stylesheet kept apart from manual overrides.
    token='''/* Generated baseline tokens; override within .s1000d-document. */\n.s1000d-document { --s1000d-font: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; --s1000d-mono: ui-monospace, SFMono-Regular, Consolas, monospace; --s1000d-ink:#192b3d; --s1000d-muted:#526478; --s1000d-surface:#fff; --s1000d-subtle:#f3f6fa; --s1000d-line:#cbd5df; --s1000d-accent:#155f9b; --s1000d-warning:#a51d24; --s1000d-warning-bg:#fff1f1; --s1000d-caution:#805600; --s1000d-caution-bg:#fff8e8; --s1000d-note:#195c84; --s1000d-note-bg:#edf7fc; --s1000d-space-1:.25rem; --s1000d-space-2:.5rem; --s1000d-space-3:.75rem; --s1000d-space-4:1rem; --s1000d-space-6:1.5rem; --s1000d-radius:.35rem; font-family:var(--s1000d-font); color:var(--s1000d-ink); background:var(--s1000d-surface); line-height:1.6; overflow-wrap:anywhere; }\n'''
    sections={
 'typography.css':''' .s1000d-document .s1000d-paragraph { display:block; margin:.55rem 0; }
.s1000d-document .s1000d-heading { font-size:1.3rem; font-weight:700; line-height:1.3; margin:1rem 0 .5rem; }
.s1000d-document .s1000d-in-cell, .s1000d-document .s1000d-in-safety, .s1000d-document .s1000d-in-step { margin:.25rem 0; }
.s1000d-document .s1000d-heading:first-child, .s1000d-document .s1000d-paragraph:first-child { margin-top:0; }
.s1000d-document .s1000d-technical-value { display:inline; }
.s1000d-document .s1000d-verbatim { font-family:var(--s1000d-mono); white-space:pre-wrap; tab-size:4; background:var(--s1000d-subtle); border:1px solid var(--s1000d-line); padding:.75rem; overflow:auto; }
.s1000d-document .s1000d-verbatim-inline { display:inline; white-space:pre-wrap; padding:.1em .3em; }
.s1000d-document .s1000d-unknown { outline:1px dashed var(--s1000d-line); }
''',
 'inline.css':''' .s1000d-document .s1000d-inline { display:inline; }
.s1000d-document .s1000d-emphasis { font-style:italic; }
.s1000d-document .s1000d-bold { font-weight:700; font-style:normal; }
.s1000d-document .s1000d-italic { font-style:italic; }
.s1000d-document .s1000d-underline { text-decoration:underline; font-style:normal; }
.s1000d-document .s1000d-strike { text-decoration:line-through; font-style:normal; }
.s1000d-document .s1000d-overline { text-decoration:overline; font-style:normal; }
.s1000d-document .s1000d-subscript { vertical-align:sub; font-size:.8em; }
.s1000d-document .s1000d-superscript { vertical-align:super; font-size:.8em; }
.s1000d-document .s1000d-reference { color:var(--s1000d-accent); text-decoration:underline; text-underline-offset:.15em; }
.s1000d-document .s1000d-reference[data-s1000d-unresolved-reference="true"] { text-decoration-style:dotted; }
''',
 'structural.css':''' .s1000d-document .s1000d-section, .s1000d-document .s1000d-requirements { display:block; margin-block:1rem; }
.s1000d-document .s1000d-structural { display:block; }
.s1000d-document .s1000d-ordered-list, .s1000d-document .s1000d-unordered-list { margin:.5rem 0; padding-inline-start:1.7rem; }
.s1000d-document .s1000d-list-item { margin:.25rem 0; }
.s1000d-document .s1000d-ordered-list { counter-reset:list-item; }
.s1000d-document .s1000d-unordered-list > .s1000d-list-item { display:list-item; list-style-type:disc; }
.s1000d-document .s1000d-ordered-list > .s1000d-list-item { display:list-item; list-style-type:decimal; }
.s1000d-document .s1000d-label { display:inline-block; font-weight:700; margin-inline-end:.5rem; }
.s1000d-document .s1000d-attribute-value { font-family:var(--s1000d-mono); font-size:.88em; border:1px solid var(--s1000d-line); border-radius:var(--s1000d-radius); padding:.05em .3em; margin-inline-end:.3rem; }
.s1000d-document .s1000d-definition-list { margin:.75rem 0; }
.s1000d-document .s1000d-definition-term { font-weight:700; margin-top:.5rem; }
.s1000d-document .s1000d-definition-description { margin-inline-start:1.5rem; }
.s1000d-document .s1000d-list-heading, .s1000d-document .s1000d-step-heading { font-size:1rem; font-weight:700; margin:.25rem 0; }
.s1000d-document .s1000d-metadata { color:var(--s1000d-muted); font-size:.9em; }
.s1000d-document .s1000d-metadata-section { display:block; border-inline-start:2px solid var(--s1000d-line); padding-inline-start:.75rem; margin:.5rem 0; font-size:.9em; color:var(--s1000d-muted); }
.s1000d-document .s1000d-condition, .s1000d-document .s1000d-interactive { display:block; padding:.35rem .5rem; border-inline-start:2px dotted var(--s1000d-line); }
''',
 'tables.css':''' .s1000d-document .s1000d-table, .s1000d-document .s1000d-table-group { border-collapse:collapse; width:100%; margin:1rem 0; }
.s1000d-document .s1000d-table-cell { border:1px solid var(--s1000d-line); padding:.5rem .65rem; text-align:start; vertical-align:top; }
.s1000d-document .s1000d-table-head, .s1000d-document .s1000d-header-cell { background:var(--s1000d-subtle); font-weight:700; }
.s1000d-document .s1000d-table-body { vertical-align:top; }
.s1000d-document .s1000d-cell-heading { font-size:1rem; line-height:1.4; margin:.25rem 0; }
.s1000d-document .s1000d-table-foot { border-top:2px solid var(--s1000d-line); }
.s1000d-document .s1000d-table-row { break-inside:avoid; }
.s1000d-document .s1000d-table-wrapper { overflow-x:auto; max-width:100%; margin:1rem 0; }
.s1000d-document .s1000d-table-caption { caption-side:top; text-align:start; font-size:1rem; font-weight:700; padding-bottom:.5rem; }
.s1000d-document [data-s1000d-attr-frame="none"] { border:0; }
.s1000d-document [data-s1000d-attr-frame="all"] { border:1px solid var(--s1000d-line); }
.s1000d-document [data-s1000d-attr-frame="top"] { border-top:1px solid var(--s1000d-line); }
.s1000d-document [data-s1000d-attr-frame="bottom"] { border-bottom:1px solid var(--s1000d-line); }
.s1000d-document [data-s1000d-attr-frame="topbot"] { border-top:1px solid var(--s1000d-line); border-bottom:1px solid var(--s1000d-line); }
.s1000d-document [data-s1000d-attr-frame="sides"] { border-inline:1px solid var(--s1000d-line); }
.s1000d-document [data-s1000d-attr-rowsep="0"] { border-bottom:0; }
.s1000d-document [data-s1000d-attr-colsep="0"] { border-inline-end:0; }
@media (max-width:40rem) { .s1000d-document .s1000d-table-wrapper { overflow-x:auto; } .s1000d-document .s1000d-table-wrapper .s1000d-table-group { min-inline-size:32rem; } }
''',
 'procedures.css':''' .s1000d-document .s1000d-procedure-step { position:relative; border-inline-start:3px solid var(--s1000d-line); padding:.65rem 1rem; margin:.75rem 0; }
.s1000d-document .s1000d-procedure-step .s1000d-procedure-step { margin-inline-start:.75rem; }
.s1000d-document .s1000d-requirements { background:var(--s1000d-subtle); border:1px solid var(--s1000d-line); border-radius:var(--s1000d-radius); padding:1rem; }
.s1000d-document .s1000d-nested-requirements { background:transparent; border:0; border-radius:0; padding:0; margin:.5rem 0; }
.s1000d-document .s1000d-parts-record { border-top:1px solid var(--s1000d-line); padding-block:.5rem; }
''',
 'diagnostics.css':''' .s1000d-document .s1000d-diagnostic { display:block; margin:.5rem 0; }
.s1000d-document .s1000d-diagnostic-step { display:block; border:1px solid var(--s1000d-line); border-inline-start:3px solid var(--s1000d-accent); padding:.75rem 1rem; margin:.75rem 0; }
.s1000d-document .s1000d-diagnostic-branch { margin-block:.5rem; }
''',
 'safety.css':''' .s1000d-document .s1000d-warning, .s1000d-document .s1000d-caution, .s1000d-document .s1000d-note { display:block; border:1px solid currentColor; border-inline-start-width:5px; border-radius:var(--s1000d-radius); padding:.75rem 1rem; margin:1rem 0; break-inside:avoid; }
.s1000d-document .s1000d-warning { color:var(--s1000d-warning); background:var(--s1000d-warning-bg); }
.s1000d-document .s1000d-caution { color:var(--s1000d-caution); background:var(--s1000d-caution-bg); }
.s1000d-document .s1000d-note { color:var(--s1000d-note); background:var(--s1000d-note-bg); }
.s1000d-document .s1000d-safety { display:block; margin-block:1rem; }
''',
 'media.css':''' .s1000d-document .s1000d-figure { display:block; margin:1rem 0; }
.s1000d-document .s1000d-media { display:block; max-width:100%; margin:.5rem 0; }
.s1000d-document .s1000d-media img, .s1000d-document .s1000d-media video { max-width:100%; height:auto; }
.s1000d-document .s1000d-caption, .s1000d-document .s1000d-figure-caption { display:block; color:var(--s1000d-muted); font-size:.95rem; margin:.5rem 0; }
.s1000d-document .s1000d-media-slot { display:inline-block; vertical-align:top; max-width:100%; margin:.5rem 0; box-sizing:border-box; }
.s1000d-document .s1000d-media-block { display:block; }
.s1000d-document .s1000d-media-inline { display:inline-block; margin:0 .15rem; }
.s1000d-document .s1000d-media-placeholder { display:block; box-sizing:border-box; width:100%; border:1px dashed var(--s1000d-line); padding:1rem; background:var(--s1000d-subtle); }
''',
 'attributes.css':''' .s1000d-document [data-s1000d-attr-align="left"], .s1000d-document [data-s1000d-attr-align-caption="left"], .s1000d-document [data-s1000d-attr-align-caption-entry="left"] { text-align:left; }
.s1000d-document [data-s1000d-attr-align="right"], .s1000d-document [data-s1000d-attr-align-caption="right"], .s1000d-document [data-s1000d-attr-align-caption-entry="right"] { text-align:right; }
.s1000d-document [data-s1000d-attr-align="center"], .s1000d-document [data-s1000d-attr-align-caption="center"], .s1000d-document [data-s1000d-attr-align-caption-entry="center"] { text-align:center; }
.s1000d-document [data-s1000d-attr-align="justify"] { text-align:justify; }
.s1000d-document [data-s1000d-attr-valign="top"] { vertical-align:top; }
.s1000d-document [data-s1000d-attr-valign="middle"] { vertical-align:middle; }
.s1000d-document [data-s1000d-attr-valign="bottom"] { vertical-align:bottom; }
.s1000d-document [data-s1000d-attr-list-direction="rtl"] { direction:rtl; }
.s1000d-document [data-s1000d-attr-list-direction="ltr"] { direction:ltr; }
.s1000d-document [data-s1000d-attr-keep-with-next="1"] { break-after:avoid; }
@media print { .s1000d-document { color:#000; background:#fff; } .s1000d-document .s1000d-reference { color:inherit; } }
'''
    }
    (ROOT/'styles/tokens.css').write_text(token)
    for n,s in sections.items(): (ROOT/'styles'/n).write_text('/* Generated inferred baseline; edit manual-overrides.css for project changes. */\n'+s.lstrip())
    names=['tokens.css']+list(sections)
    (ROOT/'styles/generated.css').write_text('/* Generated bundle entry. No manual overrides are overwritten. */\n'+''.join(f'@import "./{n}";\n' for n in names))

if __name__=='__main__': generate()
