from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.database import get_db
from app.models import Order, OrderItem, Product
from app.schemas import OrderCreate, OrderRead

router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("", response_model=list[OrderRead])
def list_orders(db: Session = Depends(get_db)):
    return db.scalars(
        select(Order).options(selectinload(Order.items)).order_by(Order.id.desc())
    ).all()


@router.get("/{order_id}", response_model=OrderRead)
def get_order(order_id: int, db: Session = Depends(get_db)):
    order = db.scalars(
        select(Order).where(Order.id == order_id).options(selectinload(Order.items))
    ).first()
    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return order


@router.post("", response_model=OrderRead, status_code=201)
def create_order(payload: OrderCreate, db: Session = Depends(get_db)):
    items: list[OrderItem] = []
    total = Decimal("0.00")

    for item in payload.items:
        product = db.get(Product, item.product_id)
        if not product:
            raise HTTPException(
                status_code=404, detail=f"Producto {item.product_id} no encontrado"
            )
        items.append(
            OrderItem(
                product_id=product.id,
                quantity=item.quantity,
                unit_price=product.price,
            )
        )
        total += product.price * item.quantity

    order = Order(
        customer_name=payload.customer_name,
        customer_email=payload.customer_email,
        status="pending",
        total=total,
        items=items,
    )
    db.add(order)
    db.commit()

    return db.scalars(
        select(Order)
        .where(Order.id == order.id)
        .options(selectinload(Order.items))
    ).one()