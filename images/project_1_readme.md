# SQL Project 1: Data Engineer Job Market Analysis

## Overview
This is my first SQL project built while following Luke Barousse's SQL for Data Engineering course. The goal of this project is simple: query a real dataset of job postings to figure out **which skills are most in-demand, which ones pay the most, and which ones give the best balance of both** for remote Data Engineers.

![Project Workflow](image_1ab316.png)

As shown in the workflow above, the project is broken down into three main steps:
1. **Data Warehouse:** Connected to the `data_jobs` database hosted on **MotherDuck** (using the **DuckDB** engine inside VS Code).
2. **SQL Analytics:** Wrote three SQL queries to analyze skill demand, median salaries, and an optimal skill score.
3. **Data Insights:** Used the query results to see which tools are actually worth learning first.

---

## Database Structure (Data Warehouse)

![Data Warehouse ERD](image_1ab314.png)

The database uses four tables connected by Primary Keys (`PK`) and Foreign Keys (`FK`):
* **`job_postings_fact`:** The main table with $1.62 \times 10^6$ job postings, including job titles, salaries (`salary_year_avg`), and whether the job is remote (`job_work_from_home`).
* **`company_dim`:** Contains company names and details linked by `company_id`.
* **`skills_job_dim`:** A bridge table that connects `job_id` to `skill_id`.
* **`skills_dim`:** Lists the actual skill names (`sql`, `python`, `aws`, etc.) for each `skill_id`.

**One thing I noticed while joining tables:** 
The original `job_postings_fact` table has $1.62 \times 10^6$ rows, but when you join it with the skills tables, the row count jumps up to $7.48 \times 10^6$ rows. This happens because a single job posting usually asks for multiple skills, so the join duplicates the job row once for each skill it requires.

---

## The Queries & Why I Calculated Things This Way

### 1. Top Demanded Skills (`01_top_demanded_skills.sql`)
* **What I did:** Joined the main job postings table with the two skills tables using `INNER JOIN`, filtered for `'Data Engineer'` and `job_work_from_home = True`, and counted how many times each skill appeared.
* **Mistake I fixed:** On my first try, I only filtered for `job_title_short = 'Data Engineer'` and forgot to add `AND job_work_from_home = True`, which meant I was counting on-site jobs too.
* **What the results show:** 
  * **SQL ($29,221$)** and **Python ($28,776$)** are #1 and #2 by a huge margin. Almost every Data Engineer role asks for both.
  * **Cloud & Big Data:** **AWS ($17,823$)** and **Azure ($14,143$)** are the top cloud platforms, followed by **Spark ($12,799$)**, **Airflow ($9,996$)**, **Snowflake ($8,639$)**, and **Databricks ($8,183$)**.

### 2. Top Paying Skills (`02_top_paying-skills.sql`)
* **Why I calculated it this way:**
  * **Used `MEDIAN()` instead of `AVG()`:** A few super-high or super-low salaries can easily mess up a normal average. The median gives a much more realistic middle number.
  * **Added `HAVING skill_count > 100`:** If a rare skill only shows up in $2$ job postings that happen to pay $\$200,000$, it would sit at the top of the list even though almost nobody is hiring for it. Filtering for skills with more than $100$ postings removes that noise.
* **What the results show:**
  * Niche or systems languages like **Rust ($\$210,000$)** and **Golang ($\$184,000$)** pay the highest, along with **Terraform ($\$184,000$)**.
  * Tools like **Airflow ($\$150,000$ across $9,996$ postings)**, **Kubernetes ($\$150,500$ across $4,202$ postings)**, and **Terraform ($3,248$ postings)** stand out because they pay high salaries *and* have thousands of job openings.
  * However, core skills like SQL and Python didn't even make the Top 25 here because their median pay is slightly lower, which is why I needed Query 3.

### 3. Optimal Skills (`03_optimal_skills.sql`)
* **The problem I faced:** I wanted one score (`optimal_score`) that combines both **high pay** and **high demand**. However, if you just multiply $\text{median\_salary} \times \text{demand\_count}$, SQL and Python completely take over the list just because they have over $1,100$ salaried job postings, while great high-paying skills like Terraform ($193$ salaried postings) get buried.
* **Why I used `LN()` (Natural Log):** Taking the natural log of the demand count (`LN(COUNT(jpf.*))`) shrinks the huge gap between job counts onto a smaller scale. For example, $1,133$ jobs for Python becomes about $7.0$, and $193$ jobs for Terraform becomes about $5.0$. Then I multiplied the median salary by that log number (and divided by $1,000,000$ to make the final number easy to read):

$$\text{optimal\_score} = \text{ROUND}\left(\frac{\text{MEDIAN}(\text{salary\_year\_avg}) \times \ln(\text{COUNT}(*))}{1,000,000}, 2\right)$$

* **Why job counts are smaller here than in Query 2:** In this query, I added `AND jpf.salary_year_avg IS NOT NULL` in the `WHERE` clause so that only job postings that actually list a salary are counted in both the median and the demand count.
* **What the results show:**
  * **Terraform ($0.97$)** takes the #1 spot because of its high median pay ($\$184,000$) and solid demand.
  * **Python ($0.95$)**, **SQL ($0.91$)**, **AWS ($0.91$)**, **Airflow ($0.89$)**, and **Spark ($0.87$)** right behind it show that learning the core tools first, then adding cloud/infrastructure tools like AWS, Airflow, and Terraform, is the best path.
  * Meanwhile, **Rust ($0.66$)** drops to #23 because it only had $23$ salaried remote postings.

---

## Problems I Faced & How I Solved Them

While setting up the tools and writing the queries, I ran into a few beginner hurdles and fixed them:

1. **`WHERE` vs. `HAVING` Error:**
   * *Problem:* While practicing `GROUP BY`, I tried filtering a count using `WHERE COUNT(...) > 3000` at the bottom of my query and got an error.
   * *Solution:* Learned how SQL order of execution works. `WHERE` goes *before* `GROUP BY` and filters raw rows, while `HAVING` goes *after* `GROUP BY` and filters aggregated groups (like `COUNT()` or `MEDIAN()`).

2. **`GROUP BY` Error When Mixing Columns:**
   * *Problem:* Got the error *"column name must appear in the GROUP BY clause or must be part of an aggregate function"* when selecting a company/skill name next to `COUNT()`.
   * *Solution:* Anytime you mix a normal column (like `sd.skills`) with an aggregate function (like `COUNT()`), you have to add `GROUP BY sd.skills` so SQL knows how to bucket the counts.

3. **MotherDuck Token Not Loading in Git Bash:**
   * *Problem:* I saved my `motherduck_token` inside `~/.bashrc` like the video showed, but every time I closed and reopened my terminal, MotherDuck asked me to authenticate again.
   * *Solution:* Because my Git Bash terminal on Windows was set up with `--login -i`, it only reads `~/.bash_profile` on startup and ignores `~/.bashrc`. Adding a few lines inside `.bash_profile` to load `.bashrc` fixed it permanently.

4. **MotherDuck Trial Ended Error:**
   * *Problem:* Halfway through, running `duckdb md:data_jobs` threw an `Invalid Input Error` saying my MotherDuck Business trial had ended.
   * *Solution:* Logged into the MotherDuck web app, skipped the trial extension, and switched my account to the **Free** plan, which is all that's needed for this course.

5. **Garbled Text in the VS Code Terminal:**
   * *Problem:* When a table had too many columns to fit on screen, running `.last` opened the terminal pager and printed weird Chinese characters (`mojibake`) instead of the table borders.
   * *Solution:* Pressed `q` to exit the pager, used `.mode line` to view wide rows vertically (and `.mode duckbox` to switch back to normal tables), and moved my VS Code terminal panel vertically to the right side of the screen.