from decimal import Decimal

from sqlalchemy import func, select

from app.database import SessionLocal
from app.models import Product

DEMO_PRODUCTS = [
    {
        "name": "EC2 Micro (1 mes)",
        "description": "Instancia de cómputo ligera. Ideal para correr tu primera API.",
        "price": Decimal("12.50"),
        "stock": 25,
    },
    {
        "name": "S3 Bucket (1 GB)",
        "description": "Almacenamiento de objetos ultra duradero.",
        "price": Decimal("0.023"),
        "stock": 500,
    },
    {
        "name": "RDS Postgres (1 mes)",
        "description": "Base de datos gestionada. Perfecta para guardar pedidos.",
        "price": Decimal("28.00"),
        "stock": 15,
    },
    {
        "name": "Lambda Fan-out",
        "description": "Función serverless que procesa eventos bajo demanda.",
        "price": Decimal("0.05"),
        "stock": 1000,
    },
    {
        "name": "CloudFront CDN",
        "description": "Entrega tu contenido rápido a todo el mundo.",
        "price": Decimal("3.20"),
        "stock": 40,
    },
    {
        "name": "EKS Node Group",
        "description": "Nodos gestionados para correr tus contenedores.",
        "price": Decimal("72.00"),
        "stock": 8,
    },
    {
        "name": "Grafana Dashboard",
        "description": "Dashboards piolas para tus métricas de rollout.",
        "price": Decimal("0.00"),
        "stock": 999,
    },
    {
        "name": "ArgoCD Rollout",
        "description": "Canary deployments con auto-rollback.",
        "price": Decimal("1.50"),
        "stock": 60,
    },
]


def seed_products() -> None:
    db = SessionLocal()
    try:
        if db.scalar(select(func.count(Product.id))) == 0:
            db.add_all([Product(**p) for p in DEMO_PRODUCTS])
            db.commit()
    finally:
        db.close()