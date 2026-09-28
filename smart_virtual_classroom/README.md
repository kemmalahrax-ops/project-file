# Smart Virtual Classroom

Backend foundation for the Smart Virtual Classroom and Intelligent Attendance Management System.

## Stack

- FastAPI and Uvicorn
- PostgreSQL 16
- SQLAlchemy 2.x
- Alembic
- Pydantic Settings

The existing normalized 23-table academic, attendance, participation, audit, and AI-ready schema is in `backend/app/db/models.py`. Attendance events remain separate from participation responses.

## Run locally

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Start PostgreSQL with Docker if available:

```bash
docker compose up -d postgres
```

Apply the initial migration:

```bash
cd backend
alembic upgrade head
```

Start the API from the `backend` directory:

```bash
uvicorn app.main:app --reload
```

The API documentation is available at `http://127.0.0.1:8000/docs`.

## Health checks

- `GET /api/v1/health/live` checks that the process is running.
- `GET /api/v1/health/ready` checks PostgreSQL connectivity and returns HTTP 503 when the database is unavailable.

## Tests

From the repository root:

```bash
PYTHONPATH=backend pytest -q
```

The readiness endpoint intentionally requires PostgreSQL. The smoke tests only exercise the process and OpenAPI endpoints, so they can run before PostgreSQL is installed.

## Next implementation phase

The recommended next step is authentication and RBAC. Do not add AI decision logic to attendance; AI outputs should remain advisory and human-reviewable.
