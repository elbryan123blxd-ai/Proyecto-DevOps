from decimal import Decimal

from app.models import Order, OrderItem, Product
from app.processor import process_pending_orders


def seed_order(db, product_stock: int, quantity: int):
    product = Product(
        name="EC2 Micro",
        description="Demo",
        price=Decimal("12.50"),
        stock=product_stock,
    )
    db.add(product)
    db.flush()

    order = Order(
        customer_name="Bryan",
        customer_email="bryan@example.com",
        status="pending",
        total=Decimal("25.00"),
        items=[
            OrderItem(
                product_id=product.id,
                quantity=quantity,
                unit_price=product.price,
            )
        ],
    )
    db.add(order)
    db.commit()
    return product.id, order.id


def test_completed_when_stock_ok(db):
    product_id, order_id = seed_order(db, product_stock=10, quantity=2)

    results = process_pending_orders(db, delay_ms=0)

    assert order_id is not None
    assert any("completed" in r for r in results)
    assert db.get(Order, order_id).status == "completed"
    assert db.get(Product, product_id).stock == 8


def test_failed_when_out_of_stock(db):
    product_id, order_id = seed_order(db, product_stock=1, quantity=5)

    results = process_pending_orders(db, delay_ms=0)

    assert any("failed" in r for r in results)
    assert db.get(Order, order_id).status == "failed"
    assert db.get(Product, product_id).stock == 1


def test_only_processes_pending(db):
    _, order_id = seed_order(db, product_stock=5, quantity=1)
    db.get(Order, order_id).status = "completed"
    db.commit()

    results = process_pending_orders(db, delay_ms=0)

    assert results == []