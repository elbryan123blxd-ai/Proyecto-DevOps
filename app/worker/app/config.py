import os

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://dbadmin:dbadmin@localhost:5432/appdb"
)

POLL_INTERVAL = float(os.environ.get("POLL_INTERVAL", "3"))
BATCH_SIZE = int(os.environ.get("BATCH_SIZE", "5"))
PROCESSING_DELAY_MS = int(os.environ.get("PROCESSING_DELAY_MS", "1500"))