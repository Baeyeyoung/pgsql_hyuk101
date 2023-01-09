--https://hashrocket.com/blog/posts/exploring-postgres-gin-index#what-is-the-gin-index-
drop TABLE U;
drop index users_search_idx;

CREATE TABLE U (
    first_name text,
    last_name text
);

--\timing; 

insert into U
SELECT md5(random()::text), md5(random()::text) FROM
          (SELECT * FROM generate_series(1,1000000) AS id) AS x;

select * from U;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX users_search_idx ON users USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);

SELECT count(*) FROM users where first_name ilike '%04e%';
SELECT count(*) FROM users where first_name ilike '%1486%' or last_name ilike'%aeb%';



/*
--CREATE INDEX gin_idx ON m USING gin (lastname) WITH (fastupdate = off);

drop table test;
drop index testidx;

CREATE TABLE test (a int4);
-- create index
CREATE INDEX testidx ON test USING GIN (a);
--: SQL Error [42704]: 오류: integer 자료형은 "gin" 인덱스 액세스 방법을 위한 기본 연산자 클래스(operator class)가 없습니다. 
--  Hint: 이 인덱스를 위한 연산자 클래스를 지정하거나 먼저 이 자료형을 위한 기본 연산자 클래스를 정의해 두어야합니다
-- query
SELECT * FROM test WHERE a < 10;

 */

