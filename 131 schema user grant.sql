/*
	정원혁 스키마 생성, 관리, 삭제
*/
create schema if not exists study;

--show current schema
set search_path to study; 
SELECT session_user, current_database();
show search_path;


create user hyuk with encrypted password 'dufrhd!'; 
create schema authorization hyuk;

SELECT schema_name
FROM information_schema.schemata;

--login as hyuk and try to select * from orders
--failed. no permission.

grant all privileges on all tables in schema public to hyuk;

--now hyuk can select 
select * from public.orders o ;

create table hyuk.tmp1  (id int);

select * from tmp1;
--SQL Error [42P01]: ERROR: relation "tmp1" does not exist
select * from hyuk.tmp1;
--OK

drop schema hyuk;
--SQL Error [2BP01]: ERROR: cannot drop schema hyuk because other objects depend on it
--  Detail: table hyuk.tmp1 depends on schema hyuk
--  Hint: Use DROP ... CASCADE to drop the dependent objects too.


drop schema hyuk cascade ;
--OK 

SELECT schema_name
FROM information_schema.schemata;

drop user hyuk;
--SQL Error [2BP01]: ERROR: role "hyuk" cannot be dropped because some objects depend on it
--  Detail: privileges for schema public

create database temp;
--다른 세션에서 사용해 본다.

--데이터베이스 삭제
drop database temp;
--SQL Error [55006]: ERROR: database "temp" is being accessed by other users
--  Detail: There are 2 other sessions using the database.
  

--새로운 연결 차단
REVOKE CONNECT ON DATABASE temp FROM public;
REVOKE CONNECT ON DATABASE temp FROM hyuk;

--kill current connection
SELECT pid, pg_terminate_backend(pid) 
FROM pg_stat_activity 
--WHERE datname = current_database() 
WHERE datname = 'temp' 
	AND pid <> pg_backend_pid();


drop database temp;
