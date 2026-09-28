# Smart Virtual Classroom Backend Foundation

## Technical Documentation and Explanation

**Project:** Smart Virtual Classroom and Intelligent Attendance Management System  
**Component:** FastAPI backend foundation  
**Version:** 0.1.0  
**Author:** Manus AI  
**Language:** English

## 1. Purpose of this document

This document explains the backend foundation created for the Smart Virtual Classroom system. It describes the architecture, project files, database connection, API endpoints, migration process, testing approach, local setup, and the recommended development sequence.

The current implementation is a foundation rather than a complete classroom application. It establishes the services and conventions needed for later authentication, role-based access control, courses, enrollments, live class sessions, attendance processing, participation tracking, WebRTC signaling, reporting, and progressively introduced artificial intelligence features.

The most important design principle is that the system keeps **technical attendance evidence** separate from **active participation evidence**. A student being connected to a class does not automatically prove that the student answered a question or actively engaged. Likewise, failing to answer a question does not automatically prove that the student was absent.

## 2. System objective

The larger system will connect the following academic workflow:

> Institutional identity → course enrollment → live virtual class → attendance evidence → participation records → academic reports → AI learning assistance

The backend will eventually serve three main user groups:

- **Students** will access their profiles, enrolled courses, authorized sessions, attendance records, and participation history.
- **Lecturers** will manage assigned courses, schedule sessions, monitor technical attendance, create questions, review participation, and make authorized attendance corrections.
- **Administrators** will manage institutional data, users, academic terms, departments, permissions, and institution-level reports.

The current foundation does not yet implement these role workflows. It prepares the application so they can be added without replacing the database layer or the application entry point.

## 3. Technology stack

| Layer | Technology | Purpose |
|---|---|---|
| API framework | FastAPI | Defines HTTP endpoints, validation, dependency injection, and OpenAPI documentation |
| Application server | Uvicorn | Runs the FastAPI application during development and deployment |
| Database | PostgreSQL 16 | Stores institutional, academic, classroom, attendance, participation, audit, and AI-related data |
| Object-relational mapper | SQLAlchemy 2.x | Maps Python classes to PostgreSQL tables and manages database sessions |
| Migration tool | Alembic | Applies version-controlled database schema changes |
| Configuration | Pydantic Settings | Reads and validates environment variables |
| Testing | Pytest and HTTPX | Tests API behavior without requiring a live database for basic smoke tests |
| Future live media | WebRTC | Provides browser or mobile audio and video communication |
| Future client | Flutter and Dart | Provides student, lecturer, and administrator interfaces |

The artificial intelligence layer is intentionally not part of this first foundation. It should be added only after the academic data, authorization rules, attendance evidence, and participation records are reliable.

## 4. Project structure

The project is located at `/home/ubuntu/smart_virtual_classroom` and has the following relevant structure:

```text
smart_virtual_classroom/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── api/
│   │   │   └── health.py
│   │   ├── core/
│   │   │   └── config.py
│   │   ├── db/
│   │   │   ├── base.py
│   │   │   ├── models.py
│   │   │   └── session.py
│   │   ├── schemas/
│   │   └── services/
│   ├── alembic/
│   │   ├── env.py
│   │   └── versions/
│   │       └── 0001_initial_schema.py
│   ├── alembic.ini
│   ├── requirements.txt
│   ├── .env.example
│   ├── schema.sql
│   └── seed.py
├── tests/
│   └── test_health.py
├── docker-compose.yml
└── README.md
```

### 4.1 `backend/app/main.py`

This is the FastAPI application entry point. It creates the application, assigns its name and version, configures Cross-Origin Resource Sharing, and registers the health router.

The application uses a factory function named `create_app`. This makes the application easier to test and allows future environments to create customized application instances.

The module also exposes an object named `app`. Uvicorn uses this object when the server is started with:

```bash
uvicorn app.main:app --reload
```

### 4.2 `backend/app/core/config.py`

This module defines the validated application settings. The settings can be loaded from a `.env` file or from operating-system environment variables.

The main settings are:

| Setting | Default or example | Explanation |
|---|---|---|
| `APP_NAME` | `Smart Virtual Classroom API` | Name displayed in API documentation |
| `APP_VERSION` | `0.1.0` | Backend version exposed by OpenAPI |
| `ENVIRONMENT` | `development` | Identifies the current deployment environment |
| `DATABASE_URL` | PostgreSQL connection URL | Tells SQLAlchemy how to connect to PostgreSQL |
| `API_PREFIX` | `/api/v1` | Common prefix for versioned API endpoints |
| `CORS_ORIGINS` | Local development origins | Lists clients allowed to call the API from a browser |
| `LOG_LEVEL` | `INFO` | Intended logging verbosity |

Secrets should not be committed to Git. The `.env.example` file contains development placeholders only. In production, use a secret manager or protected deployment environment.

### 4.3 `backend/app/db/models.py`

This module contains the SQLAlchemy models for the database. The current model set contains 23 tables covering the following domains:

- Institutional identity and profiles
- Departments and academic terms
- Courses, sections, and enrollments
- Class sessions and session participants
- Attendance events and attendance adjustments
- Questions and student responses
- Reports, chat messages, notifications, and audit logs
- Lecture materials and transcripts
- Lecture summaries and study questions
- AI conversations, messages, and recommendations

The schema uses PostgreSQL-specific types such as UUID, JSONB, and named enumerations. It also contains foreign keys, unique constraints, indexes, timestamp columns, and relationship definitions.

The model validation script was executed successfully and confirmed that all 23 tables and their relationships can be configured by SQLAlchemy.

### 4.4 `backend/app/db/base.py`

This module exposes the declarative SQLAlchemy `Base` class used by Alembic. Alembic reads `Base.metadata` to understand the tables and relationships represented by the Python models.

### 4.5 `backend/app/db/session.py`

This module creates the SQLAlchemy engine and session factory using the validated application settings.

The `get_db` function is a FastAPI dependency. It opens a database session for an endpoint, yields that session to the endpoint, and closes it afterward. This prevents connections from remaining open after a request finishes.

The engine uses `pool_pre_ping=True`. This allows SQLAlchemy to check whether a pooled connection is still usable before sending a query, which helps avoid failures caused by stale connections.

### 4.6 `backend/app/api/health.py`

This module contains the first two API endpoints. Health endpoints are used by developers, container orchestrators, reverse proxies, and deployment systems to determine whether the service is alive and ready to accept database-dependent traffic.

### 4.7 `backend/alembic/`

This directory contains the database migration environment and the initial migration. The `alembic.ini` file was configured so Alembic can locate the backend package whether the command is run from the repository root or from the `backend` directory.

The initial migration creates the complete database schema from the existing model foundation. Future schema changes should be introduced through new migrations rather than by manually editing a production database.

## 5. API endpoints

The current backend exposes the following endpoints.

### 5.1 Liveness endpoint

```http
GET /api/v1/health/live
```

Example response:

```json
{
  "status": "ok"
}
```

This endpoint does not query PostgreSQL. A successful response means that the FastAPI process is running and responding to HTTP requests.

### 5.2 Readiness endpoint

```http
GET /api/v1/health/ready
```

A successful response is:

```json
{
  "status": "ok",
  "database": "ready"
}
```

The endpoint executes `SELECT 1` through the SQLAlchemy session. If PostgreSQL cannot be reached, it returns HTTP status `503` with a message indicating that the database is unavailable.

This distinction is important. A process may be alive while its database is unavailable. The liveness and readiness checks allow deployment tools to distinguish those conditions.

### 5.3 OpenAPI documentation

The API automatically provides interactive documentation at:

```text
http://127.0.0.1:8000/docs
```

A machine-readable OpenAPI document is available at:

```text
http://127.0.0.1:8000/openapi.json
```

A ReDoc version is available at:

```text
http://127.0.0.1:8000/redoc
```

## 6. Database design explanation

### 6.1 Academic data

The academic part of the schema begins with departments and academic terms. Courses belong to a department and an academic term. A lecturer is associated with the course through the lecturer profile identifier.

A course may contain one or more class sections. Students are connected to courses through enrollments. This allows the system to verify whether a student is authorized to access a live class before creating attendance or participation records.

### 6.2 Live class data

A class session represents a scheduled virtual class. It records the course, optional section, creator, title, room identifier, scheduled times, actual start and end times, current status, and optional recording location.

Session participants represent the relationship between a student and a class session. This table stores summarized participation in the session from an attendance perspective, including the first join time, last leave time, total connection duration, and calculated attendance status.

### 6.3 Attendance data

Attendance is divided into two levels:

1. `attendance_events` stores the original technical evidence, such as join, leave, reconnect, and disconnect events.
2. `session_participants` stores the session-level attendance summary calculated from those events.

This separation is necessary because a summary can be recalculated, corrected, or reviewed without destroying the original technical evidence.

The model supports attendance statuses such as `present`, `late`, `partial`, `absent`, `excused`, and `corrected`. The final rules for assigning these statuses must be defined by the institution. For example, the institution may decide that a student is late after a specified number of minutes or that partial attendance requires a minimum percentage of active connection time.

### 6.4 Participation data

Participation is represented through questions and responses. A lecturer can create a question or poll for a session. A student can submit a response. The response may include an answer, submission time, correctness value, score, and metadata.

Participation is intentionally independent from attendance. A student may be technically present but not respond to a particular question. A student may also respond to a question and later have a separate technical attendance issue. These records must remain independently reviewable.

### 6.5 Auditability

Attendance adjustments and audit logs are designed to preserve accountability. A manual attendance correction should store the previous value, the new value, the person who made the correction, the reason, and the timestamp.

The system must not allow artificial intelligence to make final attendance or disciplinary decisions. Any future AI recommendation must remain advisory and must be reviewed by an authorized human.

## 7. Installation and setup

### 7.1 Prerequisites

Install the following tools on the development computer:

- Python 3.11 or newer
- PostgreSQL 16 or a compatible PostgreSQL version
- Git
- Docker Desktop or Docker Engine, if PostgreSQL will run in a container

The current sandbox did not include PostgreSQL or Docker, so live database connectivity was not executed there. The configuration is prepared for either a local PostgreSQL installation or the supplied Docker Compose file.

### 7.2 Create a Python virtual environment

From the project root, run:

```bash
cd smart_virtual_classroom
python3 -m venv .venv
source .venv/bin/activate
pip install -r backend/requirements.txt
```

On Windows PowerShell, activate the environment with:

```powershell
.venv\Scripts\Activate.ps1
```

### 7.3 Configure environment variables

Copy the example configuration:

```bash
cp backend/.env.example backend/.env
```

The default development database URL is:

```text
postgresql+psycopg://postgres:postgres@localhost:5432/smart_classroom
```

Change this value if your PostgreSQL username, password, host, port, or database name is different.

### 7.4 Start PostgreSQL with Docker

If Docker is installed, start the database from the repository root:

```bash
docker compose up -d postgres
```

The Compose configuration creates:

- Database: `smart_classroom`
- User: `postgres`
- Password: `postgres`
- Port: `5432`
- Persistent volume: `postgres_data`

These credentials are for local development only. They must be replaced in a production deployment.

### 7.5 Create the database manually

If PostgreSQL is installed directly, create the database with:

```bash
createdb smart_classroom
```

If the PostgreSQL server requires a specific user, create the database with that user and update `DATABASE_URL` accordingly.

## 8. Applying database migrations

From the repository root, run:

```bash
.venv/bin/alembic -c backend/alembic.ini upgrade head
```

Alternatively, from inside the backend directory, run:

```bash
cd backend
../.venv/bin/alembic upgrade head
```

The command applies all migrations up to the latest revision. The initial migration creates the complete existing schema.

To inspect the migration without connecting to a database, run:

```bash
.venv/bin/alembic -c backend/alembic.ini upgrade head --sql
```

To create a migration after modifying the SQLAlchemy models, run:

```bash
.venv/bin/alembic -c backend/alembic.ini revision --autogenerate -m "describe the schema change"
```

Review the generated migration manually before applying it. Autogenerated migrations are useful, but they should not be treated as an automatic replacement for database review.

## 9. Running the API

From the project root:

```bash
cd backend
../.venv/bin/uvicorn app.main:app --reload
```

The server will normally be available at:

```text
http://127.0.0.1:8000
```

Test the liveness endpoint:

```bash
curl http://127.0.0.1:8000/api/v1/health/live
```

Test the database readiness endpoint:

```bash
curl http://127.0.0.1:8000/api/v1/health/ready
```

If PostgreSQL is not running, the readiness endpoint should return HTTP `503`. This is expected behavior.

## 10. Testing

The current smoke tests are located in `tests/test_health.py`. They verify that:

- The liveness endpoint returns HTTP `200`.
- The liveness endpoint returns the expected JSON body.
- The OpenAPI document is available.
- The application title is configured correctly.

Run the tests from the repository root:

```bash
PYTHONPATH=backend .venv/bin/pytest -q
```

The verified result for the current foundation is:

```text
2 passed
```

The smoke tests do not require PostgreSQL because they do not call the readiness endpoint. Database integration tests should be added after PostgreSQL is available in the development or continuous integration environment.

## 11. Security considerations in the foundation

The current foundation establishes several good boundaries, but it is not yet a complete security implementation.

### Already established

- Database configuration is read from environment variables.
- The backend has a separate configuration layer.
- The Flutter client will not need direct access to PostgreSQL.
- The API has a versioned prefix, `/api/v1`.
- Database sessions are closed after requests.
- Attendance technical evidence and participation evidence are stored separately.
- The database schema includes audit and adjustment entities for future accountability.

### Still required

The next security phase must implement:

- Secure password hashing
- JWT access tokens and refresh-session management
- Role-based access control
- Student, lecturer, and administrator data isolation
- Enrollment checks before session access
- Authentication for WebSocket connections
- Validation of all request bodies and path parameters
- Production HTTPS/TLS
- Secret rotation and protected deployment variables
- Rate limiting and login abuse protection
- Audit logging for sensitive administrative actions
- Retention and deletion policies for recordings, transcripts, and AI data

CORS origins must also be restricted to the actual Flutter web or administrative client origins in production. The local development origins in `.env.example` are not production security settings.

## 12. Recommended development roadmap

### Phase 1: Completed foundation

The project now has the basic FastAPI application, PostgreSQL session wiring, SQLAlchemy models, Alembic migration configuration, Docker database configuration, health endpoints, and smoke tests.

### Phase 2: Authentication and RBAC

Implement user registration or institutional account activation, login, password hashing, access tokens, refresh sessions, role checks, and protected profile endpoints.

This phase should also define which fields students, lecturers, and administrators are permitted to read or modify.

### Phase 3: Academic management

Implement departments, academic terms, courses, class sections, enrollments, and lecturer ownership rules. Enrollment verification should be reusable by later session and WebRTC endpoints.

### Phase 4: Class sessions

Implement session creation, scheduling, starting, ending, cancellation, access control, and participant authorization.

### Phase 5: Classroom communication

Add WebSocket signaling and WebRTC support. Authentication and authorization must be applied before a user joins a room. Reconnection behavior must be designed together with attendance event handling.

### Phase 6: Attendance processing

Record join, leave, reconnect, and disconnect events. Calculate active duration. Avoid duplicate participant summaries during reconnection. Add lecturer correction workflows that require a reason and preserve the original evidence.

### Phase 7: Participation and reports

Implement lecturer questions, polls, student responses, participation dashboards, attendance reports, and export formats. Keep report access limited by role and assigned course ownership.

### Phase 8: AI features

Add AI only after the previous data is stable. Begin with lecturer-approved lecture summaries and revision questions. Later add authorized document search and a course-specific assistant with source citations, model logging, prompt versioning, and human review.

AI must not decide whether a student was present, concentrated, disciplined, or academically penalized.

## 13. Common commands

| Task | Command |
|---|---|
| Install dependencies | `pip install -r backend/requirements.txt` |
| Start PostgreSQL | `docker compose up -d postgres` |
| Apply migrations | `.venv/bin/alembic -c backend/alembic.ini upgrade head` |
| Start API | `cd backend && ../.venv/bin/uvicorn app.main:app --reload` |
| Run tests | `PYTHONPATH=backend .venv/bin/pytest -q` |
| Validate models | `PYTHONPATH=. .venv/bin/python backend/validate_models.py` |
| Generate migration | `.venv/bin/alembic -c backend/alembic.ini revision --autogenerate -m "message"` |
| Stop PostgreSQL | `docker compose down` |
| Stop PostgreSQL and delete local data | `docker compose down -v` |

The final command is destructive for the local PostgreSQL volume. Do not use it if the development database contains data that must be preserved.

## 14. Current limitations

The foundation does not yet include login, protected endpoints, role-based permissions, course APIs, enrollment APIs, class-session APIs, WebRTC signaling, attendance event processing, participation endpoints, report exports, or AI services.

The database model is present, but a model definition alone does not enforce application-level privacy. The API must add authorization checks before users can access records. PostgreSQL row-level security may also be considered for stronger isolation in later production hardening.

The Docker configuration is intended for local development. It does not include production TLS termination, backups, monitoring, secrets management, high availability, or a production-grade database user policy.

## 15. Deliverables from this phase

The completed backend foundation is packaged as:

[Smart Virtual Classroom backend foundation ZIP](/home/ubuntu/smart_virtual_classroom_backend_foundation.zip)

The project documentation and setup guide are also available in:

[Project README](/home/ubuntu/smart_virtual_classroom/README.md)

## References

[1]: https://fastapi.tiangolo.com/ "FastAPI Official Documentation"
[2]: https://docs.sqlalchemy.org/en/20/ "SQLAlchemy 2.0 Documentation"
[3]: https://alembic.sqlalchemy.org/en/latest/ "Alembic Documentation"
[4]: https://www.postgresql.org/docs/ "PostgreSQL Official Documentation"
[5]: https://docs.pydantic.dev/latest/concepts/pydantic_settings/ "Pydantic Settings Documentation"
