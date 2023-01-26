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



--9. 당장 공부 안해도 된다. 필요할 때 찾아서 사용하면 충분하다.

--제약 보기
SELECT con.*
       FROM pg_catalog.pg_constraint con
            INNER JOIN pg_catalog.pg_class rel
                       ON rel.oid = con.conrelid
            INNER JOIN pg_catalog.pg_namespace nsp
                       ON nsp.oid = connamespace
       WHERE nsp.nspname = 'public'	--schema name
             AND rel.relname = 'orders'		--tablename
;

/*
 * 
-- 컬럼/ 제약
-- 너무 장황하다. 다른 방법 없을까? 
-- 프로시저는?
select
	pgc.contype as constraint_type,
	ccu.table_schema as table_schema,
	kcu.table_name as table_name,
	case when (pgc.contype = 'f') then kcu.column_name else ccu.column_name end as column_name, 
	case when (pgc.contype = 'f') then ccu.table_name else (null) end as reference_table,
	case when (pgc.contype = 'f') then ccu.column_name else (null) end as reference_col,
	case when (pgc.contype = 'p') then 'yes' else 'no' end as auto_inc,
	case when (pgc.contype = 'p') then 'no' else 'yes' end as is_nullable,
	'integer' as data_type,
	'0' as numeric_scale,
	'32' as numeric_precision
from
	pg_constraint as pgc
	join pg_namespace nsp on nsp.oid = pgc.connamespace
	join pg_class cls on pgc.conrelid = cls.oid
	join information_schema.key_column_usage kcu on kcu.constraint_name = pgc.conname
	left join information_schema.constraint_column_usage ccu on pgc.conname = ccu.constraint_name 
	and nsp.nspname = ccu.constraint_schema
where ccu.table_schema = 'public'
	AND kcu.table_name = 'orders'

union all
 
select 
	null as constraint_type ,
	table_schema,
	table_name,
	column_name, 
	null as refrence_table, 
	null as refrence_col, 
	'no' as auto_inc,
	is_nullable,
	data_type,
	numeric_scale,
	numeric_precision
from information_schema.columns cols 
where 
	table_schema = 'public'
	and concat(table_name, column_name) not in(
	    select concat(kcu.table_name, kcu.column_name)
	    from
	    pg_constraint as pgc
	    join pg_namespace nsp on nsp.oid = pgc.connamespace
	    join pg_class cls on pgc.conrelid = cls.oid
	    join information_schema.key_column_usage kcu on kcu.constraint_name = pgc.conname
	    left join information_schema.constraint_column_usage ccu on pgc.conname = ccu.constraint_name 
	    and nsp.nspname = ccu.constraint_schema
	)
	AND table_name = 'orders'
order by table_name asc, column_name;
 */


--컬럼 목록
select 
	null as constraint_type ,
	table_schema,
	table_name,
	column_name, 
	null as refrence_table, 
	null as refrence_col, 
	'no' as auto_inc,
	is_nullable,
	data_type,
	numeric_scale,
	numeric_precision
from information_schema.columns cols 
where 
	table_schema = 'public'
	and concat(table_name, column_name) not in(
		select concat(kcu.table_name, kcu.column_name)
		from
		pg_constraint as pgc
		join pg_namespace nsp on nsp.oid = pgc.connamespace
		join pg_class cls on pgc.conrelid = cls.oid
		join information_schema.key_column_usage kcu on kcu.constraint_name = pgc.conname
		left join information_schema.constraint_column_usage ccu on pgc.conname = ccu.constraint_name 
		and nsp.nspname = ccu.constraint_schema
	)
	AND table_name = 'orders'
;


--제약
SELECT conrelid::regclass AS table_from
     , conname
     , pg_get_constraintdef(oid)
FROM   pg_constraint
WHERE  contype IN ('f', 'p ')		--FK, PK
	AND    connamespace = 'public'::regnamespace 	--스키마
ORDER  BY conrelid::regclass::text, contype DESC;

select * 
from pg_constraint
where connamespace = 'public'::regnamespace 	--스키마
;

