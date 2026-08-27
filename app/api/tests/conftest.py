import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

import pytest
from fastapi.testclient import TestClient

from app.database import SessionLocal, engine, get_db
from app.main import app
from app.models import Base
from app.seed import seed_products

if os.path.exists("test.db"):
    os.remove("test.db")

Base.metadata.create_all(bind=engine)
seed_products()


def override_get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture()
def client():
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()