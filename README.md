# Smart Government Grievance Management & Analytics System

A portfolio-ready MySQL 8.0 project prototype for managing citizen grievances, assigning departments/officers, tracking status changes, and analysing service-delivery performance.

> This is an educational portfolio project. It is not an official NIC or government deployment. Use synthetic data only.

## Technology
- MySQL 8.0+
- MySQL Workbench
- Optional dashboard: Python, Streamlit, Pandas, Plotly, mysql-connector-python

## Project structure
- `sql/01_schema.sql` – creates the database and relational tables
- `sql/02_sample_data.sql` – inserts synthetic sample records
- `sql/03_advanced_objects.sql` – views, stored procedures, triggers, indexes
- `sql/04_analytics_queries.sql` – practical SQL analysis queries
- `dashboard/app.py` – optional Streamlit dashboard
- `dashboard/requirements.txt` – Python dependencies

## Run in MySQL Workbench
1. Install MySQL Server 8.0+ and MySQL Workbench.
2. Open Workbench and connect to your local MySQL server.
3. Open `sql/01_schema.sql` and execute the whole script.
4. Open and execute `sql/02_sample_data.sql`.
5. Open and execute `sql/03_advanced_objects.sql`.
6. Open `sql/04_analytics_queries.sql` and run individual queries to explore results.

The schema script drops and recreates `GrievanceDB` for a clean first run. **Do not run it again if you want to preserve your own data.**

## Optional dashboard setup
1. Install Python 3.10+.
2. Open a terminal in the `dashboard` folder.
3. Run: `pip install -r requirements.txt`
4. Set environment variables before launching:
   - Windows PowerShell:
     ```powershell
     $env:DB_HOST="localhost"
     $env:DB_USER="root"
     $env:DB_PASSWORD="your_mysql_password"
     $env:DB_NAME="GrievanceDB"
     ```
   - macOS/Linux:
     ```bash
     export DB_HOST=localhost
     export DB_USER=root
     export DB_PASSWORD='your_mysql_password'
     export DB_NAME=GrievanceDB
     ```
5. Run: `streamlit run app.py`

Never put your real database password in a public GitHub repository. The dashboard uses read-only SELECT queries.

## What this project demonstrates
- Relational schema design, primary and foreign keys, constraints
- Joins, aggregation, subqueries, CTEs, window functions
- Views, stored procedures, triggers
- Indexes and `EXPLAIN`
- Transaction examples and reporting
- Optional Python-to-MySQL integration

## Suggested resume description (only after you understand and test it)
**Smart Government Grievance Management & Analytics System | MySQL, SQL, Python, Streamlit**
- Designed a relational MySQL database for citizen complaints, department allocation, officer assignment and status tracking.
- Implemented advanced SQL analytics using joins, CTEs, subqueries and window functions to evaluate complaint trends and departmental performance.
- Developed database views, stored procedures, triggers and indexes; integrated an optional Streamlit dashboard for operational reporting.

## Important learning note
Do not claim the project is deployed by a government department. Be ready to explain each table, relationship, query, trigger, procedure and dashboard metric in an interview.
