#!/usr/bin/env python3
"""Fetch official Issue 4.0.2 schema/definition evidence, preserving original bytes.
Run from any directory. Cached files are reused; --refresh refetches, --offline forbids network.
The source dictionary is never modified. Official examples are explanatory fragments,
not necessarily well-formed XML or schema-valid whole data modules.
"""
from __future__ import annotations
import argparse, concurrent.futures, datetime, hashlib, json, pathlib, urllib.request, xml.etree.ElementTree as ET
ROOT=pathlib.Path(__file__).resolve().parents[1]
EXT=ROOT/'sources/external'
BASE='https://users.s1000d.org/S1000D_DD_4.0/'
XS='{http://www.w3.org/2001/XMLSchema}'
FAMILIES='appliccrossreftable brex checklist condcrossreftable descript dml fault ipd pm prdcrossreftable proced'.split()
MANIFEST={}
FAILED=[]
OFFLINE=False
def fetch(path, refresh=False):
    p=EXT/path
    if refresh or not p.exists():
        if OFFLINE:raise FileNotFoundError('Unavailable in offline cache: '+path)
        p.parent.mkdir(parents=True,exist_ok=True)
        with urllib.request.urlopen(BASE+path,timeout=30) as response:p.write_bytes(response.read())
    data=p.read_bytes()
    MANIFEST[path]={'url':BASE+path,'path':'sources/external/'+path,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
    return p

def text(n):return ''.join(n.itertext()).strip() if n is not None else ''
def definitions(path):
    out={}
    for n in ET.parse(EXT/path).getroot():
        name=n.findtext('name')
        if not name: continue
        rec={key:text(n.find(key)) for key in ['definition','title','chapter','para','DMC']}
        rec.update({'source':BASE+path,'context':n.get('context'),'editorialStatus':n.get('agreed',n.get('validationStatus',''))})
        out.setdefault(name,[]).append(rec)
    return out

def structure_overlay():
    """Resolve flat-XSD group references without claiming missing groups are empty."""
    out={}
    for fam in FAMILIES:
        schema=ET.parse(EXT/('Files/xml_schema_flat/'+fam+'.xsd')).getroot()
        idx={kind:{n.get('name'):n for n in schema.findall(XS+kind)} for kind in ['element','complexType','simpleType','group','attribute','attributeGroup']}
        def local(name):return name.split(':')[-1]
        def resolve_type(name,seen=None):
            seen=seen or set()
            if name in seen:return None
            seen=seen|{name}
            return idx['complexType'].get(local(name))
        def walk(node,groups=frozenset()):
            refs=[];attrs=[];unresolved=[]
            for n in node:
                kind=n.tag.removeprefix(XS)
                if kind=='element':refs.append(n.get('ref') or n.get('name'))
                elif kind=='attribute':attrs.append(n.get('ref') or n.get('name'))
                elif kind in ['group','attributeGroup'] and n.get('ref'):
                    ref=local(n.get('ref'));g=idx[kind].get(ref)
                    if g is None or ref in groups:unresolved.append(kind+':'+ref)
                    else:
                        rr,aa,uu=walk(g,groups|{ref});refs+=rr;attrs+=aa;unresolved+=uu
                elif kind not in ['annotation','simpleType']:
                    rr,aa,uu=walk(n,groups);refs+=rr;attrs+=aa;unresolved+=uu
            return refs,attrs,unresolved
        for name,e in idx['element'].items():
            typ=e.get('type','');t=resolve_type(typ)
            if t is None:t=e.find(XS+'complexType')
            if t is None:
                rec={'type':typ,'contentKind':'simple','mixed':False,'childRefs':[],'attributeRefs':[],'unresolvedGroups':[]}
            else:
                child,attrs,unresolved=walk(t)
                rec={'type':typ,'contentKind':'simple-content' if t.find(XS+'simpleContent') is not None else 'complex','mixed':t.get('mixed')=='true','childRefs':sorted(set(child)),'attributeRefs':sorted(set(attrs)),'unresolvedGroups':sorted(set(unresolved))}
            rec['source']=BASE+'Files/xml_schema_flat/'+fam+'.xsd'
            out.setdefault(name,{})[fam]=rec
    (ROOT/'sources/schema-structure.json').write_text(json.dumps({'format':'s1000d-xsd-structure-evidence','release':'4.0.2','note':'Direct-child references expanded through model groups; summaries are evidence, not replacement grammars. Original XSD files retain complete order/occurrence/choice constraints.','elements':out},indent=2)+'\n')
    return out

def main():
    global OFFLINE
    parser=argparse.ArgumentParser();parser.add_argument('--refresh',action='store_true');parser.add_argument('--offline',action='store_true');args=parser.parse_args();OFFLINE=args.offline
    paths=['Files/js/datadictionary.json','Files/xsl/datadict.xsl','Files/definitions/elementsDefinition.xml','Files/definitions/attributesDefinition.xml','Files/definitions/schemasDefinition.xml','Files/samples/sampleList.xml']
    paths += ['Files/xml_schema_master/'+n+'.xsd' for n in ['attributes','simpleTypes','complexElements','complexTypes','simpleElements','attributeGroups']]
    paths += ['Files/xml_schema_flat/'+n+'.xsd' for n in FAMILIES]
    for p in paths:fetch(p,args.refresh)
    # Resolve relative import/include dependencies; do not rewrite fetched XSDs.
    pending=[p for p in paths if p.endswith('.xsd')];seen=set()
    while pending:
        p=pending.pop()
        if p in seen:continue
        seen.add(p)
        tree=ET.parse(EXT/p).getroot()
        for n in list(tree.findall(XS+'import'))+list(tree.findall(XS+'include')):
            loc=n.get('schemaLocation')
            if loc and ':' not in loc:
                dependency=str(pathlib.PurePosixPath(p).parent/loc)
                try:fetch(dependency,args.refresh);pending.append(dependency)
                except Exception as e:FAILED.append({'url':BASE+dependency,'error':str(e)})
    ed=definitions('Files/definitions/elementsDefinition.xml')
    ad=definitions('Files/definitions/attributesDefinition.xml')
    attrs=ET.parse(EXT/'Files/xml_schema_master/attributes.xsd').getroot()
    types=ET.parse(EXT/'Files/xml_schema_master/simpleTypes.xsd').getroot()
    type_map={n.get('name'):n for n in types.findall(XS+'simpleType')}
    for a in attrs.findall(XS+'attribute'):
        name=a.get('name');t=a.get('type','').split(':')[-1];typ=type_map.get(t)
        enum=[n.get('value') for n in typ.iter(XS+'enumeration')] if typ is not None else []
        rec={'name':name,'xsdType':t,'enumValues':enum,'xsdSource':BASE+'Files/xml_schema_master/attributes.xsd','simpleTypeSource':BASE+'Files/xml_schema_master/simpleTypes.xsd'}
        ad.setdefault(name,[])
        if ad[name]:ad[name][0].update(rec)
        else:ad[name].append(rec)
    overlay={'format':'s1000d-official-evidence-overlay','release':'4.0.2','note':'Supplemental evidence only; original source dictionary remains unchanged. Definitions carry original editorial context/status. Enumeration membership does not establish presentation meaning.','elements':ed,'attributes':ad}
    (ROOT/'sources/official-evidence.json').write_text(json.dumps(overlay,ensure_ascii=False,indent=2)+'\n')
    structure=structure_overlay()
    # Fetch representative official explanatory examples referenced by the dictionary.
    sample_names=set('para emphasis verbatimText table entry proceduralStep preliminaryRqmts isolationStep fault checkListProcedure illustratedPartsCatalog catalogSeqNumber brex structureObjectRule applicCrossRefTable condCrossRefTable productCrossRefTable pmEntry dml warning caution note title listItemPrefix emphasisType verbatimStyle randomList'.split())
    sl=ET.parse(EXT/'Files/samples/sampleList.xml').getroot()
    selected={n.get('file') for n in sl if n.get('sample') in sample_names}
    examples=[]
    for fn in sorted(selected):
        p=fetch('Files/samples/'+fn,args.refresh)
        rec={'file':fn,'path':str(p.relative_to(ROOT)),'url':BASE+'Files/samples/'+fn,'selectedFor':[n.get('sample') for n in sl if n.get('file')==fn and n.get('sample') in sample_names],'wholeDataModule':False,'xsdValidated':False}
        try:
            t=ET.parse(p);rec.update({'wellFormed':True,'root':t.getroot().tag,'elements':sorted({n.tag for n in t.iter()}),'containsIllustrativePlaceholders':any('...' in (n.text or '') or '...' in n.tag for n in t.iter())})
        except ET.ParseError as e:rec.update({'wellFormed':False,'parseError':str(e)})
        examples.append(rec)
    families={}
    for fam in FAMILIES:
        tree=ET.parse(EXT/('Files/xml_schema_flat/'+fam+'.xsd')).getroot()
        docs=[text(n) for n in tree.findall(XS+'annotation/'+XS+'documentation')]
        families[fam]={'xsd':'sources/external/Files/xml_schema_flat/'+fam+'.xsd','url':BASE+'Files/xml_schema_flat/'+fam+'.xsd','releaseEvidence':[s for s in docs if s.startswith(('Issue number:','Release number:','Release date:'))],'elementDeclarations':len(tree.findall(XS+'element')),'attributeDeclarations':len(tree.findall(XS+'attribute'))}
    try:
        from lxml import etree
        for fam,rec in families.items():
            try:etree.XMLSchema(etree.parse(str(ROOT/rec['xsd'])));rec['xsdCompilation']='passed'
            except Exception as e:rec['xsdCompilation']='failed';rec['xsdCompilationError']=str(e)
    except ImportError:
        for rec in families.values():rec['xsdCompilation']='untested-lxml-unavailable'
    evidence={'format':'s1000d-source-evidence','retrievedDateUTC':datetime.datetime.now(datetime.timezone.utc).date().isoformat(),'baseURL':BASE,'release':'4.0.2','scopeFamilies':FAMILIES,'scopeNote':'User confirmed dictionary family list; schedul excluded, checklist included. A schedul XSD was encountered during initial discrepancy research but is outside implementation scope.','families':families,'definitionCounts':{'elementsWithNonemptyDefinitions':sum(any(r.get('definition') for r in v) for v in ed.values()),'attributesWithNonemptyDefinitions':sum(any(r.get('definition') for r in v) for v in ad.values())},'examples':examples,'files':[MANIFEST[k] for k in sorted(MANIFEST)],'unavailableDependencies':FAILED,'limitations':['Examples are specification illustrations/fragments, not complete data modules. Some contain ellipses or malformed placeholder attributes and are deliberately reported rather than repaired.','XSD enumerations identify permitted codes; they do not establish official CSS or styling values.','Schema grammar validation does not establish BREX conformance or visual correctness.']}
    (ROOT/'sources/schema-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print(json.dumps({'files':len(MANIFEST),'families':len(families),'examples':len(examples),'wellFormedExamples':sum(x['wellFormed'] for x in examples),'definitionCounts':evidence['definitionCounts']},indent=2))
if __name__=='__main__':main()
