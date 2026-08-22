from worker import process_job


def test_process_job():
    job = {"id": "job-test", "payload": {"counter": 1}}
    # Debe correr sin errores.
    process_job(job)