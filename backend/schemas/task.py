from pydantic import BaseModel
from datetime import datetime


class TaskCreate(BaseModel):
    title: str
    description: str | None = None
    status: str = "todo"
    priority: str = "medium"
    deadline: datetime | None = None
    project_id: int

class TaskUpdate(BaseModel):
    title: str
    description: str | None = None
    status: str
    priority: str
    deadline: datetime | None = None

class TaskRead(BaseModel):
    id: int
    title: str
    description: str | None = None
    status: str
    priority: str
    deadline: datetime | None = None
    project_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True