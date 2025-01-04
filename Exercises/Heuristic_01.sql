-- phân tích hiệu suất phòng ban
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT
    d.depart_id,
    AVG(s.amount) AS Salary_Avg,
    COUNT(*) AS Active_Employee_Count
FROM
    Department d
JOIN
    (SELECT depart_id, salary_id
     FROM EmployeeStatus
     WHERE end_dt IS NULL OR year(end_dt) > year(Getdate())) AS es
ON d.depart_id = es.depart_id
JOIN
    Salary s ON es.salary_id = s.salary_id
GROUP BY
    d.depart_id;
	


go
SELECT
    d.depart_id,
    AVG(s.amount) AS Salary_Avg,
    COUNT(es.emp_id) AS Active_Employee_Count
FROM
    Department d
JOIN
    EmployeeStatus es ON d.depart_id = es.depart_id

JOIN
    Salary s ON es.salary_id = s.salary_id
WHERE
    es.end_dt IS NULL OR es.end_dt > GETDATE()
GROUP BY
    d.depart_id;


