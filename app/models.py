from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    name = Column(String, nullable=False)
    birthdate = Column(Date, nullable=False)
    gender = Column(String, nullable=False)
    interested_in = Column(String, nullable=False, default="any")
    bio = Column(Text, nullable=False, default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    photos = relationship(
        "Photo", back_populates="owner", cascade="all, delete-orphan", order_by="Photo.position"
    )


class Photo(Base):
    __tablename__ = "photos"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    url = Column(String, nullable=False)
    position = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="photos")


class Swipe(Base):
    __tablename__ = "swipes"
    __table_args__ = (UniqueConstraint("swiper_id", "swiped_id", name="uq_swipe_pair"),)

    id = Column(Integer, primary_key=True, index=True)
    swiper_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    swiped_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    liked = Column(Boolean, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Match(Base):
    __tablename__ = "matches"
    __table_args__ = (UniqueConstraint("user_low_id", "user_high_id", name="uq_match_pair"),)

    id = Column(Integer, primary_key=True, index=True)
    # Normalized so user_low_id < user_high_id, avoiding duplicate rows for a pair.
    user_low_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    user_high_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    match_id = Column(Integer, ForeignKey("matches.id"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
