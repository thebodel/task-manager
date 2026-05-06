# Task Manager

A full-stack task management application with a native iOS frontend built in SwiftUI and a Python REST API backend.

## Tech Stack

| Layer | Technology |
|-------|------------|
| iOS Client | Swift / SwiftUI |
| Backend | Python |
| Database | SQLite/Postgres |

## Project Structure

```
task-manager/
├── frontend/          # iOS app (SwiftUI)
├── backend/           # Python REST API
├── requirements.txt   # Python dependencies
└── .gitignore
```

## Getting Started

### Prerequisites

- Python 3.10+
- Xcode 15+
- iOS 16+

### Backend

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python main.py
```

The API will be available at `http://localhost:8000`.

### iOS App

1. Open the `frontend/` directory in Xcode
2. Select your target device or simulator
3. Press **Cmd+R** to build and run

> Make sure the backend is running before launching the app.

## Features

- Create, update, and delete tasks
- View task list on iOS
- Persistent storage via SQLite/PostgreSQL

