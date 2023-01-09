/*
페이징 쿼리
order by와 where절 동일할때
2020. 11. 정원혁 for PostgreSQL
*/

------------------------------------------------------------
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
create index ixM_issuedt on m (issue_dt);
cluster m using ixM_issuedt;


------------------------------
-- 첫페이지
------------------------------
--0. 
select row_number() over(order by issue_dt desc) as no, * 
from m
where issue_dt >= NOW() - ('60 days' :: interval)
order by issue_dt desc
limit 100000;
--6071 rows

--1. limit offset
explain analyze
select * 
from m
where issue_dt >= NOW() - ('60 days' :: interval)
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
	where issue_dt >= NOW() - ('60 days' :: interval)
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
	where issue_dt >= NOW() - ('60 days' :: interval)
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
where issue_dt >= NOW() - ('60 days' :: interval)
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
	where issue_dt >= NOW() - ('60 days' :: interval)
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
	where issue_dt >= NOW() - ('60 days' :: interval)
	offset (500-1)*10 limit 10
);
/*
Hash Semi Join  (cost=4982.80..11509.41 rows=10 width=378) (actual time=29.577..32.310 rows=10 loops=1)
  Hash Cond: (m.member_no = m_1.member_no)
  ->  Seq Scan on m  (cost=0.00..6264.00 rows=100000 width=378) (actual time=0.017..10.948 rows=100000 loops=1)
  ->  Hash  (cost=4982.68..4982.68 rows=10 width=4) (actual time=4.840..4.842 rows=10 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Limit  (cost=4972.83..4982.58 rows=10 width=4) (actual time=4.815..4.825 rows=10 loops=1)
              ->  Bitmap Heap Scan on m m_1  (cost=108.81..5706.82 rows=5743 width=4) (actual time=1.249..4.670 rows=5000 loops=1)
                    Recheck Cond: (issue_dt >= (now() - '60 days'::interval))
                    Heap Blocks: exact=3084
                    ->  Bitmap Index Scan on ixm_issuedt  (cost=0.00..107.37 rows=5743 width=0) (actual time=0.759..0.759 rows=5872 loops=1)
                          Index Cond: (issue_dt >= (now() - '60 days'::interval))
Planning Time: 0.295 ms
Execution Time: 32.369 ms
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
			where issue_dt >= NOW() - ('60 days' :: interval)
		) a
		where no <= 510
	) b
	where no >= 500
)
/*
Hash Semi Join  (cost=6252.76..12779.58 rows=29 width=378) (actual time=23.462..45.433 rows=11 loops=1)
  Hash Cond: (m.member_no = a.member_no)
  ->  Seq Scan on m  (cost=0.00..6264.00 rows=100000 width=378) (actual time=0.018..10.030 rows=100000 loops=1)
  ->  Hash  (cost=6252.39..6252.39 rows=29 width=4) (actual time=19.660..19.662 rows=11 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Subquery Scan on a  (cost=6065.71..6252.39 rows=29 width=4) (actual time=13.271..19.646 rows=11 loops=1)
              Filter: ((a.no <= 510) AND (a.no >= 500))
              Rows Removed by Filter: 5861
              ->  WindowAgg  (cost=6065.71..6166.23 rows=5744 width=20) (actual time=12.563..18.722 rows=5872 loops=1)
                    ->  Sort  (cost=6065.71..6080.07 rows=5744 width=12) (actual time=12.547..13.574 rows=5872 loops=1)
                          Sort Key: m_1.issue_dt DESC
                          Sort Method: quicksort  Memory: 468kB
                          ->  Bitmap Heap Scan on m m_1  (cost=108.81..5707.06 rows=5744 width=12) (actual time=2.393..9.824 rows=5872 loops=1)
                                Recheck Cond: (issue_dt >= (now() - '60 days'::interval))
                                Heap Blocks: exact=3626
                                ->  Bitmap Index Scan on ixm_issuedt  (cost=0.00..107.38 rows=5744 width=0) (actual time=1.263..1.263 rows=5872 loops=1)
                                      Index Cond: (issue_dt >= (now() - '60 days'::interval))
Planning Time: 0.273 ms
Execution Time: 45.744 ms
*/


