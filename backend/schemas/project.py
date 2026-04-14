from pydantic import BaseModel
from datetime import datetime


class ProjectCreate(BaseModel):
    title: str
    description: str | None = None
    user_id: int
class ProjectUpdate(BaseModel):
    title: str
    description: str | None = None

class ProjectRead(BaseModel):
    id: int
    title: str
    description: str | None = None
    created_at: datetime
    user_id: int

    class Config:
        from_attributes = True