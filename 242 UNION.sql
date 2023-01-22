/*
	UNION 
	for pgsql 2023.01	
*/

-- UNION / UNION ALL 차이
select 1, 'SQL은 재밌어'
union 
select 1, 'SQL은 재밌어';

select 1, 'SQL은 재밌어'
union ALL
select 1, 'SQL은 재밌어';

--여러번 사용가능
select 1, 'SQL은 재밌어'
union all
select 2, '짱 재밌어'
union all
select 2, '짱 재밌어';

--컬럼 제목은 처음에
select 1 as 번호, 'SQL은 재밌어' as 남긴말
union all
select 2, '짱 재밌어'
union all
select 2, '짱 재밌어'

--order by는 마지막에만
select 1 as 번호, 'SQL은 재밌어' as 남긴말
union all
select 2, '짱 재밌어'
union all
select 2, '짱 재밌어'
order by 번호, 남긴말;







drop table if exists c최근구매고객;
create temp table c최근구매고객 as (
	select *
	from customers c 
	where customer_id in (
		select customer_id from orders o 
		where order_date >= '19980501'	--주목
	)
);
select * from c최근구매고객;

drop table if exists c과거구매고객;
create temp table c과거구매고객 as (
	select *
	from customers c 
	where customer_id in (
		select customer_id from orders o 
		where order_date <= '19980501'	--주목
	)
);
select * from c과거구매고객;


select * from c과거구매고객
union all
select * from c최근구매고객;

select * from c과거구매고객
union
select * from c최근구매고객;


--5월 1일 날짜에 주목
select o.order_date, c.* 
from (
	select * from c과거구매고객
	union all
	select * from c최근구매고객
) c 
	join orders o	on c.customer_id = o.customer_id 
order by o.order_date desc, customer_id ;
