--ALTER TABLE ... ALTER COLUMN ... SET STATISTICS 400;  -- calibrate number--통계 자동 생성
drop table if exists m;
select * into m from mBase;

create index ix on m (lastname);

explain analyze
select * from m where lastname = 'a'
/*
Index Scan using ix on m  (cost=0.29..4.30 rows=1 width=378) (actual time=0.035..0.036 rows=0 loops=1)
  Index Cond: (lastname = 'a'::bpchar)
Planning Time: 0.169 ms
Execution Time: 0.062 ms
*/

SELECT relpages, reltuples FROM pg_class WHERE relname = 'm';

SELECT * FROM pg_class WHERE oid = 'public.m'::regclass;

SELECT histogram_bounds FROM pg_stats
WHERE tablename='m' AND attname='lastname';
/*
null
*/

analyze m;
update m set lastname = 'a' where member_no <= 8000;

explain analyze
select * from m where lastname = 'a';
/*
Bitmap Heap Scan on m  (cost=60.46..1060.36 rows=4152 width=378) (actual time=1.688..7.703 rows=8000 loops=1)
  Recheck Cond: (lastname = 'a'::bpchar)
  Heap Blocks: exact=422
  ->  Bitmap Index Scan on ix  (cost=0.00..59.42 rows=4152 width=0) (actual time=1.458..1.460 rows=11000 loops=1)
        Index Cond: (lastname = 'a'::bpchar)
Planning Time: 0.315 ms
Execution Time: 8.743 ms
*/
analyze m;

explain analyze
select * from m where lastname = 'a';
/*
Seq Scan on m  (cost=0.00..1073.00 rows=8000 width=378) (actual time=0.055..7.265 rows=8000 loops=1)
  Filter: (lastname = 'a'::bpchar)
  Rows Removed by Filter: 2000
Planning Time: 0.509 ms
Execution Time: 8.216 ms
*/

