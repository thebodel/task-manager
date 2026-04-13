from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.database import Base, engine, get_db
from backend.hash import hash_password,verify_password

from backend.models.project import Project
from backend.models.task import Task
from backend.models.user import User

from backend.schemas.project import ProjectCreate, ProjectRead,ProjectUpdate
from backend.schemas.task import TaskCreate, TaskRead
from backend.schemas.user import UserCreate, UserLogin

Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Task Manager API is running"}

@app.post("/projects", response_model=ProjectRead)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    new_project = Project(
        title=project.title,
        description=project.description,
        user_id=project.user_id
    )

    db.add(new_project)
    db.commit()
    db.refresh(new_project)

    return new_project

@app.get("/projects", response_model=list[ProjectRead])
def get_projects(user_id: int,db: Session = Depends(get_db)):
    projects = db.query(Project).filter(Project.user_id == user_id).all()
    return projects

@app.delete("/projects/{project_id}")
def delete_project(user_id: int,project_id: int, db: Session = Depends(get_db)):
    project = db.query(Project).filter(
        Project.id == project_id,
        Project.user_id == user_id
    ).first()


    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")

    db.delete(project)
    db.commit()

    return {"message": "Project deleted successfully"}

@app.put("/projects/{project_id}")
def update_project(project_data: ProjectUpdate, db: Session = Depends(get_db)):
    project = db.query(Project).filter(
        Project.id == project_data.project_id,
        Project.user_id == project_data.user_id
    ).first()
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    project.title = project_data.title
    project.description = project_data.description
    db.commit()
    db.refresh(project)
    return project

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

@app.delete("/projects/{project_id}/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()

    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")

    db.delete(task)
    db.commit()

    return {"message": "Task deleted successfully"}

@app.post("/users")
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.login == user.login).first()

    if db_user is not None:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = hash_password(user.password)
    new_user = User(
        login=user.login,
        password=hashed_password
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"user_id": new_user.id}

@app.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.login == user.login).first()

    if db_user is None:
        raise HTTPException(status_code=401, detail="Invalid login or password")

    if not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid login or password")
    return {"user_id": db_user.id}
