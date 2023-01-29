/*
	PIVOT2: CROSSTAB
	정원혁 for pgsql 2023.01 
	https://www.postgresql.org/docs/current/tablefunc.html
*/

/*
 * CORSSTAB: aggregated input을 사용해야 한다. (group by 된 결과를 사용해야한다.) 
 * CROSSTAB ( base table, pivot 쿼리 with DISTINCT) AS (컬럼목록)
 * 
 * extension을 설치해야한다.
 */
CREATE EXTENSION IF NOT EXISTS tablefunc;

--예제 생성
drop table if exists ct;
CREATE temp TABLE ct(id SERIAL, rowid text, attribute int, value TEXT);
INSERT INTO ct(rowid, attribute, value) VALUES('test1',1,'val1');
INSERT INTO ct(rowid, attribute, value) VALUES('test1',2,'val2');
INSERT INTO ct(rowid, attribute, value) VALUES('test1',3,'val3');
INSERT INTO ct(rowid, attribute, value) VALUES('test1',4,'val4');
INSERT INTO ct(rowid, attribute, value) VALUES('test2',1,'val5');
INSERT INTO ct(rowid, attribute, value) VALUES('test2',2,'val6');
INSERT INTO ct(rowid, attribute, value) VALUES('test2',3,'val7');
INSERT INTO ct(rowid, attribute, value) VALUES('test2',4,'val8');

select * from ct ;
select rowid, attribute, value from ct where attribute <=2 order by 1,2;


SELECT *
FROM crosstab(
  'select rowid, attribute, value
   from ct
   where attribute <=2
   order by 1,2'
)
AS ct(row_name text, category_1 text, category_2 text);

SELECT *
FROM crosstab(
  'select rowid, attribute, value
   from ct
   where attribute <=2'
)
AS ct(row_name text, category_1 text, category_2 text);

SELECT *
FROM crosstab(
  'select rowid, attribute, value
   from ct
   where attribute <=2'
)
AS ct(아무이름 text, attr1 text, attr2 text);




drop table if exists o;
create temp table o as
select ship_via, date_part('year', order_date) as order_year, sum(freight) freight
	FROM orders
	group by ship_via, order_year
	order by ship_via, order_year
;
select 거시기,* from o ;

--까탈스럽게도 자료형이 정확히 일치해야 한다.
select * 
from crosstab(
	'select * from o'
)
as (ship_via int2, y96 float4, y97 float4, y98 float4)
;

select * 
from crosstab(
	'select ship_via, date_part('year', order_date) as order_year, sum(freight) freight
	FROM orders
	group by ship_via, order_year
	order by ship_via, order_year'
)
as (ship_via int2, y96 float4, y97 float4, y98 float4)
;
--SQL Error [42601]: ERROR: syntax error at or near "year"
--짜증. date_part('year', order_date) 를 인식못하는 CROSSTAB 
select * 
from crosstab(
	'select ship_via, EXTRACT(YEAR FROM order_date) as order_year, sum(freight) freight
	FROM orders
	group by ship_via, order_year
	order by ship_via, order_year'
)
as (ship_via int2, y96 float4, y97 float4, y98 float4)
;