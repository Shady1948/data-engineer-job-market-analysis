/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface as the most practical and valuable to learn for data engineering careers.

Notes on why I calculated it this way:
- If we just multiply `median_salary * demand_count`, skills like SQL and Python win
  automatically just because they have over 1,100 postings.
- Using the natural log `LN(COUNT(jpf.*))` shrinks the gap between huge job counts (1,133
  becomes ~7) and medium job counts (193 becomes ~5).
- Multiplying `MEDIAN(salary_year_avg) * LN(COUNT(jpf.*))` (and dividing by 1,000,000 for
  a clean decimal) gives a fair score where both salary and job availability matter.
*/

SELECT
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
    COUNT(jpf.*) AS demand_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*)) / 1_000_000),2) AS optimal_score,
    ROUND(LN(COUNT(jpf.*))) AS ln_demand_count
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE job_title_short = 'Data Engineer'
    AND job_work_from_home = True
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY sd.skills
ORDER BY optimal_score DESC
LIMIT 25;

/*
Results:
┌────────────┬───────────────┬──────────────┬───────────────┬─────────────────┐
│   skills   │ median_salary │ demand_count │ optimal_score │ ln_demand_count │
│  varchar   │    double     │    int64     │    double     │     double      │
├────────────┼───────────────┼──────────────┼───────────────┼─────────────────┤
│ terraform  │      184000.0 │          193 │          0.97 │             5.0 │
│ python     │      135000.0 │         1133 │          0.95 │             7.0 │
│ sql        │      130000.0 │         1128 │          0.91 │             7.0 │
│ aws        │      137320.0 │          783 │          0.91 │             7.0 │
│ airflow    │      150000.0 │          386 │          0.89 │             6.0 │
│ spark      │      140000.0 │          503 │          0.87 │             6.0 │
│ snowflake  │      135500.0 │          438 │          0.82 │             6.0 │
│ kafka      │      145000.0 │          292 │          0.82 │             6.0 │
│ azure      │      128000.0 │          475 │          0.79 │             6.0 │
│ java       │      135000.0 │          303 │          0.77 │             6.0 │
│ scala      │      137290.0 │          247 │          0.76 │             6.0 │
│ git        │      140000.0 │          208 │          0.75 │             5.0 │
│ kubernetes │      150500.0 │          147 │          0.75 │             5.0 │
│ databricks │      132750.0 │          266 │          0.74 │             6.0 │
│ redshift   │      130000.0 │          274 │          0.73 │             6.0 │
│ gcp        │      136000.0 │          196 │          0.72 │             5.0 │
│ nosql      │      134415.0 │          193 │          0.71 │             5.0 │
│ hadoop     │      135000.0 │          198 │          0.71 │             5.0 │
│ pyspark    │      140000.0 │          152 │           0.7 │             5.0 │
│ mongodb    │      135750.0 │          136 │          0.67 │             5.0 │
│ docker     │      135000.0 │          144 │          0.67 │             5.0 │
│ golang     │      184000.0 │           39 │          0.67 │             4.0 │
│ rust       │      210000.0 │           23 │          0.66 │             3.0 │
│ go         │      140000.0 │          113 │          0.66 │             5.0 │
│ r          │      134775.0 │          133 │          0.66 │             5.0 │
└────────────┴───────────────┴──────────────┴───────────────┴─────────────────┘

Explanation of Results:
- Terraform (#1 at 0.97) comes out on top because it has a very high median salary ($184k)
  along with solid job demand (193 salaried postings).
- Core skills like Python (0.95), SQL (0.91), AWS (0.91), Airflow (0.89), and Spark (0.87)
  rank right at the top, making them the best everyday skills to focus on.
- Because the natural log penalizes very small job counts, rare skills like Rust (only 23
  salaried jobs) naturally drop to the bottom (0.66) even without needing `HAVING demand_count > 100`.
*/