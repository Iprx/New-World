from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user

router = APIRouter(prefix="/api/swipes", tags=["swipes"])


@router.post("", response_model=schemas.SwipeResult, status_code=status.HTTP_201_CREATED)
def create_swipe(
    payload: schemas.SwipeRequest,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if payload.swiped_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot swipe on yourself")

    target = db.get(models.User, payload.swiped_id)
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    swipe = (
        db.query(models.Swipe)
        .filter(
            models.Swipe.swiper_id == current_user.id,
            models.Swipe.swiped_id == payload.swiped_id,
        )
        .first()
    )
    if swipe:
        swipe.liked = payload.liked
    else:
        swipe = models.Swipe(
            swiper_id=current_user.id, swiped_id=payload.swiped_id, liked=payload.liked
        )
        db.add(swipe)
    db.commit()

    if not payload.liked:
        return schemas.SwipeResult(matched=False)

    reverse_like = (
        db.query(models.Swipe)
        .filter(
            models.Swipe.swiper_id == payload.swiped_id,
            models.Swipe.swiped_id == current_user.id,
            models.Swipe.liked.is_(True),
        )
        .first()
    )
    if not reverse_like:
        return schemas.SwipeResult(matched=False)

    user_low_id, user_high_id = sorted((current_user.id, payload.swiped_id))
    match = (
        db.query(models.Match)
        .filter(models.Match.user_low_id == user_low_id, models.Match.user_high_id == user_high_id)
        .first()
    )
    if not match:
        match = models.Match(user_low_id=user_low_id, user_high_id=user_high_id)
        db.add(match)
        db.commit()
        db.refresh(match)

    return schemas.SwipeResult(matched=True, match_id=match.id)
