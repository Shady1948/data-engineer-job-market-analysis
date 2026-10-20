/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work

Notes on what I did:
- Joined `job_postings_fact` with `skills_job_dim` and `skills_dim` using INNER JOIN
  so we only count job postings that actually list skills.
- Added `AND job_work_from_home = True` in the WHERE clause (which I initially missed)
  to make sure we are only looking at remote Data Engineer jobs.
*/

SELECT
    sd.skills,
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
ORDER BY skill_count DESC
LIMIT 10;

/*
Results:
┌────────────┬─────────────┐
│   skills   │ skill_count │
│  varchar   │    int64    │
├────────────┼─────────────┤
│ sql        │       29221 │
│ python     │       28776 │
│ aws        │       17823 │
│ azure      │       14143 │
│ spark      │       12799 │
│ airflow    │        9996 │
│ snowflake  │        8639 │
│ databricks │        8183 │
│ java       │        7267 │
│ gcp        │        6446 │
└────────────┴─────────────┘
  10 rows        2 columns

Explanation of Results:
- SQL (29,221) and Python (28,776) are by far the most requested skills and are almost
  tied, showing that Data Engineers need both.
- Cloud platforms AWS (17,823) and Azure (14,143) are in much higher demand for remote
  roles than GCP (6,446).
- Big data and pipeline tools like Spark (12,799), Airflow (9,996), Snowflake (8,639),
  and Databricks (8,183) make up the rest of the core stack.
*/