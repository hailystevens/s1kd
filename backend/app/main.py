from __future__ import annotations

import json
import logging
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .models import ModuleDetail, ModuleSummary
from .settings import settings
from .xml_pipeline import compile_release, list_modules

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
LOGGER = logging.getLogger("s1kd.api")

app = FastAPI(title="S1000D IETM API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def bootstrap_release() -> None:
    compile_release(settings.source_dir, settings.data_dir, release_id="initial")


@app.get("/api/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/modules", response_model=list[ModuleSummary])
def get_modules() -> list[ModuleSummary]:
    return list_modules(settings.source_dir)


def _resolve_compiled_module_path(module_id: str) -> Path:
    active_release = json.loads((settings.data_dir / "active-release.json").read_text(encoding="utf-8"))["active_release"]
    module_path = settings.data_dir / "releases" / active_release / "modules" / f"{module_id}.json"
    if not module_path.exists():
        raise HTTPException(status_code=404, detail=f"Module not found: {module_id}")
    return module_path


@app.get("/api/modules/{module_id}", response_model=ModuleDetail)
def get_module(module_id: str) -> ModuleDetail:
    module_path = _resolve_compiled_module_path(module_id)
    try:
        return ModuleDetail.model_validate_json(module_path.read_text(encoding="utf-8"))
    except ValueError as exc:
        LOGGER.exception("Compiled artifact parse failed for module %s", module_id)
        raise HTTPException(status_code=500, detail="Compiled module artifact is invalid") from exc
