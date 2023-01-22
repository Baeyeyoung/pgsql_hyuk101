/*
	Aggregation 집계함수
	for pgsql 2023.01 
	https://www.postgresql.org/docs/9.5/functions-aggregate.html
*/

set search_path to public;
show search_path;

select * FROM products;;

SELECT quantity FROM order_details od;
SELECT sum(quantity) FROM order_details;

SELECT max(order_date), min(order_date)  
FROM orders;

SELECT max(quantity), min(quantity), avg(quantity), stddev(quantity) 
FROM order_details

SELECT count(*)
FROM products;
---
SELECT count(product_id)
FROM products;

SELECT count(unit_price)
FROM products;

--다음 둘의 차이는?
--1
select avg(freight)
from (
	(select order_id , freight from orders o limit 3) 
	union all
	(select 11111 , null from orders o  limit 1)
) a;
--2
select avg(freight)
from (
	(select order_id , freight from orders o limit 3) 
	union all
	(select 11111 , coalesce (null,0) from orders o  limit 1)
) a;

