from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user

router = APIRouter(prefix="/api/matches", tags=["matches"])


def _get_match_for_user(match_id: int, user_id: int, db: Session) -> models.Match:
    match = db.get(models.Match, match_id)
    if not match or user_id not in (match.user_low_id, match.user_high_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found")
    return match


def _other_user_id(match: models.Match, user_id: int) -> int:
    return match.user_high_id if match.user_low_id == user_id else match.user_low_id


@router.get("", response_model=List[schemas.MatchOut])
def list_matches(
    current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)
):
    matches = (
        db.query(models.Match)
        .filter(
            or_(
                models.Match.user_low_id == current_user.id,
                models.Match.user_high_id == current_user.id,
            )
        )
        .order_by(models.Match.created_at.desc())
        .all()
    )

    result = []
    for match in matches:
        other_user = db.get(models.User, _other_user_id(match, current_user.id))
        result.append(
            schemas.MatchOut(
                id=match.id,
                other_user=schemas.to_public_profile(other_user),
                created_at=match.created_at,
            )
        )
    return result


@router.get("/{match_id}/messages", response_model=List[schemas.MessageOut])
def list_messages(
    match_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _get_match_for_user(match_id, current_user.id, db)
    return (
        db.query(models.Message)
        .filter(models.Message.match_id == match_id)
        .order_by(models.Message.created_at.asc())
        .all()
    )


@router.post(
    "/{match_id}/messages", response_model=schemas.MessageOut, status_code=status.HTTP_201_CREATED
)
def send_message(
    match_id: int,
    payload: schemas.MessageCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _get_match_for_user(match_id, current_user.id, db)
    message = models.Message(
        match_id=match_id, sender_id=current_user.id, content=payload.content
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message
