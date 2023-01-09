--https://medium.com/29cm/db-postgresql-lock-%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B0-57d37ebe057

--CREATE DATABASE TFT;
CREATE TABLE item(
  id serial NOT NULL,
  name character varying,
  selected integer NOT NULL DEFAULT 0,
  CONSTRAINT item_pk PRIMARY KEY (id)
);
INSERT INTO item(name) VALUES ('Tears of goddess');


 -- 2번 프로세스 
select locktype, relation::regclass, mode, transactionid tid, pid, granted 
from pg_catalog.pg_locks 
where not pid = pg_backend_pid() and relation::regclass::text not like 'pg%';