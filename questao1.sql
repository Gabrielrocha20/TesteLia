SELECT 
    s.name AS school_name,
    c.name AS course_name,
    COUNT(st.id) AS students_count,
    SUM(c.price) AS total_registration_value,
    st.enrolled_at::date AS enrollment_date
FROM students st
JOIN courses c ON st.course_id = c.id
JOIN schools s ON c.school_id = s.id
WHERE c.name LIKE 'data%'
GROUP BY s.name, st.enrolled_at::date, c.name
ORDER BY st.enrolled_at DESC;

WITH daily_students AS (
    SELECT 
        s.name AS school_name,
        st.enrolled_at::date AS enrollment_date,
        COUNT(st.id) AS students_count
    FROM students st
    JOIN courses c ON st.course_id = c.id
    JOIN schools s ON c.school_id = s.id
    WHERE c.name LIKE 'data%'
    GROUP BY s.name, st.enrolled_at::date
)

SELECT 
    school_name,
    enrollment_date,
    SUM(students_count) OVER (PARTITION BY school_name ORDER BY enrollment_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_students_count,
    AVG(students_count) OVER (PARTITION BY school_name ORDER BY enrollment_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7_days,
    AVG(students_count) OVER (PARTITION BY school_name ORDER BY enrollment_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS moving_avg_30_days
FROM daily_students
ORDER BY school_name, enrollment_date;