create schema if not exists study;
set search_path to study; 
show search_path;

drop table if exists 판매;
drop table if exists 판매상세;
;

create table 판매 (
	판매번호 int not null generated always as identity primary key
,	판매일자 timestamptz
,	고객번호 int	--FK
,	금액	money
,	수량	smallint
)
;

create table 판매상세 (
	판매번호 int  
,	일련번호 smallint
,	constraint pk_판매상세 primary key (판매번호, 일련번호)
,	상품번호 int	--FK
,	수량	smallint
)
;

-- 연습, 공부
begin;
	insert into 판매 values (default, now(), 1, 100000, 10);
	insert into 판매 values (default, now(), 1, 100000, 10) returning 판매번호;
	insert into 판매 values (default, now(), 1, 100000, 10) returning *;
	select * from 판매;
rollback;




--실제
begin;
	WITH ins1 AS (
		insert into 판매 values (default, now(), 1, 100000, 10) returning 판매번호
	)
	insert into 판매상세 
	SELECT 판매번호, 1, 1, 9	FROM ins1
	union all
	SELECT 판매번호, 2, 20, 1	FROM ins1;

	select * from 판매;
	select * from 판매상세;
commit;



---세션 2
begin;
	WITH ins1 AS (
		insert into 판매 values (default, now(), 11, 100000, 10) returning 판매번호
	)
	insert into 판매상세 
	SELECT 판매번호, 11, 11, 90	FROM ins1
	union all
	SELECT 판매번호, 21, 200, 10	FROM ins1;

	select * from 판매;
	select * from 판매상세;
commit;

