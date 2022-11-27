/*
 * csv 파일을 불러와 테이블에 데이터를 넣는다.
 * 수강생 csv, 전처리가 꼭 필요하다. 
 * 테이블 만들어 두고 거기다 넣으려면 죽도록 고생한다
 * csv를 기반으로 테이블을 새로 생성하고 생성된 데이터를 제대로 된 테이블에 넣는 것이 더 바람직하다 
 */

--1.1 csv 전처리, 1번행에 헤더 제대로 만들기
--1.2 csv 읽어 새 테이블 만들기

--2. 만들어진 테이블  
--CREATE TABLE public.수강생 (
--	이름 varchar(50) NULL,
--	"컴퓨터 왜" varchar(50) NULL,
--	전공 varchar(50) NULL,
--	vlookup int4 NULL,
--	excel int4 NULL,
--	메일 varchar(50) NULL,
--	전화 varchar(50) NULL,
--	소감 varchar(256) NULL
--);


--3. 제대로된 테이블 만들기
drop table if exists members; 

CREATE TABLE public.members (
	번호 smallint NOT NULL GENERATED ALWAYS AS identity primary key,
	이름	varchar(50)	null,
	email	varchar(50),
	phone	varchar(50),
	컴퓨터왜	varchar(100),
	vlookup	int2,
	excel	int2,
	comment varchar(500)
);

--4. 제대로 된 테이블에 데이터 넣기
--컬럼 이름 전부 가져올 때는 Ctrl + Space를 이용한다 
--https://github.com/dbeaver/dbeaver/issues/10995

insert into members (이름, email, phone, 컴퓨터왜, vlookup, excel, "comment")
select 이름, 메일, 전화, "컴퓨터 왜" , vlookup , excel , 소감  from 수강생;

select * from members; 

drop table 수강생;
drop table members;