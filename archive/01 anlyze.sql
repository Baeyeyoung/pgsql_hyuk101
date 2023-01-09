drop table t1;
drop table t2;
drop table t3;

create table t1 (c1 integer, dummy char(1000));
create table t2 (c1 integer, dummy char(1000));
create table t3 (c1 integer, dummy char(1000));

insert into t1 select generate_series(1,10), 'dummy';
insert into t2 select generate_series(1,1000), 'dummy';
insert into t3 select generate_series(1,10000), 'dummy';

create index t2_ix on t2 (c1);
create index t3_ix on t2 (c1);

analyze t1;
analyze t2;
analyze t3;


--NL join
set enable_mergejoin=off;
set enable_hashjoin=off;

explain (costs false)
select *
from t1 a, t2 b, t3 c
where a.c1 = b.c1 and b.c1 = c.c1;
/*
"Nested Loop"
"  Join Filter: (a.c1 = b.c1)"
"  ->  Nested Loop"
"        Join Filter: (a.c1 = c.c1)"
"        ->  Seq Scan on t3 c"
"        ->  Materialize"
"              ->  Seq Scan on t1 a"
"  ->  Index Scan using t3_ix on t2 b"
"        Index Cond: (c1 = c.c1)"
*/

--ansi join
explain (costs false)
select *
from t1 a
	join t2 b 	on a.c1 = b.c1
	join t3 c	on b.c1 = c.c1;
/*
"Nested Loop"
"  Join Filter: (a.c1 = b.c1)"
"  ->  Nested Loop"
"        Join Filter: (a.c1 = c.c1)"
"        ->  Seq Scan on t3 c"
"        ->  Materialize"
"              ->  Seq Scan on t1 a"
"  ->  Index Scan using t3_ix on t2 b"
"        Index Cond: (c1 = c.c1)"
*/

--테이블 순서 바꾸어보면: 동일하다. cbo 제대로 동작한다.
explain (costs false)
select *
from t3 c
	join t2 b 	on c.c1 = b.c1
	join t1 a	on b.c1 = a.c1;
/*
"Nested Loop"
"  ->  Nested Loop"
"        Join Filter: (c.c1 = a.c1)"
"        ->  Seq Scan on t3 c"
"        ->  Materialize"
"              ->  Seq Scan on t1 a"
"  ->  Index Scan using t3_ix on t2 b"
"        Index Cond: (c1 = c.c1)"

*/
