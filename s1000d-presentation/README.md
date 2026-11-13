# S1000D semantic presentation registry

A complete first-pass presentation registry for the uploaded S1000D 4.0.2 dictionary, with shared CSS, contextual rules, a working React reference renderer and reproducible evidence. The scope is the exact eleven dictionary families, including `checklist` and excluding `schedul`.

Start with [REPORT.md](REPORT.md) for verified counts, milestone status and remaining integration work. All styling is an editable presentation baseline, not an official S1000D presentation requirement or conformance claim.

## Run locally

Requires Node 22+ and Python 3. Install locked dependencies and run the reference harness:

```sh
npm ci
npm run generate
npm run dev
```

Open the address printed by Vite. The selector includes twenty original official dictionary fragments and twelve synthetic structural probes. Their provenance appears beside the output. XML source and rendered output can be compared without altering either source.

```sh
npm test
npm run build
npm run test:browser
npm run generate
npm run audit
```

Browser tests use `/usr/bin/chromium`; set `CHROMIUM_PATH` if necessary. They produce screenshots and `tests/visual/browser-report.json`. Regenerating afterward folds that evidence into registry validation statuses. Use `python scripts/fetch_sources.py --offline` to re-extract included official evidence; optional `lxml` enables XSD compilation. See [sources/README.md](sources/README.md).

## Integrate with React

```jsx
import {S1000DDocument, parseXml} from './render/index.js';
import './styles/index.css';

const node = parseXml(xmlString);
<S1000DDocument
  node={node}
  family="proced"
  resolveReference={(node, context) => lookupModuleUrl(node, context)}
  resolveMedia={(node, context) => lookupMedia(node, context)}
  onDiagnostic={diagnostic => diagnostics.push(diagnostic)}
/>
```

Reference resolvers return a safe URL or `undefined`; media resolvers return `{src, alt}` or a URL. Resolution uses original XML fields, not generated labels. Unresolved references retain their content and attributes. Explicit `internalRefId` and `nextActionRefId` targets become fragment links; following a link does not execute diagnostic logic. The host owns cross-document identity construction and reference validation. Namespace IDs and source spelling remain exact. Multiple modules on one page need a host namespace strategy for duplicate IDs.

`onDiagnostic` runs during render, so use an idempotent collector; React may render repeatedly. The harness does not persist user documents or execute embedded behaviors. All metadata is visible by default. Attribute-only leaves render inspectable field/value pairs rather than disappear.

## Transformation contract

An ordered AST preserves mixed text and child order:

```json
{"type":"element","name":"para","attributes":{"id":"p1"},"children":[
  {"type":"text","value":"Before "},
  {"type":"element","name":"emphasis","attributes":{"emphasisType":"em01"},"children":[{"type":"text","value":"important"}]},
  {"type":"text","value":" after."}
]}
```

The parser uses strict SAX XML parsing. CDATA becomes ordered text; comments and processing instructions inside the root are retained in the AST but have no visual output. XML lexical formatting, quote choices and entity spellings are not round-tripped. Prolog/epilog comments and PIs are not included. DTD/entity declarations are rejected explicitly: resolve trusted ICN/entity catalogs outside this parser, then provide the ordered AST and media resolver. The parser never downloads external entities. Key-grouped XML JSON cannot recover order and is rejected; adapt an ordered source rather than guessing.

Original attributes are retained in the AST, the DOM's JSON `data-s1000d-attributes`, and normalized `data-s1000d-attr-*` hooks. Canonical source spelling and values are never rewritten. CSS recognizes safe variants; unsupported values stay inspectable. Applicability and visibility are unevaluated data, never unconditional CSS hiding. Behavior expressions are content, not JavaScript.

## Shared architecture

| Path | Purpose |
| --- | --- |
| `registry/elements.json` | Explicit record for all 1,062 canonical elements |
| `registry/attributes.json` | Handling and limitations for all 377 attributes |
| `registry/contextual-rules.json` | Parent, ancestor, family and attribute overrides |
| `registry/coverage.json` | Registration, inference, unresolved evidence, testing counts |
| `registry/review-queue.csv` | Prioritized low-confidence and complex mappings |
| `registry/overrides.json` | Persistent manual registry overrides |
| `mappings/component-registry.json` | Shared presentation primitives |
| `styles/index.css` | Stable import: generated CSS, then project overrides |
| `render/` | React, attribute adapters, ordered XML parser |
| `sources/` | Original dictionary, specification and cited official evidence |
| `tests/visual/` | Browser report, screenshots, initial review evidence |

Many elements share a primitive. CALS groups become separate HTML tables inside one source-order-preserving wrapper. Table titles stay in their original order above groups. Lists use accessible list/listitem roles with CSS markers so titles and mixed content remain in place. Source attributes, table spans, step nesting and diagnostic alternatives survive transformation. Unsupported table child structures use readable ordered wrappers, with a diagnostic, instead of silent browser reparenting or data loss.

The registry's proposed HTML tag can be adapted by structural renderer logic: examples include list containers with titles, table wrappers with multiple groups, and orphan cells. Specialized handlers are documented in the runtime; these do not imply operational support for all interactive schema structures.

## Extend without losing edits

Edit `registry/overrides.json` for named element/attribute mapping changes, and `styles/manual-overrides.css` for project CSS. Generation overwrites generated registries/styles but preserves those two files. Update generator rules for reusable contextual logic. Do not add document-ID-specific CSS. Add the smallest reproducing example and assertion, run the renderer, and store the resulting evidence.

Confidence describes inference strength. `render-tested` means the reported examples passed content/order and browser smoke assertions; it does not mean every possible context of that element is correct. An attribute observed in a rendered example has not automatically had its behavior verified. Visual approval and schema validation remain separate, explicit statuses. Test counts and limitations are generated from evidence, not from registry completeness.
