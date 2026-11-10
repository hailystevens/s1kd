from pathlib import Path

from app.xml_pipeline import compile_release


ROOT = Path(__file__).resolve().parents[2]


def test_compile_release_creates_manifest_files(tmp_path: Path) -> None:
    manifest = compile_release(ROOT / "source", tmp_path, release_id="test")
    assert manifest["release_id"] == "test"
    assert (tmp_path / "manifests" / "schema-inventory.json").exists()
    assert (tmp_path / "releases" / "test" / "manifest.json").exists()
