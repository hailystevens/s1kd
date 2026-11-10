from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="S1KD_", env_file=".env", extra="ignore")

    source_dir: Path = Path(__file__).resolve().parents[2] / "source"
    data_dir: Path = Path(__file__).resolve().parents[2] / "data"
    allowed_cors_origins: list[str] = ["http://localhost:5173", "http://127.0.0.1:5173"]


settings = Settings()
