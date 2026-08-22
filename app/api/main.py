from contextlib import asynccontextmanager

from fastapi import FastAPI

from config import DB_HOST
from db import Base, engine
from routes import router as products_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Crea las tablas si no existen. En produccion esto lo manejan las migrations.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()


app = FastAPI(
    title="CloudOps Store API",
    version="1.0.0",
    description="API de productos para la app de 3 capas.",
    lifespan=lifespan,
)

app.include_router(products_router)


@app.get("/")
async def root():
    return {
        "service": "cloudops-store-api",
        "status": "ok",
        "db_host": DB_HOST,
    }