# s1kd

Initial vertical slice for a schema-driven S1000D IETM platform.

## Repository layout

- `source/` original source dataset (preserved)
- `backend/` FastAPI API + XML discovery/compilation pipeline
- `frontend/` React/Vite renderer application
- `data/` generated release artifacts and inventories
- `design-guide/` architecture, schema catalog, and component specs
- `contracts/` versioned AST contract

## Backend

```powershell
cd C:\Users\haily\Desktop\s1kd\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
python .\scripts\generate_manifests.py
uvicorn app.main:app --reload
```

## Frontend

```powershell
cd C:\Users\haily\Desktop\s1kd\frontend
npm install
npm run dev
```

Set `VITE_API_BASE_URL` if backend is not at `http://localhost:8000`.

## Tests

```bash
cd /home/runner/work/s1kd/s1kd/backend && pytest
cd /home/runner/work/s1kd/s1kd/frontend && npm test
```

## Initial discovered schemas and root types

- Root document type observed in parseable modules: `dmodule`
- Schema locations observed:
  - `http://www.s1000d.org/S1000D_4-2/xml_schema_flat/brdoc.xsd`
  - `http://www.s1000d.org/S1000D_4-2/xml_schema_flat/brex.xsd`

See `data/manifests/*.json` and `design-guide/schema-catalog/inventory-summary.md`.
