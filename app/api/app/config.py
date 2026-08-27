from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "cloudops-store-api"
    database_url: str = "postgresql://dbadmin:dbadmin@localhost:5432/appdb"


settings = Settings()