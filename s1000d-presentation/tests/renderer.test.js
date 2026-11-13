import test from 'node:test';
import assert from 'node:assert/strict';
import React from 'react';
import {renderToStaticMarkup} from 'react-dom/server';
import {DOMParser} from '@xmldom/xmldom';
import {S1000DDocument, parseXml, textContent, validateAst, resolveMapping} from '../render/index.js';
import {safeUrl, attributeProps} from '../render/attributes.js';
import {readFileSync} from 'node:fs';

function output(xml, props = {}) {
  const diagnostics = [];
  const node = parseXml(xml);
  const html = renderToStaticMarkup(React.createElement(S1000DDocument, {node, family:'descript', onDiagnostic:d => diagnostics.push(d), ...props}));
  const document = new DOMParser().parseFromString(`<root>${html}</root>`, 'text/xml');
  return {node, html, document, diagnostics};
}
function all(doc, tag) {return Array.from(doc.getElementsByTagName(tag));}
function byElement(doc, name) {return all(doc, '*').filter(x => x.getAttribute('data-s1000d-element') === name);}
function sourceText(n) {
  if (n.nodeType === 3 || n.nodeType === 4) return n.nodeValue;
  if (n.nodeType === 1 && n.hasAttribute('data-s1000d-generated')) return '';
  return Array.from(n.childNodes || []).map(sourceText).join('');
}

test('ordered AST retains mixed text, CDATA, comments, QName case, and exact attribute values', () => {
  const n = parseXml('<para id="a" customValue="A &amp; B">before <emphasis>middle</emphasis> after <![CDATA[<literal>]]><!--keep--></para>');
  assert.equal(n.name,'para');
  assert.equal(n.attributes.customValue,'A & B');
  assert.deepEqual(n.children.map(c => c.type),['text','element','text','text','comment']);
  assert.equal(textContent(n),'before middle after <literal>');
  const o = output('<para>alpha <emphasis>bravo</emphasis> charlie <subScript>delta</subScript> echo</para>');
  assert.equal(sourceText(o.document),'alpha bravo charlie delta echo');
});

test('malformed XML and untrusted DTDs fail explicitly instead of losing content', () => {
  for (const xml of ['<para><emphasis></para>', '<a/><b/>', '<a>one</a>outside', 'outside<a/>', '<a x="1" x="2"/>', '<!DOCTYPE a [<!ENTITY e "expanded">]><a>&e;</a>']) {
    assert.throws(() => parseXml(xml), undefined, xml);
  }
});

test('AST adapter refuses key-grouped or non-string attribute input', () => {
  assert.throws(() => validateAst({para:{'#text':'text'}}), /ordered AST/);
  assert.throws(() => validateAst({type:'element',name:'para',attributes:{id:42},children:[]}), /strings/);
});

test('unknown extension content stays visible and all original attributes remain recoverable', () => {
  const o = output('<futureExtension WeirdCase="Value" id="future"><para>must survive</para></futureExtension>');
  assert.equal(sourceText(o.document),'must survive');
  assert.deepEqual(JSON.parse(byElement(o.document,'futureExtension')[0].getAttribute('data-s1000d-attributes')), {WeirdCase:'Value',id:'future'});
  assert.ok(o.diagnostics.some(d => d.code === 'unknown-element'));
  const attrOnly = output('<futureExtension dataValue="42"/>');
  assert.match(attrOnly.html,/dataValue: 42/);
});

test('applicability and visibility are preserved without unconditional hiding', () => {
  const o = output('<para id="p1" applicRefId="aircraft-A" visibility="0">Applicable content remains readable</para>');
  assert.match(o.html,/Applicable content remains readable/);
  const p = byElement(o.document,'para')[0];
  assert.equal(p.getAttribute('data-s1000d-evaluation'),'not-evaluated');
  assert.equal(p.hasAttribute('hidden'),false);
  assert.doesNotMatch(p.getAttribute('style') || '',/display\s*:\s*none|visibility\s*:\s*hidden/);
});

test('attribute-only identifiers are rendered as inspectable data without invented instructions', () => {
  const o = output('<dmCode modelIdentCode="MODEL" systemCode="27" infoCode="040"/>');
  assert.match(o.html,/modelIdentCode: MODEL/);
  assert.match(o.html,/systemCode: 27/);
  assert.match(o.html,/infoCode: 040/);
  assert.deepEqual(JSON.parse(byElement(o.document,'dmCode')[0].getAttribute('data-s1000d-attributes')),o.node.attributes);
});

test('references preserve IDs, resolve internal fragments and reject executable schemes', () => {
  const internal = output('<description><para id="target">Destination</para><para>See <internalRef internalRefId="target">target text</internalRef>.</para></description>');
  assert.equal(all(internal.document,'a')[0].getAttribute('href'),'#target');
  assert.equal(all(internal.document,'a')[0].textContent,'target text');
  const external = output('<dmRef><dmRefIdent><dmCode modelIdentCode="X"/></dmRefIdent></dmRef>',{resolveReference:() => 'javascript:alert(1)'});
  assert.equal(all(external.document,'a').length,0);
  assert.ok(external.diagnostics.some(d => d.code === 'unresolved-reference'));
  assert.match(external.html,/modelIdentCode: X/);
  for (const url of ['javascript:alert(1)','data:text/html,evil','vbscript:evil','//untrusted.test/x','https://good.test/\nattack']) assert.equal(safeUrl(url),undefined,url);
  for (const url of ['https://example.test/resource','#target','./relative','/image.png']) assert.equal(safeUrl(url),url,url);
  assert.equal(safeUrl('mailto:test@example.test',{image:true}),undefined);
});

test('unsafe CSS values are retained as data, never interpolated into style', () => {
  const attrs = {reproductionWidth:'expression(alert(1))', align:'left;display:none', valign:'hidden', id:'safe', onclick:'alert(1)'};
  const props = attributeProps(attrs);
  assert.equal(props.style,undefined);
  assert.equal(props.onclick,undefined);
  assert.deepEqual(JSON.parse(props['data-s1000d-attributes']),attrs);
});

test('CALS named spans, row spans, occupied columns, header cells and multiple tgroups', () => {
  const o = output('<table><title>Spans</title><tgroup cols="3"><colspec colname="a"/><colspec colname="b"/><colspec colname="c"/><spanspec spanname="bc" namest="b" nameend="c"/><thead><row><entry namest="a" nameend="c">Header</entry></row></thead><tbody><row><entry morerows="1">A1</entry><entry spanname="bc">BC1</entry></row><row><entry> B2 </entry><entry>C2</entry></row></tbody></tgroup><tgroup cols="1"><tbody><row><entry>Second group</entry></row></tbody></tgroup></table>');
  assert.equal(all(o.document,'table').length,2);
  assert.equal(all(o.document,'th')[0].getAttribute('colSpan') || all(o.document,'th')[0].getAttribute('colspan'),'3');
  const cells = all(o.document,'td');
  assert.equal(cells[0].getAttribute('rowSpan') || cells[0].getAttribute('rowspan'),'2');
  assert.equal(cells[1].getAttribute('colSpan') || cells[1].getAttribute('colspan'),'2');
  assert.equal(cells.length,5);
  assert.equal(sourceText(o.document),'SpansHeaderA1BC1 B2 C2Second group');
  assert.equal(o.diagnostics.filter(d => d.code === 'invalid-cals-span').length,0);
});

test('unsupported CALS descendants and mixed text stay in original order instead of disappearing', () => {
  const xml = '<table><tgroup cols="1"><tbody><row><entry>one</entry></row><future>two</future><row><entry>three</entry><future>four</future></row>five</tbody><future>six</future><tbody><row><entry>seven</entry></row></tbody>eight</tgroup></table>';
  const o = output(xml);
  assert.equal(sourceText(o.document),textContent(o.node));
  assert.ok(o.diagnostics.some(d => /unsupported|fallback/.test(d.code)));
});

test('invalid CALS span is diagnosed and cell content is retained', () => {
  const o = output('<table><tgroup cols="2"><colspec colname="a"/><colspec colname="b"/><tbody><row><entry namest="b" nameend="a" morerows="999999">Bad span survives</entry></row></tbody></tgroup></table>');
  assert.match(o.html,/Bad span survives/);
  assert.ok(o.diagnostics.some(d => d.code === 'invalid-cals-span'));
});

test('table and figure titles preserve order with valid contextual heading containers', () => {
  const o = output('<description><figure><title>Diagram</title><graphic infoEntityIdent="ICN-1"/></figure><table><title>Measurements</title><tgroup cols="1"><tbody><row><entry><para>value</para></entry></row></tbody></tgroup></table></description>');
  assert.equal(all(o.document,'figcaption')[0].textContent,'Diagram');
  assert.equal(byElement(o.document,'title')[1].tagName,'div');
  assert.ok(o.html.indexOf('Diagram') < o.html.indexOf('Unresolved graphic'));
  assert.ok(o.html.indexOf('Measurements') < o.html.indexOf('value'));
});

test('nested procedural and fault content retains exact relationships and source text', () => {
  const o = output('<mainProcedure><proceduralStep id="s1"><para>Outer instruction.</para><proceduralStep id="s1a"><warning><warningAndCautionPara>Danger.</warningAndCautionPara></warning><para>Inner instruction.</para></proceduralStep></proceduralStep><proceduralStep id="s2"><para>Next instruction.</para></proceduralStep></mainProcedure>',{family:'proced'});
  const steps = byElement(o.document,'proceduralStep');
  assert.equal(steps.length,3);
  assert.equal(steps[1].parentNode,steps[0]);
  assert.equal(steps[2].parentNode,byElement(o.document,'mainProcedure')[0]);
  assert.equal(sourceText(o.document),textContent(o.node));
  assert.equal(all(o.document,'aside').length,1);
  assert.equal(all(o.document,'a').length,0);
});

test('contextual mappings are shared rules with exact XML parent and family matching', () => {
  const p = parseXml('<para>text</para>');
  const baseline = resolveMapping(p,{family:'descript',parent:'description',ancestors:['description']});
  const tableCell = resolveMapping(p,{family:'descript',parent:'entry',ancestors:['table','tgroup','tbody','row','entry']});
  assert.equal(baseline.element || baseline.name || 'para','para');
  assert.ok(tableCell.appliedRules.length > 0,'table-cell paragraph should receive a contextual rule');
  assert.notDeepEqual(tableCell.appliedRules,baseline.appliedRules);
});

test('all synthetic family probes preserve original text order and nesting content', () => {
  const manifest = JSON.parse(readFileSync(new URL('./fixtures/manifest.json',import.meta.url),'utf8'));
  assert.deepEqual(new Set(manifest.families), new Set(['appliccrossreftable','brex','checklist','condcrossreftable','descript','dml','fault','ipd','pm','prdcrossreftable','proced']));
  for (const f of manifest.fixtures) {
    const xml = readFileSync(new URL(`./fixtures/${f.file}`,import.meta.url),'utf8');
    const o = output(xml,{family:f.family});
    assert.equal(sourceText(o.document),textContent(o.node),f.file);
  }
});

test('diagnostic branches link only to their explicit target and do not collapse alternatives', () => {
  const xml = '<isolationMainProcedure><isolationStep id="question"><isolationStepQuestion>Question text?</isolationStepQuestion><isolationStepAnswer><yesNoAnswer><yesAnswer nextActionRefId="yes-end"/><noAnswer nextActionRefId="no-end">Negative branch.</noAnswer></yesNoAnswer></isolationStepAnswer></isolationStep><isolationProcedureEnd id="yes-end"><para>Positive outcome.</para></isolationProcedureEnd><isolationProcedureEnd id="no-end"><para>Negative outcome.</para></isolationProcedureEnd></isolationMainProcedure>';
  const o = output(xml,{family:'fault'});
  const links = all(o.document,'a');
  assert.deepEqual(links.map(a => a.getAttribute('href')),['#yes-end','#no-end']);
  assert.match(links[0].textContent,/Yes/);
  assert.match(links[1].textContent,/Negative branch/);
  assert.equal(sourceText(o.document),textContent(o.node));
  assert.equal(byElement(o.document,'isolationProcedureEnd').length,2);
  assert.equal(all(o.document,'button').length,0,'presentation must not execute a diagnostic process');
});

test('nested mixed-content references avoid nested anchors and preserve every child', () => {
  const xml = '<description><para id="target">Destination.</para><para>Before <internalRef internalRefId="target"><emphasis>caption</emphasis><dmRef><dmRefIdent><dmCode modelIdentCode="DMC-X"/></dmRefIdent></dmRef> after</internalRef> end.</para></description>';
  const o = output(xml,{resolveReference:() => 'https://example.test/dmc'});
  const links = all(o.document,'a');
  assert.equal(links.length,1);
  assert.equal(links[0].getAttribute('href'),'#target');
  assert.equal(byElement(o.document,'dmRef').length,1);
  assert.equal(byElement(o.document,'dmCode').length,1);
  assert.equal(sourceText(o.document),textContent(o.node));
  assert.match(o.html,/modelIdentCode: DMC-X/);
});

test('unsafe media resolver URLs become explicit placeholders without losing hotspot content', () => {
  const o = output('<graphic infoEntityIdent="ICN-X"><hotspot id="h1" applicationStructureIdent="part-1">Hotspot caption.</hotspot></graphic>', {resolveMedia:() => ({src:'javascript:alert(1)',alt:'Unsafe media'})});
  assert.equal(all(o.document,'img').length,0);
  assert.match(o.html,/Unresolved graphic: ICN-X/);
  assert.equal(sourceText(o.document),'Hotspot caption.');
  assert.equal(byElement(o.document,'hotspot')[0].getAttribute('id'),'h1');
});

test('CALS unresolved named spans and columns are diagnosed while all values survive', () => {
  const o = output('<table><tgroup cols="4"><colspec colname="known"/><tbody><row><entry namest="missing-start">A</entry><entry nameend="missing-end">B</entry><entry colname="missing-column">C</entry><entry spanname="missing-span">D</entry></row></tbody></tgroup></table>');
  assert.equal(sourceText(o.document),'ABCD');
  assert.equal(o.diagnostics.filter(d => d.code==='unresolved-cals-column').length,3);
  assert.equal(o.diagnostics.filter(d => d.code==='unresolved-cals-span').length,1);
  assert.deepEqual(all(o.document,'td').map(c => JSON.parse(c.getAttribute('data-s1000d-attributes'))), [
    {namest:'missing-start'},{nameend:'missing-end'},{colname:'missing-column'},{spanname:'missing-span'},
  ]);
});

test('sparse CALS colnum declarations keep widths on the correct physical column', () => {
  const o = output('<table><tgroup cols="3"><colspec colnum="3" colname="last" colwidth="40mm"/><tbody><row><entry colname="last">Third column</entry></row></tbody></tgroup></table>');
  const cols=all(o.document,'col');
  assert.equal(cols.length,3);
  assert.equal(cols[0].getAttribute('data-s1000d-generated'),'empty-layout-column');
  assert.equal(cols[1].getAttribute('data-s1000d-generated'),'empty-layout-column');
  assert.equal(cols[2].getAttribute('data-s1000d-attr-colname'),'last');
  assert.match(cols[2].getAttribute('style'),/width:40mm/);
  assert.equal(all(o.document,'td').length,3,'two missing cells should retain the third-column placement');
  assert.equal(sourceText(o.document),'Third column');
});

test('CALS alignment and separators inherit into cells with original attributes preserved', () => {
  const o = output('<table><tgroup cols="2" align="left" valign="bottom" rowsep="0" colsep="0"><colspec colname="first" align="right"/><colspec colname="second"/><tbody><row><entry>Column inherited</entry><entry>Group inherited</entry></row><row align="center" rowsep="1"><entry>Row inherited</entry><entry align="justify" colsep="1">Entry override</entry></row></tbody></tgroup></table>');
  const cells=all(o.document,'td');
  assert.deepEqual(cells.map(c=>c.getAttribute('data-s1000d-effective-align')),['right','left','center','justify']);
  assert.deepEqual(cells.map(c=>c.getAttribute('data-s1000d-effective-rowsep')),['0','0','1','1']);
  assert.match(cells[0].getAttribute('style'),/text-align:right/);
  assert.match(cells[0].getAttribute('style'),/vertical-align:bottom/);
  assert.match(cells[0].getAttribute('style'),/border-bottom:0/);
  assert.match(cells[0].getAttribute('style'),/border-inline-end:0/);
  assert.match(cells[2].getAttribute('style'),/text-align:center/);
  assert.match(cells[2].getAttribute('style'),/border-bottom:1px solid var\(--s1000d-line\)/);
  assert.match(cells[3].getAttribute('style'),/border-inline-end:1px solid var\(--s1000d-line\)/);
  assert.equal(cells[0].getAttribute('data-s1000d-attr-align'),'');
  assert.deepEqual(JSON.parse(cells[0].getAttribute('data-s1000d-attributes')),{});
  assert.deepEqual(JSON.parse(cells[3].getAttribute('data-s1000d-attributes')),{align:'justify',colsep:'1'});
});

test('complete all-star column widths resolve proportionally; mixed formulas are explicit limitations', () => {
  const weighted = output('<table><tgroup cols="2"><colspec colwidth="1*"/><colspec colwidth="3*"/><tbody><row><entry>A</entry><entry>B</entry></row></tbody></tgroup></table>');
  assert.deepEqual(all(weighted.document,'col').map(c=>c.getAttribute('style')),['width:25%','width:75%']);
  assert.equal(weighted.diagnostics.filter(d=>d.code==='unsupported-cals-width').length,0);
  const mixed=output('<table><tgroup cols="2"><colspec colwidth="1*+2pt"/><colspec colwidth="40mm"/><tbody><row><entry>A</entry><entry>B</entry></row></tbody></tgroup></table>');
  assert.equal(mixed.diagnostics.filter(d=>d.code==='unsupported-cals-width').length,1);
  assert.equal(all(mixed.document,'col')[0].getAttribute('data-s1000d-attr-colwidth'),'1*+2pt');
  assert.equal(sourceText(mixed.document),'AB');
});

test('oversized CALS column grids fall back visibly instead of allocating an unbounded grid', () => {
  for(const xml of ['<table><tgroup cols="10001"><tbody><row><entry>Bounded content</entry></row></tbody></tgroup></table>', '<table><tgroup cols="2"><colspec colnum="10001"/><tbody><row><entry>Bounded content</entry></row></tbody></tgroup></table>']) {
    const o = output(xml);
    assert.ok(o.diagnostics.some(d=>d.code==='invalid-cals-grid'));
    assert.equal(all(o.document,'col').length,0);
    assert.equal(sourceText(o.document),'Bounded content');
  }
});
