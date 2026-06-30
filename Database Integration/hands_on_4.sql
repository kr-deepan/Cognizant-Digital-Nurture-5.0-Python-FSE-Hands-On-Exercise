-- Baseline Performance

-- Examine query plan before indexes

EXPLAIN
SELECT *
FROM students
WHERE department_id = 1;

EXPLAIN
SELECT *
FROM enrollments
WHERE student_id = 1;

EXPLAIN
SELECT *
FROM courses
WHERE department_id = 1;

-- Observation:
-- PostgreSQL typically performs Seq Scan
-- when no suitable index exists.


-- Create Indexes

-- Index on students.department_id

CREATE INDEX idx_students_department
ON students(department_id);

-- Index on enrollments.student_id

CREATE INDEX idx_enrollments_student
ON enrollments(student_id);

-- Index on enrollments.course_id

CREATE INDEX idx_enrollments_course
ON enrollments(course_id);

-- Composite Index

CREATE INDEX idx_enrollments_student_course
ON enrollments(student_id, course_id);


-- Verify Query Plans

EXPLAIN ANALYZE
SELECT *
FROM students
WHERE department_id = 1;

EXPLAIN ANALYZE
SELECT *
FROM enrollments
WHERE student_id = 1;

EXPLAIN ANALYZE
SELECT *
FROM enrollments
WHERE student_id = 1
AND course_id = 2;

-- Expected:
-- Planner may use Index Scan or Bitmap Index Scan.
-- Small tables may still use Seq Scan because
-- PostgreSQL determines it is cheaper.


-- Additional Optimisation Queries

EXPLAIN ANALYZE
SELECT
    s.first_name,
    s.last_name,
    c.course_name
FROM enrollments e
JOIN students s
ON e.student_id = s.student_id
JOIN courses c
ON e.course_id = c.course_id;

-- Observe join strategy:
-- Nested Loop
-- Hash Join
-- Merge Join


-- N+1 Problem Demonstration
-- Inefficient approach:

SELECT *
FROM enrollments;

-- Then for every enrollment:

SELECT *
FROM students
WHERE student_id = 1;

SELECT *
FROM students
WHERE student_id = 2;

SELECT *
FROM students
WHERE student_id = 3;

-- This creates N+1 queries.

-- Explanation:
-- 1 query to fetch enrollments
-- N queries to fetch student information


-- Optimised Solution

SELECT
    e.enrollment_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    e.grade
FROM enrollments e
JOIN students s
ON e.student_id = s.student_id
JOIN courses c
ON e.course_id = c.course_id;

-- Single query replaces N+1 queries.


-- Query Cost Comparison

EXPLAIN ANALYZE
SELECT
    e.enrollment_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    e.grade
FROM enrollments e
JOIN students s
ON e.student_id = s.student_id
JOIN courses c
ON e.course_id = c.course_id;


-- Documentation

-- N+1 Problem:
-- One query retrieves N rows.
-- Additional N queries retrieve related records.
-- Total queries = N + 1.

-- Example:
-- 100 enrollments
-- 1 query for enrollments
-- 100 queries for student details
-- Total = 101 queries

-- Optimised JOIN version executes
-- all retrieval in one query.

-- Indexes created:
-- idx_students_department
-- idx_enrollments_student
-- idx_enrollments_course
-- idx_enrollments_student_course

-- Benefits:
-- Faster filtering
-- Faster joins
-- Reduced query execution time