import os
import time
from datetime import datetime, timezone

import click
from dotenv import load_dotenv

load_dotenv()

WORKER_NAME = os.getenv("WORKER_NAME", "worker-default")
POLL_INTERVAL = float(os.getenv("POLL_INTERVAL", "3.0"))


def process_job(job: dict):
    """Procesa un trabajo de ejemplo. En produccion se conecta a SQS/SNS."""
    job_id = job.get("id", "unknown")
    print(
        f"[{datetime.now(timezone.utc).isoformat()}] worker={WORKER_NAME} "
        f"procesando job={job_id} payload={job.get('payload')}",
        flush=True,
    )
    time.sleep(0.2)


@click.command()
@click.option("--once", is_flag=True, help="Procesa un solo job y termina (usado en tests).")
def main(once: bool):
    print(f"Worker {WORKER_NAME} listo. Polling cada {POLL_INTERVAL}s.", flush=True)
    counter = 0
    while True:
        counter += 1
        # Demo: job sintetico. Reemplazar por lectura real de una cola (SQS/Redis).
        process_job({"id": f"job-{counter}", "payload": {"counter": counter}})
        if once:
            break
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()