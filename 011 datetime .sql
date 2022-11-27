create schema if not exists study;
set search_path to study; 

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

--declare @판매번호 int
begin
	insert 판매 values (getdate(), 1, 100000, 10)
	select  scope_identity()
--	select @판매번호 = scope_identity()
-- 	insert 판매상세 values (@판매번호(), 1, 1, 9)
-- 	insert 판매상세 values (@판매번호(), 2, 20, 1)

	insert 판매상세 values (3, 1, 1, 9)
	insert 판매상세 values (3, 2, 20, 1)
commit



---세션 2
--declare @판매번호 int
begin tran
	insert 판매 values (getdate(), 2, 100000, 10)
	select  scope_identity()	--4

	insert 판매상세 values (4, 11, 11, 9)
	insert 판매상세 values (4, 12, 200, 1)
commit

select * from 판매상세
select * from 판매