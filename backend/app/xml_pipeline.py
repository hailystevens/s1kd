from __future__ import annotations

import hashlib
import json
import logging
from collections import Counter, defaultdict
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from lxml import etree

from .models import AST_VERSION, AstNode, Diagnostic, ModuleDetail, ModuleSummary

LOGGER = logging.getLogger("s1kd.xml")
XSI_NS = "http://www.w3.org/2001/XMLSchema-instance"
SCHEMA_BUNDLE_DIR = (
    Path(__file__).resolve().parents[2] / "S1000D Issue 4.2" / "XML Schema Package" / "xml_schema_flat"
)


@dataclass
class SourceModule:
    module_id: str
    file_name: str
    path: Path


def _safe_parser() -> etree.XMLParser:
    return etree.XMLParser(
        resolve_entities=False,
        no_network=True,
        recover=False,
        remove_blank_text=False,
        huge_tree=False,
    )


def _resolve_schema_path(module_path: Path, schema_location: str | None) -> Path | None:
    if not schema_location:
        return None

    schema_name = Path(schema_location).name
    local_candidate = module_path.parent / schema_name
    if local_candidate.exists():
        return local_candidate

    bundled_candidate = SCHEMA_BUNDLE_DIR / schema_name
    if bundled_candidate.exists():
        return bundled_candidate

    return None


@lru_cache(maxsize=64)
def _load_xml_schema(schema_path: str) -> etree.XMLSchema:
    schema_tree = etree.parse(schema_path, _safe_parser())
    return etree.XMLSchema(schema_tree)


def _validate_against_schema(
    tree: etree._ElementTree, schema_path: Path, diagnostics: list[Diagnostic]
) -> bool:
    try:
        schema = _load_xml_schema(str(schema_path))
    except (etree.XMLSchemaParseError, etree.XMLSyntaxError, OSError, ValueError) as exc:
        diagnostics.append(
            Diagnostic(
                severity="error",
                code="SCHEMA_INVALID",
                message=f"Failed to load schema {schema_path.name}: {exc}",
                xpath="/",
            )
        )
        return False

    if not schema.validate(tree):
        schema_errors = [entry.message for entry in schema.error_log]
        details = "; ".join(schema_errors[:3])
        diagnostics.append(
            Diagnostic(
                severity="error",
                code="XSD_VALIDATION_FAILED",
                message=f"Strict XSD validation failed for {schema_path.name}: {details}",
                xpath="/",
            )
        )
        return False

    return True


def discover_xml_modules(source_dir: Path) -> list[SourceModule]:
    modules: list[SourceModule] = []
    for path in sorted(source_dir.glob("*.[xX][mM][lL]")):
        modules.append(SourceModule(module_id=path.stem, file_name=path.name, path=path))
    return modules


def _xpath_for(element: etree._Element) -> str:
    return element.getroottree().getpath(element)


def _to_ast(element: etree._Element, diagnostics: list[Diagnostic]) -> AstNode:
    node = AstNode(
        type="element",
        name=etree.QName(element).localname,
        attributes={k: v for k, v in element.attrib.items()},
        xpath=_xpath_for(element),
    )
    if element.text and element.text.strip():
        node.children.append(
            AstNode(type="text", name="#text", text=element.text, xpath=f"{node.xpath}/text()[1]")
        )

    for child in element:
        if not isinstance(child.tag, str):
            continue
        node.children.append(_to_ast(child, diagnostics))
        if child.tail and child.tail.strip():
            tail_idx = len(node.children) + 1
            node.children.append(
                AstNode(
                    type="text",
                    name="#text",
                    text=child.tail,
                    xpath=f"{node.xpath}/text()[{tail_idx}]",
                )
            )

    if node.name == "unknown":
        diagnostics.append(
            Diagnostic(
                severity="warning",
                code="UNSUPPORTED_ELEMENT",
                message="Unknown element encountered",
                xpath=node.xpath,
            )
        )

    return node


def compile_module(path: Path) -> ModuleDetail:
    diagnostics: list[Diagnostic] = []
    parser = _safe_parser()
    tree = etree.parse(str(path), parser)
    root = tree.getroot()
    schema_location = root.attrib.get(f"{{{XSI_NS}}}noNamespaceSchemaLocation")
    schema_path = _resolve_schema_path(path, schema_location)

    if schema_location and schema_path is None:
        diagnostics.append(
            Diagnostic(
                severity="error",
                code="SCHEMA_MISSING",
                message=f"Schema not available locally: {schema_location}",
                xpath="/",
            )
        )
    elif schema_path is not None:
        _validate_against_schema(tree, schema_path, diagnostics)

    ast_root = AstNode(type="document", name="dmodule", xpath="/", children=[_to_ast(root, diagnostics)])

    return ModuleDetail(
        module_id=path.stem,
        ast_version=AST_VERSION,
        root_element=etree.QName(root).localname,
        source_path=str(path),
        schema_location=schema_location,
        diagnostics=diagnostics,
        ast=ast_root,
    )


def list_modules(source_dir: Path) -> list[ModuleSummary]:
    summaries: list[ModuleSummary] = []
    parser = _safe_parser()
    for module in discover_xml_modules(source_dir):
        title = None
        issue = None
        root_element = None
        schema_location = None
        parsed = False
        try:
            tree = etree.parse(str(module.path), parser)
            root = tree.getroot()
            root_element = etree.QName(root).localname
            schema_location = root.attrib.get(f"{{{XSI_NS}}}noNamespaceSchemaLocation")
            title_node = root.find(".//dmTitle/infoName")
            issue_node = root.find(".//issueInfo")
            title = title_node.text.strip() if title_node is not None and title_node.text else None
            issue = issue_node.get("issueNumber") if issue_node is not None else None
            schema_path = _resolve_schema_path(module.path, schema_location)
            diagnostics: list[Diagnostic] = []
            parsed = schema_path is not None and _validate_against_schema(tree, schema_path, diagnostics)
        except etree.XMLSyntaxError:
            parsed = False

        summaries.append(
            ModuleSummary(
                module_id=module.module_id,
                file_name=module.file_name,
                source_path=str(module.path),
                root_element=root_element,
                schema_location=schema_location,
                issue=issue,
                title=title,
                size_bytes=module.path.stat().st_size,
                parsed=parsed,
            )
        )

    return summaries


def compile_release(source_dir: Path, data_dir: Path, release_id: str = "initial") -> dict:
    release_dir = data_dir / "releases" / release_id
    module_dir = release_dir / "modules"
    manifest_dir = data_dir / "manifests"
    module_dir.mkdir(parents=True, exist_ok=True)
    manifest_dir.mkdir(parents=True, exist_ok=True)

    modules = list_modules(source_dir)
    element_counter: Counter[str] = Counter()
    attr_counter: defaultdict[str, Counter[str]] = defaultdict(Counter)
    relationship_counter: Counter[str] = Counter()
    schema_counter: Counter[str] = Counter()
    references: Counter[str] = Counter()
    validation_report = {"parsed": [], "failed": []}

    compiled = []

    parser = _safe_parser()
    for summary in modules:
        path = Path(summary.source_path)
        if not summary.parsed:
            validation_report["failed"].append(
                {
                    "module_id": summary.module_id,
                    "file_name": summary.file_name,
                    "reason": "xml_parse_error",
                }
            )
            continue

        detail = compile_module(path)
        compiled.append(summary.module_id)

        out_path = module_dir / f"{summary.module_id}.json"
        out_path.write_text(detail.model_dump_json(indent=2), encoding="utf-8")

        tree = etree.parse(str(path), parser)
        root = tree.getroot()
        schema_location = root.attrib.get(f"{{{XSI_NS}}}noNamespaceSchemaLocation")
        if schema_location:
            schema_counter[schema_location] += 1

        for elem in root.iter():
            if not isinstance(elem.tag, str):
                continue
            name = etree.QName(elem).localname
            element_counter[name] += 1
            for attr_name, attr_val in elem.attrib.items():
                attr_counter[f"{name}@{attr_name}"][attr_val] += 1
                if "ref" in attr_name.lower() or attr_name.endswith("Ident"):
                    references[attr_name] += 1
            parent = elem.getparent()
            if parent is not None:
                rel = f"{etree.QName(parent).localname}>{name}"
                relationship_counter[rel] += 1

        validation_report["parsed"].append({"module_id": summary.module_id, "file_name": summary.file_name})

    source_fingerprint = hashlib.sha256(
        "\n".join(f"{m.file_name}:{m.size_bytes}" for m in modules).encode("utf-8")
    ).hexdigest()

    manifest = {
        "release_id": release_id,
        "source_fingerprint": source_fingerprint,
        "compiler_version": "0.1.0",
        "ast_version": AST_VERSION,
        "module_count": len(modules),
        "compiled_module_count": len(compiled),
        "compiled_modules": compiled,
    }

    (release_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    (data_dir / "active-release.json").write_text(
        json.dumps({"active_release": release_id}, indent=2), encoding="utf-8"
    )

    schema_inventory = {
        "observed_schema_locations": [
            {"schema_location": loc, "count": count} for loc, count in sorted(schema_counter.items())
        ]
    }
    element_inventory = {
        "elements": [{"name": name, "count": count} for name, count in element_counter.most_common()],
        "relationships": [
            {"relationship": rel, "count": count} for rel, count in relationship_counter.most_common()
        ],
        "attributes": [
            {
                "attribute": name,
                "distinct_values": len(values),
                "sample_values": sorted(values.keys())[:10],
            }
            for name, values in sorted(attr_counter.items())
        ],
    }
    reference_inventory = {
        "reference_attributes": [
            {"attribute": name, "count": count} for name, count in references.most_common()
        ]
    }

    (manifest_dir / "schema-inventory.json").write_text(json.dumps(schema_inventory, indent=2), encoding="utf-8")
    (manifest_dir / "element-inventory.json").write_text(json.dumps(element_inventory, indent=2), encoding="utf-8")
    (manifest_dir / "reference-inventory.json").write_text(
        json.dumps(reference_inventory, indent=2), encoding="utf-8"
    )
    (manifest_dir / "validation-report.json").write_text(json.dumps(validation_report, indent=2), encoding="utf-8")

    report_path = Path(__file__).resolve().parents[2] / "design-guide" / "schema-catalog"
    report_path.mkdir(parents=True, exist_ok=True)
    (report_path / "inventory-summary.md").write_text(
        "\n".join(
            [
                "# S1000D Schema Discovery Summary",
                "",
                f"- Source modules discovered: {len(modules)}",
                f"- Parseable XML modules: {len(compiled)}",
                f"- Non-parseable placeholder modules: {len(modules) - len(compiled)}",
                "",
                "## Observed schema locations",
                *[f"- `{row['schema_location']}` ({row['count']})" for row in schema_inventory["observed_schema_locations"]],
            ]
        ),
        encoding="utf-8",
    )

    LOGGER.info("Compiled release %s with %d parseable modules", release_id, len(compiled))
    return manifest
