# Delivery report

## Milestone 1 — Exhaustive first-pass classification

Complete for the uploaded inventory: **1062 elements and 377 attributes** across the exact eleven dictionary families. Every entry has a role, proposed presentation or handling, rationale, provenance, confidence, validation status and limitations. The original dictionary is unchanged. 2 structural specifications are intentionally nonvisual; their original data remains available to table logic. Inferred confidence is not a correctness or conformity score.

Official release 4.0.2 XSDs and dictionary definitions supplement missing source context. All eleven flat XSDs compile. This does not certify input documents or their presentation.

## Milestone 2 — Contextual refinement

**Partially completed in the included reference React renderer.** 32 browser cases passed: 20 byte-preserved official explanatory fragments and 12 clearly labeled synthetic probes. Checks assert meaningful text order, CSS loading, visible unevaluated applicability and no viewport overflow. 197 registered elements were exercised; 865 remain unexercised. 79 registered attributes occurred in rendered examples; occurrence alone does not prove every attribute behavior.

Screenshots were captured at desktop and mobile widths. Initial screenshot review exposed over-nested requirement panels and overlapping unresolved media; shared contextual rules were refined. CALS row/column spans, occupied grids and malformed table fallbacks have focused tests. See tests/visual/visual-review.json and before/after images. Screenshots are an initial baseline, not an approved regression baseline.

No existing host renderer was supplied. Official dictionary samples are illustrative fragments, sometimes with placeholders; none is represented as a whole schema-valid DMC. Full DMC validation and integration into the production renderer remain open.

## Artifacts

- registry/elements.json and attributes.json: complete machine-readable mappings.
- registry/contextual-rules.json: shared parent, ancestor, family and attribute variations.
- registry/coverage.json and review-queue.csv: explicit coverage and review priorities.
- styles/index.css: stable stylesheet entry; manual overrides remain separate.
- render/index.js: ordered-AST React renderer, specialized CALS handling, references and media adapters.
- sources/: immutable inventory, official XSDs, definitions, examples and source hashes.
- tests/: behavioral checks, example probes and browser screenshot evidence.

## Open integration work

The host must provide validated media/entity resolution, cross-document navigation, applicability evaluation and any operational diagnostic/interactive engine. The baseline preserves those structures and attributes without executing them. Complex IPD, learning and interactive structures receive conservative readable output and explicit registry limitations. Coded typography uses separately cited presentation conventions, not invented enumeration meanings. Decimal/character table alignment, rotated text, mixed star/fixed column widths and complete print pagination may require specialized implementation.

## Verification

23 focused renderer tests passed; the production harness build, registry audit and 32 browser cases passed. Command outputs are retained in reports/. All eleven selected XSDs compile offline. The reference harness bundles the complete evidence-rich registry and currently produces a large-chunk build advisory; a production adapter can load only runtime mapping fields.

## Reproduce

Run `npm ci`, `npm run generate`, `npm test`, `npm run build`, `npm run test:browser`, then `npm run generate && npm run audit`. Browser tests use /usr/bin/chromium by default; set CHROMIUM_PATH for another Chromium binary. Python 3 is required for generation. Optional lxml enables offline XSD compilation with `python scripts/fetch_sources.py --offline`.
