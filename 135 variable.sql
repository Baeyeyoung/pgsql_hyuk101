/*
	전문가로 가는 지름길 1 / 개발자용
	제 3장 소스 스크립트 
	정원혁 2000.1
	for pgsql 2022.11
*/


-- 변수 선언과 사용
WITH my_var (id, cust_id) as (
   values (10248, 'TOMSP')
)
SELECT * from my_var;



WITH my_var (id, cust_id) as (
   values (10248, 'TOMSP')
)
SELECT * from orders , my_var
where order_id  = id	or customer_id = cust_id ;

-- 더 바람직한 ANSI JOIN 문법
WITH my_var (id, cust_id) as (
   values (10248, 'TOMSP')
)
SELECT * from orders 
	cross join my_var
where order_id  = id	or customer_id = cust_id ;







