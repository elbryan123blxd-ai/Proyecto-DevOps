from contextlib import asynccontextmanager

from fastapi import FastAPI

from app import seed
from app.database import engine
from app.models import Base
from app.routers import health, orders, products


@asynccontextmanager
async def lifespan(_app: FastAPI):
    Base.metadata.create_all(bind=engine)
    seed.seed_products()
    yield


app = FastAPI(title="cloudops-store API", version="0.1.0", lifespan=lifespan)
app.include_router(health.router)
app.include_router(products.router, prefix="/api")
app.include_router(orders.router, prefix="/api")