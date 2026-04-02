from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session

from backend.database import Base, engine, get_db
from backend.models.project import Project
from backend.schemas.project import ProjectCreate, ProjectRead
from backend.models.task import Task
from backend.schemas.task import TaskCreate, TaskRead


Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Task Manager API is running"}

@app.post("/projects", response_model=ProjectRead)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    new_project = Project(
        title=project.title,
        description=project.description
    )

    db.add(new_project)
    db.commit()
    db.refresh(new_project)

    return new_project


@app.get("/projects", response_model=list[ProjectRead])
def get_projects(db: Session = Depends(get_db)):
    projects = db.query(Project).all()
    return projects

@app.post("/tasks", response_model=TaskRead)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    new_task = Task(
        title=task.title,
        description=task.description,
        status=task.status,
        priority=task.priority,
        deadline=task.deadline,
        project_id=task.project_id
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task

@app.get("/projects/{project_id}/tasks", response_model=list[TaskRead])
def get_tasks_by_project(project_id: int, db: Session = Depends(get_db)):
    tasks = db.query(Task).filter(Task.project_id == project_id).all()
    return tasks