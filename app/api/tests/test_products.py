def test_products_seeded(client):
    res = client.get("/api/products")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert data[0]["name"]


def test_create_product(client):
    payload = {
        "name": "Lambda Cold Start",
        "description": "Pago por invocación.",
        "price": "0.05",
        "stock": 1000,
    }
    res = client.post("/api/products", json=payload)
    assert res.status_code == 201
    body = res.json()
    assert body["name"] == "Lambda Cold Start"
    assert float(body["price"]) == 0.05
    assert body["stock"] == 1000


def test_get_missing_product_returns_404(client):
    res = client.get("/api/products/999999")
    assert res.status_code == 404