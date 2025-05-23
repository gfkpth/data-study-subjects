-- 1. What was the total number of students in Germany in 2023/24?

SELECT SUM(number)
    FROM students
    WHERE year = 2023;

-- 2. What were the 10 subjects with the highest number of students in 2023/24?

SELECT st.subj_name_en,SUM(s.number) AS total_students
  	FROM students s
  	LEFT JOIN subject_taxonomy st ON s.subj_code = st.subj_code
    WHERE year = 2023
    GROUP BY s.subj_code
    ORDER BY total_students DESC
	LIMIT 10;

-- 3. How was the gender distribution of students in 2023/24?
SELECT gender,SUM(`number`) as total
	FROM students s
	WHERE "year" = 2023
	GROUP BY gender;

-- 4. How was the gender distribution in the 5 most studied subjects?
WITH top_subjects AS (
    SELECT 
        subj_code,
        SUM(number) AS total_number
    FROM students
    WHERE year = 2023
    GROUP BY subj_code
    ORDER BY total_number DESC
    LIMIT 5
)
SELECT 
    st.subj_name_en,
    s.gender,
    SUM(s.number) AS gender_total
FROM students s
JOIN top_subjects ts ON s.subj_code = ts.subj_code
LEFT JOIN subject_taxonomy st ON s.subj_code = st.subj_code
WHERE s.year = 2023
GROUP BY st.subj_name_en, s.gender
ORDER BY st.subj_name_en, gender_total DESC;

-- 5. What were the top subjects by gender?
-- we need an embedded selection here (or window function)
SELECT gender, subj_name_en, total_number
FROM (
    SELECT 
        s.gender,
        st.subj_name_en,
        SUM(s.number) AS total_number,
        RANK() OVER (
            PARTITION BY s.gender 
            ORDER BY SUM(s.number) DESC
        ) AS rnk
    FROM students s
    LEFT JOIN subject_taxonomy st ON s.subj_code = st.subj_code
    WHERE s.year = 2023
    GROUP BY s.gender, s.subj_code
)
WHERE rnk <= 10
ORDER BY gender, total_number DESC;


-- 6. Which were the top 10 subjects studied by non-citizens in 2023? 
SELECT st.subj_name_en,SUM(number) AS total_number
FROM students s 
LEFT JOIN subject_taxonomy st ON s.subj_code = st.subj_code
WHERE s.nationality = 'foreign' AND s.year = 2023
GROUP BY s.subj_code
ORDER BY total_number DESC
LIMIT 10;



-- 7. How are the student numbers distributed across subject groups?
SELECT st.grp_name_en, SUM(s."number") AS student_count
FROM students s 
LEFT JOIN subject_taxonomy st ON s.subj_code = st.subj_code
WHERE year = 2023
GROUP BY st.grp_code 
ORDER BY student_count DESC;




-- 8. How does the number of incoming students change over the time period by group?
SELECT st.grp_name_en,is2."year", SUM(is2."number") AS student_number
FROM incoming_students is2 
LEFT JOIN subject_taxonomy st ON is2.subj_code = st.subj_code
GROUP BY st.grp_code,is2."year"
ORDER BY st.grp_name_en, is2."year";


-- 9. How does the number of incoming students change over the time period for language related subjects?
SELECT is2."year", SUM(is2."number") AS student_number
FROM incoming_students is2 
LEFT JOIN subject_taxonomy st ON is2.subj_code = st.subj_code
WHERE st.cluster_code IN ('07','08','09','10','11', '12', '13')
GROUP BY is2."year"
ORDER BY is2."year";

SELECT st.cluster_name_en,is2."year", SUM(is2."number") AS student_number
FROM incoming_students is2 
LEFT JOIN subject_taxonomy st ON is2.subj_code = st.subj_code
WHERE st.cluster_code IN ('07','08','09','10','11', '12', '13')
GROUP BY st.cluster_code,is2."year"
ORDER BY st.cluster_code, is2."year";



-- 10. How does the number of incoming students change for linguistics in a narrow perspective?
SELECT is2."year", SUM(is2."number") AS student_number
FROM incoming_students is2 
LEFT JOIN subject_taxonomy st ON is2.subj_code = st.subj_code
WHERE is2.subj_code IN ('152','284','160')
GROUP BY is2."year"
ORDER BY is2."year";

SELECT st.subj_name_en, is2."year", SUM(is2."number") AS student_number
FROM incoming_students is2 
LEFT JOIN subject_taxonomy st ON is2.subj_code = st.subj_code
WHERE is2.subj_code IN ('152','284','160')
GROUP BY is2.subj_code, is2."year"
ORDER BY is2.subj_code, is2."year";



-- 11. Which 10 subjects saw the highest percentual drop in intake from 2018 to 2023?


WITH year_bounds AS (
    SELECT MIN(year) AS first_year, MAX(year) AS last_year FROM incoming_students is2 
),
aggregated AS (
    SELECT
        subj_code,
        year,
        SUM(number) AS total_intake
    FROM incoming_students is2 
    GROUP BY subj_code, year
),
filtered AS (
    SELECT a.subj_code, a.total_intake, a.year, y.first_year, y.last_year
    FROM aggregated a
    JOIN year_bounds y ON a.year = y.first_year OR a.year = y.last_year
),
pivoted AS (
    SELECT
        subj_code,
        MAX(CASE WHEN year = first_year THEN total_intake END) AS intake_first_year,
        MAX(CASE WHEN year = last_year THEN total_intake END) AS intake_last_year
    FROM filtered
    GROUP BY subj_code
)
SELECT
    st.subj_name_en,
    intake_first_year,
    intake_last_year,
    ROUND(
        (CAST(intake_last_year - intake_first_year AS FLOAT) / NULLIF(intake_first_year, 0)) * 100,
        2
    ) AS percentual_change
FROM pivoted
LEFT JOIN subject_taxonomy st ON pivoted.subj_code = st.subj_code
WHERE percentual_change IS NOT NULL AND percentual_change > -100
ORDER BY percentual_change
LIMIT 10;

-- 12. Which 10 subjects saw the highest percentual rise in intake from 2018 to 2023?
WITH year_bounds AS (
        SELECT MIN(year) AS first_year, MAX(year) AS last_year FROM incoming_students is2 
    ),
    aggregated AS (
        SELECT
            subj_code,
            year,
            SUM(number) AS total_intake
        FROM incoming_students is2 
        GROUP BY subj_code, year
    ),
    filtered AS (
        SELECT a.subj_code, a.total_intake, a.year, y.first_year, y.last_year
        FROM aggregated a
        JOIN year_bounds y ON a.year = y.first_year OR a.year = y.last_year
    ),
    pivoted AS (
        SELECT
            subj_code,
            MAX(CASE WHEN year = first_year THEN total_intake END) AS intake_first_year,
            MAX(CASE WHEN year = last_year THEN total_intake END) AS intake_last_year
        FROM filtered
        GROUP BY subj_code
    )
    SELECT
        st.subj_name_en,
        intake_first_year,
        intake_last_year,
        ROUND(
            (CAST(intake_last_year - intake_first_year AS FLOAT) / NULLIF(intake_first_year, 0)) * 100,
            2
        ) AS percentual_change
    FROM pivoted
    LEFT JOIN subject_taxonomy st ON pivoted.subj_code = st.subj_code
    WHERE percentual_change IS NOT NULL
    ORDER BY percentual_change DESC
    LIMIT 10;
