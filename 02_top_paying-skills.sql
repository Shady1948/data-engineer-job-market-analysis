/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities

Notes on why I calculated it this way:
- Used MEDIAN() instead of AVG() so a few extreme salaries don't skew the numbers.
- Used `HAVING skill_count > 100` (after GROUP BY) to filter out rare skills that only
  appear in a handful of high-paying job posts.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
    COUNT(sd.skills) AS skill_count
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE job_title_short = 'Data Engineer'
    AND job_work_from_home = True
GROUP BY sd.skills
HAVING skill_count > 100
ORDER BY median_salary DESC
LIMIT 25;

/*
Results:
┌────────────┬───────────────┬─────────────┐
│   skills   │ median_salary │ skill_count │
│  varchar   │    double     │    int64    │
├────────────┼───────────────┼─────────────┤
│ rust       │      210000.0 │         232 │
│ terraform  │      184000.0 │        3248 │
│ golang     │      184000.0 │         912 │
│ spring     │      175500.0 │         364 │
│ neo4j      │      170000.0 │         277 │
│ gdpr       │      169616.0 │         582 │
│ zoom       │      168438.0 │         127 │
│ graphql    │      167500.0 │         445 │
│ mongo      │      162250.0 │         265 │
│ fastapi    │      157500.0 │         204 │
│ bitbucket  │      155000.0 │         478 │
│ django     │      155000.0 │         265 │
│ crystal    │      154224.0 │         129 │
│ c          │      151500.0 │         444 │
│ atlassian  │      151500.0 │         249 │
│ typescript │      151000.0 │         388 │
│ kubernetes │      150500.0 │        4202 │
│ airflow    │      150000.0 │        9996 │
│ css        │      150000.0 │         262 │
│ node       │      150000.0 │         179 │
│ ruby       │      150000.0 │         736 │
│ redis      │      149000.0 │         605 │
│ ansible    │      148798.0 │         475 │
│ vmware     │      148798.0 │         136 │
│ jupyter    │      147500.0 │         400 │
└────────────┴───────────────┴─────────────┘

Explanation of Results:
- Specialized languages and tools like Rust ($210k), Terraform ($184k), and Golang ($184k)
  sit at the top of the pay list.
- However, many skills on this list have low job counts (120 to 400 postings), while core
  skills like Python and SQL don't show up here at all.
- Terraform (3,248 jobs), Kubernetes (4,202 jobs), and Airflow (9,996 jobs) stand out because
  they have both high salaries ($150k+) and thousands of openings.
*/