from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health() -> None:
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_modules_includes_parseable_entries() -> None:
    response = client.get("/api/modules")
    assert response.status_code == 200
    data = response.json()
    assert any(row["parsed"] for row in data)


def test_module_detail_round_trip() -> None:
    modules = client.get("/api/modules").json()
    parseable = next(row for row in modules if row["parsed"])

    response = client.get(f"/api/modules/{parseable['module_id']}")
    assert response.status_code == 200
    body = response.json()
    assert body["module_id"] == parseable["module_id"]
    assert body["ast"]["type"] == "document"
