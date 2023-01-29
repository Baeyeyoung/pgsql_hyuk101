/*
	전문가로 가는 지름길 1 / 개발자용
	제 3장 소스 스크립트 
	정원혁 2000.1
	for pgsql 2022.11
*/

/*
Data Types: https://www.postgresql.org/docs/current/datatype.html
Data Types Cheat Sheet: https://tableplus.com/blog/2018/06/postgresql-data-types.html
*/

select 1 + 3 ;
select 'a' || 'b';
select 1 || '4';
select 1 || 4;
select 10/ 3;
select 10.0 / 3;
select 10. / 3;

select round(9.8829), round(9.8829, 2);

SELECT unit_price, floor(unit_price), ceiling(unit_price), round(unit_price::numeric ,2) 
from order_details od ;


/*
 * casting, 자료형의 변환
 * 1. 값::type
 * 2. cast(값 as type)
*/

select 123 + '4', 123 || '4';

select cast(10 as decimal(20, 18) ) / 3;

SELECT 	cast('32.2' as  float );
SELECT 	cast('32.2' as  int );
SELECT 	cast('32' as  int );
SELECT 	cast(32.2 as  varchar(5) );
SELECT 	cast(32.2 as  varchar(3) );
SELECT 	cast(32  as  float );


SELECT 32::float;
SELECT 32.2::int;
/*
 * timestamp, datetime 에 관해 : "datetime .sql"
 */

