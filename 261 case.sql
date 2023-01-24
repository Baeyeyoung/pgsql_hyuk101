/*
	case  
	정원혁 for pgsql 2023.01 
*/
select order_id, ship_via, freight, s.company_name 
from orders o
	join shippers s on o.ship_via = s.shipper_id ;

select order_id, ship_via, freight, s.company_name
	, case when freight > 100 then 'expensive' else 'good' end frGrade
from orders o
	join shippers s on o.ship_via = s.shipper_id ;


select * from employees e ;
select employee_id , hire_date
	, case 
		when 1995-date_part('year', hire_date) >=3 then '숙련자' 
		when 1995-date_part('year', hire_date) >=2 then '보통'
		when 1995-date_part('year', hire_date) >=1 then '초급'
		else '새내기'
	end
from employees e ;


