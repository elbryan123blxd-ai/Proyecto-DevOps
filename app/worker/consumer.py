import logging
import signal
import time

from app.config import BATCH_SIZE, POLL_INTERVAL, PROCESSING_DELAY_MS
from app.db import SessionLocal
from app.processor import process_pending_orders

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger("cloudops-worker")

running = True


def _stop(_sig=None, _frame=None):
    global running
    running = False


def main():
    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    logger.info(
        "Worker arrancando (poll cada %ss, batch %s)...",
        POLL_INTERVAL,
        BATCH_SIZE,
    )
    while running:
        try:
            db = SessionLocal()
            try:
                for result in process_pending_orders(
                    db, batch_size=BATCH_SIZE, delay_ms=PROCESSING_DELAY_MS
                ):
                    logger.info(result)
            finally:
                db.close()
        except Exception:
            logger.exception("Error procesando pedidos")
        time.sleep(POLL_INTERVAL)
    logger.info("Worker detenido.")


if __name__ == "__main__":
    main()