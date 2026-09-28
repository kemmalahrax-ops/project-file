"""Seed fictional development data. Never run this against production."""

from datetime import date

from sqlalchemy import select

from app.db.models import AcademicTerm, Department
from app.db.session import SessionLocal


def seed() -> None:
    with SessionLocal.begin() as db:
        if db.scalar(select(Department).limit(1)):
            print("Seed skipped: data already exists.")
            return
        db.add_all(
            [
                Department(code="COMP", name="Computer Science", description="Fictional development department"),
                Department(code="BUS", name="Business Administration", description="Fictional development department"),
            ]
        )
        db.add(
            AcademicTerm(
                name="First Semester",
                academic_year="2026/2027",
                start_date=date(2026, 9, 1),
                end_date=date(2027, 1, 31),
            )
        )
    print("Development seed completed.")


if __name__ == "__main__":
    seed()
