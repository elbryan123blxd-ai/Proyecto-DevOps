# App 3 capas — CloudOps Store

Frontend (React), API (FastAPI + Postgres) y worker (Python) para el megaproyecto DevOps.

| Servicio | Tech | Puerto |
|----------|------|--------|
| `frontend` | React + Vite + nginx | 5173 → 80 |
| `api` | FastAPI + SQLAlchemy (async) + Postgres | 8000 |
| `worker` | Python (click) | — |

## Correr local (todo en Docker)

```bash
cd app
docker compose up --build
```

- Frontend: http://localhost:5173
- API docs: http://localhost:8000/docs
- Health: http://localhost:8000/api/products/health

## Correr solo la API (desarrollo)

```bash
cd app/api
cp .env.example .env
pip install -r requirements.txt
uvicorn main:app --reload
```

## Tests

```bash
# API (necesita Postgres en DB_HOST/DB_PORT)
cd app/api
pytest

# Worker
cd app/worker
pytest

# Frontend
cd app/frontend
npm ci
npm test
```