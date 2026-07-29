from datetime import date, datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field, field_validator

from app.config import MIN_AGE


def _age_from_birthdate(birthdate: date) -> int:
    today = date.today()
    return today.year - birthdate.year - (
        (today.month, today.day) < (birthdate.month, birthdate.day)
    )


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    name: str = Field(min_length=1, max_length=80)
    birthdate: date
    gender: str = Field(min_length=1, max_length=30)
    interested_in: str = "any"
    bio: str = ""

    @field_validator("birthdate")
    @classmethod
    def must_be_adult(cls, value: date) -> date:
        if _age_from_birthdate(value) < MIN_AGE:
            raise ValueError(f"You must be at least {MIN_AGE} years old to register.")
        return value


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=80)
    bio: Optional[str] = None
    gender: Optional[str] = Field(default=None, min_length=1, max_length=30)
    interested_in: Optional[str] = None


class PhotoOut(BaseModel):
    id: int
    url: str
    position: int

    model_config = {"from_attributes": True}


class UserOut(BaseModel):
    id: int
    email: EmailStr
    name: str
    birthdate: date
    gender: str
    interested_in: str
    bio: str
    photos: List[PhotoOut] = []

    model_config = {"from_attributes": True}


class PublicProfile(BaseModel):
    id: int
    name: str
    age: int
    gender: str
    bio: str
    photos: List[PhotoOut] = []

    model_config = {"from_attributes": True}


def to_public_profile(user) -> "PublicProfile":
    return PublicProfile(
        id=user.id,
        name=user.name,
        age=_age_from_birthdate(user.birthdate),
        gender=user.gender,
        bio=user.bio,
        photos=[PhotoOut.model_validate(photo) for photo in user.photos],
    )


class SwipeRequest(BaseModel):
    swiped_id: int
    liked: bool


class SwipeResult(BaseModel):
    matched: bool
    match_id: Optional[int] = None


class MatchOut(BaseModel):
    id: int
    other_user: PublicProfile
    created_at: datetime


class MessageCreate(BaseModel):
    content: str = Field(min_length=1, max_length=2000)


class MessageOut(BaseModel):
    id: int
    match_id: int
    sender_id: int
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}
