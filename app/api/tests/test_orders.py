def test_create_order_sets_pending_and_total(client):
    products = client.get("/api/products").json()
    p1, p2 = products[0], products[1]

    res = client.post(
        "/api/orders",
        json={
            "customer_name": "Bryan",
            "customer_email": "bryan@example.com",
            "items": [
                {"product_id": p1["id"], "quantity": 2},
                {"product_id": p2["id"], "quantity": 1},
            ],
        },
    )
    assert res.status_code == 201
    body = res.json()
    assert body["status"] == "pending"
    assert body["customer_email"] == "bryan@example.com"
    assert len(body["items"]) == 2
    expected = float(p1["price"]) * 2 + float(p2["price"]) * 1
    assert float(body["total"]) == expected


def test_create_order_with_unknown_product_returns_404(client):
    res = client.post(
        "/api/orders",
        json={
            "customer_name": "Bryan",
            "customer_email": "bryan@example.com",
            "items": [{"product_id": 999999, "quantity": 1}],
        },
    )
    assert res.status_code == 404


def test_get_created_order(client):
    products = client.get("/api/products").json()
    created = client.post(
        "/api/orders",
        json={
            "customer_name": "Bryan",
            "customer_email": "bryan@example.com",
            "items": [{"product_id": products[0]["id"], "quantity": 1}],
        },
    ).json()

    res = client.get(f"/api/orders/{created['id']}")
    assert res.status_code == 200
    assert res.json()["id"] == created["id"]
    assert res.json()["status"] == "pending"

    missing = client.get("/api/orders/999999")
    assert missing.status_code == 404