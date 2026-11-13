# Agent Specification: S1000D Semantic Presentation & CSS Registry

**Project:** S1000D Element and Attribute Styling Library  
**Source:** S1000D Issue 4.0.2, `data-dict.json`  
**Target:** React-based, XML-to-JSON IETM rendering engine  
**Mission:** Generate comprehensive, context-aware baseline presentation coverage for the complete supported S1000D vocabulary.

## 1. Mission

Build a centralized, extensible repository mapping S1000D elements, attributes, and structural relationships to appropriate HTML presentation semantics, React rendering behavior, and CSS styling.

The goal is not to reproduce the legacy IETM or achieve pixel-perfect styling. The goal is to provide a functional, consistent, visually coherent baseline for as much of the supported vocabulary as possible, with minimal manual intervention.

Do not require manual instructions for every element.

Exercise independent judgment when appropriate. Infer sensible presentation conventions from element names, schema context, attributes, ancestor/descendant relationships, and technical publication practices.

Treat inferred styling as an editable baseline, not an official S1000D presentation requirement.

**Primary objective: Eliminate the need to style every XML element manually.**

## 2. Authoritative Inputs

Use `data-dict.json` as the initial structural inventory.

It contains:

- 1,062 canonical elements.
- 377 canonical attributes.
- 11 schema families.
- Element `parents`, `children`, `attributes`, `sourceSchemas`, and `schemaViews`.
- Family-specific content models containing sequences, choices, groups, and occurrence information.
- Identity rules for selected references.

Use the actual S1000D 4.0.2 XSDs when available to resolve incomplete or ambiguous definitions.

Do not assume that empty definitions, empty child arrays, or unresolved group items mean those structures have no content.

Preserve exact XML element and attribute spelling and case.

Do not modify source schemas or XML content.

## 3. Required Architecture

Implement one persistent presentation registry.

The registry must separate the following concerns:

| Layer | Purpose |
|---|---|
| Element inventory | Every known XML element |
| Semantic classification | What the element represents |
| Presentation mapping | HTML/React representation |
| Attribute handling | Behavior and styling modifiers |
| Contextual rules | Parent, family, and structural variations |
| CSS | Actual visual presentation |
| Coverage audit | Verified, inferred, unsupported, and untested rules |

Multiple elements may share one presentation primitive, but every element must have an explicit registry entry.

Do not create a separate React component or CSS file for every element unless its behavior requires it.

Do not duplicate styles across schema families when shared rules are sufficient.

## 4. Element Classification

Evaluate every element and assign a presentation role.

Initial role categories:

1. **Block content:** Paragraphs, sections, headings, descriptions, text containers.
2. **Inline content:** Emphasis, subscripts, superscripts, inline references, abbreviations.
3. **Structured layouts:** Tables, rows, entries, column specifications, lists.
4. **Procedural content:** Steps, substeps, preliminary requirements, closing requirements.
5. **Safety content:** Warnings, cautions, notes, hazards.
6. **Diagnostic content:** Fault isolation, questions, answers, branches, termination states.
7. **Media:** Figures, graphics, multimedia, captions, hotspots.
8. **Navigation:** Internal references, data module references, cross-references.
9. **Metadata:** Identification, issue information, management data.
10. **Structural containers:** XML hierarchy requiring no independent visual decoration.

An element can possess multiple roles or require contextual overrides.

Use an `unknown` classification only when no defensible inference can be made. Unknown elements must still preserve and display their content wherever safe and structurally possible.

## 5. Attribute Intelligence

Do not treat attributes as independent visual elements.

Classify them according to their actual effect:

- Typography and emphasis.
- Horizontal/vertical alignment.
- Width, height, and layout.
- Table row and column spanning.
- Borders, separators, and framing.
- Visibility and applicability.
- Numbering and enumeration.
- Semantic references and identifiers.
- Behavioral controls.
- Metadata-only attributes.

Generate CSS variants where appropriate.

Use normalized data attributes or CSS classes to express dynamic variants.

Preserve original attribute values within the transformation contract.

Do not conflate display-only styling with document semantics.

For example, applicability attributes must not be implemented as unconditional CSS hiding rules; actual applicability requires separately validated evaluation logic.

## 6. Context-Aware Presentation Decisions

An element's name alone is insufficient to determine presentation.

Evaluate:

- Parent element.
- Ancestor chain.
- Schema family.
- Element attributes.
- Child composition.
- Mixed text and element content.
- Neighboring elements where relevant.
- Existing presentation conventions.
- Document structure and intended use.

For example:

`para` may be a normal paragraph, a table-cell paragraph, a warning paragraph, or a procedural instruction.

These should share foundational typography without necessarily sharing identical spacing.

Generate contextual variants rather than requiring separate manually written rules for every occurrence.

Do not infer operational meaning solely from visual appearance.

## 7. Initial Presentation Baseline

Produce immediately useful defaults.

Examples:

| Element | Initial presentation intent |
|---|---|
| `para` | Readable paragraph typography and spacing |
| `emphasis` | Inline emphasis, modified by `emphasisType` |
| `verbatimText` | Monospace with whitespace preservation |
| `title` | Context-dependent heading typography |
| `preliminaryRqmts` | Structured preliminary requirements section |
| `closeRqmts` | Closing requirements section |
| `warning` | Highly visible safety notice |
| `caution` | Distinct caution notice |
| `note` | Informational notice |
| `isolationStep` | Diagnostic step with preserved decision structure |
| `entry` | Table cell respecting structural attributes |

These examples establish intent, not exhaustive mappings or mandatory styling values.

Use design tokens for colors, spacing, typography, borders, and emphasis.

Avoid arbitrary per-element styling when a shared semantic rule will produce the same result.

## 8. Structural Integrity Requirements

Presentation must never corrupt XML meaning.

The following are mandatory:

- Preserve document order.
- Preserve mixed-content text ordering.
- Preserve all meaningful text.
- Preserve nesting and semantic containment.
- Preserve references, IDs, and target identifiers.
- Preserve procedural and diagnostic relationships.
- Preserve table structure and spanning information.
- Do not synthesize missing technical instructions.
- Do not silently discard unknown or unsupported nodes.

CSS cannot resolve every structural problem.

When an element requires complex rendering logic, register the required component or behavior rather than attempting to compensate using CSS alone.

Flag structural limitations explicitly.

## 9. Intelligent Analysis Workflow

Process the dictionary systematically.

For each element:

**Step A — Inspect**

Read its canonical definition, family-specific views, attributes, parents, and available content model.

**Step B — Interpret**

Determine its most probable semantic and visual role. Consider structural context, not only its name.

**Step C — Map**

Assign an existing presentation primitive where possible. Create a new primitive only when it represents genuinely distinct behavior.

**Step D — Style**

Generate baseline CSS and attribute-driven variants.

**Step E — Validate**

Check syntax, selector targeting, registry integration, and representative rendered output.

**Step F — Record**

Store the mapping, rationale, confidence, source references, and testing status in the centralized registry.

Proceed to the next element or family without generating disconnected temporary implementations.

## 10. Suggested Repository Organization

```text
render/
├── registry/
│   ├── elements.json
│   ├── attributes.json
│   ├── contextual-rules.json
│   └── coverage.json
├── styles/
│   ├── tokens.css
│   ├── typography.css
│   ├── inline.css
│   ├── structural.css
│   ├── tables.css
│   ├── procedures.css
│   ├── diagnostics.css
│   ├── safety.css
│   └── media.css
├── mappings/
│   └── component-registry.json
├── tests/
│   ├── fixtures/
│   ├── snapshots/
│   └── visual/
└── README.md
```

Adapt this structure to the existing repository. Do not blindly replace existing files or create redundant modules.

Generated CSS must remain separate from manually maintained overrides.

## 11. Registry Entry Requirements

Each element requires a machine-readable record.

Example:

```json
{
  "element": "verbatimText",
  "role": "verbatim",
  "display": "block",
  "component": "Verbatim",
  "cssClass": "s1000d-verbatim",
  "attributes": {
    "verbatimStyle": {
      "handling": "variant"
    }
  },
  "contextOverrides": [],
  "classification": "inferred",
  "confidence": 0.9,
  "validationStatus": "untested"
}
```

The example is an inferred proposal, not a verified S1000D rule.

Required record metadata:

- Element identifier.
- Classification and presentation role.
- Component or HTML mapping.
- CSS selector/class reference.
- Supported attribute handling.
- Context-specific overrides.
- Classification provenance.
- Confidence score.
- Validation status.
- Known limitations.

Keep machine-inferred confidence separate from actual validation status.

## 12. Verification and Coverage

Generate a coverage audit from the original dictionary and registry.

Track:

- Total known elements.
- Total registered elements.
- Elements with generated presentation rules.
- Elements intentionally handled as nonvisual.
- Elements requiring dedicated structural logic.
- Attributes mapped to behaviors or styles.
- Unresolved definitions.
- Tested and untested mappings.
- Unsupported structures.
- Rendering regressions.

**Registry completeness does not equal rendering correctness.**

An element counts as registered when it has an explicit classification and mapping. It counts as visually validated only after representative output has been inspected or approved.

Do not manufacture successful validation results.

## 13. Implementation Priorities

Work in progressive batches.

**Priority 1 — Foundational coverage**

Text, paragraph, headings, inline formatting, lists, references, and common containers.

**Priority 2 — Technical structure**

Tables, figures, captions, warnings, cautions, notes, and requirements sections.

**Priority 3 — Specialized schema behavior**

Procedural instructions, fault isolation, illustrated parts data, and interactive content.

**Priority 4 — Remaining vocabulary**

Metadata structures, uncommon elements, exceptional attributes, and incomplete schema definitions.

Continue expanding existing working mappings instead of restarting the design for each schema family.

## 14. Acceptance Criteria

The assignment is complete when:

1. Every element in the provided dictionary has a registry entry.
2. Elements requiring visual output have an initial presentation mapping or are explicitly marked as blocked.
3. Every attribute has a documented handling classification.
4. Shared styling is reused consistently.
5. Source content survives transformation without silent data loss.
6. Contextual variants are supported.
7. CSS is generated and actually loaded by the target renderer.
8. Representative DMC fixtures demonstrate the output.
9. Unresolved structures are documented rather than guessed away.
10. The registry can be extended without rewriting the architecture.

Do not claim that full dictionary coverage means full S1000D conformance.

## 15. Agent Operating Instructions

You are authorized to make reasonable initial styling decisions independently.

Do not stop at every element to request human interpretation.

Do not limit output to a conceptual design, demonstration, or a handful of example selectors.

Implement working registry entries and styling.

Favor comprehensive baseline coverage over pixel-perfect presentation of a small subset.

However:

- Do not invent schema facts.
- Do not alter source document content.
- Do not silently ignore complex elements.
- Do not replace functioning implementations without justification.
- Do not generate repeated competing architectures.
- Do not create unnecessary scripts or output artifacts.
- Do not spend the entire task redesigning the registry.
- Do not declare success solely because CSS files exist.

When uncertain, use a conservative, content-preserving presentation, mark the inference, and continue.

**Final instruction:**

Build the actual element-and-attribute presentation repository. The deliverable is not another proposal for how such a system might work. It is a functional, progressively validated styling library that removes the burden of manually styling thousands of dynamic XML structures.
