-- thống kê số lượng nhân viên theo thành phố và trình độ học vấn
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
select tam.edu_level,count(*) as count_employee,City.city_nm
from Address as ad
inner join City 
on ad.city_id = City.city_id

inner join EmployeeStatus as ep
on ad.addr_id = ep.addr_id

inner join (
	select em.emp_id, ed.edu_level
	from Education as ed
	inner join Employee as em
	on ed.edu_id = em.edu_id
	) as tam

on tam.emp_id = ep.emp_id
WHERE
    ep.end_dt IS NULL OR ep.end_dt > GETDATE()
group by City.city_nm, tam.edu_level
order by tam.edu_level,count_employee desc





SELECT
    ed.edu_level,
    COUNT(emp.emp_id) AS count_employee,
    ci.city_nm
FROM
    Address ad
JOIN
    City ci ON ad.city_id = ci.city_id
JOIN
    EmployeeStatus es ON ad.addr_id = es.addr_id
JOIN
	Employee emp ON es.emp_id = emp.emp_id
JOIN
    Education ed ON emp.edu_id = ed.edu_id
WHERE
    es.end_dt IS NULL OR es.end_dt > GETDATE()
GROUP BY
    ci.city_nm, ed.edu_level
ORDER BY
    ed.edu_level, count_employee DESC;




WITH EmployeeEducation AS (
    SELECT
        em.emp_id,
        ed.edu_level
    FROM
        Education AS ed
    JOIN
        Employee AS em ON ed.edu_id = em.edu_id
)
SELECT
    ee.edu_level,
    COUNT(emp.emp_id) AS count_employee,
    ci.city_nm
FROM
    Address ad
JOIN
    City ci ON ad.city_id = ci.city_id
JOIN
    EmployeeStatus es ON ad.addr_id = es.addr_id
JOIN
	Employee emp ON es.emp_id = emp.emp_id
JOIN
    EmployeeEducation ee ON emp.emp_id = ee.emp_id
WHERE
    es.end_dt IS NULL OR es.end_dt > GETDATE()
GROUP BY
    ci.city_nm, ee.edu_level
ORDER BY
    ee.edu_level, count_employee DESC;