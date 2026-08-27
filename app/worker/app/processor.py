import time

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Order, Product


def process_pending_orders(
    db: Session, batch_size: int = 5, delay_ms: int = 1500
) -> list[str]:
    pending = db.scalars(
        select(Order)
        .where(Order.status == "pending")
        .order_by(Order.created_at)
        .limit(batch_size)
    ).all()

    results: list[str] = []

    for order in pending:
        order.status = "processing"
        db.flush()

        missing: set[int] = set()
        for item in order.items:
            product = db.get(Product, item.product_id)
            if product is None or product.stock < item.quantity:
                missing.add(item.product_id)

        if delay_ms:
            time.sleep(delay_ms / 1000)

        if missing:
            order.status = "failed"
            results.append(
                f"order {order.id} -> failed (sin stock: {sorted(missing)})"
            )
        else:
            for item in order.items:
                product = db.get(Product, item.product_id)
                product.stock -= item.quantity
            order.status = "completed"
            results.append(f"order {order.id} -> completed")

        db.commit()

    return results