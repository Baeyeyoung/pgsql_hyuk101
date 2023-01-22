/*
	search argument 검색 제한자
 	정원혁 for pgsql 2023.01
*/

select customer_id , city, region, coalesce (region, 'N/A') from customers;
select customer_id , city, region, coalesce (region, 'N/A') from customers where region is null;
select customer_id , city, region, coalesce (region, 'N/A') from customers where region is not null;
select customer_id , city, region, coalesce (region, 'N/A') from customers where coalesce (region, 'N/A') = 'BC';
select customer_id , city, region, coalesce (region, 'N/A') from customers where region = 'BC' or region is null;



--큰 테이블에서 해 보자: 테이블이 없으면 "901 bigO.sql" 를 실행해서 만든다.
select order_id, order_date, ship_name  from bigO;



--성능을 비교하자: explain, explain analyze
--https://postgresql.kr/docs/9.6/sql-explain.html
--https://scalegrid.io/blog/postgres-explain-cost/
--https://onbaba.tistory.com/3

--0.
explain 
select order_id, order_date, ship_name  from bigO;
--Seq Scan on bigo  (cost=0.00..282.90 rows=10790 width=24)

explain analyse
select order_id, order_date, ship_name  from bigO;
--Seq Scan on bigo  (cost=0.00..282.90 rows=10790 width=24) (actual time=0.013..4.853 rows=10790 loops=1)


--1a.
explain analyse
select order_id, order_date, ship_name  from bigO where ship_name is null;
--Bitmap Heap Scan on bigo  (cost=5.64..188.39 rows=175 width=24)
--  ->  Bitmap Index Scan on ix_ship_name  (cost=0.00..5.60 rows=175 width=0)

--1b.
explain analyse
select order_id, order_date, ship_name  from bigO where coalesce (ship_name, '') = '';
--Seq Scan on bigo  (cost=0.00..309.88 rows=54 width=24)
--  Filter: ((COALESCE(ship_name, ''::character varying))::text = ''::text)

--2a. 
explain analyse
select order_id, order_date, ship_name  from bigO where ship_name = 'Toms Spezialitäten';
--Bitmap Heap Scan on bigo  (cost=4.88..145.73 rows=77 width=24)
--  ->  Bitmap Index Scan on ix_ship_name  (cost=0.00..4.86 rows=77 width=0)

--2b. 
explain analyse 
select order_id, order_date, ship_name  from bigO where trim(ship_name) = 'Toms Spezialitäten';
--Seq Scan on bigo  (cost=0.00..336.85 rows=54 width=24)
--  Filter: (TRIM(BOTH FROM ship_name) = 'Toms Spezialitäten'::text)


--3a.
explain analyse 
select order_id, order_date, ship_name  from bigO where order_date = '19960719';
--Bitmap Heap Scan on bigo  (cost=4.42..59.33 rows=18 width=24) (actual time=0.032..0.072 rows=25 loops=1)
--  Recheck Cond: (order_date = '1996-07-19'::date)
--  Heap Blocks: exact=14
--  ->  Bitmap Index Scan on ix_orderdate  (cost=0.00..4.42 rows=18 width=0) (actual time=0.020..0.020 rows=25 loops=1)
--        Index Cond: (order_date = '1996-07-19'::date)

--3b.
explain analyse 
select order_id, order_date, ship_name  from bigO where order_date < '19960720';
--Bitmap Heap Scan on bigo  (cost=5.61..188.08 rows=171 width=24) (actual time=0.045..0.140 rows=179 loops=1)
--  Recheck Cond: (order_date <= '1996-07-20'::date)
--  Heap Blocks: exact=26
--  ->  Bitmap Index Scan on ix_orderdate  (cost=0.00..5.57 rows=171 width=0) (actual time=0.026..0.026 rows=179 loops=1)
--        Index Cond: (order_date <= '1996-07-20'::date)


--4a.
explain analyse 
select order_id, order_date, ship_name  from bigO where order_date between '19000101' and '19960731';
--Bitmap Heap Scan on bigo  (cost=7.08..193.78 rows=273 width=24) (actual time=0.045..0.218 rows=281 loops=1)
--  Recheck Cond: ((order_date >= '1900-01-01'::date) AND (order_date <= '1996-07-31'::date))
--  Heap Blocks: exact=33
--  ->  Bitmap Index Scan on ix_orderdate  (cost=0.00..7.02 rows=273 width=0) (actual time=0.025..0.025 rows=281 loops=1)
--        Index Cond: ((order_date >= '1900-01-01'::date) AND (order_date <= '1996-07-31'::date))


--5a.
explain analyse 
select order_id, order_date, ship_name  from bigO where order_date <= '19960731';
--Bitmap Heap Scan on bigo  (cost=6.40..192.42 rows=273 width=24) (actual time=0.049..0.295 rows=281 loops=1)
--  Recheck Cond: (order_date <= '1996-07-31'::date)
--  Heap Blocks: exact=33
--  ->  Bitmap Index Scan on ix_orderdate  (cost=0.00..6.33 rows=273 width=0) (actual time=0.027..0.028 rows=281 loops=1)
--        Index Cond: (order_date <= '1996-07-31'::date)

--5b.
explain analyse 
select order_id, order_date, ship_name  from bigO where  date_part('year', order_date) = 1996 and date_part('month', order_date) = 7;
--Seq Scan on bigo  (cost=0.00..444.75 rows=1 width=24) (actual time=0.012..6.560 rows=281 loops=1)
--  Filter: ((date_part('year'::text, (order_date)::timestamp without time zone) = '1996'::double precision) AND (date_part('month'::text, (order_date)::timestamp without time zone) = '7'::double precision))
--  Rows Removed by Filter: 10509






--6a.
explain analyse
select ship_name from bigO where ship_name >='Lone' and ship_name < 'Lonf';
--Bitmap Heap Scan on bigo  (cost=5.33..163.62 rows=102 width=18) (actual time=0.237..0.433 rows=102 loops=1)
--  Recheck Cond: (((ship_name)::text >= 'Lone'::text) AND ((ship_name)::text < 'Lonf'::text))
--  Heap Blocks: exact=73
--  ->  Bitmap Index Scan on ix_ship_name  (cost=0.00..5.30 rows=102 width=0) (actual time=0.210..0.210 rows=102 loops=1)
--        Index Cond: (((ship_name)::text >= 'Lone'::text) AND ((ship_name)::text < 'Lonf'::text))
        
--6b.
explain analyse
select ship_name from bigO where ship_name like 'Lone%';
--Seq Scan on bigo  (cost=0.00..309.88 rows=102 width=18) (actual time=0.039..3.419 rows=102 loops=1)
--  Filter: ((ship_name)::text ~~ 'Lone%'::text)
--  Rows Removed by Filter: 10688

--6c.
explain analyse
select ship_name from bigO where ship_name like '%Lone%';
--Seq Scan on bigo  (cost=0.00..309.88 rows=102 width=18) (actual time=0.045..3.458 rows=102 loops=1)
--  Filter: ((ship_name)::text ~~ '%Lone%'::text)
--  Rows Removed by Filter: 10688
