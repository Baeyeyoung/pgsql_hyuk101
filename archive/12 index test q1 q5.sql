--q1 no index
explain analyze 
select * from post 
where account_id =1;

"Seq Scan on post  (cost=0.00..2084.00 rows=443 width=29) (actual time=0.017..16.763 rows=462 loops=1)"
"  Filter: (account_id = 1)"
"  Rows Removed by Filter: 99538"
"Planning Time: 0.085 ms"
"Execution Time: 16.821 ms"

--q2 index
explain analyze 
select count(*) from post 
where account_id =1;

"Aggregate  (cost=2085.27..2085.28 rows=1 width=8) (actual time=19.788..19.789 rows=1 loops=1)"
"  ->  Seq Scan on post  (cost=0.00..2084.00 rows=507 width=0) (actual time=0.035..19.661 rows=487 loops=1)"
"        Filter: (account_id = 1)"
"        Rows Removed by Filter: 99513"
"Planning Time: 1.413 ms"
"Execution Time: 19.829 ms"


--q3 no index
explain analyze 
select * from post
where thread_id = 1
	and visible = TRUE;

"Seq Scan on post  (cost=0.00..2084.00 rows=88 width=29) (actual time=0.145..9.284 rows=46 loops=1)"
"  Filter: (visible AND (thread_id = 1))"
"  Rows Removed by Filter: 99954"
"Planning Time: 0.187 ms"
"Execution Time: 9.302 ms"


--q4 no index
explain analyze 
select count(*) from post
where thread_id = 1
	and visible = TRUE
	and account_id = 1;

"Aggregate  (cost=2334.00..2334.01 rows=1 width=8) (actual time=12.394..12.395 rows=1 loops=1)"
"  ->  Seq Scan on post  (cost=0.00..2334.00 rows=1 width=0) (actual time=12.389..12.390 rows=0 loops=1)"
"        Filter: (visible AND (thread_id = 1) AND (account_id = 1))"
"        Rows Removed by Filter: 100000"
"Planning Time: 0.143 ms"
"Execution Time: 12.450 ms"	

--q5 no index
explain analyze 
select *
from post
where thread_id = 1 
	and visible = TRUE 
	and created > now() - '1 month'::interval
order by created;


"Sort  (cost=2834.02..2834.03 rows=3 width=29) (actual time=11.381..11.382 rows=1 loops=1)"
"  Sort Key: created"
"  Sort Method: quicksort  Memory: 25kB"
"  ->  Seq Scan on post  (cost=0.00..2834.00 rows=3 width=29) (actual time=3.471..11.356 rows=1 loops=1)"
"        Filter: (visible AND (thread_id = 1) AND (created > (now() - '1 mon'::interval)))"
"        Rows Removed by Filter: 99999"
"Planning Time: 0.238 ms"
"Execution Time: 11.399 ms"




------------------------------------------------
create index ixP1 on post(account_id);
-- drop index ixP1 on post;

create index ixP2c on post (thread_id, visible);

--partial index
create index ixP3p on post (thread_id, visible)
where visible = TRUE;



