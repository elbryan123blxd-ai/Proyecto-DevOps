import pytest
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


@pytest.mark.asyncio
async def test_health(client):
    resp = await client.get("/api/products/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_create_and_get_product(client):
    payload = {"name": "Laptop", "description": "Ultrabook", "price": 1200.0, "stock": 5}
    created = await client.post("/api/products", json=payload)
    assert created.status_code == 201
    body = created.json()
    assert body["name"] == "Laptop"
    assert body["id"] > 0

    fetched = await client.get(f"/api/products/{body['id']}")
    assert fetched.status_code == 200
    assert fetched.json()["price"] == 1200.0


@pytest.mark.asyncio
async def test_update_product(client):
    payload = {"name": "Mouse", "price": 25.0, "stock": 10}
    created = await client.post("/api/products", json=payload)
    pid = created.json()["id"]

    updated = await client.patch(f"/api/products/{pid}", json={"price": 30.0})
    assert updated.status_code == 200
    assert updated.json()["price"] == 30.0


@pytest.mark.asyncio
async def test_delete_product(client):
    payload = {"name": "Keyboard", "price": 50.0, "stock": 3}
    created = await client.post("/api/products", json=payload)
    pid = created.json()["id"]

    deleted = await client.delete(f"/api/products/{pid}")
    assert deleted.status_code == 204

    gone = await client.get(f"/api/products/{pid}")
    assert gone.status_code == 404