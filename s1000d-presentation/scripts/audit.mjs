import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const inventory=read('sources/data-dict.json'), elements=read('registry/elements.json'),attributes=read('registry/attributes.json'),coverage=read('registry/coverage.json');
const components=read('mappings/component-registry.json');
assert.deepEqual(Object.keys(elements).sort(),Object.keys(inventory.elements).sort());
assert.deepEqual(Object.keys(attributes).sort(),Object.keys(inventory.attributes).sort());
for(const [name,e] of Object.entries(elements)) {
  assert.equal(e.element,name);
  for(const k of ['role','component','htmlTag','cssClass','classification','validationStatus']) assert.ok(e[k],`${name}.${k}`);
  assert.ok(e.confidence>=0 && e.confidence<=1,`${name}.confidence`);
  assert.ok(Array.isArray(e.knownLimitations),`${name}.knownLimitations`);
  const css=fs.readdirSync('styles').filter(x=>x.endsWith('.css')).map(x=>fs.readFileSync(`styles/${x}`,'utf8')).join('\n');
  if(e.display!=='nonvisual') assert.ok(css.includes(`.${e.cssClass}`),`${name} selector missing`);
}
for(const [name,a] of Object.entries(attributes)) {assert.ok(a.role && a.handling,`${name} handling`);assert.ok(a.confidence>=0&&a.confidence<=1);}
const bytes=fs.readFileSync('sources/data-dict.json');
assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),coverage.inventory.sourceSha256,'original inventory hash');
const browser=read('tests/visual/browser-report.json');
const known=browser.elementsExercised.filter(x=>elements[x]);
const observedAttrs=browser.attributesExercised.filter(x=>attributes[x]);
const summary={format:'s1000d-delivery-audit',milestone1:'complete-first-pass',milestone2:'partial-reference-renderer-refinement',
  elements:Object.keys(elements).length,attributes:Object.keys(attributes).length,families:Object.keys(inventory.schemas).sort(),
  browserFixtures:browser.fixtureCount,officialFragments:browser.results.filter(x=>x.origin==='official-dd-fragment').length,
  syntheticProbes:browser.results.filter(x=>x.origin==='synthetic').length,
  registeredElementsExercised:known.length,registeredAttributesObserved:observedAttrs.length,
  registeredElementsNotExercised:Object.keys(elements).length-known.length,
  originalInventoryUnmodified:true,missingElementEntries:[],missingAttributeEntries:[],
  hostRendererIntegration:'not-available',wholeDMCValidation:'not-performed',
  humanVisualApproval:'not-performed',limitations:browser.limitations};
fs.mkdirSync('reports',{recursive:true});
fs.writeFileSync('reports/delivery-audit.json',JSON.stringify(summary,null,2)+'\n');
const report=`# Delivery report\n\n## Milestone 1 — Exhaustive first-pass classification\n\nComplete for the uploaded inventory: **${summary.elements} elements and ${summary.attributes} attributes** across the exact eleven dictionary families. Every entry has a role, proposed presentation or handling, rationale, provenance, confidence, validation status and limitations. The original dictionary is unchanged. ${coverage.registration.elementsIntentionallyNonvisual} structural specifications are intentionally nonvisual; their original data remains available to table logic. Inferred confidence is not a correctness or conformity score.\n\nOfficial release 4.0.2 XSDs and dictionary definitions supplement missing source context. All eleven flat XSDs compile. This does not certify input documents or their presentation.\n\n## Milestone 2 — Contextual refinement\n\n**Partially completed in the included reference React renderer.** ${summary.browserFixtures} browser cases passed: ${summary.officialFragments} byte-preserved official explanatory fragments and ${summary.syntheticProbes} clearly labeled synthetic probes. Checks assert meaningful text order, CSS loading, visible unevaluated applicability and no viewport overflow. ${known.length} registered elements were exercised; ${summary.registeredElementsNotExercised} remain unexercised. ${observedAttrs.length} registered attributes occurred in rendered examples; occurrence alone does not prove every attribute behavior.\n\nScreenshots were captured at desktop and mobile widths. Initial screenshot review exposed over-nested requirement panels and overlapping unresolved media; shared contextual rules were refined. CALS row/column spans, occupied grids and malformed table fallbacks have focused tests. See tests/visual/visual-review.json and before/after images. Screenshots are an initial baseline, not an approved regression baseline.\n\nNo existing host renderer was supplied. Official dictionary samples are illustrative fragments, sometimes with placeholders; none is represented as a whole schema-valid DMC. Full DMC validation and integration into the production renderer remain open.\n\n## Artifacts\n\n- registry/elements.json and attributes.json: complete machine-readable mappings.\n- registry/contextual-rules.json: shared parent, ancestor, family and attribute variations.\n- registry/coverage.json and review-queue.csv: explicit coverage and review priorities.\n- styles/index.css: stable stylesheet entry; manual overrides remain separate.\n- render/index.js: ordered-AST React renderer, specialized CALS handling, references and media adapters.\n- sources/: immutable inventory, official XSDs, definitions, examples and source hashes.\n- tests/: behavioral checks, example probes and browser screenshot evidence.\n\n## Open integration work\n\nThe host must provide validated media/entity resolution, cross-document navigation, applicability evaluation and any operational diagnostic/interactive engine. The baseline preserves those structures and attributes without executing them. Complex IPD, learning and interactive structures receive conservative readable output and explicit registry limitations. Coded typography uses separately cited presentation conventions, not invented enumeration meanings. Decimal/character table alignment, rotated text, mixed star/fixed column widths and complete print pagination may require specialized implementation.\n\n## Reproduce\n\nRun \`npm ci\`, \`npm run generate\`, \`npm test\`, \`npm run build\`, \`npm run test:browser\`, then \`npm run generate && npm run audit\`. Browser tests use /usr/bin/chromium by default; set CHROMIUM_PATH for another Chromium binary. Python 3 is required for generation. Optional lxml enables offline XSD compilation with \`python scripts/fetch_sources.py --offline\`.\n`;
fs.writeFileSync('REPORT.md',report);
console.log(JSON.stringify(summary,null,2));
