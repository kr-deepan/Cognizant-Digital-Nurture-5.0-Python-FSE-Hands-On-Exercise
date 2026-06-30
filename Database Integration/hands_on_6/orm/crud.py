from datetime import date

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import joinedload

from models import (
    Department,
    Student,
    Course,
    Enrollment
)

DATABASE_URL = "postgresql+psycopg2://postgres:1234@localhost:5432/college_db_orm"

engine = create_engine(
    DATABASE_URL,
    echo=True
)

Session = sessionmaker(bind=engine)
session = Session()

# N+1 OBSERVATION
#
# Before joinedload:
# 1 query for enrollments
# N queries for students
# N queries for courses
#
# After joinedload:
# Single SQL query with JOINs
#
# Query count reduced dramatically.


# INSERT DEPARTMENTS

cs = Department(
    dept_name="Computer Science",
    head_of_dept="Dr. Kumar",
    budget=500000
)

ece = Department(
    dept_name="Electronics",
    head_of_dept="Dr. Sharma",
    budget=400000
)

mech = Department(
    dept_name="Mechanical",
    head_of_dept="Dr. Singh",
    budget=350000
)

session.add_all([cs, ece, mech])
session.commit()

# INSERT STUDENTS

students = [
    Student(
        first_name="Prithvi",
        last_name="Singh",
        email="prithvi@gmail.com",
        enrollment_year=2022,
        department=cs
    ),
    Student(
        first_name="Rahul",
        last_name="Kumar",
        email="rahul@gmail.com",
        enrollment_year=2022,
        department=cs
    ),
    Student(
        first_name="Priya",
        last_name="Sharma",
        email="priya@gmail.com",
        enrollment_year=2023,
        department=ece
    ),
    Student(
        first_name="Arjun",
        last_name="Ravi",
        email="arjun@gmail.com",
        enrollment_year=2022,
        department=ece
    ),
    Student(
        first_name="Karthik",
        last_name="Raj",
        email="karthik@gmail.com",
        enrollment_year=2021,
        department=mech
    )
]

session.add_all(students)
session.commit()

# INSERT COURSES

courses = [
    Course(
        course_name="Database Systems",
        credits=4,
        department=cs
    ),
    Course(
        course_name="Data Structures",
        credits=4,
        department=cs
    ),
    Course(
        course_name="Digital Electronics",
        credits=3,
        department=ece
    )
]

session.add_all(courses)
session.commit()

# INSERT ENROLLMENTS

enrollments = [
    Enrollment(
        student=students[0],
        course=courses[0],
        enrollment_date=date.today(),
        grade="A"
    ),
    Enrollment(
        student=students[1],
        course=courses[1],
        enrollment_date=date.today(),
        grade="B"
    ),
    Enrollment(
        student=students[2],
        course=courses[2],
        enrollment_date=date.today(),
        grade="A"
    ),
    Enrollment(
        student=students[3],
        course=courses[2],
        enrollment_date=date.today(),
        grade="B"
    )
]

session.add_all(enrollments)
session.commit()

# READ

print("\nStudents in Computer Science\n")

cs_students = (
    session.query(Student)
    .join(Department)
    .filter(
        Department.dept_name == "Computer Science"
    )
    .all()
)

for s in cs_students:
    print(s.first_name, s.last_name)

# N+1 VERSION

print("\nEnrollment Details (N+1)\n")

all_enrollments = session.query(
    Enrollment
).all()

for e in all_enrollments:
    print(
        e.student.first_name,
        "->",
        e.course.course_name
    )

# OPTIMISED VERSION

print("\nEnrollment Details (joinedload)\n")

all_enrollments = (
    session.query(Enrollment)
    .options(
        joinedload(Enrollment.student),
        joinedload(Enrollment.course)
    )
    .all()
)

for e in all_enrollments:
    print(
        e.student.first_name,
        "->",
        e.course.course_name
    )

# UPDATE

student = (
    session.query(Student)
    .filter(
        Student.email == "prithvi@gmail.com"
    )
    .first()
)

if student:
    student.enrollment_year = 2024
    session.commit()

# DELETE

record = session.query(
    Enrollment
).first()

if record:
    session.delete(record)
    session.commit()

print("CRUD Operations Completed")
