from pathlib import Path

from app.xml_pipeline import compile_module, compile_release


ROOT = Path(__file__).resolve().parents[2]


def test_compile_release_creates_manifest_files(tmp_path: Path) -> None:
    manifest = compile_release(ROOT / "source", tmp_path, release_id="test")
    assert manifest["release_id"] == "test"
    assert (tmp_path / "manifests" / "schema-inventory.json").exists()
    assert (tmp_path / "releases" / "test" / "manifest.json").exists()


def test_compile_module_uses_local_schema_bundle_for_strict_validation() -> None:
    detail = compile_module(ROOT / "source" / "DMC-S1000D-E-04-10-00-00A-024A-D_001-00_EN-US.XML")
    codes = {diag.code for diag in detail.diagnostics}
    assert "SCHEMA_MISSING" not in codes
    assert "XSD_VALIDATION_FAILED" not in codes
