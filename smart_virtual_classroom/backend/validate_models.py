from sqlalchemy.orm import configure_mappers

from app.db.base import Base
from app.db import models  # noqa: F401

configure_mappers()
expected = {
    "profiles", "departments", "academic_terms", "courses", "class_sections",
    "enrollments", "class_sessions", "session_participants", "attendance_events",
    "questions", "responses", "attendance_adjustments", "reports", "chat_messages",
    "notifications", "audit_logs", "lecture_materials", "transcripts",
    "lecture_summaries", "study_questions", "ai_conversations", "ai_messages",
    "ai_recommendations",
}
actual = set(Base.metadata.tables)
missing = expected - actual
if missing:
    raise SystemExit(f"Missing tables: {sorted(missing)}")
print(f"Validated {len(actual)} SQLAlchemy tables and all relationships.")
