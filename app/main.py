import os

from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from app import models
from app.config import UPLOAD_DIR
from app.database import Base, engine
from app.routers import auth, discovery, matches, pages, swipes, users

os.makedirs(UPLOAD_DIR, exist_ok=True)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="New World")

app.mount("/static", StaticFiles(directory="app/static"), name="static")

templates = Jinja2Templates(directory="app/templates")

app.include_router(pages.router)
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(discovery.router)
app.include_router(swipes.router)
app.include_router(matches.router)
