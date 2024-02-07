-- 1. Print the names of professors who work in departments that have fewer than 50 PhD students.
SELECT p.pname, d.numphds
FROM prof AS p
JOIN dept AS d ON p.dname = d.dname
WHERE d.numphds < 50;


-- 2. Print the names of the students with the lowest GPA.
SELECT sname
FROM students
WHERE gpa = (SELECT MIN(gpa) FROM students);

-- 3. For each Computer Sciences class, print the class number, section number, and the average gpa of the students enrolled in the class section.
SELECT c.cno, s.sectno, AVG(st.gpa) AS average_gpa
FROM course AS c
JOIN section AS s ON c.cno = s.cno
JOIN enroll AS e ON s.sectno = e.sectno
JOIN students AS st ON e.sid = st.sid
JOIN dept AS d ON c.dname = d.dname
WHERE d.dname = 'Computer Sciences'
GROUP BY c.cno, s.sectno;

-- 4. Print the names and section numbers of all sections with more than six students enrolled in them.
SELECT s.cno, s.sectno
FROM section s
JOIN (
    SELECT cno, sectno
    FROM enroll
    GROUP BY cno, sectno
    HAVING COUNT(*) > 6
) e ON s.cno = e.cno AND s.sectno = e.sectno;

-- 5. Print the name(s) and sid(s) of the student(s) enrolled in the most sections.
SELECT s.sname, s.sid
FROM students AS s
JOIN enroll AS e ON s.sid = e.sid
GROUP BY s.sid, s.sname
HAVING COUNT(DISTINCT e.sectno) = (
    SELECT COUNT(DISTINCT e2.sectno)
    FROM enroll AS e2
    GROUP BY e2.sid
    ORDER BY COUNT(DISTINCT e2.sectno) DESC
    LIMIT 1
);


-- 6. Print the names of departments that have one or more majors who are under 18 years old.
SELECT DISTINCT d.dname
FROM dept AS d
JOIN major m ON d.dname = m.dname
JOIN students AS s ON m.sid = s.sid
WHERE s.age < 18 ;



-- 7. Print the names and majors of students who are taking one of the College Geometry courses.
SELECT s.sname, m.dname
FROM students s
JOIN major m ON s.sid = m.sid
JOIN enroll e ON s.sid = e.sid
JOIN course c ON e.cno = c.cno
WHERE c.cname LIKE '%College Geometry%';

-- 8. For those departments that have no major taking a College Geometry course print the department name and the number of PhD students in the department.
WITH college_geom_dept AS (
    SELECT DISTINCT dname
    FROM course
    WHERE cname LIKE '%College Geometry%'
)
SELECT d.dname, COUNT(*) AS numphds
FROM dept d
LEFT JOIN major m ON d.dname = m.dname
WHERE d.dname NOT IN (SELECT dname FROM college_geom_dept)
GROUP BY d.dname;

-- 9. Print the names of students who are taking both a Computer Sciences course and a Mathematics course.
SELECT s.sname
FROM students s
JOIN enroll e1 ON s.sid = e1.sid
JOIN enroll e2 ON s.sid = e2.sid
JOIN course c1 ON e1.cno = c1.cno
JOIN course c2 ON e2.cno = c2.cno
WHERE c1.dname = 'Computer Sciences' AND c2.dname = 'Mathematics';

-- 10. Print the age difference between the oldest and the youngest Computer Sciences major.
SELECT MAX(s.age) - MIN(s.age) AS age_difference
FROM students s
JOIN major m ON s.sid = m.sid
WHERE m.dname = 'Computer Sciences';

-- 11. For each department that has one or more majors with a GPA under 1.0, print the name of the department and the average GPA of its majors.
SELECT d.dname, AVG(s.gpa) AS avg_gpa
FROM dept d
JOIN major m ON d.dname = m.dname
JOIN students s ON m.sid = s.sid
GROUP BY d.dname
HAVING MIN(s.gpa) < 1.0;



-- 12. Print the ids, names and GPAs of the students who are currently taking all the Civil Engineering courses.
WITH ce_course_count AS (
    SELECT COUNT(*) AS ce_course_count
    FROM course
    WHERE dname = 'Civil Engineering'
)
SELECT s.sid, s.sname, s.gpa
FROM students s
JOIN major m ON s.sid = m.sid
JOIN course c ON m.dname = c.dname
WHERE c.dname = 'Civil Engineering'
GROUP BY s.sid, s.sname, s.gpa
HAVING COUNT(*) = (SELECT ce_course_count FROM ce_course_count);