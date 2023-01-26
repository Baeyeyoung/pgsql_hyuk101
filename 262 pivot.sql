/*
	PIVOT1: CASE, FILTER
	정원혁 for pgsql 2023.01 
*/
select * from orders;

select ship_via, date_part('year', order_date) as order_year, freight 
FROM orders
order by 1;

select ship_via, date_part('year', order_date) as order_year, sum(freight) 
FROM orders
group by ship_via, order_year
order by ship_via, order_year;

/*
 * CASE
 */
--우선 하나만
select ship_via 
	, case date_part('year', order_date) when 1996 then freight else 0 end as y96
FROM orders
order by ship_via;

select ship_via 
	, sum(case date_part('year', order_date) when 1996 then freight else 0 end) as y96
FROM orders
group by ship_via;
 
--전체 다
select ship_via
	, sum(case date_part('year', order_date) when 1996 then freight else 0 end) as y96
	, sum(case date_part('year', order_date) when 1997 then freight else 0 end) as y97
	, sum(case date_part('year', order_date) when 1998 then freight else 0 end) as y99
FROM orders
group by ship_via;


/*
 * FILTER
 */
select ship_via
	, sum(freight) filter (where date_part('year', order_date) =1996) as y96
	, sum(freight) filter (where date_part('year', order_date) =1997) as y97
	, sum(freight) filter (where date_part('year', order_date) =1998) as y98
FROM orders
group by ship_via;
