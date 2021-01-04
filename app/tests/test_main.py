from base64 import b64encode

from fastapi.testclient import TestClient


def test_protect_docs_no_credentials(client: TestClient):
    response = client.get(
        "/docs",
    )
    assert response.status_code == 401


def test_protect_docs_invalid_credentials(client: TestClient):
    response = client.get("/docs", headers={"Authorization": "xxx"})
    assert response.status_code == 401


def test_protect_docs_valid_credentials(client: TestClient):
    # ユーザー名とパスワードは app.main.py で定義してます
    encoded = b64encode("user:password".encode()).decode()
    response = client.get("/docs", headers={"Authorization": f"Basic {encoded}"})
    assert response.status_code == 200


def test_openapi(client: TestClient):
    # ユーザー名とパスワードは app.main.py で定義してます
    encoded = b64encode("user:password".encode()).decode()
    response = client.get("/openapi.json", headers={"Authorization": f"Basic {encoded}"})
    assert response.status_code == 200
