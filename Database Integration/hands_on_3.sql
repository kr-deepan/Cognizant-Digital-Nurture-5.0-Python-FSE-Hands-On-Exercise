-- SUBQUERIES

-- Students enrolled in more courses than average

SELECT s.student_id,
       s.first_name,
       s.last_name
FROM students s
JOIN enrollments e
ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(*) >
(
    SELECT AVG(enrollment_count)
    FROM
    (
        SELECT COUNT(*) AS enrollment_count
        FROM enrollments
        GROUP BY student_id
    ) avg_table
);

-- Courses where all enrolled students received A

SELECT c.course_id,
       c.course_name
FROM courses c
WHERE NOT EXISTS
(
    SELECT 1
    FROM enrollments e
    WHERE e.course_id = c.course_id
    AND e.grade <> 'A'
);

-- Highest paid professor in each department

SELECT p.*
FROM professors p
WHERE salary =
(
    SELECT MAX(p2.salary)
    FROM professors p2
    WHERE p2.department_id = p.department_id
);

-- Departments whose average professor salary exceeds 85000

SELECT *
FROM
(
    SELECT department_id,
           AVG(salary) AS avg_salary
    FROM professors
    GROUP BY department_id
) dept_avg
WHERE avg_salary > 85000;

-- VIEWS

-- Student Enrollment Summary View

CREATE OR REPLACE VIEW vw_student_enrollment_summary AS
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    d.dept_name,

    COUNT(e.course_id) AS total_courses,

    ROUND(
        AVG(
            CASE
                WHEN e.grade='A' THEN 4
                WHEN e.grade='B' THEN 3
                WHEN e.grade='C' THEN 2
                WHEN e.grade='D' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS gpa

FROM students s
LEFT JOIN departments d
ON s.department_id = d.department_id

LEFT JOIN enrollments e
ON s.student_id = e.student_id

GROUP BY
s.student_id,
student_name,
d.dept_name;

-- Course Statistics View

CREATE OR REPLACE VIEW vw_course_stats AS
SELECT
    c.course_id,
    c.course_name,

    COUNT(e.enrollment_id) AS total_enrollments,

    ROUND(
        AVG(
            CASE
                WHEN e.grade='A' THEN 4
                WHEN e.grade='B' THEN 3
                WHEN e.grade='C' THEN 2
                WHEN e.grade='D' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS avg_gpa

FROM courses c
LEFT JOIN enrollments e
ON c.course_id = e.course_id

GROUP BY
c.course_id,
c.course_name;

-- Students with GPA > 3.0

SELECT *
FROM vw_student_enrollment_summary
WHERE gpa > 3.0;

-- Attempt update through view

UPDATE vw_student_enrollment_summary
SET gpa = 4
WHERE student_id = 1;

-- Expected Result:
-- ERROR: cannot update view
-- Views containing GROUP BY are not automatically updatable.

-- Explanation:
-- This view contains JOINs, COUNT(), AVG() and GROUP BY.
-- PostgreSQL cannot determine how updates should
-- propagate back to underlying tables.

-- Drop and recreate a simple updatable view WITH CHECK OPTION

DROP VIEW IF EXISTS vw_student_enrollment_summary;

CREATE VIEW vw_student_enrollment_summary AS
SELECT
    student_id,
    first_name,
    last_name,
    department_id
FROM students
WHERE enrollment_year >= 2022
WITH LOCAL CHECK OPTION;

-- Verify

SELECT *
FROM vw_student_enrollment_summary;

-- FUNCTIONS & TRANSACTIONS

-- Function to enroll a student

CREATE OR REPLACE FUNCTION fn_enroll_student
(
    p_student_id INT,
    p_course_id INT,
    p_enrollment_date DATE
)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM enrollments
        WHERE student_id = p_student_id
        AND course_id = p_course_id
    )
    THEN
        RAISE EXCEPTION 'Duplicate enrollment';
    END IF;

    INSERT INTO enrollments
    (
        student_id,
        course_id,
        enrollment_date
    )
    VALUES
    (
        p_student_id,
        p_course_id,
        p_enrollment_date
    );

    RETURN 'Enrollment Successful';

END;
$$;

-- Test Function

SELECT fn_enroll_student
(
    1,
    2,
    CURRENT_DATE
);

-- Expected:
-- Duplicate enrollment error if already enrolled.

-- Transfer Log Table

CREATE TABLE IF NOT EXISTS department_transfer_log
(
    log_id SERIAL PRIMARY KEY,
    student_id INT,
    old_department INT,
    new_department INT,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaction Example

BEGIN;

UPDATE students
SET department_id = 2
WHERE student_id = 1;

INSERT INTO department_transfer_log
(
    student_id,
    old_department,
    new_department
)
VALUES
(
    1,
    1,
    2
);

COMMIT;

-- Verify

SELECT *
FROM department_transfer_log;

-- SAVEPOINT Demonstration

BEGIN;

INSERT INTO enrollments
(
    student_id,
    course_id,
    enrollment_date
)
VALUES
(
    2,
    4,
    CURRENT_DATE
);

SAVEPOINT first_insert;

-- Intentionally invalid

INSERT INTO enrollments
(
    student_id,
    course_id,
    enrollment_date
)
VALUES
(
    999,
    999,
    CURRENT_DATE
);

-- Expected:
-- Foreign key violation

ROLLBACK TO SAVEPOINT first_insert;

COMMIT;

-- Verify first insert remains

SELECT *
FROM enrollments
WHERE student_id = 2
AND course_id = 4;