/*
페이징 쿼리
order by와 where절 다를 때
2020. 11. 정원혁 for PostgreSQL
*/

------------------------------
--table create
------------------------------
drop table if exists m;
CREATE TABLE m(
	member_no int NOT NULL,
	lastname char(30) NOT NULL default 'last',
	firstname char(30) NOT NULL default 'first',
	issue_dt TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
	dummy char(300) default 'dummy'
);
INSERT INTO m (member_no, issue_dt)
	select ROW_NUMBER() over (), NOW() - ('1 days' :: interval* random() * 1000)
	from generate_series(1, 100000) AS x;
create index ixM_member on m (member_no);
drop index ixM_member;
create index ixM_issuedt on m (issue_dt);
drop index ixM_issuedt;
--cluster m using ixM_issuedt;
create index ixM_member_issue on m (member_no, issue_dt);


------------------------------
-- 첫페이지
------------------------------
--0. 
select row_number() over(order by issue_dt desc) as no, * 
from m
where member_no between 5000 and 15000
order by issue_dt desc
limit 100000;
--10001 rows

--1. limit offset
explain analyze

select * 
from m
where member_no between 5000 and 15000
order by issue_dt desc
offset (1-1)*10 limit 10;
/*
Limit  (cost=1511.60..1511.63 rows=10 width=1464) (actual time=3.862..3.865 rows=10 loops=1)
  ->  Sort  (cost=1511.60..1512.85 rows=500 width=1464) (actual time=3.860..3.862 rows=10 loops=1)
        Sort Key: issue_dt DESC
        Sort Method: top-N heapsort  Memory: 34kB
        ->  Bitmap Heap Scan on m  (cost=13.42..1500.80 rows=500 width=1464) (actual time=0.673..2.492 rows=10001 loops=1)
              Recheck Cond: ((member_no >= 5000) AND (member_no <= 15000))
              Heap Blocks: exact=527
              ->  Bitmap Index Scan on ixm_member  (cost=0.00..13.29 rows=500 width=0) (actual time=0.612..0.612 rows=10001 loops=1)
                    Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
Planning Time: 0.190 ms
Execution Time: 3.939 ms
*/

--2. row_number
explain analyze

select * 
from (
	select row_number() over(order by issue_dt desc) as no, *
	from m 
	where member_no between 5000 and 15000
) a
where no between 1 and 10;
/*
Subquery Scan on a  (cost=1523.21..1539.46 rows=2 width=1472) (actual time=26.681..35.133 rows=10 loops=1)
  Filter: ((a.no >= 1) AND (a.no <= 10))
  Rows Removed by Filter: 9991
  ->  WindowAgg  (cost=1523.21..1531.96 rows=500 width=1472) (actual time=26.680..34.213 rows=10001 loops=1)
        ->  Sort  (cost=1523.21..1524.46 rows=500 width=1464) (actual time=26.648..29.268 rows=10001 loops=1)
              Sort Key: m.issue_dt DESC
              Sort Method: external merge  Disk: 3824kB
              ->  Bitmap Heap Scan on m  (cost=13.42..1500.80 rows=500 width=1464) (actual time=0.833..3.379 rows=10001 loops=1)
                    Recheck Cond: ((member_no >= 5000) AND (member_no <= 15000))
                    Heap Blocks: exact=527
                    ->  Bitmap Index Scan on ixm_member  (cost=0.00..13.29 rows=500 width=0) (actual time=0.741..0.741 rows=10001 loops=1)
                          Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
Planning Time: 0.227 ms
Execution Time: 37.131 ms
*/

--3 그냥 그냥: 해당 페이지의 key만 구한 후 전체 행 가져온다.
explain analyze

select * from m where member_no in (
	select member_no
	from m 
	where member_no between 5000 and 15000
	order by issue_dt desc 
	offset (1-1)*10 limit 10
)
order by issue_dt desc 
;

/*
Sort  (cost=1160.37..1160.40 rows=10 width=378) (actual time=4.726..4.727 rows=10 loops=1)
  Sort Key: m.issue_dt DESC
  Sort Method: quicksort  Memory: 30kB
  ->  Nested Loop  (cost=1077.20..1160.21 rows=10 width=378) (actual time=4.698..4.720 rows=10 loops=1)
        ->  HashAggregate  (cost=1076.91..1077.01 rows=10 width=4) (actual time=4.685..4.687 rows=10 loops=1)
              Group Key: m_1.member_no
              Batches: 1  Memory Usage: 24kB
              ->  Limit  (cost=1076.76..1076.78 rows=10 width=12) (actual time=4.672..4.674 rows=10 loops=1)
                    ->  Sort  (cost=1076.76..1102.14 rows=10153 width=12) (actual time=4.670..4.671 rows=10 loops=1)
                          Sort Key: m_1.issue_dt DESC
                          Sort Method: top-N heapsort  Memory: 25kB
                          ->  Index Scan using ixm_member on m m_1  (cost=0.29..857.35 rows=10153 width=12) (actual time=0.010..3.549 rows=10001 loops=1)
                                Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
        ->  Index Scan using ixm_member on m  (cost=0.29..8.31 rows=1 width=378) (actual time=0.003..0.003 rows=1 loops=10)
              Index Cond: (member_no = m_1.member_no)
Planning Time: 0.227 ms
Execution Time: 4.753 ms
*/






------------------------------
-- 500페이지
------------------------------
--1. limit offset
explain analyze

select * 
from m
where member_no between 5000 and 15000

order by issue_dt desc
offset (500-1)*10 limit 10
/*
Limit  (cost=7409.51..7409.53 rows=10 width=378) (actual time=44.533..44.536 rows=10 loops=1)
  ->  Sort  (cost=7397.03..7412.27 rows=6093 width=378) (actual time=43.835..44.414 rows=5000 loops=1)
        Sort Key: issue_dt DESC
        Sort Method: quicksort  Memory: 3309kB
        ->  Seq Scan on m  (cost=0.00..7014.00 rows=6093 width=378) (actual time=0.022..39.541 rows=6071 loops=1)
              Filter: (issue_dt >= (now() - '60 days'::interval))
              Rows Removed by Filter: 93929
Planning Time: 0.088 ms
Execution Time: 44.982 ms
*/


--2 row_nubmer
explain analyze
select * 
from (
	select row_number() over(order by issue_dt desc) as no, *
	from m 
	where member_no between 5000 and 15000

) a
offset (500-1)*10 limit 10
/*
Limit  (cost=7534.26..7534.53 rows=10 width=386) (actual time=53.415..53.424 rows=10 loops=1)
  ->  WindowAgg  (cost=7397.03..7503.66 rows=6093 width=386) (actual time=49.064..53.266 rows=5000 loops=1)
        ->  Sort  (cost=7397.03..7412.27 rows=6093 width=378) (actual time=49.049..49.833 rows=5001 loops=1)
              Sort Key: m.issue_dt DESC
              Sort Method: quicksort  Memory: 3309kB
              ->  Seq Scan on m  (cost=0.00..7014.00 rows=6093 width=378) (actual time=0.024..44.124 rows=6071 loops=1)
                    Filter: (issue_dt >= (now() - '60 days'::interval))
                    Rows Removed by Filter: 93929
Planning Time: 0.109 ms
Execution Time: 53.951 ms
*/

--3 빠르다: 해당 페이지의 key만 구한 후 전체 행 가져온다.
explain analyze

select * from m where member_no in (
	select member_no
	from m 
	where member_no between 5000 and 15000
	order by issue_dt desc 
	offset (500-1)*10 limit 10
);
/*
Nested Loop  (cost=1514.41..1597.42 rows=10 width=378) (actual time=12.953..13.015 rows=10 loops=1)
  ->  HashAggregate  (cost=1514.12..1514.22 rows=10 width=4) (actual time=12.906..12.911 rows=10 loops=1)
        Group Key: m_1.member_no
        Batches: 1  Memory Usage: 24kB
        ->  Limit  (cost=1513.97..1513.99 rows=10 width=12) (actual time=12.881..12.885 rows=10 loops=1)
              ->  Sort  (cost=1501.49..1526.41 rows=9966 width=12) (actual time=11.657..12.734 rows=5000 loops=1)
                    Sort Key: m_1.issue_dt DESC
                    Sort Method: top-N heapsort  Memory: 781kB
                    ->  Index Scan using ixm_member on m m_1  (cost=0.29..839.61 rows=9966 width=12) (actual time=0.015..6.417 rows=10001 loops=1)
                          Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
  ->  Index Scan using ixm_member on m  (cost=0.29..8.31 rows=1 width=378) (actual time=0.006..0.007 rows=1 loops=10)
        Index Cond: (member_no = m_1.member_no)
Planning Time: 0.389 ms
Execution Time: 13.352 ms
*/




--9 별 의미 없다: 마지막 제한 > 첫번째 제한> 다시 해당 key값의 행
explain analyze
select * from m
where member_no in 
(
	select member_no from(
		select * 
		from (
			select row_number() over(order by issue_dt desc) as no, member_no
			from m 
			where member_no between 5000 and 15000

		) a
		where no <= 510
	) b------------------------------
--table create
------------------------------
drop table if exists m;
CREATE TABLE m(
	member_no int NOT NULL,
	lastname char(30) NOT NULL default 'last',
	firstname char(30) NOT NULL default 'first',
	issue_dt TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
	dummy char(300) default 'dummy'
);
INSERT INTO m (member_no, issue_dt)
	select ROW_NUMBER() over (), NOW() - ('1 days' :: interval* random() * 1000)
	from generate_series(1, 100000) AS x;
create index ixM_member on m (member_no);
drop index ixM_member
drop index ixM_issuedt
create index ixM_issuedt on m (issue_dt);
create index ixM_member_issue on m (member_no, issue_dt);
cluster m using ixM_issuedt;


------------------------------
-- 첫페이지
------------------------------
--0. 
select row_number() over(order by issue_dt desc) as no, * 
from m
where member_no between 5000 and 15000
order by issue_dt desc
limit 100000;
--10001 rows

--1. limit offset
explain analyze
select * 
from m
where member_no between 5000 and 15000
order by issue_dt desc
offset (1-1)*10 limit 10;
/*
Limit  (cost=7048.06..7049.22 rows=10 width=378) (actual time=155.904..162.135 rows=10 loops=1)
  ->  Gather Merge  (cost=7048.06..7640.53 rows=5078 width=378) (actual time=155.902..162.131 rows=10 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=6048.03..6054.38 rows=2539 width=378) (actual time=24.535..24.536 rows=3 loops=3)
              Sort Key: issue_dt DESC
              Sort Method: top-N heapsort  Memory: 35kB
              Worker 0:  Sort Method: quicksort  Memory: 25kB
              Worker 1:  Sort Method: quicksort  Memory: 25kB
              ->  Parallel Seq Scan on m  (cost=0.00..5993.17 rows=2539 width=378) (actual time=0.006..23.532 rows=2024 loops=3)
                    Filter: (issue_dt >= (now() - '60 days'::interval))
                    Rows Removed by Filter: 31310
Planning Time: 0.144 ms
Execution Time: 162.179 ms
*/

--2. row_number
explain analyze
select * 
from (
	select row_number() over(order by issue_dt desc) as no, *
	from m 
	where member_no between 5000 and 15000
) a
where no between 1 and 10;
/*
Subquery Scan on a  (cost=7397.10..7595.16 rows=30 width=386) (actual time=50.326..56.023 rows=10 loops=1)
  Filter: ((a.no >= 1) AND (a.no <= 10))
  Rows Removed by Filter: 6061
  ->  WindowAgg  (cost=7397.10..7503.75 rows=6094 width=386) (actual time=50.325..55.639 rows=6071 loops=1)
        ->  Sort  (cost=7397.10..7412.34 rows=6094 width=378) (actual time=50.303..51.601 rows=6071 loops=1)
              Sort Key: m.issue_dt DESC
              Sort Method: quicksort  Memory: 3309kB
              ->  Seq Scan on m  (cost=0.00..7014.00 rows=6094 width=378) (actual time=0.019..45.320 rows=6071 loops=1)
                    Filter: (issue_dt >= (now() - '60 days'::interval))
                    Rows Removed by Filter: 93929
Planning Time: 0.126 ms
Execution Time: 56.500 ms
*/
--3 빠르다: 해당 페이지의 key만 구한 후 전체 행 가져온다.
explain analyze
select * from m where member_no in (
	select member_no
	from m 
	where member_no between 5000 and 15000
	offset (1-1)*10 limit 10
);
/*
Hash Semi Join  (cost=12.44..6539.05 rows=10 width=378) (actual time=0.122..27.923 rows=10 loops=1)
  Hash Cond: (m.member_no = m_1.member_no)
  ->  Seq Scan on m  (cost=0.00..6264.00 rows=100000 width=378) (actual time=0.025..10.961 rows=100000 loops=1)
  ->  Hash  (cost=12.31..12.31 rows=10 width=4) (actual time=0.086..0.088 rows=10 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Limit  (cost=0.00..12.21 rows=10 width=4) (actual time=0.022..0.080 rows=10 loops=1)
              ->  Seq Scan on m m_1  (cost=0.00..7014.00 rows=5743 width=4) (actual time=0.021..0.078 rows=10 loops=1)
                    Filter: (issue_dt >= (now() - '60 days'::interval))
                    Rows Removed by Filter: 67
Planning Time: 0.325 ms
Execution Time: 27.954 ms
*/






------------------------------
-- 500페이지
------------------------------
--1. limit offset
explain analyze
select * 
from m
where member_no between 5000 and 15000
order by issue_dt desc
offset (500-1)*10 limit 10
/*
Limit  (cost=1544.38..1544.40 rows=10 width=378) (actual time=37.617..37.623 rows=10 loops=1)
  ->  Sort  (cost=1531.90..1557.29 rows=10153 width=378) (actual time=35.975..37.394 rows=5000 loops=1)
        Sort Key: issue_dt DESC
        Sort Method: external merge  Disk: 3856kB
        ->  Index Scan using ixm_member on m  (cost=0.29..857.35 rows=10153 width=378) (actual time=0.049..2.841 rows=10001 loops=1)
              Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
Planning Time: 0.162 ms
Execution Time: 39.978 ms
*/


--2 row_nubmer
explain analyze
select * 
from (
	select row_number() over(order by issue_dt desc) as no, *
	from m 
	where member_no between 5000 and 15000

) a
offset (500-1)*10 limit 10;
/*
Limit  (cost=1670.24..1670.52 rows=10 width=386) (actual time=24.769..24.774 rows=10 loops=1)
  ->  WindowAgg  (cost=1533.02..1710.69 rows=10153 width=386) (actual time=22.668..24.666 rows=5000 loops=1)
        ->  Sort  (cost=1533.02..1558.40 rows=10153 width=378) (actual time=22.653..23.095 rows=5001 loops=1)
              Sort Key: m.issue_dt DESC
              Sort Method: external merge  Disk: 3824kB
              ->  Index Scan using ixm_member on m  (cost=0.29..857.35 rows=10153 width=378) (actual time=0.023..2.597 rows=10001 loops=1)
                    Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
Planning Time: 0.132 ms
Execution Time: 27.056 ms
*/

--3 빠르다: 해당 페이지의 key만 구한 후 전체 행 가져온다.
explain analyze
select * from m where member_no in (
	select member_no
	from m 
	where member_no between 5000 and 15000
	order by issue_dt desc 
	offset (500-1)*10 limit 10
)
order by issue_dt desc 
;
/*
Index: member만 
Index: member / issue_dt 따로. 동일한 결과

Sort  (cost=1627.99..1628.02 rows=10 width=378) (actual time=8.155..8.157 rows=10 loops=1)
  Sort Key: m.issue_dt DESC
  Sort Method: quicksort  Memory: 30kB
  ->  Nested Loop  (cost=1544.82..1627.83 rows=10 width=378) (actual time=8.100..8.141 rows=10 loops=1)
        ->  HashAggregate  (cost=1544.53..1544.63 rows=10 width=4) (actual time=8.076..8.080 rows=10 loops=1)
              Group Key: m_1.member_no
              Batches: 1  Memory Usage: 24kB
              ->  Limit  (cost=1544.38..1544.40 rows=10 width=12) (actual time=8.066..8.068 rows=10 loops=1)
                    ->  Sort  (cost=1531.90..1557.29 rows=10153 width=12) (actual time=7.495..7.955 rows=5000 loops=1)
                          Sort Key: m_1.issue_dt DESC
                          Sort Method: top-N heapsort  Memory: 784kB
                          ->  Index Scan using ixm_member on m m_1  (cost=0.29..857.35 rows=10153 width=12) (actual time=0.019..3.716 rows=10001 loops=1)
                                Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
        ->  Index Scan using ixm_member on m  (cost=0.29..8.31 rows=1 width=378) (actual time=0.005..0.005 rows=1 loops=10)
              Index Cond: (member_no = m_1.member_no)
Planning Time: 0.391 ms
Execution Time: 8.388 ms



-- member_no + issue_dt
Sort  (cost=1135.37..1135.39 rows=10 width=378) (actual time=6.436..6.438 rows=10 loops=1)
  Sort Key: m.issue_dt DESC
  Sort Method: quicksort  Memory: 30kB
  ->  Nested Loop  (cost=1051.07..1135.20 rows=10 width=378) (actual time=6.399..6.429 rows=10 loops=1)
        ->  HashAggregate  (cost=1050.65..1050.75 rows=10 width=4) (actual time=6.380..6.383 rows=10 loops=1)
              Group Key: m_1.member_no
              Batches: 1  Memory Usage: 24kB
              ->  Limit  (cost=1050.50..1050.53 rows=10 width=12) (actual time=6.370..6.372 rows=10 loops=1)
                    ->  Sort  (cost=1038.03..1063.41 rows=10153 width=12) (actual time=5.693..6.232 rows=5000 loops=1)
                          Sort Key: m_1.issue_dt DESC
                          Sort Method: top-N heapsort  Memory: 784kB
                          ->  Index Only Scan using ixm_member_issue on m m_1  (cost=0.42..363.48 rows=10153 width=12) (actual time=0.021..1.272 rows=10001 loops=1)
                                Index Cond: ((member_no >= 5000) AND (member_no <= 15000))
                                Heap Fetches: 0
        ->  Index Scan using ixm_member_issue on m  (cost=0.42..8.44 rows=1 width=378) (actual time=0.004..0.004 rows=1 loops=10)
              Index Cond: (member_no = m_1.member_no)
Planning Time: 0.281 ms
Execution Time: 6.705 ms

*/


