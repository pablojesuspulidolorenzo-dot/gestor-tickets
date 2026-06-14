from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Configuración central del sistema.

    El proyecto se ejecuta dentro de Docker. Las variables llegan normalmente
    desde docker-compose mediante env_file=.env.
    """

    # Aplicación
    APP_NAME: str = "gestor-tickets"
    APP_ENV: str = "development"
    APP_VERSION: str = "0.1.0"
    APP_SUBVERSION: int = 0
    APP_TIMEZONE: str = "Atlantic/Canary"
    SESSION_SECRET_KEY: str = "cambiar-este-secreto-en-produccion"

    # Seguridad / cifrado de secretos IMAP
    APP_ENCRYPTION_SECRET: str = "cambiar-este-secreto-de-cifrado"

    # PostgreSQL dockerizado
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "gestor_tickets"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"

    # Esquema lógico de la aplicación
    DB_SCHEMA: str = "gestor_tickets"

    # GLPI
    GLPI_BASE_URL: str = "http://glpi"
    GLPI_APP_TOKEN: str | None = None
    GLPI_REQUIRED_PROFILE: str = "Supervisor"
    GLPI_TIMEOUT_SECONDS: int = 30

    # IMAP por defecto
    DEFAULT_IMAP_PORT: int = 993
    DEFAULT_IMAP_SSL: bool = True

    # Archivo de correos .eml
    MAIL_ARCHIVE_ROOT: str = "/data/mail_archive"

    # IA / LLM
    LLM_BASE_URL: str | None = None
    LLM_API_KEY: str | None = None
    LLM_MODEL: str | None = None
    LLM_TIMEOUT_SECONDS: int = 300

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def database_url(self) -> str:
        return (
            f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def full_version(self) -> str:
        return f"{self.APP_VERSION}.{self.APP_SUBVERSION}"

    @property
    def mail_archive_path(self) -> Path:
        return Path(self.MAIL_ARCHIVE_ROOT)


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
