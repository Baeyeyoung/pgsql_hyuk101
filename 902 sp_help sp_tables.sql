/*
	테이블, 컬럼 정보 얻기. 명세서 생성
	for pgsql 정원혁 2022.10
*/
create or replace view vTables
as
select * from information_schema.tables
where table_type = 'BASE TABLE'
	and table_schema = 'public'
--order by table_name
;

select * from vTables;

create or replace view vIndex
as
SELECT tablename, indexname, indexdef
FROM    pg_indexes
WHERE schemaname = 'public'
--ORDER BY tablename, indexname
;

create view vColumn 
as
SELECT 
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema.columns;


--테이블 명세서
select	t.schemaname, tablename, tableowner, coalesce("tablespace",'') tablespace, hasindexes	--, hastriggers
,	obj_description(oid) 
from pg_tables t 
	left join pg_class c on t.tablename::regclass::oid = c.oid
where t.schemaname in('public')	
order by tablename
;
--hastriggers는 오류



--전체 테이블, 컬럼 명과 속성 정보를 보여준다
--그래도 시트에 넣으면 컬럼 명세서로 사용가능하다.
select c.table_schema, table_name, column_name, ordinal_position ord
	, pgd.description
	, udt_name, character_maximum_length, is_nullable, column_default
	, is_identity
	, numeric_precision, numeric_scale
from information_schema."columns" c
	left join pg_catalog.pg_statio_all_tables as st on  c.table_schema = st.schemaname and	c.table_name   = st.relname
	left join pg_catalog.pg_description pgd on pgd.objoid = st.relid and pgd.objsubid = c.ordinal_position
where  table_schema in('public')
	--view 제외
	and not exists (
		select * from information_schema."views"
		where table_schema in('public')
			and table_name = c.table_name 
	)	
order by table_name, ordinal_position ;



/*
SELECT obj_description(oid), *
FROM pg_class
WHERE relkind = 'r'
;


select * from information_schema."tables" t ;

select *, t.tablename::regclass::oid oid
from pg_tables t
where schemaname in('public')	
order by t.tablename
;
 * 
 */


