# Source evidence

The uploaded `data-dict.json` remains the immutable inventory. Supplemental evidence resolves ambiguities without replacing it.

The official online dictionary at <https://users.s1000d.org/S1000D_DD_4.0/> identifies itself as **4.0.2** in `Files/js/datadictionary.json`. Every selected flat XSD also declares release **4.0.2**, release date **2013-09-13**. The URL folder `4.0` does not indicate a version mismatch.

## What is included

- `schema-evidence.json`: source URLs, SHA-256 hashes, lengths, exact family list, XSD compilation results, representative explanatory example metadata, and unresolved dependency evidence.
- `official-evidence.json`: element and attribute definitions from official dictionary XML, preserving editorial status, context, chapter and DMC references. Attribute records also contain XSD type and permitted enumeration values. Definitions may be incomplete or carry editorial status; presentation remains an inference.
- `schema-structure.json`: exact family/type evidence, mixed-content flags, direct child references expanded through model groups, attribute references expanded through groups, and unresolved groups. This summary supplements the uploaded dictionary's empty group arrays. Complete choices, ordering, occurrence bounds and constraints remain in the original XSDs.
- `presentation-code-evidence.json`: separately attributed presentation conventions for coded emphasis. These conventions are distinct from permitted enumeration membership.
- `external/Files/xml_schema_flat/`: the eleven dictionary families, with the `xlink`, RDF and DC imports needed to compile them.
- `external/Files/xml_schema_master/`: shared definitions used as evidence. A learning-object LOM dependency referenced by the general master schema is unavailable at the published location; it is recorded. All selected **flat** family XSDs compile successfully without it.
- `external/Files/samples/`: twenty byte-preserved official explanatory fragments selected through the official `sampleList.xml` index. All parse as XML. They are **not whole data modules**. Some contain literal ellipses or placeholder element names. Their original contents are retained and their limitations recorded; they must not be called schema-valid DMCs.

The implementation scope follows the user's clarification: the exact eleven families in the uploaded dictionary, including `checklist` and excluding `schedul`.

## Reproduce evidence

From the repository root:

```sh
python scripts/fetch_sources.py --offline
# To retrieve/update the published sources:
python scripts/fetch_sources.py --refresh
```

Python's standard library handles fetching and extraction. If `lxml` is installed, the script also compiles all eleven flat XSDs. Without it, compilation is explicitly marked untested.

A source hash identifies the bytes used in this baseline. It does not establish that the current remote source still has those bytes. XSD compilation establishes grammar availability; XML parsing establishes well-formedness. Neither establishes visual correctness, business-rule conformance, or complete S1000D conformance.

The official complete Bike sample package is offered on the S1000D download page, which requires agreement to terms and a human verification step. It was not obtained in this run. The official dictionary's explanatory fragments are used for representative output, alongside clearly identified test fixtures.
