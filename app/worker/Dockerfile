# ===== Imagen builder =====
FROM python:3.12-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# ===== Imagen final =====
FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH"

COPY --from=builder /install /install

RUN groupadd -g 1001 appuser && useradd -r -u 1001 -g appuser appuser

COPY . .

USER appuser

CMD ["python", "worker.py"]