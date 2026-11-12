USE GrievanceDB;

-- 1. Overall KPI summary
SELECT
    COUNT(*) AS total_complaints,
    SUM(status = 'Pending') AS pending_complaints,
    SUM(status = 'In Progress') AS in_progress_complaints,
    SUM(status = 'Resolved') AS resolved_complaints,
    SUM(status = 'Rejected') AS rejected_complaints,
    ROUND(100 * SUM(status = 'Resolved') / COUNT(*), 2) AS resolution_rate_pct
FROM Complaints;

-- 2. Full complaint register
SELECT * FROM vw_complaint_register
ORDER BY complaint_date DESC;

-- 3. Department-wise workload (LEFT JOIN includes departments with zero complaints)
SELECT
    d.department_name,
    COUNT(c.complaint_id) AS total_complaints
FROM Departments d
LEFT JOIN Complaints c ON c.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_complaints DESC;

-- 4. Department resolution rate using conditional aggregation
SELECT
    d.department_name,
    COUNT(c.complaint_id) AS total,
    SUM(c.status = 'Resolved') AS resolved,
    ROUND(100 * SUM(c.status = 'Resolved') /
          NULLIF(COUNT(c.complaint_id),0), 2) AS resolution_rate_pct
FROM Departments d
LEFT JOIN Complaints c ON c.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- 5. High and critical open complaints
SELECT *
FROM vw_open_complaints
WHERE priority IN ('High','Critical')
ORDER BY FIELD(priority,'Critical','High'), complaint_date;

-- 6. Citizens with more than one complaint
SELECT
    ci.citizen_id,
    ci.citizen_name,
    COUNT(c.complaint_id) AS complaint_count
FROM Citizens ci
JOIN Complaints c ON c.citizen_id = ci.citizen_id
GROUP BY ci.citizen_id, ci.citizen_name
HAVING COUNT(c.complaint_id) > 1
ORDER BY complaint_count DESC;

-- 7. CTE: department-level summary
WITH department_stats AS (
    SELECT department_id,
           COUNT(*) AS total,
           SUM(status = 'Resolved') AS resolved
    FROM Complaints
    GROUP BY department_id
)
SELECT d.department_name, ds.total, ds.resolved
FROM department_stats ds
JOIN Departments d ON d.department_id = ds.department_id;

-- 8. CTE: open complaint age
WITH open_age AS (
    SELECT complaint_id, complaint_title, status,
           DATEDIFF(CURRENT_DATE, DATE(complaint_date)) AS age_days
    FROM Complaints
    WHERE status IN ('Pending','In Progress')
)
SELECT *
FROM open_age
WHERE age_days > 7
ORDER BY age_days DESC;

-- 9. Window function: rank departments by complaint volume
WITH dept_counts AS (
    SELECT d.department_id, d.department_name,
           COUNT(c.complaint_id) AS total_complaints
    FROM Departments d
    LEFT JOIN Complaints c ON c.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
)
SELECT *,
       DENSE_RANK() OVER (ORDER BY total_complaints DESC) AS volume_rank
FROM dept_counts;

-- 10. Window function: rank officers within each department
WITH officer_load AS (
    SELECT o.officer_id, o.officer_name, o.department_id,
           COUNT(c.complaint_id) AS assigned_complaints
    FROM Officers o
    LEFT JOIN Complaints c ON c.officer_id = o.officer_id
    GROUP BY o.officer_id, o.officer_name, o.department_id
)
SELECT *,
       RANK() OVER (
         PARTITION BY department_id
         ORDER BY assigned_complaints DESC
       ) AS officer_rank_in_department
FROM officer_load;

-- 11. Window function: running monthly complaint total
WITH monthly_counts AS (
    SELECT DATE_FORMAT(complaint_date,'%Y-%m') AS complaint_month,
           COUNT(*) AS monthly_total
    FROM Complaints
    GROUP BY DATE_FORMAT(complaint_date,'%Y-%m')
)
SELECT complaint_month, monthly_total,
       SUM(monthly_total) OVER (
         ORDER BY complaint_month
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM monthly_counts;

-- 12. Subquery: complaints from citizens whose complaint count is above average
SELECT *
FROM vw_complaint_register
WHERE citizen_name IN (
    SELECT ci.citizen_name
    FROM Citizens ci
    JOIN Complaints c ON c.citizen_id = ci.citizen_id
    GROUP BY ci.citizen_id, ci.citizen_name
    HAVING COUNT(*) > (
        SELECT AVG(citizen_complaint_count)
        FROM (
            SELECT COUNT(*) AS citizen_complaint_count
            FROM Complaints
            GROUP BY citizen_id
        ) AS counts_by_citizen
    )
);

-- 13. Average resolution time by department
SELECT
    d.department_name,
    ROUND(AVG(TIMESTAMPDIFF(HOUR,c.complaint_date,c.resolution_date))/24,2)
      AS avg_resolution_days
FROM Complaints c
JOIN Departments d ON d.department_id = c.department_id
WHERE c.status = 'Resolved'
GROUP BY d.department_id, d.department_name;

-- 14. SLA-style report: unresolved complaints older than department target
SELECT
    c.complaint_id,
    c.complaint_title,
    d.department_name,
    d.service_level_days,
    DATEDIFF(CURRENT_DATE, DATE(c.complaint_date)) AS age_days
FROM Complaints c
JOIN Departments d ON d.department_id = c.department_id
WHERE c.status IN ('Pending','In Progress')
  AND DATEDIFF(CURRENT_DATE, DATE(c.complaint_date)) > d.service_level_days
ORDER BY age_days DESC;

-- 15. Feedback average by department
SELECT
    d.department_name,
    ROUND(AVG(f.rating),2) AS average_rating,
    COUNT(f.feedback_id) AS feedback_count
FROM Departments d
JOIN Complaints c ON c.department_id = d.department_id
JOIN Feedback f ON f.complaint_id = c.complaint_id
GROUP BY d.department_id, d.department_name
ORDER BY average_rating DESC;

-- 16. Category-wise complaint distribution
SELECT
    cc.category_name,
    COUNT(c.complaint_id) AS total_complaints
FROM Complaint_Categories cc
LEFT JOIN Complaints c ON c.category_id = cc.category_id
GROUP BY cc.category_id, cc.category_name
ORDER BY total_complaints DESC;

-- 17. Find complaints without an assigned officer
SELECT complaint_id, complaint_title, department_id, status
FROM Complaints
WHERE officer_id IS NULL;

-- 18. EXPLAIN query plan for an indexed filter
EXPLAIN
SELECT complaint_id, complaint_date, status
FROM Complaints
WHERE status = 'Pending'
  AND complaint_date >= '2026-02-01';

-- 19. Status history for every complaint
SELECT
    c.complaint_id,
    c.complaint_title,
    h.old_status,
    h.new_status,
    h.changed_at,
    h.changed_by
FROM Status_History h
JOIN Complaints c ON c.complaint_id = h.complaint_id
ORDER BY h.changed_at DESC;

-- 20. Test stored procedures separately:
-- CALL sp_department_summary();
-- CALL sp_assign_officer(1,1);
-- CALL sp_update_complaint_status(1,'In Progress');
