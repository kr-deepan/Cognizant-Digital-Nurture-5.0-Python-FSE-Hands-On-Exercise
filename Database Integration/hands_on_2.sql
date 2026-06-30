INSERT INTO departments (dept_name, head_of_dept, budget)
VALUES
('Computer Science', 'Dr. Ramesh Kumar', 850000.00),
('Electronics', 'Dr. Priya Nair', 620000.00),
('Mechanical', 'Dr. Suresh Iyer', 540000.00),
('Civil', 'Dr. Ananya Sharma', 430000.00);

INSERT INTO courses (course_name, credits, department_id)
VALUES
('Database Systems', 4, 1),
('Data Structures', 4, 1),
('Digital Electronics', 3, 2),
('Thermodynamics', 4, 3),
('Structural Analysis', 3, 4);

INSERT INTO professors
(first_name, last_name, email, department_id, hire_date, salary)
VALUES
('Rajesh', 'Kumar', 'rajesh.kumar@college.edu', 1, '2018-06-10', 95000),
('Priya', 'Nair', 'priya.nair@college.edu', 2, '2019-03-15', 90000),
('Suresh', 'Iyer', 'suresh.iyer@college.edu', 3, '2017-01-20', 85000),
('Ananya', 'Sharma', 'ananya.sharma@college.edu', 4, '2020-08-12', 80000);

INSERT INTO students
(first_name, last_name, email, date_of_birth, department_id, enrollment_year)
VALUES
('Arun', 'Kumar', 'arun.kumar@college.edu', '2003-01-15', 1, 2022),
('Meena', 'Ravi', 'meena.ravi@college.edu', '2003-03-10', 1, 2022),
('Vikram', 'Singh', 'vikram.singh@college.edu', '2002-11-21', 2, 2021),
('Divya', 'Nair', 'divya.nair@college.edu', '2004-02-05', 3, 2023),
('Karthik', 'Raj', 'karthik.raj@college.edu', '2003-07-30', 4, 2022),
('Prithvi', 'Singh', 'prithvi.singh@college.edu', '2003-05-10', 1, 2022),
('Rahul', 'Kumar', 'rahul.kumar@college.edu', '2004-02-15', 2, 2023);

INSERT INTO enrollments
(student_id, course_id, enrollment_date, grade)
VALUES
(1, 1, '2022-08-01', 'A'),
(1, 2, '2022-08-01', 'A'),
(2, 1, '2022-08-01', 'B'),
(3, 3, '2021-08-01', 'A'),
(4, 4, '2023-08-01', 'B'),
(5, 5, '2022-08-01', 'A'),
(6, 1, '2022-08-01', 'A'),
(7, 3, '2023-08-01', 'B');



UPDATE enrollments
SET grade = 'B'
WHERE student_id = 5
AND course_id = 5;



DELETE FROM enrollments
WHERE grade IS NULL;



SELECT *
FROM students
WHERE enrollment_year = 2022
ORDER BY last_name;

SELECT *
FROM courses
WHERE credits > 3
ORDER BY credits DESC;

SELECT *
FROM professors
WHERE salary BETWEEN 80000 AND 95000;

SELECT *
FROM students
WHERE email LIKE '%@college.edu';

SELECT
    enrollment_year,
    COUNT(*) AS total_students
FROM students
GROUP BY enrollment_year;



SELECT
    s.first_name || ' ' || s.last_name AS student_name,
    d.dept_name
FROM students s
JOIN departments d
ON s.department_id = d.department_id;

SELECT
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    e.grade
FROM enrollments e
JOIN students s
ON e.student_id = s.student_id
JOIN courses c
ON e.course_id = c.course_id;