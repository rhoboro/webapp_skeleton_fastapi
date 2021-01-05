import os
from pathlib import Path

from pydantic import BaseSettings


class Settings(BaseSettings):
    LOG_LEVEL: str

    # /docs 用のBasic認証
    BASIC_USER_NAME = "user"
    BASIC_PASSWORD = "password"

    class Config:
        env = os.environ["APP_CONFIG_FILE"]
        env_file = Path(__file__).parent / f"config/{env}.env"
        case_sensitive = True
