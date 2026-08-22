import os
from pathlib import Path

from dotenv import load_dotenv

# Carga de variables desde .env en desarrollo local.
load_dotenv()

BASE_DIR = Path(__file__).resolve().parent

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "dbadmin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "dbadmin")
DB_SSL = os.getenv("DB_SSL", "false").lower() == "true"