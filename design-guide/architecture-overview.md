# Initial Architecture Overview

## Pipeline

`source XML -> hardened lxml parser -> AST compiler -> versioned release artifacts -> FastAPI -> React renderer registry`

## Backend

- `backend/app/xml_pipeline.py` discovers modules and compiles parseable XML into per-module JSON artifacts.
- Release artifacts are written to `data/releases/<release_id>/modules` and activated by `data/active-release.json`.
- Machine-readable inventories are emitted in `data/manifests/`.

## Frontend

- React + TypeScript + Vite shell with MUI theme tokens.
- Left navigation panel lists parseable modules from `/api/modules`.
- Main panel loads `/api/modules/{module_id}` and renders AST using a centralized registry in `AstRenderer`.
- Frontend enforces AST version compatibility via `SUPPORTED_AST_VERSION`.

## Scope in this first slice

- Fully parseable source corpus currently includes two real XML modules.
- Placeholder files that contain only filename text are reported as parse failures and are not rendered.
- Unknown XML structures are preserved in AST and surfaced through fallback rendering.
