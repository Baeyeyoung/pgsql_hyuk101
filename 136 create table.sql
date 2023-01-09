--1. 기존 테이블을 바탕으로 새 테이블 생성
select * 
into tmp1 
from orders o ;

select * from tmp1;

--2. 새로운 테이블 생성
create table 사람 (
	번호	int, 
 	이름	varchar(50)	not null,
 	폰번호	varchar(20)	null
);

alter table 사람 
	add 이메일	varchar(30)	null
;

select * from 사람;
insert into 사람 values (1, '이순신', '01012345678', 'me@abc.kr');
select * from 사람;
insert into 사람 values (1, '이순신', '01012345678', 'me@abc.kr');
select * from 사람;

drop table 사람;


--3. 새로운 테이블 생성. 제약과 함께
create table 사람 (
	번호	int	primary key, 
 	이름	varchar(50)	not null,
 	폰번호	varchar(20)	null,
	이메일	varchar(30)	unique null
);

insert into 사람 values (1, '이순신', '01012345678', 'me@abc.kr');
insert into 사람 values (1, '이순신', '01012345678', 'me@abc.kr');	--실패
insert into 사람 values (2, '이순신', '01012345678', 'me@abc.kr');	--실패
insert into 사람 values (2, '이순신', '01012345678', null);
insert into 사람 values (3, '이순신', '01012345678', null);		--성공
select * from 사람;

