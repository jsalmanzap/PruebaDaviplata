from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_generar_consecutivo_returns_expected_payload():
    response = client.post("/consecutivo", json={"nombre": "Ana", "id": 1})
    assert response.status_code == 200
    body = response.json()
    assert body["nombre"] == "Ana"
    assert body["id"] == 1
    assert body["consecutivo"] >= 1


def test_generar_consecutivo_increments_on_each_call():
    first = client.post("/consecutivo", json={"nombre": "Ana", "id": 1}).json()
    second = client.post("/consecutivo", json={"nombre": "Beto", "id": 2}).json()
    assert second["consecutivo"] == first["consecutivo"] + 1


def test_generar_consecutivo_requires_valid_payload():
    response = client.post("/consecutivo", json={"nombre": "Ana"})
    assert response.status_code == 422
