/*
	전문가로 가는 지름길 1 / 개발자용
	제 2장 소스 스크립트 
	정원혁 2000.1
	for pgsql 2022.11	
*/


--1. 테이블 목록 보기
SELECT  *  FROM  information_schema."tables" t WHERE  table_type = 'BASE TABLE' and table_schema = 'public'
;

select table_name, table_catalog, table_schema, table_type    
FROM  information_schema."tables" t WHERE  table_type = 'BASE TABLE' and table_schema = 'public'
;

SELECT * FROM pg_catalog.pg_tables;


--2 버전, 접속 user 보기
SELECT version(), CURRENT_USER;


--3. select (DBeaver 특성)
SELECT * FROM public.orders o;	--limit 200 by default in DBeaver
SELECT * FROM public.orders o limit all;