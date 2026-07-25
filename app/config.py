import os

SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-change-me")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.environ.get("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./dev.db")
UPLOAD_DIR = os.environ.get("UPLOAD_DIR", "app/static/uploads")
MIN_AGE = 18
