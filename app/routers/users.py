import os
import uuid

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.config import UPLOAD_DIR
from app.database import get_db
from app.deps import get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])

ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}
EXTENSION_BY_CONTENT_TYPE = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


@router.get("/me", response_model=schemas.UserOut)
def get_me(current_user: models.User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=schemas.UserOut)
def update_me(
    payload: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(current_user, field, value)
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user


@router.post("/me/photos", response_model=schemas.PhotoOut, status_code=status.HTTP_201_CREATED)
def upload_photo(
    file: UploadFile,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only JPEG, PNG, or WEBP images are allowed",
        )

    user_dir = os.path.join(UPLOAD_DIR, str(current_user.id))
    os.makedirs(user_dir, exist_ok=True)

    filename = f"{uuid.uuid4().hex}{EXTENSION_BY_CONTENT_TYPE[file.content_type]}"
    destination = os.path.join(user_dir, filename)
    with open(destination, "wb") as out_file:
        out_file.write(file.file.read())

    next_position = len(current_user.photos)
    photo = models.Photo(
        user_id=current_user.id,
        url=f"/static/uploads/{current_user.id}/{filename}",
        position=next_position,
    )
    db.add(photo)
    db.commit()
    db.refresh(photo)
    return photo


@router.delete("/me/photos/{photo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_photo(
    photo_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    photo = db.get(models.Photo, photo_id)
    if not photo or photo.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Photo not found")

    file_path = os.path.join(".", photo.url.lstrip("/"))
    if os.path.exists(file_path):
        os.remove(file_path)

    db.delete(photo)
    db.commit()
    return None
