# Synthetic renderer probes

These twelve XML files exercise presentation behavior. Eleven use the dictionary's eleven family contexts; `edge-cases.xml` concentrates structural regression cases. They were authored for this library and are not authentic S1000D DMCs, XSD-validated examples, or approved technical instructions. Family labels select rendering context and do not certify content-model validity.

The eleven family probes use element and attribute names present in the uploaded dictionary. The edge-case probe deliberately adds three namespaced extension elements, namespaced attributes, and an unknown behavioral attribute to check conservative fallback behavior. Missing ICN media identifiers are intentional: unresolved media must remain represented rather than disappearing.

`manifest.json` records SHA-256 checksums, provenance, family context, covered features, and limitations. Verify the XML source text order, identifier/reference values, table spans, and unresolved applicability preservation when comparing renderers. Attribute-only nodes in the publication, DML, and product probes are meaningful source data even when they contain no text nodes.

Real DMCs and the production renderer are still needed for Milestone 2 integration and representative visual approval. Rendering these probes does not establish complete S1000D conformance.
