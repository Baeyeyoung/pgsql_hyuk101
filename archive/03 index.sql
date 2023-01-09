drop table t1;

create table t1 (c1 integer, dummy char(1000));

insert into t1 select generate_series(1,50000), 'dummy';
create index t1_ix on t1 (c1);

analyze t1;


explain (costs false, analyze, buffers)
select *
from t1
where c1 between 1 and 4000;
-- "Index Scan using t1_ix on t1 (actual time=0.015..1.213 rows=4000 loops=1)"
-- "  Index Cond: ((c1 >= 1) AND (c1 <= 4000))"
-- "  Buffers: shared hit=574 read=10"
-- "Planning:"
-- "  Buffers: shared hit=20"
-- "Planning Time: 1.798 ms"
-- "Execution Time: 1.407 ms"


explain (costs false, analyze, buffers)
select *
from t1
where c1 between 1 and 40;
-- "Index Scan using t1_ix on t1 (actual time=0.008..0.021 rows=40 loops=1)"
-- "  Index Cond: ((c1 >= 1) AND (c1 <= 40))"
-- "  Buffers: shared hit=8"
-- "Planning:"
-- "  Buffers: shared hit=6"
-- "Planning Time: 0.172 ms"
-- "Execution Time: 0.034 ms"


explain (costs false, analyze, buffers)
select *
from t1
-- "Seq Scan on t1 (actual time=0.016..9.503 rows=50000 loops=1)"
-- "  Buffers: shared hit=7143"
-- "Planning Time: 0.082 ms"
-- "Execution Time: 11.674 ms"


explain analyze 
select *
from t1
-- "Seq Scan on t1  (cost=0.00..7643.00 rows=50000 width=1008) (actual time=0.016..9.234 rows=50000 loops=1)"
-- "Planning Time: 0.063 ms"
-- "Execution Time: 10.869 ms"

