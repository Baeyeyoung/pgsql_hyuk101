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
