from typing import List

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user

router = APIRouter(prefix="/api", tags=["discovery"])


def _interested_in_gender(interested_in: str, gender: str) -> bool:
    if interested_in == "any" or not interested_in:
        return True
    return gender in {g.strip() for g in interested_in.split(",")}


@router.get("/discover", response_model=List[schemas.PublicProfile])
def discover(
    limit: int = Query(default=20, ge=1, le=100),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    already_swiped = select(models.Swipe.swiped_id).where(
        models.Swipe.swiper_id == current_user.id
    )
    candidates = (
        db.query(models.User)
        .filter(models.User.id != current_user.id)
        .filter(models.User.id.notin_(already_swiped))
        .all()
    )

    results = []
    for candidate in candidates:
        if not _interested_in_gender(current_user.interested_in, candidate.gender):
            continue
        if not _interested_in_gender(candidate.interested_in, current_user.gender):
            continue
        results.append(schemas.to_public_profile(candidate))
        if len(results) >= limit:
            break

    return results
