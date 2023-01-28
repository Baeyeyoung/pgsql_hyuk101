/*
	CTE
	정원혁 for pgsql 2023.01
*/
select employee_id, last_name, first_name, title, reports_to  
from employees;

WITH RECURSIVE employee_hierarchy(employee_id, last_name, first_name, title, reports_to, level) AS (
    -- Anchor member
    SELECT employee_id, last_name, first_name, title, reports_to, 1 as level
    FROM employees
    WHERE reports_to IS NULL
    UNION ALL
    -- Recursive member
    SELECT e.employee_id, e.last_name, e.first_name, e.title, e.reports_to, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.reports_to = eh.employee_id
)
SELECT employee_id, last_name, first_name, title, reports_to, level
FROM employee_hierarchy
ORDER BY level, employee_id;
