drop table if exists m;

CREATE TABLE m(
	member_no int NOT NULL,
	lastname char(30) NOT NULL default 'last',
	firstname char(30) NOT NULL default 'first',
	issue_dt TIMESTAMP WITH TIME ZONE NULL DEFAULT NOW(),
	dummy char(300) default 'dummy'
);

drop table if exists mBase;
drop table if exists mcx;
drop table if exists mnc;
drop table if exists mCovered;

INSERT INTO m (member_no, issue_dt)
	select ROW_NUMBER() over (), NOW() - ('1 days' :: interval* random() * 1000)
	from generate_series(1, 10000) AS x;
select * from m;

select * into mBase from m; 
select * into mCX from m; 
create index ix_cx on mCX (member_no); 
cluster mCX using ix_cx;

select * into mNC from m; 
create index ix_nc on mNC (member_no);

select * into mCovered from m; 
create index ix_cv on mCovered (member_no, lastname);
--테스트 테이블 생성 끝
--필요하면 몇 번이고 반복하여 테이블을 삭제하고 다시 만든다.

-----------------------------------------------
--1 하나의 값 선택	
-----------------------------------------------
explain (analyze, costs, buffers)
select * from m where member_no = 30;

explain (analyze, costs, buffers)
select * from mCX where member_no = 30;

explain (analyze, costs, buffers)
select * from mNC where member_no = 30;

/*
Seq Scan on m  (cost=0.00..652.00 rows=1 width=378) (actual time=0.026..2.039 rows=1 loops=1)
  Filter: (member_no = 30)
  Rows Removed by Filter: 9999
  Buffers: shared hit=527
Planning Time: 0.068 ms
Execution Time: 2.053 ms


Index Scan using cx on mcx  (cost=0.29..8.30 rows=1 width=378) (actual time=0.021..0.022 rows=1 loops=1)
  Index Cond: (member_no = 30)
  Buffers: shared hit=3
Planning Time: 0.103 ms
Execution Time: 0.040 ms

Seq Scan on mnc  (cost=0.00..652.00 rows=1 width=378) (actual time=0.024..2.036 rows=1 loops=1)
  Filter: (member_no = 30)
  Rows Removed by Filter: 9999
  Buffers: shared hit=527
Planning Time: 0.080 ms
Execution Time: 2.060 ms
*/





-----------------------------------------------
--2.1 select 범위 
-----------------------------------------------
explain analyze
select * from m where member_no <= 30;

explain analyze
select * from mCX where member_no <= 30;

explain analyze
select * from mNC where member_no <= 30;

/*
Seq Scan on m  (cost=0.00..652.00 rows=30 width=378) (actual time=0.019..2.227 rows=30 loops=1)
  Filter: (member_no <= 30)
  Rows Removed by Filter: 9970
Planning Time: 0.139 ms
Execution Time: 2.246 ms

Index Scan using cx on mcx  (cost=0.29..9.81 rows=30 width=378) (actual time=0.017..0.029 rows=30 loops=1)
  Index Cond: (member_no <= 30)
Planning Time: 1.271 ms
Execution Time: 0.090 ms

Seq Scan on mnc  (cost=0.00..652.00 rows=30 width=378) (actual time=0.022..3.609 rows=30 loops=1)
  Filter: (member_no <= 30)
  Rows Removed by Filter: 9970
Planning Time: 0.081 ms
Execution Time: 3.628 ms
*/

-----------------------------------------------
--2.2 select 범위 더 큰
-----------------------------------------------
explain analyze
select * from m where member_no <= 3000;

explain analyze
select * from mCX where member_no <= 3000;

explain analyze
select * from mNC where member_no <= 3000;

set session enable_seqscan = off;
explain analyze
select * from mNC where member_no <= 3000;
set session enable_seqscan = on;

-- enable_indexscan 
-- enable_indexonlyscan 
-- enable_seqscan 

/*
Seq Scan on m  (cost=0.00..652.00 rows=3000 width=378) (actual time=0.018..1.922 rows=3000 loops=1)
  Filter: (member_no <= 3000)
  Rows Removed by Filter: 7000
Planning Time: 0.882 ms
Execution Time: 2.027 ms

Index Scan using cx on mcx  (cost=0.29..250.78 rows=3000 width=378) (actual time=0.071..3.080 rows=3000 loops=1)
  Index Cond: (member_no <= 3000)
Planning Time: 0.127 ms
Execution Time: 3.336 ms

Index Scan using ix_nc on mnc  (cost=0.29..250.78 rows=3000 width=378) (actual time=0.020..2.288 rows=3000 loops=1)
  Index Cond: (member_no <= 3000)
Planning Time: 0.096 ms
Execution Time: 2.440 ms
*/



explain analyze
select * from mNC where member_no <= 7779;

explain analyze
select * from mNC where member_no <= 7780;
/*
Index Scan using ix_nc on mnc  (cost=0.29..645.42 rows=7779 width=378) (actual time=0.019..2.257 rows=7779 loops=1)
  Index Cond: (member_no <= 7779)
Planning Time: 0.079 ms
Execution Time: 2.551 ms

Seq Scan on mnc  (cost=0.00..652.00 rows=7780 width=378) (actual time=0.013..2.418 rows=7780 loops=1)
  Filter: (member_no <= 7780)
  Rows Removed by Filter: 2220
Planning Time: 0.084 ms
Execution Time: 2.632 ms
*/


explain analyze
select * from mCX where member_no <= 1;

explain analyze
select * from mCX where member_no <= 9999;

explain analyze
select * from mCX;

/*
Index Scan using ix_cx on mcx  (cost=0.29..8.30 rows=1 width=378) (actual time=0.008..0.009 rows=1 loops=1)
  Index Cond: (member_no <= 1)
Planning Time: 2.840 ms
Execution Time: 0.030 ms

Seq Scan on mcx  (cost=0.00..652.00 rows=9999 width=378) (actual time=0.017..4.446 rows=9999 loops=1)
  Filter: (member_no <= 9999)
  Rows Removed by Filter: 1
Planning Time: 0.203 ms
Execution Time: 4.810 ms

Seq Scan on mcx  (cost=0.00..627.00 rows=10000 width=378) (actual time=0.013..1.170 rows=10000 loops=1)
Planning Time: 0.080 ms
Execution Time: 1.498 ms
*/


-----------------------------------------------
--3 insert
-----------------------------------------------
explain analyze
INSERT INTO m (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no = 3;
	
explain analyze
INSERT INTO mNC (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no = 3;
	
explain analyze
INSERT INTO mCX (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no = 3;
/*
Insert on m  (cost=4.67..153.96 rows=50 width=1464) (actual time=5.067..5.069 rows=0 loops=1)
  ->  Bitmap Heap Scan on mnc  (cost=4.67..153.96 rows=50 width=1464) (actual time=0.250..0.258 rows=1 loops=1)
        Recheck Cond: (member_no = 3)
        Heap Blocks: exact=1
        ->  Bitmap Index Scan on ix_nc  (cost=0.00..4.66 rows=50 width=0) (actual time=0.104..0.104 rows=1 loops=1)
              Index Cond: (member_no = 3)
Planning Time: 4.120 ms
Execution Time: 5.173 ms


Insert on mnc  (cost=4.67..153.84 rows=50 width=292) (actual time=0.745..0.746 rows=0 loops=1)
  ->  Bitmap Heap Scan on mnc mnc_1  (cost=4.67..153.84 rows=50 width=292) (actual time=0.061..0.066 rows=1 loops=1)
        Recheck Cond: (member_no = 3)
        Heap Blocks: exact=1
        ->  Bitmap Index Scan on ix_nc  (cost=0.00..4.66 rows=50 width=0) (actual time=0.039..0.040 rows=1 loops=1)
              Index Cond: (member_no = 3)
Planning Time: 0.359 ms
Execution Time: 0.958 ms


Insert on mcx  (cost=0.29..8.30 rows=1 width=106) (actual time=5.357..5.358 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..8.30 rows=1 width=106) (actual time=0.037..0.047 rows=1 loops=1)
        Index Cond: (member_no = 3)
Planning Time: 3.269 ms
Execution Time: 5.624 ms

*/


-----------------------------------------------
--3.2 insert more
-----------------------------------------------
explain analyze
INSERT INTO m (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no >= 9500;
	
explain analyze
INSERT INTO mNC (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no >= 9500;
	
explain analyze
INSERT INTO mCX (member_no, lastname, firstname, issue_dt)
	SELECT member_no, lastname, firstname, issue_dt FROM mBase WHERE member_no >= 9500;	
/*
Insert on m  (cost=0.29..48.30 rows=501 width=1278) (actual time=9.084..9.085 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..48.30 rows=501 width=1278) (actual time=0.136..1.474 rows=501 loops=1)
        Index Cond: (member_no >= 9500)
Planning Time: 0.202 ms
Execution Time: 9.120 ms

Insert on mnc  (cost=0.29..47.05 rows=501 width=106) (actual time=15.714..15.716 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc mnc_1  (cost=0.29..47.05 rows=501 width=106) (actual time=0.060..0.894 rows=501 loops=1)
        Index Cond: (member_no >= 9500)
Planning Time: 0.370 ms
Execution Time: 15.834 ms

Insert on mcx  (cost=0.29..47.05 rows=501 width=106) (actual time=5.723..5.725 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..47.05 rows=501 width=106) (actual time=0.078..0.794 rows=501 loops=1)
        Index Cond: (member_no >= 9500)
Planning Time: 0.402 ms
Execution Time: 5.826 ms
*/

-----------------------------------------------
--4 update
-----------------------------------------------
explain analyze
update m set issue_dt =now() where member_no = 3;

explain analyze
update mNC set issue_dt =now() where member_no = 3;

explain analyze
update mCX set issue_dt =now() where member_no = 3;
/*
Update on m  (cost=0.00..652.00 rows=1 width=384) (actual time=13.677..13.680 rows=0 loops=1)
  ->  Seq Scan on m  (cost=0.00..652.00 rows=1 width=384) (actual time=0.107..6.409 rows=1 loops=1)
        Filter: (member_no = 3)
        Rows Removed by Filter: 9999
Planning Time: 4.934 ms
Execution Time: 21.125 ms

Update on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=5.032..5.033 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=0.505..0.510 rows=1 loops=1)
        Index Cond: (member_no = 3)
Planning Time: 4.594 ms
Execution Time: 5.243 ms

Update on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=6.484..6.486 rows=0 loops=1)
  ->  Index Scan using ix_cx on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=0.307..0.313 rows=1 loops=1)
        Index Cond: (member_no = 3)
Planning Time: 4.905 ms
Execution Time: 6.665 ms
*/


explain analyze
update m set member_no = member_no + 10000 where member_no = 3;

explain analyze
update mNC set member_no = member_no + 10000 where member_no = 3;

explain analyze
update mCX set member_no = member_no + 10000 where member_no = 3;

/*
Update on m  (cost=0.00..652.00 rows=1 width=384) (actual time=12.095..12.097 rows=0 loops=1)
  ->  Seq Scan on m  (cost=0.00..652.00 rows=1 width=384) (actual time=0.051..8.130 rows=1 loops=1)
        Filter: (member_no = 3)
        Rows Removed by Filter: 9999
Planning Time: 2.597 ms
Execution Time: 12.381 ms

Update on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=5.820..5.823 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=0.255..0.262 rows=1 loops=1)
        Index Cond: (member_no = 3)
Planning Time: 4.660 ms
Execution Time: 5.998 ms

Update on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=7.401..7.404 rows=0 loops=1)
  ->  Index Scan using ix_cx on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=0.418..0.429 rows=1 loops=1)
        Index Cond: (member_no = 3)
Planning Time: 6.896 ms
Execution Time: 7.693 ms
*/


explain analyze
update m set issue_dt =now() where member_no % 50 = 0;

explain analyze
update mNC set issue_dt =now() where member_no % 50 = 0;

explain analyze
update mCX set issue_dt =now() where member_no % 50 = 0;
/*
Update on m  (cost=0.00..677.13 rows=50 width=384) (actual time=9.436..9.438 rows=0 loops=1)
  ->  Seq Scan on m  (cost=0.00..677.13 rows=50 width=384) (actual time=0.107..5.747 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 0.259 ms
Execution Time: 9.499 ms

Update on mnc  (cost=0.00..677.13 rows=50 width=384) (actual time=29.666..29.668 rows=0 loops=1)
  ->  Seq Scan on mnc  (cost=0.00..677.13 rows=50 width=384) (actual time=0.183..16.212 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 0.302 ms
Execution Time: 29.765 ms

Update on mcx  (cost=0.00..677.13 rows=50 width=384) (actual time=23.342..23.344 rows=0 loops=1)
  ->  Seq Scan on mcx  (cost=0.00..677.13 rows=50 width=384) (actual time=0.225..9.842 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 0.356 ms
Execution Time: 23.443 ms
*/

explain analyze
update m set member_no = member_no + 3 where member_no = 3000;

explain analyze
update mNC set member_no = member_no + 3 where member_no = 3000;

explain analyze
update mCX set member_no = member_no + 3 where member_no = 3000;
/*
Update on m  (cost=0.00..664.38 rows=1 width=384) (actual time=13.403..13.406 rows=0 loops=1)
  ->  Seq Scan on m  (cost=0.00..664.38 rows=1 width=384) (actual time=13.258..13.341 rows=1 loops=1)
        Filter: (member_no = 3000)
        Rows Removed by Filter: 9999
Planning Time: 0.250 ms
Execution Time: 13.480 ms

Update on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=0.302..0.306 rows=0 loops=1)
  ->  Index Scan using ix_nc on mnc  (cost=0.29..8.30 rows=1 width=384) (actual time=0.170..0.178 rows=1 loops=1)
        Index Cond: (member_no = 3000)
Planning Time: 0.611 ms
Execution Time: 0.447 ms

Update on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=0.169..0.171 rows=0 loops=1)
  ->  Index Scan using ix_cx on mcx  (cost=0.29..8.30 rows=1 width=384) (actual time=0.099..0.104 rows=1 loops=1)
        Index Cond: (member_no = 3000)
Planning Time: 0.288 ms
Execution Time: 0.248 ms
*/

explain analyze
update m set member_no = member_no + 10000 where member_no % 50 = 0;
explain analyze
update mNC set member_no = member_no + 10000 where member_no % 50 = 0;
explain analyze
update mCX set member_no = member_no + 10000 where member_no % 50 = 0;

explain analyze
update m set member_no = member_no + 300 where member_no % 50 = 0;
explain analyze
update mNC set member_no = member_no + 300 where member_no % 50 = 0;
explain analyze
update mCX set member_no = member_no + 300 where member_no % 50 = 0;

-----------------------------------------------
--5 delete
-----------------------------------------------
delete m where member_no = 3
delete mNC where member_no = 3
delete mCX where member_no = 3

delete m where member_no % 50 = 0
delete mNC where member_no % 50 = 0
delete mCX where member_no % 50 = 0


-----------------------------------------------
--6 covered
-----------------------------------------------
explain analyze
select lastname from m where member_no = 30;

explain analyze
select lastname from mCX where member_no = 30;

explain analyze
select lastname from mNC where member_no = 30;

explain analyze
select lastname from mCovered where member_no = 30;
/*
Seq Scan on m  (cost=0.00..559.94 rows=13 width=124) (actual time=0.034..5.268 rows=1 loops=1)
  Filter: (member_no = 30)
  Rows Removed by Filter: 9999
Planning Time: 0.081 ms
Execution Time: 5.295 ms

Bitmap Heap Scan on mcx  (cost=4.67..153.84 rows=50 width=124) (actual time=0.033..0.035 rows=1 loops=1)
  Recheck Cond: (member_no = 30)
  Heap Blocks: exact=1
  ->  Bitmap Index Scan on ix_cx  (cost=0.00..4.66 rows=50 width=0) (actual time=0.021..0.022 rows=1 loops=1)
        Index Cond: (member_no = 30)
Planning Time: 0.193 ms
Execution Time: 0.115 ms

Bitmap Heap Scan on mnc  (cost=4.67..153.84 rows=50 width=124) (actual time=0.038..0.040 rows=1 loops=1)
  Recheck Cond: (member_no = 30)
  Heap Blocks: exact=1
  ->  Bitmap Index Scan on ix_nc  (cost=0.00..4.66 rows=50 width=0) (actual time=0.024..0.024 rows=1 loops=1)
        Index Cond: (member_no = 30)
Planning Time: 0.226 ms
Execution Time: 0.133 ms

Bitmap Heap Scan on mcovered  (cost=4.67..153.84 rows=50 width=124) (actual time=0.120..0.122 rows=1 loops=1)
  Recheck Cond: (member_no = 30)
  Heap Blocks: exact=1
  ->  Bitmap Index Scan on ix_cv  (cost=0.00..4.66 rows=50 width=0) (actual time=0.100..0.101 rows=1 loops=1)
        Index Cond: (member_no = 30)
Planning Time: 6.201 ms
Execution Time: 0.213 ms
*/

explain analyze
select lastname from mCX where member_no < 3000;

explain analyze
select lastname from mCovered where member_no < 3000;
/*
Index Scan using ix_cx on mcx  (cost=0.29..250.77 rows=2999 width=31) (actual time=0.063..5.256 rows=2999 loops=1)
  Index Cond: (member_no < 3000)
Planning Time: 4.213 ms
Execution Time: 5.614 ms

Index Only Scan using ix_cv on mcovered  (cost=0.29..144.77 rows=2999 width=31) (actual time=1.508..2.878 rows=2999 loops=1)
  Index Cond: (member_no < 3000)
  Heap Fetches: 0
Planning Time: 3.459 ms
Execution Time: 3.106 ms
*/

explain analyze
select lastname from mCX where member_no < 8000;

explain analyze
select lastname from mCovered where member_no < 8000;
/*
Seq Scan on mcx  (cost=0.00..652.00 rows=7999 width=31) (actual time=0.057..9.965 rows=7999 loops=1)
  Filter: (member_no < 8000)
  Rows Removed by Filter: 2001
Planning Time: 0.212 ms
Execution Time: 10.863 ms

Index Only Scan using ix_cv on mcovered  (cost=0.29..380.27 rows=7999 width=31) (actual time=0.079..7.678 rows=7999 loops=1)
  Index Cond: (member_no < 8000)
  Heap Fetches: 0
Planning Time: 0.295 ms
Execution Time: 8.929 ms
*/

explain analyze
select lastname from mCX ;

explain analyze
select lastname from mCovered ;
/*
Seq Scan on mcx  (cost=0.00..627.00 rows=10000 width=31) (actual time=0.074..4.510 rows=10000 loops=1)
Planning Time: 0.240 ms
Execution Time: 5.614 ms

Index Only Scan using ix_cv on mcovered  (cost=0.29..446.29 rows=10000 width=31) (actual time=0.034..2.335 rows=10000 loops=1)
  Heap Fetches: 0
Planning Time: 0.127 ms
Execution Time: 2.911 ms
*/



--index: cx	member_no
--index: covered 	member_no, lastname

explain analyze
select member_no, lastname from mCX where lastname <'k';

explain analyze
select member_no, lastname from mCovered where lastname <'k'	;
/*
Seq Scan on mcx  (cost=0.00..652.00 rows=1 width=35) (actual time=7.048..7.049 rows=0 loops=1)
  Filter: (lastname < 'k'::bpchar)
  Rows Removed by Filter: 10000
Planning Time: 0.228 ms
Execution Time: 7.078 ms

Index Only Scan using ix_cv on mcovered  (cost=0.29..371.30 rows=1 width=35) (actual time=4.642..4.643 rows=0 loops=1)
  Index Cond: (lastname < 'k'::bpchar)
  Heap Fetches: 0
Planning Time: 0.328 ms
Execution Time: 4.669 ms
*/



explain analyze
select count(*) from mcx;

explain analyze
select count(*) from mCovered;
/*
Aggregate  (cost=295.29..295.30 rows=1 width=8) (actual time=7.050..7.053 rows=1 loops=1)
  ->  Index Only Scan using ix_cx on mcx  (cost=0.29..270.29 rows=10000 width=0) (actual time=1.988..5.546 rows=10000 loops=1)
        Heap Fetches: 0
Planning Time: 0.274 ms
Execution Time: 7.273 ms

Aggregate  (cost=471.29..471.30 rows=1 width=8) (actual time=7.902..7.903 rows=1 loops=1)
  ->  Index Only Scan using ix_cv on mcovered  (cost=0.29..446.29 rows=10000 width=0) (actual time=0.048..5.087 rows=10000 loops=1)
        Heap Fetches: 0
Planning Time: 0.480 ms
Execution Time: 8.002 ms
*/
explain analyze
select count(lastname) from mCovered;

explain analyze
select count(member_no) from mCovered;

explain analyze
select count(firstname) from mCovered;

explain analyze
select count(issue_dt) from mCovered;
/*
Aggregate  (cost=471.29..471.30 rows=1 width=8) (actual time=8.210..8.212 rows=1 loops=1)
  ->  Index Only Scan using ix_cv on mcovered  (cost=0.29..446.29 rows=10000 width=31) (actual time=0.049..5.245 rows=10000 loops=1)
        Heap Fetches: 0
Planning Time: 0.394 ms
Execution Time: 8.327 ms

Aggregate  (cost=471.29..471.30 rows=1 width=8) (actual time=2.793..2.794 rows=1 loops=1)
  ->  Index Only Scan using ix_cv on mcovered  (cost=0.29..446.29 rows=10000 width=4) (actual time=0.020..1.725 rows=10000 loops=1)
        Heap Fetches: 0
Planning Time: 0.132 ms
Execution Time: 2.833 ms

Aggregate  (cost=652.00..652.01 rows=1 width=8) (actual time=9.234..9.235 rows=1 loops=1)
  ->  Seq Scan on mcovered  (cost=0.00..627.00 rows=10000 width=31) (actual time=0.049..3.401 rows=10000 loops=1)
Planning Time: 0.336 ms
Execution Time: 9.300 ms

Aggregate  (cost=652.00..652.01 rows=1 width=8) (actual time=10.123..10.125 rows=1 loops=1)
  ->  Seq Scan on mcovered  (cost=0.00..627.00 rows=10000 width=8) (actual time=0.054..3.905 rows=10000 loops=1)
Planning Time: 0.308 ms
Execution Time: 10.197 ms
*/


-----------------------------------------------
--7 split test
-----------------------------------------------
explain analyze
INSERT INTO m 
	SELECT * FROM mBase WHERE member_no % 50 = 0
;
explain analyze
INSERT INTO mNC
	SELECT * FROM mBase WHERE member_no % 50 = 0 
;
explain analyze
INSERT INTO mCX
	SELECT * FROM mBase WHERE member_no % 50 = 0 
/*
Insert on m  (cost=0.00..677.00 rows=50 width=378) (actual time=9.939..9.940 rows=0 loops=1)
  ->  Seq Scan on mbase  (cost=0.00..677.00 rows=50 width=378) (actual time=0.065..3.729 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 1.720 ms
Execution Time: 9.989 ms

Insert on mnc  (cost=0.00..677.00 rows=50 width=378) (actual time=20.792..20.794 rows=0 loops=1)
  ->  Seq Scan on mbase  (cost=0.00..677.00 rows=50 width=378) (actual time=0.140..5.228 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 0.307 ms
Execution Time: 21.134 ms

Insert on mcx  (cost=0.00..677.00 rows=50 width=378) (actual time=29.148..29.150 rows=0 loops=1)
  ->  Seq Scan on mbase  (cost=0.00..677.00 rows=50 width=378) (actual time=0.106..8.650 rows=200 loops=1)
        Filter: ((member_no % 50) = 0)
        Rows Removed by Filter: 9800
Planning Time: 0.359 ms
Execution Time: 29.383 ms
*/