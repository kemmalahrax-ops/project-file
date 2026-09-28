from pathlib import Path

from sqlalchemy.schema import CreateTable
from sqlalchemy.dialects import postgresql

from app.db.base import Base
from app.db import models  # noqa: F401

output = Path(__file__).parent / "schema.sql"
statements = ["CREATE EXTENSION IF NOT EXISTS pgcrypto;\n"]
for table in Base.metadata.sorted_tables:
    statements.append(str(CreateTable(table).compile(dialect=postgresql.dialect())) + ";\n")
output.write_text("\n".join(statements), encoding="utf-8")
print(output)
